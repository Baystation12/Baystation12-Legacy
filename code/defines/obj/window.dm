/obj/window
	name = "window"
	icon = 'structures.dmi'
	icon_state = "window"
	desc = "A window."
	density = 1
	var/health = 14.0
	var/ini_dir = null
	var/state = 0
	var/reinf = 0
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = 1.0
	flags = ON_BORDER

// Prefab windows to make it easy...



// Basic

/obj/window/basic/north
	dir = NORTH

/obj/window/basic/east
	dir = NORTH

/obj/window/basic/west
	dir = WEST

/obj/window/basic/south
	dir = SOUTH

/obj/window/basic/northwest
	dir = NORTHWEST

/obj/window/basic/northeast
	dir = NORTHEAST

/obj/window/basic/southwest
	dir = SOUTHWEST

/obj/window/basic/southeast
	dir = SOUTHEAST

// Reinforced

/obj/window/reinforced
	reinf = 1
	icon_state = "rwindow"
	name = "reinforced window"

/obj/window/reinforced/north
	dir = NORTH

/obj/window/reinforced/east
	dir = EAST

/obj/window/reinforced/west
	dir = WEST

/obj/window/reinforced/south
	dir = SOUTH

/obj/window/reinforced/northwest
	dir = NORTHWEST

/obj/window/reinforced/northeast
	dir = NORTHEAST

/obj/window/reinforced/southwest
	dir = SOUTHWEST

/obj/window/reinforced/southeast
	dir = SOUTHEAST
