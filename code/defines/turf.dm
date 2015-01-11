/turf
	icon = 'icons/turf/floors.dmi'
	var/intact = 1

	level = 1.0

	var
		//Properties for open tiles (/floor)
		oxygen = 0
		carbon_dioxide = 0
		nitrogen = 0
		toxins = 0

		//Properties for airtight tiles (/wall)
		thermal_conductivity = 0.05
		heat_capacity = 1

		//Properties for both
		temperature = T20C

		blocks_air = 0
		icon_old = null
		pathweight = 1
		list/obj/machinery/network/wirelessap/wireless = list( )
		explosionstrength = 1 //NEVER SET THIS BELOW 1
		floorstrength = 6

		melting_point = 0 //Either the temperature to melt at, or 0 if it doesn't melt


/turf/space
	icon = 'icons/turf/space.dmi'
	name = "space"
	icon_state = "placeholder"
	var/sand = 0
	temperature = TSPC
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000
	mouse_opacity = 2

/turf/space/sand
	name = "sand"
	icon = 'icons/obj/sand.dmi'
	icon_state = "placeholder"
	sand = 1
	temperature = T20C + 80


/turf/space/New()
	. = ..()
	if(!sand)
		icon = 'icons/turf/space.dmi'
		//icon_state = "[rand(1,25)]"
		icon_state = pick("1", "2", "3", "4", "5", "6", "7", "8", "9", "10",
					"11", "12", "13", "14", "15", "16", "17", "18", "19",
					"20", "21", "22", "23", "24", "25")
		/* Just did a quick test: In an otherwise empty project and a 1000x1000 map,
			pick()ing from a list took less than half as long as creating a string
			from the result of rand(). (~3 seconds vs ~7).

			Would be even faster if a numerical index could be used directly,
			without the "[]", though.*/
	else
		icon = 'icons/obj/sand.dmi'
		icon_state = "[rand(1,3)]"

/turf/space/proc/Check()
	var/turf/T = locate(x, y, z + 1)
	if (T)
		if(istype(T, /turf/space) || istype(T, /turf/unsimulated))
			return
		var/turf/space/S = src
		var/turf/simulated/floor/open/open = new(src)
		open.LightLevelRed = S.LightLevelRed
		open.LightLevelBlue = S.LightLevelBlue
		open.LightLevelGreen = S.LightLevelGreen
		open.ul_UpdateLight()

/turf/simulated/floor/prison			//Its good to be lazy.
	name = "Welcome to Admin Prison"
	wet = 0
	image/wet_overlay = null

	thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/simulated/floor/engine
	name = "reinforced floor"
	icon_state = "engine"
	thermal_conductivity = 0.025
	heat_capacity = 325000

/turf/simulated/floor/engine/vacuum
	name = "vacuum floor"
	icon_state = "engine"
	oxygen = 0
	nitrogen = 0.000
	temperature = TSPC

///turf/space/hull //TEST
turf/space/hull
	name = "Hull Plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "engine"
turf/space/hull/New()
	return
/*	oxygen = 0
	nitrogen = 0.000
	temperature = TSPC
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000*/
/turf/simulated/floor/

/turf/simulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "floor"
	thermal_conductivity = 0.040
	heat_capacity = 225000
	var/broken = 0
	var/burnt = 0
/turf
	var/turf/simulated/floor/open/open = null

/turf/simulated/floor/New()
	. = ..()
	if(type != /turf/simulated/floor/open)
		var/obj/lattice/L = locate() in src
		if(L) del L
	name = "floor"
	var/turf/T = locate(x,y,z-1)
	if(T)
		if(istype(T, /turf/simulated/floor/open))
			open = T
			open.update()

/turf/simulated/floor/Enter(var/atom/movable/AM)
	. = ..()
	spawn(1)
		if(AM in src.contents)
			if(open && istype(open))
				open.update()

/turf/simulated/floor/Exit(var/atom/movable/AM)
	. = ..()
	spawn(1)
		if(!(AM in src.contents))
			if(open && istype(open))
				open.update()

/turf/simulated/floor/airless
	name = "airless floor"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TSPC



/turf/simulated/floor/open
	name = "open space"
	intact = 0
	icon_state = "open"
	pathweight = 100000 //Seriously, don't try and path over this one numbnuts
	var/icon/darkoverlays = null
	var/turf/floorbelow
	floorstrength = 1
	layer = 0
	mouse_opacity = 2

/turf/simulated/floor/open/New()
	..()
	spawn(1)
		if(!istype(src, /turf/simulated/floor/open)) //This should not be needed but is.
			return

		floorbelow = locate(x, y, z + 1)
		if(floorbelow)
			floorbelow.open = src
			//Fortunately, I've done this before. - Aryn
			if(istype(floorbelow,/turf/space) || floorbelow.z > 4)
				new/turf/space(src)
				update()
		else
			new/turf/space(src)

/turf/simulated/floor/open/Del()
	if(floorbelow)
		if(floorbelow.open == src)
			floorbelow.open = null
	. = ..()


/turf/simulated/floor/open/Enter(var/atom/movable/AM)
	if (..()) //TODO make this check if gravity is active (future use) - Sukasa
		spawn(1)
			if(AM && !floorbelow.density)
				var/failed = AM.Move(locate(x, y, z + 1))
				if (istype(AM, /mob))
					if(!failed)
						AM.loc = floorbelow;
						step_rand(AM,0)
					if(istype(AM,/mob/living/carbon))
						var/mob/living/carbon/C = AM
						var/datum/organ/external/A = C.organs["l_leg"]
						A.take_damage(10,0)
						A = C.organs["r_leg"]
						A.take_damage(10,0)
					else
						AM:bruteloss += 20 //You were totally doin it wrong. 5 damage? Really? - Aryn
					AM:weakened = max(AM:weakened,5)
					AM:updatehealth()
	return ..()


/turf/simulated/floor/open/attackby()


/turf/simulated/floor/open/proc/update() //Update the overlayss to make the openspace turf show what's down a level
	if(!floorbelow) return
	src.clearoverlays()
	src.addoverlay(image(floorbelow, dir=floorbelow.dir, layer = 0))
	if(!floorbelow.density)
		for(var/obj/o in floorbelow.contents)
			src.addoverlay(image(o, dir=o.dir, layer =  1-(1/o.layer)))
	src.color = rgb(191.25,191.25,191.25)
	var/image/I = image('icons/effects/ULIcons.dmi', "[min(max(floorbelow.LightLevelRed - 4, 0), 7)]-[min(max(floorbelow.LightLevelGreen - 4, 0), 7)]-[min(max(floorbelow.LightLevelBlue - 4, 0), 7)]")
	I.layer = TURF_LAYER + 0.2
	src.addoverlay(I)
	I = image('icons/effects/ULIcons.dmi', "1-1-1")
	I.layer = TURF_LAYER + 0.2
	src.addoverlay(I)

/turf/simulated/floor/plating
		name = "Plating"
		icon_state = "plating"
		intact = 0



/proc/update_open()
	for(var/turf/simulated/floor/open/a in world)
		a.update()

/turf/simulated/floor/plating/airless
	name = "Airless Plating"
	oxygen = 0.01
	nitrogen = 0.01
	temperature = TSPC

	New()
		..()
		name = "plating"

/turf/simulated/floor/grid
	icon = 'icons/turf/floors.dmi'
	icon_state = "circuit"

/turf/simulated/wall
	name = "Wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "wall0"
	opacity = 1
	density = 1
	blocks_air = 1
	explosionstrength = 2
	floorstrength = 6
	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m steel wall
	var/Zombiedamage
	var/obj/wall_contents/trapped_objects = null
	melting_point = 2500

/obj/wall_contents
	icon = 'icons/turf/walls.dmi'
	icon_state = "wall-contents-alert"
	invisibility = 2
	layer = 10
	anchored = 1
	var/image/meson_image = null
	var/bang_time


/turf/simulated/wall/r_wall
	name = "Reinforced Wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "r_wall"
	opacity = 1
	density = 1
	var/d_state = 0
	explosionstrength = 4
	melting_point = 3000


/turf/simulated/wall/heatshield
	thermal_conductivity = 0
	opacity = 0
	explosionstrength = 5
	name = "Heat Shielding"
	icon = 'icons/turf/thermal.dmi'
	icon_state = "thermal"
	melting_point = 3500

	var/health = 10

/turf/simulated/wall/heatshield/attackby()
	return
/turf/simulated/wall/heatshield/attack_hand()
	return

/turf/simulated/shuttle
	name = "Shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 10000000

/turf/simulated/shuttle/floor
	name = "Shuttle Floor"
	icon_state = "floor"

/turf/simulated/shuttle/wall
	name = "Shuttle Wall"
	icon_state = "wall"
	explosionstrength = 4
	opacity = 1
	density = 1
	blocks_air = 1

/turf/unsimulated
	name = "Command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/shuttle
	name = "Shuttle"
	icon = 'icons/turf/shuttle.dmi'

/turf/unsimulated/shuttle/floor
	name = "Shuttle Floor"
	icon_state = "floor"

/turf/unsimulated/shuttle/wall
	name = "Shuttle Wall"
	icon_state = "wall"
	opacity = 1
	density = 1

/turf/unsimulated/floor
	name = "Floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "Wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc
	AdjacentTurfs()

		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density && !LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)

		return L
	Railturfs()

		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density && !LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				if(locate(/obj/rail) in t)
					L.Add(t)

		return L
	Distance(turf/t)
		if(!src || !t)
			return 1e31
		t = get_turf(t)
		if(get_dist(src, t) == 1 || src.z != t.z)
			var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y) + (src.z - t.z) * (src.z - t.z) * 3
			cost *= (pathweight+t.pathweight)/2
			return cost
		else
			return max(get_dist(src,t), 1)
	AdjacentTurfsSpace()
		var/L[] = new()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)

		return L
	process()
		return

/turf/simulated/asteroid
	oxygen = 0.01
	nitrogen = 0.01
	var/mapped = 0
	name = "rocky floor"
	icon = 'icons/turf/mining.dmi'
	icon_state = "floor"

/turf/simulated/asteroid/wall
	var/health = 40
	name = "rocky wall"
	icon = 'icons/turf/mining.dmi'
	icon_state = "wall"
	oxygen = 0.01
	nitrogen = 0.01
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/asteroid/wall/planet
	mapped = 1
	thermal_conductivity = 0

/turf/simulated/asteroid/wall/New()
	health+= rand(1)
	..()

/turf/simulated/asteroid/wall/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/pickaxe))
		if(W:active)
			src.health -= 20
			user << "You use \the [W.name] to hack away part of the unwanted ore."
		else
			src.health -= 5
			user << "The [W.name] wasn't very effective against the ore."
		if(src.health<1)
			src.mine()

/turf/simulated/asteroid/wall/laser_act(var/obj/beam/e_beam/b)
	var/power = b.power
	//Get the collective laser power
	src.health-=power/100
	if(src.health<1)
		src.mine()

/turf/simulated/asteroid/wall/proc/mine()
	while(!rand(1))
		if(rand(2))
			new/obj/item/weapon/ore(locate(src.x,src.y,src.z))
		else
			new/obj/item/weapon/artifact(locate(src.x,src.y,src.z))
	processing_turfs.Remove(src)
	new/turf/simulated/asteroid/floor(locate(src.x,src.y,src.z))


/turf/simulated/asteroid/floor
	oxygen = 0.01
	nitrogen = 0.01
	level = 1
	name = "rocky floor"
	icon = 'icons/turf/mining.dmi'
	icon_state = "floor"

/turf/simulated/asteroid/floor/planet
	mapped = 1
	name = "sand"
	icon = 'icons/obj/sand.dmi'
	icon_state = "placeholder"
	carbon_dioxide = 0.3 * ONE_ATMOSPHERE
	toxins = 0.54 * ONE_ATMOSPHERE
	nitrogen = 0.03 * ONE_ATMOSPHERE
	temperature = 742

/turf/simulated/asteroid/floor/planet/New()
	icon_state = "sand[rand(1,3)]"
	return ..()