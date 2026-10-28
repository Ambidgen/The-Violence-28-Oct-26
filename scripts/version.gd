extends RefCounted
## The single runtime version source. Run tools/sync_version.py after changing it
## to update Godot's project and Windows export metadata, then commit all three.
const VALUE := "1.2.1"
const WINDOWS := VALUE + ".0"
