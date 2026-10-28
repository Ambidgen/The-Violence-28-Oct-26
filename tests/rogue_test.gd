extends SceneTree
## The run layer (1.3): the roguelike story mode, headless.
##   godot --headless --path . -s res://tests/rogue_test.gd [-- --seeds=6]
## Gates: the same seed deals the same desk; a run saves and loads back unchanged; the
## armoury gates every kit and opens as contracts are signed; a finished program
## teaches its habit to the whole force and to every hire after; forty weeks of
## randomly answered desks reach the election with a score and a legacy entry; the
## classic campaign (the harnesses' campaign) is untouched.

const Campaign = preload("res://scripts/campaign/campaign.gd")
const Rogue = preload("res://scripts/campaign/rogue.gd")
const Equipment = preload("res://scripts/data/equipment.gd")

const LEGACY := "user://legacy_rogue_test.json"
var failures := 0


func check(ok: bool, what: String) -> void:
	print(("PASS  " if ok else "FAIL  ") + what)
	if not ok:
		failures += 1


## JSON keeps numbers as floats: compare what a save would hold.
static func _norm(d) -> String:
	return JSON.stringify(JSON.parse_string(JSON.stringify(d)), "", true)


func _week_through(c) -> void:
	c.run.auto_resolve(c)
	c.end_week()


func _init() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=")
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	DirAccess.open("user://").remove(LEGACY.get_file())

	# the classic campaign has no run layer and no armoury
	var classic = Campaign.new()
	classic.start(1001)
	check(classic.run == null and Equipment.armory.is_empty(), "the classic campaign has no run layer and an open armoury")

	# same seed, same desk
	var a = Campaign.new()
	a.start(4242, true, LEGACY)
	var b = Campaign.new()
	b.start(4242, true, LEGACY)
	for k in 10:
		_week_through(a)
		_week_through(b)
	check(JSON.stringify(a.run.to_data()) == JSON.stringify(b.run.to_data()), "the same seed deals the same desk for ten weeks")
	check(a.run.doctrine != "", "the inheritance was drafted (%s)" % a.run.doctrine)
	check(a.run.desk_log.size() >= 3, "the desk decided things (%d entries)" % a.run.desk_log.size())

	# save and load
	var saved: Dictionary = JSON.parse_string(JSON.stringify(a.to_data()))
	var a2 = Campaign.new()
	check(a2.from_data(saved), "a run loads from its save")
	check(a2.run != null and _norm(a2.run.to_data()) == _norm(a.run.to_data()), "and its desk comes back unchanged")
	check(a2.dept.curriculum == a.dept.curriculum, "and so does the academy curriculum")

	# the armoury
	var c = Campaign.new()
	c.start(77, true, LEGACY)
	var heavy := {"primary": "sbr", "secondary": "heavy_pistol", "optic": "magnified", "armour": "plates", "plates": 2,
		"head": "ballistic_helmet", "gear": {"flashbang": 2, "medkit": 1, "taser": 1}}
	var k1: Dictionary = Equipment.validate(heavy, "tactical")
	check(k1["primary"] == "carbine" and k1["secondary"] == "service_pistol" and k1["optic"] == "red_dot",
		"locked weapons and sights fall back to patrol stock")
	check(k1["armour"] == ("plates" if c.run.armory.has("plates") else "vest"), "plates only with a contract (%s)" % k1["armour"])
	check(k1["head"] == "none" and not k1["gear"].has("flashbang") and k1["gear"].has("medkit"), "locked gear is left in the armoury")
	c.run.stock(["sbr", "flashbang", "ballistic_helmet"])
	var k2: Dictionary = Equipment.validate(heavy, "tactical")
	check(k2["primary"] == "sbr" and k2["head"] == "ballistic_helmet" and k2["gear"].get("flashbang", 0) == 2, "signed contracts open the armoury")
	var ok_all := true
	for r in c.dept.officers:
		var v: Dictionary = Equipment.validate(r["kit"], Equipment.who_of_record(r))
		if v["primary"] != r["kit"]["primary"] or v["gear"].size() != r["kit"]["gear"].size():
			ok_all = false
	check(ok_all, "every inherited officer's kit is already in patrol stock")
	classic.activate()
	check(Equipment.armory.is_empty(), "activating a classic campaign opens the armoury again")
	c.activate()

	# a program teaches the whole force
	c.run.program = {"id": "GD03", "name": "Respect lines of fire (GD03)", "weeks_left": 1, "started": 1}
	c.run.on_week_end(c)
	var force: Array = c.dept.officers.filter(func(r): return String(r["status"]) not in ["dead", "fired", "resigned"])
	check(force.all(func(r): return (r["good"] as Array).has("GD03")), "a finished program teaches every officer (%d)" % force.size())
	var hire: Dictionary = c.dept.hire("Officer", 0)
	check((hire["good"] as Array).has("GD03"), "and the academy teaches it to the next hire")

	# a whole run, randomly answered, for several seeds
	var seeds := int(args.get("seeds", "4"))
	for sd in seeds:
		var r0 = Campaign.new()
		r0.start(9000 + sd, true, LEGACY)
		var weeks := 0
		while not r0.over() and weeks < 45:
			_week_through(r0)
			weeks += 1
		var sc: Dictionary = Rogue.run_score(r0)
		check(r0.over() and weeks == 40, "run %d reaches the election in 40 weeks (score %d, %d contracts, %d programs, %d desk entries)" % [
			9000 + sd, int(sc["total"]), r0.run.contracts.size(), r0.run.programs_done.size(), r0.run.desk_log.size()])
	var lg: Dictionary = Rogue.load_legacy(LEGACY)
	check((lg["runs"] as Array).size() == seeds, "every finished run is in the legacy file (%d)" % (lg["runs"] as Array).size())
	check(Rogue.unlocked_doctrines(lg).size() > Rogue.DOCTRINE_BASE, "finished runs unlock more doctrines (%d)" % Rogue.unlocked_doctrines(lg).size())
	DirAccess.open("user://").remove(LEGACY.get_file())
	Equipment.armory = {}
	print("rogue_test: %d failure%s" % [failures, "" if failures == 1 else "s"])
	quit(1 if failures > 0 else 0)
