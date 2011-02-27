/*
CONTAINS:
PROJECTILE DEFINES
PULSE RIFLE
357 AMMO
38 AMMO
REVOLVER
DETECTIVES REVOLVER
LASER GUN
TASER GUN
CROSSBOW
TELEPORT GUN

*/

/var/const/PROJECTILE_TASER = 1
/var/const/PROJECTILE_LASER = 2
/var/const/PROJECTILE_BULLET = 3
/var/const/PROJECTILE_PULSE = 4
/var/const/PROJECTILE_BOLT = 5
/var/const/PROJECTILE_WEAKBULLET = 6
/var/const/PROJECTILE_TELEGUN = 7




// PULSE RIFLE

/obj/item/weapon/gun/energy/pulse_rifle
	name = "pulse rifle"
	icon_state = "pulse_rifle"
	force = 15

	var/mode = 1

	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if ((usr.mutations & 16) && prob(50))
			usr << "\red The pulse rifle blows up in your face."
			usr.fireloss += 20
			usr.drop_item()
			del(src)
			return
		if (flag)
			return
		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return

		src.add_fingerprint(user)

		var/turf/curloc = user.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return
		if(mode == 1)
			if (targloc == curloc)
				user.bullet_act(PROJECTILE_PULSE)
				return
		else if(mode == 2)
			if (targloc == curloc)
				user.bullet_act(PROJECTILE_TASER)
				return

		if(mode == 1)
			var/obj/beam/a_laser/A = new /obj/beam/a_laser/pulse_laser(user.loc)
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			user.next_move = world.time + 4
			spawn()
				A.process()

		else if(mode == 2)
			var/obj/bullet/electrode/A = new /obj/bullet/electrode(user.loc)
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			user.next_move = world.time + 4
			spawn()
				A.process()

	attack_self(mob/user as mob)
		if(mode == 1)
			mode = 2
			user << "\blue You set the pulse rifle to stun"
		else if (mode == 2)
			mode = 1
			user << "\blue You set the pulse rifle to kill"

	attack(mob/M as mob, mob/user as mob)
		..()
		src.add_fingerprint(user)
		if ((prob(50) && M.stat < 2))
			var/mob/living/carbon/human/H = M
			if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(70)))
				M << "\red The helmet protects you from being hit hard in the head!"
				return
			var/time = rand(50, 170)
			if (prob(90))
				M.paralysis = min(time, M.paralysis)
			else
				M.weakened = min(time, M.weakened)
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				if(O.client)	O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall", 2)




// AMMO


/obj/item/weapon/ammo/proc/update_icon()
	return


// 357

/obj/item/weapon/ammo/a357/update_icon()
	src.icon_state = text("357-[]", src.amount_left)
	src.desc = text("There are [] bullet\s left!", src.amount_left)
	return


// 38

/obj/item/weapon/ammo/a38/update_icon()
	src.desc = text("There are [] bullet\s left!", src.amount_left)
	if(src.amount_left > 0)
		src.icon_state = text("38-[]", src.amount_left)
	else
		src.icon_state = "speedloader_empty"





// REVOLVER

/obj/item/weapon/gun/revolver/examine()
	set src in usr

	src.desc = text("There are [] bullet\s left! Uses 357.", src.bullets)
	..()
	return

obj/item/weapon/gun/revolver/attackby(obj/item/weapon/ammo/a357/A as obj, mob/user as mob)

	if (istype(A, /obj/item/weapon/ammo/a357))
		if (src.bullets >= 7)
			user << "\blue It's already fully loaded!"
			return 1
		if (A.amount_left <= 0)
			user << "\red There is no more bullets!"
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			user << text("\red You reload [] bullet\s!", A.amount_left)
			A.amount_left = 0
		else
			user << text("\red You reload [] bullet\s!", 7 - src.bullets)
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	return

/obj/item/weapon/gun/revolver/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if (flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("\red *click* *click*", 2)
		return
	playsound(user, 'Gunshot.ogg', 100, 1)
	src.bullets--
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\red <B>[] fires a revolver at []!</B>", user, target), 1, "\red You hear a gunshot", 2)
	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return
	if (U == T)
		user.bullet_act(PROJECTILE_BULLET)
		return
	var/obj/bullet/A = new /obj/bullet( user.loc )
	if (!istype(U, /turf))
		del(A)
		return
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	user.next_move = world.time + 4
	spawn( 0 )
		A.process()
		return
	return

/obj/item/weapon/gun/revolver/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	var/mob/living/carbon/human/H = M

// ******* Check

	if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	if ((user.a_intent == "hurt" && src.bullets > 0))
		if (prob(20))
			if (M.paralysis < 10)
				M.paralysis = 10
		else
			if (M.weakened < 10)
				M.weakened = 10
		src.bullets--
		src.force = 90
		..()
		src.force = 60
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if(O.client)	O.show_message(text("\red <B>[] has been shot point-blank by []!</B>", M, user), 1, "\red You hear someone fall", 2)
	else
		if (prob(50))
			if (M.paralysis < 60)
				M.paralysis = 60
		else
			if (M.weakened < 60)
				M.weakened = 60
		src.force = 10
		..()
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if (O.client)	O.show_message(text("\red <B>[] has been pistol whipped by []!</B>", M, user), 1, "\red You hear someone fall", 2)
	return






// DETECTIVE REVOLVER


/obj/item/weapon/gun/detectiverevolver/examine()
	set src in usr
	src.desc = text("There are [] bullet\s left! Uses .38-Special rounds", src.bullets)
	..()
	return

/obj/item/weapon/gun/detectiverevolver/attackby(obj/item/weapon/ammo/a38/A as obj, mob/user as mob)

	if (istype(A, /obj/item/weapon/ammo/a38))
		if (src.bullets >= 7)
			user << "\blue It's already fully loaded!"
			return 1
		if (A.amount_left <= 0)
			user << "\red There are no more bullets!"
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			user << text("\red You reload [] bullet\s!", A.amount_left)
			A.amount_left = 0
		else
			user << text("\red You reload [] bullet\s!", 7 - src.bullets)
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	return

/obj/item/weapon/gun/detectiverevolver/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)

	//var/detective = (istype(user:w_uniform, /obj/item/clothing/under/det) && istype(user:head, /obj/item/clothing/head/det_hat)  && istype(user:wear_suit, /obj/item/clothing/suit/storage/det_suit))

	if (flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	src.add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message("\red *click* *click*", 2)
		return
	playsound(user, 'Gunshot.ogg', 100, 1)
	src.bullets--
	for(var/mob/O in viewers(user, null))
		O.show_message(text("\red <B>[] fires the detectives revolver at []!</B>", user, target), 1, "\red You hear a gunshot", 2)
	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)
	if ((!( U ) || !( T )))
		return
	while(!( istype(U, /turf) ))
		U = U.loc
	if (!( istype(T, /turf) ))
		return
	if (U == T)
		user.bullet_act(PROJECTILE_WEAKBULLET)
		return
	var/obj/bullet/weakbullet/A = new /obj/bullet/weakbullet( user.loc )
	if (!istype(U, /turf))
		del(A)
		return
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	user.next_move = world.time + 4
	spawn( 0 )
		A.process()
		return
	return

/obj/item/weapon/gun/detectiverevolver/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	var/mob/living/carbon/human/H = M
//	var/detective = (istype(user:w_uniform, /obj/item/clothing/under/det) && istype(user:head, /obj/item/clothing/head/det_hat)  && istype(user:wear_suit, /obj/item/clothing/suit/storage/det_suit))

// ******* Check
//
//	if(!detective)
//		usr << "\red You just don't feel cool enough to use this gun looking like that."
//		return
	if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	if ((user.a_intent == "hurt" && src.bullets > 0))
		if (prob(5))
			if (M.paralysis < 10)
				M.paralysis = 10
		else
			if (M.weakened < 10)
				M.weakened = 10
		src.bullets--
		src.force = 9.0
		..()
		src.force = 9.0
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if(O.client)	O.show_message(text("\red <B>[] has been shot point-blank with the detectives revolver by []!</B>", M, user), 1, "\red You hear someone fall", 2)
	else
		if (prob(5))
			if (M.paralysis < 10)
				M.paralysis = 10
		else
			if (M.weakened < 10)
				M.weakened = 10
		src.force = 8.0
		..()
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if (O.client)	O.show_message(text("\red <B>[] has been pistol whipped with the detectives revolver by []!</B>", M, user), 1, "\red You hear someone fall", 2)
	return





// ENERGY GUN

/obj/item/weapon/gun/energy/proc/update_icon()
	if (istype(src, /obj/item/weapon/gun/energy/crossbow)) return
	var/ratio = src.charges / 10
	ratio = round(ratio, 0.25) * 100
	src.icon_state = text("gun[]", ratio)
	return




// LASER GUN

/obj/item/weapon/gun/energy/laser_gun/update_icon()
	if (istype(src, /obj/item/weapon/gun/energy/crossbow)) return
	var/ratio = src.charges / 10
	ratio = round(ratio, 0.25) * 100
	if (istype(src, /obj/item/weapon/gun/energy/laser_gun/captain))
		src.icon_state = text("caplaser[]", ratio)
	else
		src.icon_state = text("laser[]", ratio)
	return

/obj/item/weapon/gun/energy/laser_gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red The laser gun blows up in your face."
		usr.fireloss += 20
		usr.drop_item()
		del(src)
		return
	if (flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	src.add_fingerprint(user)

	if(src.charges < 1)
		user << "\red *click* *click*"
		return

	playsound(user, 'Laser.ogg', 50, 1)
	src.charges--
	update_icon()

	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U, /turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if(U == T)
		user.bullet_act(PROJECTILE_LASER)
		return
	if(!istype(U, /turf))
		return

	var/obj/beam/a_laser/A = new /obj/beam/a_laser( user.loc )

	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x

	user.next_move = world.time + 4
	A.process()
	return

/obj/item/weapon/gun/energy/laser_gun/attack(mob/M as mob, mob/user as mob)
	..()
	src.add_fingerprint(user)
	if ((prob(30) && M.stat < 2))
		var/mob/living/carbon/human/H = M

// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(10, 120)
		if (prob(90))
			if (M.paralysis < time)
				M.paralysis = time
		else
			if (M.weakened < time)
				M.weakened = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			if(O.client)	O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall", 2)

	return







// TASER GUN


/obj/item/weapon/gun/energy/taser_gun/update_icon()
	var/ratio = src.charges / maximum_charges
	ratio = round(ratio, 0.25) * 100
	src.icon_state = text("taser[]", ratio)
	if(src.blood_DNA)
		var/icon/I = new /icon(initial(src.icon), src.icon_state)
		I.Blend(new /icon('blood.dmi', "thisisfuckingstupid"),ICON_ADD)
		I.Blend(new /icon('blood.dmi', "itemblood"),ICON_MULTIPLY)
		I.Blend(new /icon(initial(src.icon), src.icon_state),ICON_UNDERLAY) //motherfucker
		src.icon = I
/obj/item/weapon/gun/energy/taser_gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(flag)
		return
	if (ismonkey(user) && ticker.mode.name != "monkey")
		user << "\red You don't have the dexterity to do this!"
		return
	src.add_fingerprint(user)
	if(!isrobot(user) && src.charges < 1)
		user << "\red *click* *click*";
		return

	playsound(user, 'Taser.ogg', 50, 1)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		R.cell.charge -= 20
	else
		src.charges--
	update_icon()

	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		user.bullet_act(PROJECTILE_TASER)
		return
	if(!istype(U, /turf))
		return

	var/obj/bullet/electrode/A = new /obj/bullet/electrode(user.loc)

	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x

	A.process()


/obj/item/weapon/gun/energy/taser_gun/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red The taser gun discharges in your hand."
		usr.paralysis += 60
		return
	src.add_fingerprint(user)
	var/mob/living/carbon/human/H = M
	if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	if((src.charges >= 1) && (istype(H, /mob/living/carbon/human)))
		if (user.a_intent == "hurt")
			if (prob(20))
				if (M.paralysis < 10 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
					M.paralysis = 10
			else if (M.weakened < 10 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.weakened = 10
			if (M.stuttering < 10 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 10
			..()
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				O.show_message("\red <B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall", 2)
		else
			if (prob(50))
				if (M.paralysis < 60 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
					M.paralysis = 60
			else
				if (M.weakened < 60 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
					M.weakened = 60
			if (M.stuttering < 60 && (!(M.mutations & 8))  /*&& (!istype(H:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
				M.stuttering = 60
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message("\red <B>[M] has been stunned with the taser gun by [user]!</B>", 1, "\red You hear someone fall", 2)
		src.charges--
		update_icon()
	else if((src.charges >= 1) && (istype(M, /mob/living/carbon/monkey)))
		if (user.a_intent == "hurt")
			if (prob(20))
				if (M.paralysis < 10 && (!(M.mutations & 8)) )
					M.paralysis = 10
			else if (M.weakened < 10 && (!(M.mutations & 8)) )
				M.weakened = 10
			if (M.stuttering < 10 && (!(M.mutations & 8)) )
				M.stuttering = 10
			..()
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				O.show_message("\red <B>[M] has been knocked unconscious!</B>", 1, "\red You hear someone fall", 2)
		else
			if (prob(50))
				if (M.paralysis < 60 && (!(M.mutations & 8)) )
					M.paralysis = 60
			else
				if (M.weakened < 60 && (!(M.mutations & 8)) )
					M.weakened = 60
			if (M.stuttering < 60 && (!(M.mutations & 8)) )
				M.stuttering = 60
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message("\red <B>[M] has been stunned with the taser gun by [user]!</B>", 1, "\red You hear someone fall", 2)
		src.charges--
		update_icon()
	else // no charges in the gun, so they just wallop the target with it
		..()




// CROSSBOW


/obj/item/weapon/gun/energy/crossbow/New()
	charge()

/obj/item/weapon/gun/energy/crossbow/proc/charge()
	if(charges < maximum_charges) charges++
	spawn(50) charge()

/obj/item/weapon/gun/energy/crossbow/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return

	//src.add_fingerprint(user) stealthy and stuff

	if(src.charges < 1)
		user << "\red *click* *click*";
		return

	playsound(user, 'Genhit.ogg', 20, 1)
	src.charges--
	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		user.bullet_act(PROJECTILE_BOLT)
		return
	if(!istype(U, /turf))
		return

	var/obj/bullet/cbbolt/A = new /obj/bullet/cbbolt(user.loc)

	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x

	A.process()

/obj/item/weapon/gun/energy/crossbow/attack(mob/M as mob, mob/user as mob)
	src.add_fingerprint(user)
	var/mob/living/carbon/human/H = M
	if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
		M << "\red The helmet protects you from being hit hard in the head!"
		return
	..()




// TELEPORT GUN
// This whole thing is just a copy/paste job

/obj/item/weapon/gun/energy/teleport_gun/attack_self(mob/user as mob)
	var/list/L = list(  )
	for(var/obj/machinery/teleport/hub/R in world)
		var/obj/machinery/computer/teleporter/com = locate(/obj/machinery/computer/teleporter, locate(R.x - 2, R.y, R.z))
		if (istype(com, /obj/machinery/computer/teleporter) && com.locked)
			if(R.icon_state == "tele1")
				L["[com.id] (Active)"] = com.locked
			else
				L["[com.id] (Inactive)"] = com.locked
	L["None (Dangerous)"] = null
	var/t1 = input(user, "Please select a teleporter to lock in on.", "Hand Teleporter") in L
	if ((user.equipped() != src || user.stat || user.restrained()))
		return
	var/T = L[t1]
	src.target = T
	usr << "\blue Teleportation hub selected!"
	src.add_fingerprint(user)
	return

/obj/item/weapon/gun/energy/teleport_gun/update_icon()
	var/ratio = src.charges / maximum_charges
	ratio = round(ratio, 0.25) * 100
	src.icon_state = text("taser[]", ratio)
	if(src.blood_DNA)
		var/icon/I = new /icon(initial(src.icon), src.icon_state)
		I.Blend(new /icon('blood.dmi', "thisisfuckingstupid"),ICON_ADD)
		I.Blend(new /icon('blood.dmi', "itemblood"),ICON_MULTIPLY)
		I.Blend(new /icon(initial(src.icon), src.icon_state),ICON_UNDERLAY) //motherfucker
		src.icon = I
/obj/item/weapon/gun/energy/teleport_gun/afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
	if(flag)
		return
	if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
		usr << "\red You don't have the dexterity to do this!"
		return
	src.add_fingerprint(user)
	if(src.charges < 1)
		user << "\red *click* *click*";
		return

	playsound(user, 'Taser.ogg', 50, 1)
	src.charges--
	update_icon()

	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)

	if(!U || !T)
		return
	while(U && !istype(U,/turf))
		U = U.loc
	if(!istype(T, /turf))
		return
	if (U == T)
		return
	if(!istype(U, /turf))
		return

	var/obj/bullet/teleshot/A = new /obj/bullet/teleshot(user.loc)

	A.target = src.target
	A.current = U
	A.yo = U.y - T.y
	A.xo = U.x - T.x

	A.process()

/obj/item/weapon/gun/energy/teleport_gun/proc/point_blank_teleport(mob/M as mob, mob/user as mob)
	if (src.target == null)
		var/list/turfs = list(	)
		for(var/turf/T in orange(10))
			if(T.x>world.maxx-4 || T.x<4)	continue	//putting them at the edge is dumb
			if(T.y>world.maxy-4 || T.y<4)	continue
			turfs += T
		if(turfs)
			src.target = pick(turfs)
	if (!src.target)
		return
	spawn(0)
		if(M)
			var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
			s.set_up(5, 1, M)
			s.start()
			if(prob(src.failchance)) //oh dear a problem, put em in deep space
				do_teleport(M, locate(rand(5, world.maxx - 5), rand(5, world.maxy -5), 3), 0)
			else
				do_teleport(M, src.target, 2)
	return

/obj/item/weapon/gun/energy/teleport_gun/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red You shoot the teleport gun while holding it backwards."
		point_blank_teleport(usr)
		return
	src.add_fingerprint(user)
	if(src.charges >= 1)
		if (prob(95))
			point_blank_teleport(M)
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message("\red <B>[M] was shot point blank with the teleport gun by [user]!</B>", 1)
		else
			point_blank_teleport(usr)
			for(var/mob/O in viewers(M, null))
				if (O.client)	O.show_message("\red <B>[user] tried to shoot [M] but the teleport gun misfired!</B>", 1)
		src.charges--
		update_icon()
	else // no charges in the gun, so they just wallop the target with it
		..()








// General Gun

/obj/item/weapon/gun/energy/general
	name = "energy gun"
	icon_state = "energy"
	desc = "Its a gun that has two modes, stun and kill"
	w_class = 3.0
	item_state = "gun"
	force = 10.0
	throw_speed = 2
	throw_range = 10
	charges = 10
	maximum_charges = 10
	m_amt = 2000

	var/mode = 2

	update_icon()
		var/ratio = src.charges / maximum_charges
		ratio = round(ratio, 0.25) * 100
		src.icon_state = text("energy[]", ratio)
		if(src.blood_DNA)
			var/icon/I = new /icon(initial(src.icon), src.icon_state)
			I.Blend(new /icon('blood.dmi', "thisisfuckingstupid"),ICON_ADD)
			I.Blend(new /icon('blood.dmi', "itemblood"),ICON_MULTIPLY)
			I.Blend(new /icon(initial(src.icon), src.icon_state),ICON_UNDERLAY) //motherfucker
			src.icon = I
	afterattack(atom/target as mob|obj|turf|area, mob/user as mob, flag)
		if ((usr.mutations & 16) && prob(50))
			usr << "\red The energy gun blows up in your face."
			usr.fireloss += 20
			usr.drop_item()
			del(src)
			return
		if (flag)
			return
		if (!(istype(usr, /mob/living/carbon/human) || ticker) && ticker.mode.name != "monkey")
			usr << "\red You don't have the dexterity to do this!"
			return

		src.add_fingerprint(user)

		if(src.charges < 1)
			user << "\red *click* *click*";
			return

		playsound(user, 'Taser.ogg', 50, 1)
		src.charges--
		update_icon()

		var/turf/curloc = user.loc
		var/atom/targloc = get_turf(target)
		if (!targloc || !istype(targloc, /turf) || !curloc)
			return

		if(mode == 1)
			if (targloc == curloc)
				user.bullet_act(PROJECTILE_LASER)
				return
		else if(mode == 2)
			if (targloc == curloc)
				user.bullet_act(PROJECTILE_TASER)
				return

		if(mode == 1)
			var/obj/beam/a_laser/A = new /obj/beam/a_laser(user.loc)
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			user.next_move = world.time + 4
			spawn()
				A.process()

		else if(mode == 2)
			var/obj/bullet/electrode/A = new /obj/bullet/electrode(user.loc)
			A.current = curloc
			A.yo = targloc.y - curloc.y
			A.xo = targloc.x - curloc.x
			user.next_move = world.time + 4
			spawn()
				A.process()

	attack_self(mob/user as mob)
		if(mode == 1)
			mode = 2
			user << "\blue You set the gun to stun"
		else if (mode == 2)
			mode = 1
			user << "\blue You set the gun to kill"

	attack(mob/M as mob, mob/user as mob)
		..()
		src.add_fingerprint(user)
		if ((prob(30) && M.stat < 2))
			var/mob/living/carbon/human/H = M

			if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
				M << "\red The helmet protects you from being hit hard in the head!"
				return
			var/time = rand(10, 120)
			if (prob(90))
				if (M.paralysis < time)
					M.paralysis = time
			else
				if (M.weakened < time)
					M.weakened = time
			if(M.stat != 2)	M.stat = 1
			for(var/mob/O in viewers(M, null))
				if(O.client)	O.show_message(text("\red <B>[M] has been knocked unconscious!</B>"), 1, "\red You hear someone fall", 2)

		return
