#define METEOR_TEMPERATURE

/var/const/meteor_wave_delay = 600 //minimum wait between waves in tenths of seconds
//set to at least 100 unless you want evarr ruining every round

/var/const/meteors_in_wave = 2
/var/const/meteors_in_small_wave = 1

/proc/meteor_wave()
	if(!ticker || wavesecret)
		return

	wavesecret = 1
	for(var/i = 0 to meteors_in_wave)
		spawn(rand(10,100))
			spawn_meteor()
	spawn(meteor_wave_delay)
		wavesecret = 0

/proc/spawn_meteors()
	for(var/i = 0; i < meteors_in_small_wave; i++)
		spawn(0)
			spawn_meteor()

/proc/spawn_meteor()

	AGAIN

	var/startside = pick(cardinal)
	var/startx
	var/starty
	var/endx
	var/endy

	switch(startside)

		if(NORTH)
			starty = world.maxy-1
			startx = rand(1, world.maxx-1)
			endy = 1
			endx = rand(1, world.maxx-1)

		if(EAST)
			starty = rand(1,world.maxy-1)
			startx = world.maxx-1
			endy = rand(1, world.maxy-1)
			endx = 1

		if(SOUTH)
			starty = 1
			startx = rand(1, world.maxx-1)
			endy = world.maxy-1
			endx = rand(1, world.maxx-1)

		if(WEST)
			starty = rand(1, world.maxy-1)
			startx = 1
			endy = rand(1,world.maxy-1)
			endx = world.maxx-1

	var/turf/pickedstart = locate(startx, starty, rand(1, 4))
	var/turf/pickedgoal = locate(endx, endy, pickedstart.z)

	if (!istype(pickedstart, /turf/space) || pickedstart.loc.name != "Space" ) //FUUUCK, should never happen.
		goto AGAIN

	var/obj/meteor/M

	if(rand(50))
		M = new /obj/meteor( pickedstart )
	else
		M = new /obj/meteor/small( pickedstart )
	M.dest = new /obj(pickedgoal)
	M.dest.name = "METEORTARGET_THIS_IS_A_HACK"
	walk_towards(M, M.dest, 1)

/obj/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "flaming"
	density = 1
	anchored = 1.0
	var/hits = 1
	var/obj/dest

/obj/meteor/small
	name = "small meteor"
	icon_state = "smallf"

/obj/meteor/Move()
	var/turf/T = src.loc
	if (istype(T, /turf))
		T.hotspot_expose(METEOR_TEMPERATURE, 1000)
	..()
	return

/obj/meteor/Bump(atom/A)
	spawn(0)
		for(var/mob/M in view(A, null))
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) //bad idea to shake an ai's view
				shake_camera(M, 3, 1)
		if (A)
			A.meteorhit(src)
			playsound(src.loc, 'sound/misc/meteorimpact.ogg', 40, 1)
		if (--src.hits <= 0)
			if(prob(15) && !istype(A, /obj/grille))
				explosion(loc, 2, 5, 8, 10, 1)
				playsound(src.loc, "explosion", 50, 1)
			del(src)
	return


/obj/meteor/ex_act(severity)

	if (severity < 4)
		del(src)
	return

/obj/meteor/Del()
	if(src.dest.name == "METEORTARGET_THIS_IS_A_HACK")
		del src.dest

	..()