/turf/DblClick()
	if(istype(usr, /mob/living/silicon/ai))
		return move_camera_by_click()
	if(usr.stat || usr.restrained() || usr.lying)
		return ..()
	/*
	if(usr.hand && istype(usr.l_hand, /obj/item/weapon/flamethrower))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrower/F = usr.l_hand
		F.flame_turf(turflist)
		..()
	else if(!usr.hand && istype(usr.r_hand, /obj/item/weapon/flamethrower))
		var/turflist = getline(usr,src)
		var/obj/item/weapon/flamethrower/F = usr.r_hand
		F.flame_turf(turflist)
		..()
	else
	*/
	return ..()

/turf/New()
	..()
	for(var/atom/movable/AM as mob|obj in src)
		spawn( 0 )
			src.Entered(AM)
			return
	return

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover || !isturf(mover.loc))
		return 1


	//First, check objects to block exit that are not on the border
	for(var/obj/obstacle in mover.loc)
		if((obstacle.flags & ~ON_BORDER) && (mover != obstacle) && (forget != obstacle))
			if(!obstacle.CheckExit(mover, src))
				mover.Bump(obstacle, 1)
				return 0

	//Now, check objects to block exit that are on the border
	for(var/obj/border_obstacle in mover.loc)
		if((border_obstacle.flags & ON_BORDER) && (mover != border_obstacle) && (forget != border_obstacle))
			if(!border_obstacle.CheckExit(mover, src))
				mover.Bump(border_obstacle, 1)
				return 0

	//Next, check objects to block entry that are on the border
	for(var/obj/border_obstacle in src)
		if(border_obstacle.flags & ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in src)
		if(obstacle.flags & ~ON_BORDER)
			if(!obstacle.CanPass(mover, mover.loc, 1, 0) && (forget != obstacle))
				mover.Bump(obstacle, 1)
				return 0
	return 1 //Nothing found to block so return success!


/turf/Entered(atom/movable/M as mob|obj)
	if(ismob(M) && !istype(src, /turf/space))
		var/mob/tmob = M
		tmob.inertia_dir = 0
	..()
	if(prob(1) && ishuman(M))
		var/mob/living/carbon/human/tmob = M
		if (!tmob.lying && istype(tmob.shoes, /obj/item/clothing/shoes/clown_shoes))
			if(istype(tmob.head, /obj/item/clothing/head/helmet))
				tmob << "\red You stumble and fall to the ground. Thankfully, that helmet protected you."
				tmob.weakened = max(rand(1,2), tmob.weakened)
			else
				tmob << "\red You stumble and hit your head."
				tmob.weakened = max(rand(3,10), tmob.weakened)
				tmob.stuttering = max(rand(0,3), tmob.stuttering)
				tmob.make_dizzy(150)
	for(var/atom/A as mob|obj|turf|area in src)
		spawn( 0 )
			if ((A && M))
				A.HasEntered(M, 1)
			return
	for(var/atom/A as mob|obj|turf|area in range(1))
		spawn( 0 )
			if ((A && M))
				A.HasProximity(M, 1)
			return
	return


/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

/turf/proc/ReplaceWithFloor()
	if(!icon_old) icon_old = icon_state
	var/turf/simulated/floor/W
	var/old_icon = icon_old
	var/old_dir = dir

	W = new /turf/simulated/floor( locate(src.x, src.y, src.z) )

	W.dir = old_dir
	W.icon_old = old_icon
	if(old_icon) W.icon_state = old_icon
	W.opacity = 1
	W.ul_SetOpacity(0)
	W.levelupdate()
	return W

/turf/proc/ReplaceWithEngineFloor()
	if(!icon_old) icon_old = icon_state
	var/old_icon = icon_old
	var/old_dir = dir
	var/turf/simulated/floor/engine/E = new /turf/simulated/floor/engine( locate(src.x, src.y, src.z) )
	E.dir = old_dir
	E.icon_old = old_icon

/turf/simulated/Entered(atom/A, atom/OL)
	if (istype(A,/mob/living/carbon))
		var/mob/M = A
		if(M.lying)
			return
		if(istype(M, /mob/living/carbon/human) && istype(M:shoes, /obj/item/clothing/shoes/clown_shoes))
			if(M.m_intent == "run")
				if(M.footstep >= 2)
					M.footstep = 0
				else
					M.footstep++
				if(M.footstep == 0)
					playsound(src, "clownstep", 50, 1) // this will get annoying very fast.
			else
				playsound(src, "clownstep", 20, 1)
		switch (src.wet)
			if(1)
				if ((M.m_intent == "run") && (!istype(M:shoes, /obj/item/clothing/shoes/galoshes)))
					M.pulling = null
					step(M, M.dir)
					M << "\blue You slipped on the wet floor!"
					playsound(src.loc, 'slip.ogg', 50, 1, -3)
					M.stunned = 8
					M.weakened = 5
				else
					M.inertia_dir = 0
					return
			if(2) //lube
				M.pulling = null
				step(M, M.dir)
				spawn(1) step(M, M.dir)
				spawn(2) step(M, M.dir)
				spawn(3) step(M, M.dir)
				spawn(4) step(M, M.dir)
				M.bruteloss += 5
				M << "\blue You slipped on the floor!"
				playsound(src.loc, 'slip.ogg', 50, 1, -3)
				M.weakened = 10

	..()

/turf/proc/ReplaceWithSpace()
	if(!icon_old) icon_old = icon_state
	var/old_icon = icon_old
	var/old_dir = dir
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	S.dir = old_dir
	S.icon_old = old_icon
	return S

/turf/proc/ReplaceWithLattice()
	if(!icon_old) icon_old = icon_state
	var/old_icon = icon_old
	var/old_dir = dir
	var/turf/space/S = new /turf/space( locate(src.x, src.y, src.z) )
	S.dir = old_dir
	S.icon_old = old_icon
	new /obj/lattice( locate(src.x, src.y, src.z) )
	return S

/turf/proc/ReplaceWithWall()
	var/turf/simulated/wall/S = new /turf/simulated/wall( locate(src.x, src.y, src.z) )
	S.opacity = 0
	S.ul_SetOpacity(1)
	return S

/turf/proc/ReplaceWithRWall()
	var/turf/simulated/wall/r_wall/S = new /turf/simulated/wall/r_wall( locate(src.x, src.y, src.z) )
	S.opacity = 0
	S.ul_SetOpacity(1)
	return S

/turf/simulated/wall/New()
	..()

	var/turf/simulated/wall/S = src
	var/turf/simulated/wall/north
	var/turf/simulated/wall/east
	var/turf/simulated/wall/south
	var/turf/simulated/wall/west
	var/turf/simulated/wall/T

	// Removing the overlay first to fix bug that is causd upon map initialisation, where multiple overlays of the same direction can be applied.
	if (istype(locate((S.x - 1),S.y,S.z), /turf/simulated/wall))
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=WEST)
		west = locate((S.x - 1),S.y,S.z)
		west.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
		west.overlays += image('walls.dmi',icon_state="wall1",dir=EAST)
		if (istype(locate(west.x,(west.y + 1),west.z), /turf/simulated/wall))
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			west.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
		if (istype(locate(west.x,(west.y - 1),west.z), /turf/simulated/wall))
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			west.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
	if (istype(locate((S.x + 1),S.y,S.z), /turf/simulated/wall))
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=EAST)
		east = locate((S.x + 1),S.y,S.z)
		east.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
		east.overlays += image('walls.dmi',icon_state="wall1",dir=WEST)
		if (istype(locate(east.x,(east.y + 1),east.z), /turf/simulated/wall))
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
			east.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
		if (istype(locate(east.x,(east.y - 1),east.z), /turf/simulated/wall))
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			east.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
	if (istype(locate(S.x,(S.y - 1),S.z), /turf/simulated/wall))
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTH)
		south = locate(S.x,(S.y - 1),S.z)
		south.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
		south.overlays += image('walls.dmi',icon_state="wall1",dir=NORTH)
		if (istype(locate((south.x + 1),south.y,south.z), /turf/simulated/wall))
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			south.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
		if (istype(locate((south.x - 1),south.y,south.z), /turf/simulated/wall))
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
			south.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
	if (istype(locate(S.x,(S.y + 1),S.z), /turf/simulated/wall))
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=NORTH)
		north = locate(S.x,(S.y + 1),S.z)
		north.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
		north.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTH)
		if (istype(locate((north.x + 1),north.y,north.z), /turf/simulated/wall))
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			north.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
		if (istype(locate((north.x - 1),north.y,north.z), /turf/simulated/wall))
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			north.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)

	if (north && west)
		if (istype(locate((north.x - 1), (north.y + 1), north.z), /turf/simulated/wall) && istype(locate((north.x - 1), north.y, north.z), /turf/simulated/wall) && istype(locate(north.x, (north.y + 1), north.z), /turf/simulated/wall))
			T = locate((north.x - 1), north.y, north.z)
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
		if (istype(locate((west.x - 1), (west.y + 1), west.z), /turf/simulated/wall) && istype(locate(west.x, (west.y + 1), west.z), /turf/simulated/wall) && istype(locate((west.x - 1), west.y, west.z), /turf/simulated/wall))
			T = locate(west.x, (west.y + 1), west.z)
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
	if (north && east)
		if (istype(locate((north.x + 1), (north.y + 1), north.z), /turf/simulated/wall) && istype(locate((north.x + 1), north.y, north.z), /turf/simulated/wall) && istype(locate(north.x, (north.y + 1), north.z), /turf/simulated/wall))
			T = locate((north.x + 1), north.y, north.z)
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			north.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
		if (istype(locate((east.x + 1), (east.y + 1), east.z), /turf/simulated/wall) && istype(locate(east.x, (east.y + 1), east.z), /turf/simulated/wall) && istype(locate((east.x + 1), east.y, east.z), /turf/simulated/wall))
			T = locate(east.x, (east.y + 1), east.z)
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
	if (south && west)
		if (istype(locate((south.x - 1), (south.y - 1), south.z), /turf/simulated/wall) && istype(locate((south.x - 1), south.y, south.z), /turf/simulated/wall) && istype(locate(south.x, (south.y - 1), south.z), /turf/simulated/wall))
			T = locate((south.x - 1), south.y, south.z)
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
		if (istype(locate((west.x - 1), (west.y - 1), west.z), /turf/simulated/wall) && istype(locate(west.x, (west.y - 1), west.z), /turf/simulated/wall) && istype(locate((west.x - 1), west.y, west.z), /turf/simulated/wall))
			T = locate(west.x, (west.y - 1), west.z)
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			west.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
	if (south && east)
		if (istype(locate((south.x + 1), (south.y - 1), south.z), /turf/simulated/wall) && istype(locate((south.x + 1), south.y, south.z), /turf/simulated/wall) && istype(locate(south.x, (south.y - 1), south.z), /turf/simulated/wall))
			T = locate((south.x + 1), south.y, south.z)
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			south.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
		if (istype(locate((east.x + 1), (east.y - 1), east.z), /turf/simulated/wall) && istype(locate(east.x, (east.y - 1), east.z), /turf/simulated/wall) && istype(locate((east.x + 1), east.y, east.z), /turf/simulated/wall))
			T = locate(east.x, (east.y - 1), east.z)
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
			east.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
			T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)


// Another method which may be faster - Incomplete.
/*	var/north
	var/east
	var/south
	var/west
	for(var/turf/simulated/wall/W in range(1,S))
		if (S.z == W.z)
			if ((S.x == W.x) && (S.y == (W.y - 1)))
				S.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
				S.overlays += image('walls.dmi',icon_state="wall1",dir=NORTH)
				W.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
				W.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTH)
				if (istype(locate((W.x - 1),W.y,W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
				if (istype(locate((W.x + 1),W.y,W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
				north++
			else if ((S.x == (W.x - 1)) && (S.y == W.y))
				S.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
				S.overlays += image('walls.dmi',icon_state="wall1",dir=EAST)
				W.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
				W.overlays += image('walls.dmi',icon_state="wall1",dir=WEST)
				if (istype(locate(W.x,(W.y - 1),W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
				if (istype(locate(W.x,(W.y + 1),W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
				east++
			else if ((S.x == W.x) && (S.y == (W.y + 1)))
				S.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
				S.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTH)
				W.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
				W.overlays += image('walls.dmi',icon_state="wall1",dir=NORTH)
				if (istype(locate((W.x - 1),W.y,W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
				if (istype(locate((W.x + 1),W.y,W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
				south++
			else if ((S.x == (W.x + 1)) && (S.y == W.y))
				S.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
				S.overlays += image('walls.dmi',icon_state="wall1",dir=WEST)
				W.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
				W.overlays += image('walls.dmi',icon_state="wall1",dir=EAST)
				if (istype(locate(W.x,(W.y - 1),W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
				if (istype(locate(W.x,(W.y + 1),W.z), /turf/simulated/wall))
					W.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
					W.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
				west++
	if (north && west)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
	if (north && east)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
	if (south && west)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
	if (south && east)
		S.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
		S.overlays += image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
*/


/turf/simulated/wall/proc/dismantle_wall(devastated=0)
	var/turf/simulated/wall/S = src
	if(istype(src,/turf/simulated/wall/r_wall))
		if(!devastated)
			playsound(src.loc, 'Welder.ogg', 100, 1)
			new /obj/structure/girder/reinforced(src)
			new /obj/item/weapon/sheet/r_metal( src )
		else
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/r_metal( src )
	else
		if(!devastated)
			playsound(src.loc, 'Welder.ogg', 100, 1)
			new /obj/structure/girder(src)
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
		else
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )
			new /obj/item/weapon/sheet/metal( src )

	for (var/turf/simulated/wall/T in range(1,src))
		if (z == T.z)
			if (y == (T.y - 1) && x == T.x)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTH)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			else if (y == (T.y + 1) && x == T.x)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTH)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
			else if (x == (T.x - 1) && y == T.y)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=WEST)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHWEST)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHWEST)
			else if (x == (T.x + 1) && y == T.y)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=EAST)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=NORTHEAST)
				T.overlays -= image('walls.dmi',icon_state="wall1",dir=SOUTHEAST)

	S.ReplaceWithFloor()

/turf/simulated/wall/examine()
	set src in oview(1)

	usr << "It looks like a regular wall."
	return

/turf/simulated/wall/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			src.ReplaceWithSpace()
			del(src)
			return
		if(2.0)
			if (prob(50))
				dismantle_wall()
			else
				dismantle_wall(devastated=1)
		if(3.0)
			dismantle_wall()
		else
	return

/turf/simulated/wall/blob_act()
	if(prob(20))
		dismantle_wall()

/turf/simulated/wall/attack_paw(mob/user as mob)
	if ((user.mutations & 8))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	return src.attack_hand(user)

/turf/simulated/wall/attack_hand(mob/user as mob)
	if ((user.mutations & 8))
		if (prob(40))
			usr << text("\blue You smash through the wall.")
			dismantle_wall(1)
			return
		else
			usr << text("\blue You punch the wall.")
			return

	user << "\blue You push the wall but nothing happens!"
	playsound(src.loc, 'Genhit.ogg', 25, 1)
	src.add_fingerprint(user)
	return

/turf/simulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	var/turf/simulated/wall/S = src
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		W:eyecheck(user)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (thermite)
			var/obj/overlay/O = new/obj/overlay( src )
			O.name = "Thermite"
			O.desc = "Looks hot."
			O.icon = 'fire.dmi'
			O.icon_state = "2"
			O.anchored = 1
			O.density = 1
			O.layer = 5
			var/turf/simulated/floor/F = ReplaceWithFloor()
			F.to_plating()
			F.burn_tile()
			user << "\red The thermite melts the wall."
			spawn(100) del(O)
			return

		if (W:get_fuel() < 5)
			user << "\blue You need more welding fuel to complete this task."
			return
		W:use_fuel(5)

		user << "\blue Now disassembling the outer wall plating."
		playsound(src.loc, 'Welder.ogg', 100, 1)

		sleep(100)

		if ((user.loc == T && user.equipped() == W) && S)
			user << "\blue You disassembled the outer wall plating."
			S.dismantle_wall()

	else
		return attack_hand(user)
	return

/turf/simulated/wall/r_wall/attackby(obj/item/weapon/W as obj, mob/user as mob)

	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	if (istype(W, /obj/item/weapon/weldingtool) && W:welding)
		W:eyecheck(user)
		var/turf/T = user.loc
		if (!( istype(T, /turf) ))
			return

		if (thermite)
			var/obj/overlay/O = new/obj/overlay( src )
			O.name = "Thermite"
			O.desc = "Looks hot."
			O.icon = 'fire.dmi'
			O.icon_state = "2"
			O.anchored = 1
			O.density = 1
			O.layer = 5
			var/turf/simulated/floor/F = ReplaceWithFloor()
			F.to_plating()
			F.burn_tile()
			user << "\red The thermite melts the wall."
			spawn(100) del(O)
			return

		if (src.d_state == 2)
			user << "\blue Slicing metal cover."
			playsound(src.loc, 'Welder.ogg', 100, 1)
			sleep(60)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 3
				user << "\blue You removed the metal cover."

		else if (src.d_state == 5)
			user << "\blue Removing support rods."
			playsound(src.loc, 'Welder.ogg', 100, 1)
			sleep(100)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 6
				new /obj/item/weapon/rods( src )
				user << "\blue You removed the support rods."

	else if (istype(W, /obj/item/weapon/wrench))
		if (src.d_state == 4)
			var/turf/T = user.loc
			user << "\blue Detaching support rods."
			playsound(src.loc, 'Ratchet.ogg', 100, 1)
			sleep(40)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 5
				user << "\blue You detach the support rods."

	else if (istype(W, /obj/item/weapon/wirecutters))
		if (src.d_state == 0)
			playsound(src.loc, 'Wirecutter.ogg', 100, 1)
			src.d_state = 1
			new /obj/item/weapon/rods( src )

	else if (istype(W, /obj/item/weapon/screwdriver))
		if (src.d_state == 1)
			var/turf/T = user.loc
			playsound(src.loc, 'Screwdriver.ogg', 100, 1)
			user << "\blue Removing support lines."
			sleep(40)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 2
				user << "\blue You removed the support lines."

	else if (istype(W, /obj/item/weapon/crowbar))

		if (src.d_state == 3)
			var/turf/T = user.loc
			user << "\blue Prying cover off."
			playsound(src.loc, 'Crowbar.ogg', 100, 1)
			sleep(100)
			if ((user.loc == T && user.equipped() == W))
				src.d_state = 4
				user << "\blue You removed the cover."

		else if (src.d_state == 6)
			var/turf/T = user.loc
			user << "\blue Prying outer sheath off."
			playsound(src.loc, 'Crowbar.ogg', 100, 1)
			sleep(100)
			if ((user.loc == T && user.equipped() == W))
				user << "\blue You removed the outer sheath."
				dismantle_wall()
				return

	else if ((istype(W, /obj/item/weapon/sheet/metal)) && (src.d_state))
		var/turf/T = user.loc
		user << "\blue Repairing wall."
		sleep(100)
		if ((user.loc == T && user.equipped() == W))
			src.d_state = 0
			src.icon_state = initial(src.icon_state)
			user << "\blue You repaired the wall."
			if (W:amount > 1)
				W:amount--
			else
				del(W)

	if(src.d_state > 0)
		src.icon_state = "r_wall-[d_state]"

	else
		return attack_hand(user)
	return

/turf/simulated/wall/meteorhit(obj/M as obj)
	if (M.icon_state == "flaming")
		dismantle_wall()
	return 0

/turf/simulated/floor/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if ((istype(mover, /obj/machinery/vehicle) && !(src.burnt)))
		if (!( locate(/obj/machinery/mass_driver, src) ))
			return 0
	return ..()

/turf/simulated/floor/ex_act(severity)
	//set src in oview(1)
	switch(severity)
		if(1.0)
			src.ReplaceWithSpace()
		if(2.0)
			switch(pick(1,2;75,3))
				if (1)
					src.ReplaceWithLattice()
					if(prob(33)) new /obj/item/weapon/sheet/metal(src)
				if(2)
					src.ReplaceWithSpace()
				if(3)
					if(prob(80))
						src.break_tile_to_plating()
					else
						src.break_tile()
					src.hotspot_expose(1000,CELL_VOLUME)
					if(prob(33)) new /obj/item/weapon/sheet/metal(src)
		if(3.0)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)
	return

/turf/simulated/floor/blob_act()
	return

turf/simulated/floor/proc/update_icon()


/turf/simulated/floor/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/simulated/floor/attack_hand(mob/user as mob)

	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/simulated/floor/engine/attackby(obj/item/weapon/C as obj, mob/user as mob)
	if(!C)
		return
	if(!user)
		return
	if(istype(C, /obj/item/weapon/wrench))
		user << "\blue Removing rods..."
		playsound(src.loc, 'Ratchet.ogg', 80, 1)
		if(do_after(user, 30))
			new /obj/item/weapon/rods(src)
			new /obj/item/weapon/rods(src)
			ReplaceWithFloor()
			var/turf/simulated/floor/F = src
			F.to_plating()
			return

/turf/simulated/floor/proc/to_plating()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(!intact) return
	if(!icon_old) icon_old = icon_state
	src.icon_state = "plating"
	intact = 0
	broken = 0
	burnt = 0
	levelupdate()

/turf/simulated/floor/proc/break_tile_to_plating()
	if(intact) to_plating()
	break_tile()

/turf/simulated/floor/proc/break_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(broken) return
	if(!icon_old) icon_old = icon_state
	if(intact)
		src.icon_state = "damaged[pick(1,2,3,4,5)]"
		broken = 1
	else
		src.icon_state = "platingdmg[pick(1,2,3)]"
		broken = 1

/turf/simulated/floor/proc/burn_tile()
	if(istype(src,/turf/simulated/floor/engine)) return
	if(broken || burnt) return
	if(!icon_old) icon_old = icon_state
	if(intact)
		src.icon_state = "floorscorched[pick(1,2)]"
	else
		src.icon_state = "panelscorched"
	burnt = 1

/turf/simulated/floor/proc/restore_tile()
	if(intact) return
	intact = 1
	broken = 0
	burnt = 0
	if(icon_old)
		icon_state = icon_old
	else
		icon_state = "floor"
	levelupdate()

/turf/simulated/floor/attackby(obj/item/weapon/C as obj, mob/user as mob)

	if(!C || !user)
		return 0

	if(istype(C, /obj/item/weapon/crowbar) && intact)
		if(broken || burnt)
			user << "\red You remove the broken plating."
		else
			new /obj/item/weapon/tile(src)

		to_plating()
		playsound(src.loc, 'Crowbar.ogg', 80, 1)

		return

	if(istype(C, /obj/item/weapon/rods))
		if (!src.intact)
			if (C:amount >= 2)
				user << "\blue Reinforcing the floor..."
				if(do_after(user, 30))
					ReplaceWithEngineFloor()
					C:amount -= 2
					if (C:amount <= 0) del(C) //wtf
					playsound(src.loc, 'Deconstruct.ogg', 80, 1)
			else
				user << "\red You need more rods."
		else
			user << "\red You must remove the plating first."
		return

	if(istype(C, /obj/item/weapon/tile) && !intact)
		restore_tile()
		var/obj/item/weapon/tile/T = C
		playsound(src.loc, 'Genhit.ogg', 50, 1)
		if(--T.amount < 1)
			del(T)
			return

	if(istype(C, /obj/item/weapon/cable_coil))
		if(!intact)
			var/obj/item/weapon/cable_coil/coil = C
			coil.turf_place(src, user)
		else
			user << "\red You must remove the plating first."

/turf/unsimulated/floor/attack_paw(user as mob)
	return src.attack_hand(user)

/turf/unsimulated/floor/attack_hand(var/mob/user as mob)
	if ((!( user.canmove ) || user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/mob/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

// imported from space.dm

/turf/space/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/turf/space/attack_hand(mob/user as mob)
	if ((user.restrained() || !( user.pulling )))
		return
	if (user.pulling.anchored)
		return
	if ((user.pulling.loc != user.loc && get_dist(user, user.pulling) > 1))
		return
	if (ismob(user.pulling))
		var/mob/M = user.pulling
		var/t = M.pulling
		M.pulling = null
		step(user.pulling, get_dir(user.pulling.loc, src))
		M.pulling = t
	else
		step(user.pulling, get_dir(user.pulling.loc, src))
	return

/turf/space/attackby(obj/item/weapon/C as obj, mob/user as mob)

	if (istype(C, /obj/item/weapon/rods))
		user << "\blue Constructing support lattice ..."
		playsound(src.loc, 'Genhit.ogg', 50, 1)
		ReplaceWithLattice()
		C:amount--

		if (C:amount < 1)
			user.u_equip(C)
			del(C)
			return
		return

	if (istype(C, /obj/item/weapon/tile))
		if(locate(/obj/lattice, src))
			var/obj/lattice/L = locate(/obj/lattice, src)
			del(L)
			playsound(src.loc, 'Genhit.ogg', 50, 1)
			C:build(src)
			C:amount--

			if (C:amount < 1)
				user.u_equip(C)
				del(C)
				return
			return
		else
			user << "\red The plating is going to need some support."
	return


// Ported from unstable r355

/turf/space/Entered(atom/movable/A as mob|obj)
	..()
	if ((!(A) || src != A.loc || istype(null, /obj/beam)))
		return

	if (!(A.last_move))
		return

//	if (locate(/obj/movable, src))
//		return 1

	if ((istype(A, /mob/) && src.x > 2 && src.x < (world.maxx - 1)))
		var/mob/M = A

		if ((!( M.handcuffed) && M.canmove))
			var/prob_slip = 5

			if (locate(/obj/grille, oview(1, M)) || locate(/obj/lattice, oview(1, M)) )
				if (!( M.l_hand ))
					prob_slip -= 2
				else if (M.l_hand.w_class <= 2)
					prob_slip -= 1

				if (!( M.r_hand ))
					prob_slip -= 2
				else if (M.r_hand.w_class <= 2)
					prob_slip -= 1
			else if (locate(/turf/unsimulated, oview(1, M)) || locate(/turf/simulated, oview(1, M)))
				if (!( M.l_hand ))
					prob_slip -= 1
				else if (M.l_hand.w_class <= 2)
					prob_slip -= 0.5

				if (!( M.r_hand ))
					prob_slip -= 1
				else if (M.r_hand.w_class <= 2)
					prob_slip -= 0.5
			prob_slip = round(prob_slip)
			if (prob_slip < 5) //next to something, but they might slip off
				if (prob(prob_slip) )
					M << "\blue <B>You slipped!</B>"
					M.inertia_dir = M.last_move
					step(M, M.inertia_dir)
					return
				else
					M.inertia_dir = 0 //no inertia
			else //not by a wall or anything, they just keep going
				spawn(5)
					if ((A && !( A.anchored ) && A.loc == src))
						if(M.inertia_dir) //they keep moving the same direction
							step(M, M.inertia_dir)
						else
							M.inertia_dir = M.last_move
							step(M, M.inertia_dir)
		else //can't move, they just keep going (COPY PASTED CODE WOO)
			spawn(5)
				if ((A && !( A.anchored ) && A.loc == src))
					if(M.inertia_dir) //they keep moving the same direction
						step(M, M.inertia_dir)
					else
						M.inertia_dir = M.last_move
						step(M, M.inertia_dir) //TODO: DEFERRED
	if(ticker && ticker.mode && ticker.mode.name == "nuclear emergency")
		return
	if (src.x <= 2)
		if(prob(50))
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 3
			A.x = world.maxx - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
		else
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 4
			A.x = world.maxx - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (A.x >= (world.maxx - 1))
		if(prob(50))
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 3
			A.x = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
		else
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 4
			A.x = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
	else if (src.y <= 2)
		if(prob(50))
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 3
			A.y = world.maxy - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
		else
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 4
			A.y = world.maxy - 2
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)

	else if (A.y >= (world.maxy - 1))
		if(prob(50))
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 3
			A.y = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)
		else
			if(istype(A, /obj/meteor))
				del(A)
				return
			A.z = 4
			A.y = 3
			spawn (0)
				if ((A && A.loc))
					A.loc.Entered(A)