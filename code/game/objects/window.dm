/obj/window/bullet_act(flag)
	if (flag == PROJECTILE_BULLET)
		if(!reinf)
			new /obj/item/weapon/shard( src.loc )
			//SN src = null
			src.density = 0

			del(src)
		else
			health -= 35
			if(health <=0)
				new /obj/item/weapon/shard( src.loc )
				new /obj/item/weapon/rods( src.loc )
				src.density = 0
				del(src)

		return
	return
/obj/window/Bumped(AM as mob|obj)
	if(ismob(AM) && iszombie(AM))
		src.attack_hand(AM)
	return ..()

/obj/window/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			new /obj/item/weapon/shard( src.loc )
			if(reinf) new /obj/item/weapon/rods( src.loc)
			//SN src = null
			del(src)
			return
		if(3.0)
			if (prob(50))
				new /obj/item/weapon/shard( src.loc )
				if(reinf) new /obj/item/weapon/rods( src.loc)

				del(src)
				return
	return

/obj/window/blob_act()
	if(prob(50))
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/weapon/rods( src.loc)
		density = 0
		del(src)

/obj/window/CanPass(atom/movable/mover, turf/source, height=0, air_group=0)
	if(istype(mover, /obj/beam))
		return 1
	if(istype(mover, /obj/projectile) && mover:pass_windows)
		return 1
	if (src.dir == SOUTHWEST || src.dir == SOUTHEAST || src.dir == NORTHWEST || src.dir == NORTHEAST)
		return 0 //full tile window, you can't move into it!
	if(get_dir(loc, source) == dir)
		return !density
	else
		return 1

/obj/window/CheckExit(atom/movable/O as mob|obj, target as turf)
	if(istype(O, /obj/beam))
		return 1
	if(istype(O, /obj/projectile) && O:pass_windows)
		return 1
	if (get_dir(O.loc, target) == src.dir)
		return 0
	return 1

/obj/window/meteorhit()

	//*****RM
	//world << "glass at [x],[y],[z] Mhit"
	src.health = 0
	new /obj/item/weapon/shard( src.loc )
	if(reinf) new /obj/item/weapon/rods( src.loc)
	src.density = 0


	del(src)
	return


/obj/window/hitby(AM as mob|obj)

	..()
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] was hit by [AM].</B>"), 1)
	var/tforce = 0
	if(ismob(AM))
		tforce = 40
	else
		tforce = AM:throwforce
	if(reinf) tforce /= 4.0
	playsound(src.loc, 'sound/effects/Glasshit.ogg', 100, 1)
	src.health = max(0, src.health - tforce)
	if (src.health <= 7 && !reinf)
		src.anchored = 0
		step(src, get_dir(AM, src))
	if (src.health <= 0)
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/weapon/rods( src.loc)
		src.density = 0
		del(src)
		return
	..()
	return

/obj/window/attack_hand()
	if ((usr.mutations & 8))
		usr << text("\blue You smash through the window.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes through the window.", usr)
		src.health = 0
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/weapon/rods( src.loc)
		src.density = 0
		del(src)
	if(istype(usr,/mob/living/carbon/human))
		if(usr:zombie && !(locate(/turf/space) in view(1,src)))
			usr << text("\blue You bang on the window.")
			for(var/mob/O in oviewers())
				if ((O.client && !( O.blinded )))
					O << text("\red [] bangs on the window.", usr)
			if(prob(24))
				for(var/mob/O in oviewers())
					if ((O.client && !( O.blinded )))
						O << text("\red [] smashes through the window.", usr)
				src.health = 0
				new /obj/item/weapon/shard( src.loc )
				if(reinf) new /obj/item/weapon/rods( src.loc)
				src.density = 0
				del(src)
	return

/obj/window/attack_paw()
	if ((usr.mutations & 8))
		usr << text("\blue You smash through the window.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] smashes through the window.", usr)
		src.health = 0
		new /obj/item/weapon/shard( src.loc )
		if(reinf) new /obj/item/weapon/rods( src.loc)
		src.density = 0
		del(src)
	return

/obj/window/attackby(obj/item/weapon/W as obj, mob/user as mob)


	if (istype(W, /obj/item/weapon/screwdriver))
		if(reinf && state >= 1)
			state = 3 - state
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			usr << ( state==1? "You have unfastened the window from the frame." : "You have fastened the window to the frame." )
		else if(reinf && state == 0)
			anchored = !anchored
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (src.anchored ? "You have fastened the frame to the floor." : "You have unfastened the frame from the floor.")
		else if(!reinf)
			src.anchored = !( src.anchored )
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 75, 1)
			user << (src.anchored ? "You have fastened the window to the floor." : "You have unfastened the window.")
	else if(istype(W, /obj/item/weapon/crowbar) && reinf)
		if(state <=1)
			state = 1-state;
			playsound(src.loc, 'sound/items/Crowbar.ogg', 75, 1)
			user << (state ? "You have pried the window into the frame." : "You have pried the window out of the frame.")
	else
		var/aforce = W.force
		if(reinf) aforce /= 2.0
		src.health = max(0, src.health - aforce)
		playsound(src.loc, 'sound/effects/Glasshit.ogg', 75, 1)
		if (src.health <= 7)
			src.anchored = 0
			step(src, get_dir(user, src))
		if (src.health <= 0)
			if (src.dir == SOUTHWEST)
				var/index = null
				index = 0
				while(index < 2)
					new /obj/item/weapon/shard( src.loc )
					if(reinf) new /obj/item/weapon/rods( src.loc)
					index++
			else
				new /obj/item/weapon/shard( src.loc )
				if(reinf) new /obj/item/weapon/rods( src.loc)
			src.density = 0
			del(src)
			return
		..()
	return


/obj/window/verb/rotate()
	set src in oview(1)

	if (src.anchored)
		usr << "It is fastened to the floor; therefore, you can't rotate it!"
		return 0

	update_nearby_tiles(need_rebuild=1) //Compel updates before

	src.dir = turn(src.dir, 90)

	update_nearby_tiles(need_rebuild=1)

	src.ini_dir = src.dir
	return

/obj/window/New(Loc,re=0)
	..()

	if(re)	reinf = re

	src.ini_dir = src.dir
	if(reinf)
		icon_state = "rwindow"
		desc = "A reinforced window."
		name = "reinforced window"
		state = 2*anchored
		health = 40

	update_nearby_tiles(need_rebuild=1)

	return

/obj/window/Del()
	density = 0

	update_nearby_tiles()

	playsound(src, "shatter", 70, 1)
	..()

/obj/window/Move()
	update_nearby_tiles(need_rebuild=1)

	..()

	src.dir = src.ini_dir
	update_nearby_tiles(need_rebuild=1)

	return

/obj/window/update_nearby_tiles(need_rebuild)
	if(!air_master) return 0

	var/turf/simulated/source = loc
	var/turf/simulated/target = get_step_3d(source,dir)
	if(istype(source)) air_master.mark_for_update(source)
	if(istype(target)) air_master.mark_for_update(target)

	return 1