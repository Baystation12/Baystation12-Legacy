/obj
	//var/datum/module/mod		//not used
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass
	var/w_amt = 0	// waster amounts
	var/global/tagcnum = 0
	var/explosionstrength = 0

	var/list/NetworkNumber = list( )
	var/list/Networks = list( )

	animate_movement = 2

	proc
		handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
			//Return: (NONSTANDARD)
			//		null if object handles breathing logic for lifeform
			//		datum/air_group to tell lifeform to process using that breath return
			//DEFAULT: Take air from turf to give to have mob process
			if(breath_request>0)
				return remove_air(breath_request)
			else
				return null

		initialize()

	New()
		src.tag = "obj[++tagcnum]"



/obj/item/policetaperoll
	name = "police tape roll"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon = 'policetape.dmi'
	icon_state = "rollstart"
	flags = FPRINT
	var/tapestartx = 0
	var/tapestarty = 0
	var/tapestartz = 0
	var/tapeendx = 0
	var/tapeendy = 0
	var/tapeendz = 0

/obj/item/policetape
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	icon = 'policetape.dmi'
	anchored = 1
	density = 1
	throwpass = 1
	req_access = list(access_security)

/obj/blob
	icon = 'blob.dmi'
	icon_state = "bloba0"
	var/health = 30
	density = 1
	opacity = 0
	anchored = 1

/obj/blob/idle
	name = "blob"
	desc = "it looks... frightened"
	icon_state = "blobidle0"

/obj/mark
	var/mark = ""
	icon = 'mark.dmi'
	icon_state = "blank"
	anchored = 1
	layer = 99
	mouse_opacity = 0

/obj/admins
	name = "admins"
	var/rank = null
	var/owner = null
	var/state = 1
	//state = 1 for playing : default
	//state = 2 for observing

/obj/bhole
	name = "black hole"
	icon = 'objects.dmi'
	desc = "FUCK FUCK FUCK AAAHHH"
	icon_state = "bhole2"
	opacity = 0
	density = 0
	anchored = 1
	var/datum/effects/system/harmless_smoke_spread/smoke




/obj/beam
	name = "beam"

/obj/beam/a_laser
	name = "a laser"
	icon = 'projectiles.dmi'
	icon_state = "laser"
	density = 1
	var/yo = null
	var/xo = null
	var/current = null
	var/life = 50.0
	anchored = 1.0
	flags = TABLEPASS

/obj/beam/i_beam
	name = "i beam"
	icon = 'projectiles.dmi'
	icon_state = "ibeam"
	var/obj/beam/i_beam/next = null
	var/obj/item/device/infra/master = null
	var/limit = null
	var/visible = 0.0
	var/left = null
	anchored = 1.0
	flags = TABLEPASS


/obj/bedsheetbin
	name = "linen bin"
	desc = "A bin for containing bedsheets."
	icon = 'items.dmi'
	icon_state = "bedbin"
	var/amount = 23.0
	anchored = 1.0

/obj/begin
	name = "begin"
	icon = 'stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0

/obj/bullet
	name = "bullet"
	icon = 'projectiles.dmi'
	icon_state = "bullet"
	density = 1
	var/yo = null
	var/xo = null
	var/current = null
	anchored = 1.0
	flags = TABLEPASS

/obj/bullet/weakbullet


/obj/bullet/electrode
	name = "electrode"
	icon_state = "spark"

/obj/bullet/teleshot
	name = "teleshot"
	icon_state = "spark"
	var/failchance = 5
	var/obj/item/target = null

/obj/bullet/cbbolt
	name = "crossbow bolt"
	icon_state = "cbbolt"

/obj/datacore
	name = "datacore"
	var/list/medical = list(  )
	var/list/general = list(  )
	var/list/security = list(  )

/obj/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null
	var/t_loc = null
	var/obj/item/item = null
	var/place = null

/obj/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/grille
	desc = "A piece of metal with evenly spaced gridlike holes in it. Blocks large object but lets small items, gas, or energy beams through."
	name = "grille"
	icon = 'structures.dmi'
	icon_state = "grille"
	density = 1
	layer = 2.9
	var/health = 10.0
	var/destroyed = 0.0
	anchored = 1.0
	flags = FPRINT | CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE

/obj/item
	name = "item"
	icon = 'items.dmi'
	var/icon_old = null
	var/abstract = 0.0
	var/force = null
	var/item_state = null
	var/damtype = "brute"
	var/throwforce = 10
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/w_class = 3.0
	flags = FPRINT | TABLEPASS
	pressure_resistance = 50
	var/obj/item/master = null

/obj/item/device
	icon = 'device.dmi'

/obj/item/device/detective_scanner
	name = "Scanner"
	desc = "Used to scan objects for DNA and fingerprints"
	icon_state = "forensic0"
	var/amount = 20.0
	var/printing = 0.0
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | USEDELAY


/obj/item/device/flash
	name = "flash"
	icon_state = "flash"
	var/l_time = 1.0
	var/shots = 5.0
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	var/status = 1

/obj/item/device/flashlight
	name = "flashlight"
	desc = "A hand-held emergency light."
	icon_state = "flight0"
	var/on = 0
	w_class = 2
	item_state = "flight"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	m_amt = 50
	g_amt = 20

/obj/item/device/healthanalyzer
	name = "Health Analyzer"
	icon_state = "health"
	item_state = "analyzer"
	desc = "A hand-held body scanner able to distinguish vital signs of the subject."
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	m_amt = 200

/obj/item/device/igniter
	name = "igniter"
	desc = "A small electronic device able to ignite combustable substances."
	icon_state = "igniter"
	var/status = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 100
	throwforce = 5
	w_class = 1.0
	throw_speed = 3
	throw_range = 10


/obj/item/device/infra
	name = "Infrared Beam (Security)"
	desc = "Emits a visible or invisible beam and is triggered when the beam is interrupted."
	icon_state = "infrared0"
	var/obj/beam/i_beam/first = null
	var/state = 0.0
	var/visible = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 150

/obj/item/device/infra_sensor
	name = "Infrared Sensor"
	desc = "Scans for infrared beams in the vicinity."
	icon_state = "infra_sensor"
	var/passive = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 150

/obj/item/device/t_scanner
	name = "T-ray scanner"
	desc = "A terahertz-ray emitter and scanner used to detect underfloor objects such as cables and pipes."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT|ONBELT|TABLEPASS
	w_class = 2
	item_state = "electronic"
	m_amt = 150

/obj/item/device/multitool
	name = "multitool"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "You can use this on airlocks or APCs to try to hack them without cutting wires."
	m_amt = 50
	g_amt = 20

// So far, its functionality is found only in code/game/machinery/doors/airlock.dm
/obj/item/device/hacktool
	name = "hacktool"
	icon_state = "hacktool"
	flags = FPRINT | TABLEPASS | CONDUCT
	var/in_use = 0
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "An item of dubious origins, with wires and antennas protruding out of it."
	m_amt = 60
	g_amt = 20

/obj/item/device/prox_sensor
	name = "Proximity Sensor"
	icon_state = "motion0"
	var/state = 0.0
	var/timing = 0.0
	var/time = null
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 300


/obj/item/device/shield
	name = "shield"
	icon_state = "shield0"
	var/active = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/device/timer
	name = "timer"
	icon_state = "timer0"
	item_state = "electronic"
	var/timing = 0.0
	var/time = null
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	m_amt = 100


/obj/landmark
	name = "landmark"
	icon = 'screen1.dmi'
	icon_state = "x2"
	anchored = 1.0




/*/obj/landmark/ptarget
	name = "portal target"
	icon = 'screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	var/t_id*/

/obj/landmark/derelict
	name = "Derelict Info Node"

	nodamage
		icon_state = "blocked"

	noblast
		icon_state = "blocked"

	o2crate
	o2canister
	metal
	glass


/obj/landmark/alterations
	name = "alterations"
	nopath
		invisibility = 101
		name = "Bot No-Path"

/obj/laser
	name = "laser"
	icon = 'projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0

/obj/lattice
	desc = "A lightweight support lattice."
	name = "lattice"
	icon = 'structures.dmi'
	icon_state = "lattice"
	density = 0
	anchored = 1.0
	layer = 2
	//	flags = 64.0

/obj/list_container
	name = "list container"

/obj/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/m_tray
	name = "morgue tray"
	icon = 'stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = 2.0
	var/obj/morgue/connected = null
	anchored = 1.0

/obj/c_tray
	name = "crematorium tray"
	icon = 'stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	layer = 2.0
	var/obj/crematorium/connected = null
	anchored = 1.0

/obj/manifest
	name = "manifest"
	icon = 'screen1.dmi'
	icon_state = "x"

/obj/morgue
	name = "morgue"
	icon = 'stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	var/obj/m_tray/connected = null
	anchored = 1.0

/obj/crematorium
	name = "crematorium"
	desc = "A human incinerator."
	icon = 'stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0

/obj/mine
	name = "Mine"
	desc = "I Better stay away from that thing."
	density = 1
	anchored = 1
	layer = 3
	icon = 'weapons.dmi'
	icon_state = "uglymine"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/mine/dnascramble
	name = "Radiation Mine"
	icon_state = "uglymine"
	triggerproc = "triggerrad"

/obj/mine/plasma
	name = "Plasma Mine"
	icon_state = "uglymine"
	triggerproc = "triggerplasma"

/obj/mine/kick
	name = "Kick Mine"
	icon_state = "uglymine"
	triggerproc = "triggerkick"

/obj/mine/n2o
	name = "N2O Mine"
	icon_state = "uglymine"
	triggerproc = "triggern2o"

/obj/mine/stun
	name = "Stun Mine"
	icon_state = "uglymine"
	triggerproc = "triggerstun"

/obj/overlay
	name = "overlays"

/obj/projection
	name = "Projection"
	anchored = 1.0

/obj/rack
	name = "rack"
	icon = 'objects.dmi'
	icon_state = "rack"
	density = 1
	flags = FPRINT
	anchored = 1.0

/obj/screen
	name = "screen"
	icon = 'screen1.dmi'
	layer = 20.0
	var/id = 0.0
	var/obj/master

/obj/screen/close
	name = "close"
	master = null

/obj/screen/grab
	name = "grab"
	master = null

/obj/screen/storage
	name = "storage"
	master = null

/obj/screen/zone_sel
	name = "Damage Zone"
	icon = 'zone_sel.dmi'
	icon_state = "blank"
	var/selecting = "chest"
	screen_loc = "EAST+1,NORTH"

/obj/shut_controller
	name = "shut controller"
	var/moving = null
	var/list/parts = list(  )

/obj/landmark/start
	name = "start"
	icon = 'screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/stool
	name = "stool"
	icon = 'objects.dmi'
	icon_state = "stool"
	flags = FPRINT
	anchored = 1.0
	pressure_resistance = 3*ONE_ATMOSPHERE

/obj/stool/barstool
	name = "barstool"
	icon_state = "barstool"

/obj/stool/bed
	name = "bed"
	icon_state = "bed"

/obj/stool/chair
	name = "chair"
	icon_state = "chair"
	var/status = 0.0

/obj/stool/chair/e_chair
	name = "electrified chair"
	icon_state = "e_chair0"
	var/atom/movable/overlay/overl = null
	var/on = 0.0
	var/obj/item/assembly/shock_kit/part1 = null
	var/last_time = 1.0

/obj/stool/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."

/obj/stool/chair/comfy/brown
	icon_state = "comfychair_brown"

/obj/stool/chair/comfy/beige
	icon_state = "comfychair_beige"

/obj/stool/chair/comfy/teal
	icon_state = "comfychair_teal"

/obj/stool/chair/comfy/black
	icon_state = "comfychair_black"

/obj/stool/chair/comfy/lime
	icon_state = "comfychair_lime"

/obj/table
	name = "table"
	icon = 'structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0

/obj/table/reinforced
	name = "reinforced table"
	icon_state = "reinf_table"
	var/status = 2

/obj/table/woodentable
	name = "wooden table"
	icon_state = "woodentable"

/obj/mopbucket
	desc = "Fill it with water, but don't forget a mop!"
	name = "mop bucket"
	icon = 'janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	flags = FPRINT
	pressure_resistance = ONE_ATMOSPHERE
	flags = FPRINT | TABLEPASS | OPENCONTAINER

/obj/kitchenspike
	name = "a meat spike"
	icon = 'kitchen.dmi'
	icon_state = "spike"
	desc = "A spike for collecting meat from animals"
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0

/obj/displaycase
	name = "Display Case"
	icon = 'stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "A display case for prized possessions."
	density = 1
	anchored = 1
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

obj/item/brain
	name = "brain"
	icon = 'surgery.dmi'
	icon_state = "brain2"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5

	var/mob/living/carbon/human/owner = null

/obj/item/brain/New()
	..()
	spawn(5)
		if(src.owner)
			src.name = "[src.owner]'s brain"

/obj/noticeboard
	name = "Notice Board"
	icon = 'stationobjs.dmi'
	icon_state = "nboard00"
	flags = FPRINT
	desc = "A board for pinning important notices upon."
	density = 0
	anchored = 1
	var/notices = 0

/obj/deskclutter
	name = "desk clutter"
	icon = 'items.dmi'
	icon_state = "deskclutter"
	desc = "Some clutter the detective has accumalated over the years..."
	anchored = 1



/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER


/obj/item/weapon/ore
	name = "Rock"
	icon = 'rubble.dmi'
	icon_state = "ore"
	var/amt = 1
	var/cook = 0
	var/cook_temp = 1000
	var/cook_time = 30


// TODO: robust mixology system! (and merge with beakers, maybe)
/obj/item/weapon/reagent_containers/food/drinks/glass
	name = "drinking glass"
	icon = 'kitchen.dmi'
	icon_state = "glass_empty"
	item_state = "beaker"
	flags = FPRINT | TABLEPASS | OPENCONTAINER
	amount_per_transfer_from_this = 10
	throwforce = 5
	g_amt = 100
	New()
		var/datum/reagents/R = new/datum/reagents(30)
		reagents = R
		R.my_atom = src