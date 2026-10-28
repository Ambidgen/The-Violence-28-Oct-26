extends SceneTree
## Probe (1.3 playtest): police on post at a quiet public event, with and without a
## habit or a stress floor. Counts crowd members hit by police when no attack comes.
##   godot --headless --path . -s res://tests/event_probe.gd -- --habit=HD17 --n=6 [--officers=2] [--morale=35]

const Campaign = preload("res://scripts/campaign/campaign.gd")
const Situations = preload("res://scripts/campaign/situations.gd")
const Autoplan = preload("res://scripts/campaign/autoplan.gd")
const Operation = preload("res://scripts/campaign/operation.gd")
const Maps = preload("res://scripts/maps/registry.gd")
const Nav = preload("res://scripts/sim/nav.gd")
const World = preload("res://scripts/sim/world.gd")


func _run(seed_v: int, habits: Array, n_off: int, morale: int, trauma := 0.0) -> Dictionary:
	var c = Campaign.new()
	c.start(1001)
	c.dept.morale = morale
	for r in c.dept.officers:
		r["trauma"] = maxf(float(r["trauma"]), trauma)
		for h in habits:
			if not (r["good"] as Array).has(h):
				r["good"].append(h)
	var s: Dictionary = Situations.make("event", seed_v, 12, 0, c.politics.trust, true)
	s["attack"] = false
	s["attack_p"] = 0.0
	c.board = [s]
	var lv = Maps.get_level(int(s["map"]))
	var nav = Nav.new()
	nav.build(lv)
	var av: Array = c.available_for(s["id"]).slice(0, n_off)
	var plan: Dictionary = Autoplan.suggest(s, av, lv, false, n_off)
	s["plan"] = plan
	var b: Dictionary = Operation.build_planned(s, plan, c.dept, lv, nav)
	var w = World.new()
	w.setup(lv, nav, b["cfgs"], b["postures"], b["seed"], b["alerts"], b["opts"])
	var guard := 0
	while not w.over and guard < 60000:
		w.step()
		w.events.clear()
		guard += 1
	var sm: Dictionary = w.incident.summary()
	var out := {"attack": w.attack_on, "civ_hit_police": int(sm["civ_hit_police"]), "civ_killed": int(sm["civ_killed"]), "police_shots": int(sm["police_shots"]), "misjudged": int(sm["misjudged"])}
	w.dispose()
	return out


func _init() -> void:
	var args := {}
	for a in OS.get_cmdline_user_args():
		var kv := a.trim_prefix("--").split("=")
		args[kv[0]] = kv[1] if kv.size() > 1 else "1"
	var n := int(args.get("n", "4"))
	var habits: Array = String(args.get("habit", "")).split(",", false)
	var n_off := int(args.get("officers", "2"))
	var morale := int(args.get("morale", "60"))
	var tot := {"civ_hit_police": 0, "civ_killed": 0, "police_shots": 0, "misjudged": 0, "attacks": 0}
	for k in n:
		var r: Dictionary = _run(5000 + k * 17, habits, n_off, morale, float(args.get("trauma", "0")))
		print("seed %d: %s" % [5000 + k * 17, str(r)])
		for key in ["civ_hit_police", "civ_killed", "police_shots", "misjudged"]:
			tot[key] += int(r[key])
		tot["attacks"] += 1 if r["attack"] else 0
	print("TOTAL habits=%s officers=%d morale=%d n=%d: %s" % [",".join(habits), n_off, morale, n, str(tot)])
	quit(0)
