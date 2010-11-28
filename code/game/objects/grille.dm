//returns the netnum of a stub cable at this grille loc, or 0 if none



/obj/grille/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				src.health -= 11
				healthcheck()
		else
	return

/obj/grille/blob_act()
	src.health--
	src.healthcheck()


/obj/grille/meteorhit(var/obj/M)
	if (M.icon_state == "flaming")
		src.health -= 2
		healthcheck()
	return

/obj/grille/attack_hand(var/obj/M)
	if ((usr.mutations & 8))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		src.health -= 2
		healthcheck()
		return
	else if(!shock(usr, 70))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		playsound(src.loc, 'grillehit.ogg', 80, 1)
		src.health -= 1

/obj/grille/attack_paw(var/obj/M)
	if ((usr.mutations & 8))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		src.health -= 2
		healthcheck()
		return
	else if(!shock(usr, 70))
		usr << text("\blue You kick the grille.")
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << text("\red [] kicks the grille.", usr)
		playsound(src.loc, 'grillehit.ogg', 80, 1)
		src.health -= 1

/obj/grille/CanPass(atom/movable/mover, turf/source, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if ((istype(mover, /obj/effects) || istype(mover, /obj/item/weapon/dummy) || istype(mover, /obj/beam) || istype(mover, /obj/meteor/small)))
		return 1
	else
		if (istype(mover, /obj/bullet))
			return prob(30)
		else
			return !src.density

/obj/grille/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/wirecutters))
		if(!shock(user, 100))
			playsound(src.loc, 'Wirecutter.ogg', 100, 1)
			src.health = 0
	else if ((istype(W, /obj/item/weapon/screwdriver) && (istype(src.loc, /turf/simulated) || src.anchored)))
		if(!shock(user, 90))
			playsound(src.loc, 'Screwdriver.ogg', 100, 1)
			src.anchored = !( src.anchored )
			user << (src.anchored ? "You have fastened the grille to the floor." : "You have unfastened the grill.")
			for(var/mob/O in oviewers())
				O << text("\red [user] [src.anchored ? "fastens" : "unfastens"] the grille.")
			return
	else if(istype(W, /obj/item/weapon/shard))	// can't get a shock by attacking with glass shard
		src.health -= W.force * 0.1

	else						// anything else, chance of a shock
		if(!shock(user, 70))
			playsound(src.loc, 'grillehit.ogg', 80, 1)
			switch(W.damtype)
				if("fire")
					src.health -= W.force
				if("brute")
					src.health -= W.force * 0.1

	src.healthcheck()
	..()
	return

/obj/grille/proc/healthcheck()
	if (src.health <= 0)
		if (!( src.destroyed ))
			src.icon_state = "brokengrille"
			src.density = 0
			src.destroyed = 1
			new /obj/item/weapon/rods( src.loc )

		else
			if (src.health <= -10.0)
				new /obj/item/weapon/rods( src.loc )
				//SN src = null
				del(src)
				return
	return

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/grille/proc/shock(mob/user, prb)

	if(!anchored || destroyed)		// anchored/destroyed grilles are never connected
		return 0

	if(!prob(prb))
		return 0

	var/turf/MyLocation = loc
	if(!istype(MyLocation, /turf/simulated/floor))
		return 0

	for (var/obj/cabling/power/Cable in MyLocation)
		var/datum/UnifiedNetwork/Network = Networks[/obj/cabling/power]
		if(!Network)
			return 0
		var/datum/UnifiedNetworkController/PowernetController/Controller = Network.Controller
		Controller.CableTouched(Cable, user)
		return 1