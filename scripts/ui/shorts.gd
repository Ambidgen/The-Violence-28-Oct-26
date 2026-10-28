extends CanvasLayer
## The short cutscenes: five-to-ten second interstitials made with Remotion
## (cinematics/src/shorts) and shipped as Ogg Theora in assets/cutscenes/shorts.
##
## They are the same page as the opening — paper, ink, stepped greys, one red that only
## marks where a plan touched a real room — but they are not a film: each one is a single
## beat the campaign can call whenever it lands (a week starting, a situation picked off
## the board, RUN, the first door, an officer down, a debrief, the front page, a case, an
## ally crossing 25, election night, a funeral, the allocation, a course ending).
##
## The words on the page come from the campaign, not from the render: every short is
## prop-driven, and where a short publishes a `slot` (a plate left empty on purpose the
## engine may paint its own text into it at play time — a name, a ward, a headline —
## without re-rendering the video. Everything else is drawn.
##
## Typical use, from a screen that already owns its own flow:
##
##     var shorts := Shorts.new()          # preload("res://scripts/ui/shorts.gd").new()
##     add_child(shorts)
##     shorts.play("s01_week", {"week-title": "IRONWORKS"}, func(): os_week_board())
##
## Shorts never block and never require a waiting state: `done` fires when the video
## ends, when the player skips it (Space, Enter or a click), when it is stopped, or at
## once if the file is missing — so a caller can always continue on the callback.

signal done(key: String)

const MANIFEST_PATH := "res://assets/cutscenes/shorts/shorts.json"
const PAPER := Color(0.93, 0.93, 0.91)
const MID := Color(0.45, 0.45, 0.44)
const INK := Color(0.07, 0.07, 0.07)
const HINT_AFTER := 3.0            # seconds of video before the skip hint fades in

static var _cache: Dictionary = {}

var player: VideoStreamPlayer
var overlay: Control
var hint: Label
var skip_button: Button
var busy := false

var _key := ""
var _on_done := Callable()
var _plates: Array = []            # [{label: Label, slot: Dictionary}]
var _t := 0.0


func _ready() -> void:
	layer = 38                     # under the opening's 40
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	var bg := ColorRect.new()
	bg.color = PAPER
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.gui_input.connect(_on_click)
	add_child(bg)

	player = VideoStreamPlayer.new()
	player.set_anchors_preset(Control.PRESET_FULL_RECT)
	player.expand = true
	player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player.bus = "Effects"
	player.finished.connect(_on_video_finished)
	add_child(player)

	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# a window resize while a short is playing must move the plate text with it
	overlay.resized.connect(_layout_plates)
	add_child(overlay)

	hint = Label.new()
	hint.text = "Space: skip"
	hint.add_theme_font_size_override("font_size", 13)
	hint.add_theme_color_override("font_color", MID)
	hint.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	hint.position = Vector2(-160, -34)
	hint.size = Vector2(150, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.modulate.a = 0.0
	add_child(hint)

	skip_button = Button.new()
	skip_button.text = "Skip  [Space]"
	skip_button.focus_mode = Control.FOCUS_NONE
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	skip_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	skip_button.position = Vector2(24, -52)
	skip_button.size = Vector2(150, 34)
	skip_button.pressed.connect(stop)
	add_child(skip_button)


# ------------------------------------------------------------------ the catalogue
## The manifest, parsed once (an empty Dictionary when the shorts were not shipped).
static func manifest() -> Dictionary:
	if not _cache.is_empty():
		return _cache
	if not FileAccess.file_exists(MANIFEST_PATH):
		return {}
	var f := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if f == null:
		return {}
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if parsed is Dictionary:
		_cache = parsed
	return _cache


## Every short, in the manifest's order.
static func entries() -> Array:
	return manifest().get("shorts", [])


## One short's entry, or {} .
static func entry(key: String) -> Dictionary:
	for s in entries():
		if String(s.get("key", "")) == key:
			return s
	return {}


## The video's path for a key, or "" when the key is unknown.
static func video_path(key: String) -> String:
	var s := entry(key)
	if s.is_empty():
		return ""
	var dir := String(manifest().get("video", {}).get("dir", "res://assets/cutscenes/shorts"))
	return "%s/%s.%s" % [dir, key, String(manifest().get("video", {}).get("ext", "ogv"))]


## True when the key is known and its video is on disk.
static func available(key: String) -> bool:
	var p := video_path(key)
	return p != "" and ResourceLoader.exists(p)


## Seconds a short runs, or 0.0.
static func length(key: String) -> float:
	return float(entry(key).get("seconds", 0.0))


## The keys whose `tags` contain tag (e.g. "weekly", "consequence", "in-run").
static func with_tag(tag: String) -> Array:
	var out: Array = []
	for s in entries():
		if tag in s.get("tags", []):
			out.append(String(s.get("key", "")))
	return out


# ------------------------------------------------------------------ playing
## Play one short. `text` fills published slots (slot id -> String) with the campaign's
## own words; `on_done` runs when it ends or is skipped. Returns false (and calls
## on_done at once) if the short is not shipped, so callers need no special case.
func play(key: String, text: Dictionary = {}, on_done: Callable = Callable()) -> bool:
	if busy:
		return false
	if not available(key):
		if on_done.is_valid():
			on_done.call()
		return false
	_key = key
	_on_done = on_done
	_build_plates(key, text)
	player.stream = load(video_path(key))
	player.play()
	_t = 0.0
	hint.modulate.a = 0.0
	visible = true
	busy = true
	return true


## Play a list of shorts in order (a campaign can chain a week card into a briefing).
func play_all(keys: Array, texts: Array = [], on_done: Callable = Callable()) -> void:
	var queue := keys.duplicate()
	if queue.is_empty():
		if on_done.is_valid():
			on_done.call()
		return
	var first: String = String(queue.pop_front())
	var t: Dictionary = texts[0] if texts.size() > 0 else {}
	var rest := texts.slice(1)
	play(first, t, func(): play_all(queue, rest, on_done))


## Stop early and run the caller's callback exactly once.
func stop() -> void:
	if not busy:
		return
	busy = false
	if player.is_playing():
		player.stop()
	player.stream = null
	visible = false
	_clear_plates()
	hint.modulate.a = 0.0
	var cb := _on_done
	_on_done = Callable()
	if cb.is_valid():
		cb.call()


func _on_video_finished() -> void:
	if not busy:
		return
	busy = false
	visible = false
	_clear_plates()
	hint.modulate.a = 0.0
	var key := _key
	var cb := _on_done
	_on_done = Callable()
	done.emit(key)
	if cb.is_valid():
		cb.call()


func _process(dt: float) -> void:
	if not busy:
		return
	_t += dt
	if hint.modulate.a < 1.0 and _t > HINT_AFTER:
		hint.modulate.a = min(1.0, hint.modulate.a + dt * 2.0)
	_layout_plates()


func _unhandled_input(event: InputEvent) -> void:
	if not busy:
		return
	var skip := false
	if event is InputEventKey and (event as InputEventKey).pressed:
		var k := (event as InputEventKey).keycode
		skip = k == KEY_SPACE or k == KEY_ENTER or k == KEY_KP_ENTER or k == KEY_ESCAPE
	elif event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		skip = true
	if skip:
		get_viewport().set_input_as_handled()
		stop()


func _on_click(_e: InputEvent) -> void:
	if busy:
		stop()


# ------------------------------------------------------------------ the plates
func _build_plates(key: String, text: Dictionary) -> void:
	_clear_plates()
	for sl in entry(key).get("slots", []):
		var id := String(sl.get("id", ""))
		if not text.has(id):
			continue
		var value := String(text[id])
		if value.strip_edges().is_empty():
			continue
		var lab := Label.new()
		lab.text = value
		lab.add_theme_color_override("font_color", INK)
		lab.add_theme_color_override("font_shadow_color", Color(0.93, 0.93, 0.91, 0.85))
		lab.add_theme_constant_override("shadow_offset_x", 0)
		lab.add_theme_constant_override("shadow_offset_y", 0)
		lab.autowrap_mode = TextServer.AUTOWRAP_OFF
		lab.clip_text = false
		overlay.add_child(lab)
		_plates.append({"label": lab, "slot": sl})
	_layout_plates()


func _layout_plates() -> void:
	if _plates.is_empty():
		return
	# The overlay is the full-rect Control the plates are parented to, so its size is the
	# canvas grid the slots are normalised against. (The viewport's visible rect is in
	# window pixels, which drift from that grid at any content_scale_factor but 1.0 —
	# e.g. the --ui-scale test hook, or a resized window mid-video.)
	var vp: Vector2 = overlay.size if overlay != null and overlay.size.x > 0.0 and overlay.size.y > 0.0 else get_viewport().get_visible_rect().size
	for p in _plates:
		var sl: Dictionary = p["slot"]
		var lab: Label = p["label"]
		var rect := Rect2(Vector2(float(sl.get("x", 0.0)), float(sl.get("y", 0.0))) * vp,
			Vector2(float(sl.get("w", 0.2)), float(sl.get("h", 0.05))) * vp)
		lab.position = rect.position
		lab.size = rect.size
		# the plate's own height sets the type, so a slot never overflows its box
		lab.add_theme_font_size_override("font_size", max(10, int(rect.size.y * 0.62)))


func _clear_plates() -> void:
	for p in _plates:
		if is_instance_valid(p["label"]):
			(p["label"] as Label).queue_free()
	_plates.clear()
