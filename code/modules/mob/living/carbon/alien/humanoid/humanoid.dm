/mob/living/carbon/alien/humanoid/name = "alien"
/mob/living/carbon/alien/humanoid/icon_state = "alien_s"

/mob/living/carbon/alien/humanoid/var/obj/item/weapon/r_store = null
/mob/living/carbon/alien/humanoid/var/obj/item/weapon/l_store = null

/mob/living/carbon/alien/humanoid/var/icon/stand_icon = null
/mob/living/carbon/alien/humanoid/var/icon/lying_icon = null

/mob/living/carbon/alien/humanoid/var/last_b_state = 1.0

/mob/living/carbon/alien/humanoid/var/image/face_standing = null
/mob/living/carbon/alien/humanoid/var/image/face_lying = null

/mob/living/carbon/alien/humanoid/var/list/body_standing = list(  )
/mob/living/carbon/alien/humanoid/var/list/body_lying = list(  )

/mob/living/carbon/alien/humanoid/New()
	..()
	if(!istype(src, /mob/living/carbon/alien/humanoid/queen))
		stand_icon = new /icon('icons/mob/alien.dmi', "alien_s")
		lying_icon = new /icon('icons/mob/alien.dmi', "alien_l")
	icon = stand_icon

	if(name == "alien") name = text("alien ([rand(1, 1000)])")
	real_name = name



/mob/living/carbon/alien/humanoid/movement_delay()
	var/tally = 0
	if (istype(src, /mob/living/carbon/alien/humanoid/queen))
		tally += 5
	return tally

/mob/living/carbon/alien/humanoid/Stat()
	..()
	if (client.statpanel == "Status")
		if (internal)
			if (!internal.air_contents)
				del(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)

		stat(null, "Plasma Stored: [toxloss]")

/mob/living/carbon/alien/humanoid/bullet_act(flag, A as obj)
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			if (flag == "bullet")
				return
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"

	for(var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"

	if (shielded && flag != "bullet")
		src << "\blue Your shield was disturbed by a laser!"
		if(paralysis <= 12)	paralysis = 12
		updatehealth()

	return ..(flag, A)

/mob/living/carbon/alien/humanoid/ex_act(severity)
	flick("flash", flash)

	if (stat == 2 && client)
		gib(1)
		return

	else if (stat == 2 && !client)
		gibs(loc, microorganism)
		del(src)
		return

	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			gib(1)
			return

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			ear_damage += 30
			ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				paralysis += 1
			ear_damage += 15
			ear_deaf += 60

	bruteloss += b_loss
	fireloss += f_loss

	updatehealth()

/mob/living/carbon/alien/humanoid/blob_act()
	if (stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4


	show_message("\red The blob attacks you!")

	bruteloss += damage

	return

//unequip
/mob/living/carbon/alien/humanoid/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		wear_suit = null
	else if (W == head)
		head = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null

/mob/living/carbon/alien/humanoid/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3	//permit the double-click redirection to proceed.
	switch(text)

//if emptyhand then wear the suit, no bedsheet clothes for the alien

		if("o_clothing")
			if (wear_suit)
				if (emptyHand)
					wear_suit.DblClick()
				return
			if (( istype(W, /obj/alien/skin_suit) ))
				u_equip(W)
				head = W
				return
			return
/*			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			u_equip(W)
			wear_suit = W
			W.equipped(src, text)
*/
		if("head")
			if (head)
				if (emptyHand)
					head.DblClick()
				return
			if (( istype(W, /obj/alien/head) ))
				u_equip(W)
				head = W
				return
			return
/*			if (!( istype(W, /obj/item/clothing/head) ))
				return
			u_equip(W)
			head = W
			W.equipped(src, text)
*/
		if("storage1")
			if (l_store)
				if (emptyHand)
					l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			u_equip(W)
			l_store = W
		if("storage2")
			if (r_store)
				if (emptyHand)
					r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 3))
				return
			u_equip(W)
			r_store = W
		else
	return

/mob/living/carbon/alien/humanoid/update_clothing()
	..()

	if (monkeyizing)
		return

	overlays = null

	if(buckled)
		if(istype(buckled, /obj/stool/bed))
			lying = 1
		else
			lying = 0

	// Automatically drop anything in store / id / belt if you're not wearing a uniform.
	if (zone_sel)
		zone_sel.overlays = null
		zone_sel.overlays += body_standing
		zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", zone_sel.selecting))

	if (lying)
		icon = lying_icon

		overlays += body_lying

		if (face_lying)
			overlays += face_lying
	else
		icon = stand_icon

		overlays += body_standing

		if (face_standing)
			overlays += face_standing

	// Uniform
	if (client)
		client.screen -= hud_used.other
		client.screen -= hud_used.intents
		client.screen -= hud_used.mov_int

	// ???
	if (client && other)
		client.screen += hud_used.other


	if (client)
		if (i_select)
			if (intent)
				client.screen += hud_used.intents

				var/list/L = dd_text2list(intent, ",")
				L[1] += ":-11"
				i_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				i_select.screen_loc = null
		if (m_select)
			if (m_int)
				client.screen += hud_used.mov_int

				var/list/L = dd_text2list(m_int, ",")
				L[1] += ":-11"
				m_select.screen_loc = dd_list2text(L,",") //ICONS4, FUCKING SHIT
			else
				m_select.screen_loc = null

	if (wear_suit)
		var/t1 = wear_suit.item_state
		if (!t1)
			t1 = wear_suit.icon_state
		overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (wear_suit.blood_DNA)
			if (istype(wear_suit, /obj/item/clothing/suit/armor))
				overlays += image("icon" = 'icons/effects/blood.dmi', "icon_state" = "armorblood[!lying ? "" : "2"]", "layer" = MOB_LAYER)
			else
				overlays += image("icon" = 'icons/effects/blood.dmi', "icon_state" = "suitblood[!lying ? "" : "2"]", "layer" = MOB_LAYER)
		wear_suit.screen_loc = ui_iclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (handcuffed)
				handcuffed.loc = loc
				handcuffed.layer = initial(handcuffed.layer)
				handcuffed = null
			if ((l_hand || r_hand))
				var/h = hand
				hand = 1
				drop_item()
				hand = 0
				drop_item()
				hand = h

	// Head
	if (head)
		var/t1 = head.item_state
		if (!t1)
			t1 = head.icon_state
		overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (head.blood_DNA)
			overlays += image("icon" = 'icons/effects/blood.dmi', "icon_state" = "helmetblood[!lying ? "" : "2"]", "layer" = MOB_LAYER)
		head.screen_loc = ui_oclothing

	if (l_store)
		l_store.screen_loc = ui_storage1

	if (r_store)
		r_store.screen_loc = ui_storage2

	if (client)
		client.screen -= contents
		client.screen += contents

	if (r_hand)
		overlays += image("icon" = 'icons/mob/items_righthand.dmi', "icon_state" = r_hand.item_state ? r_hand.item_state : r_hand.icon_state, "layer" = MOB_LAYER+1)

		r_hand.screen_loc = ui_id

	if (l_hand)
		overlays += image("icon" = 'icons/mob/items_lefthand.dmi', "icon_state" = l_hand.item_state ? l_hand.item_state : l_hand.icon_state, "layer" = MOB_LAYER+1)

		l_hand.screen_loc = ui_belt



	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	for (var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 2
			break

	if(client && client.admin_invis)
		invisibility = 100
	else if (shielded == 2 || alien_invis)
		invisibility = 2
	else
		invisibility = 0

	if (shielded || alien_invis)
		overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				show_inv(M)
				return

	last_b_state = stat

/mob/living/carbon/alien/humanoid/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
			bruteloss  += rand(1, 3)

			updatehealth()
	return

/mob/living/carbon/alien/humanoid/attack_paw(mob/M as mob)
	if (M.a_intent == "help")
		sleeping = 0
		resting = 0
		if (paralysis >= 3) paralysis -= 3
		if (stunned >= 3) stunned -= 3
		if (weakened >= 3) weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue The alien shakes [src] trying to wake him up!", ), 1)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has bit [src]!</B>"), 1)
			bruteloss  += rand(1, 3)

			updatehealth()
	return

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

/*Removed stungloves as they are dodgy weapons :3. -CN
	if ((M.gloves && M.gloves.elecgen == 1 && M.a_intent == "hurt") /*&& (!istype(src:wear_suit, /obj/item/clothing/suit/judgerobe))*/)
		if(M.gloves.uses > 0)
			M.gloves.uses--
			if (weakened < 5)
				weakened = 5
			if (stuttering < 5)
				stuttering = 5
			if (stunned < 5)
				stunned = 5
			for(var/mob/O in viewers(src, null))
				if (O.client)
					O.show_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>", 1, "\red You hear someone fall", 2)
		else
			M.gloves.elecgen = 0
			M << "\red Not enough charge! "
			return*/

	if (M.a_intent == "help")
		if (health > 0)
			sleeping = 0
			resting = 0
			if (paralysis >= 3) paralysis -= 3
			if (stunned >= 3) stunned -= 3
			if (weakened >= 3) weakened -= 3
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\blue [] shakes [] trying to wake [] up!", M, src, src), 1)
		else
			if (M.health >= -75.0)
				if (((M.head && M.head.flags & 4) || ((M.wear_mask && !( M.wear_mask.flags & 32 )) || ((head && head.flags & 4) || (wear_mask && !( wear_mask.flags & 32 ))))))
					M << "\blue <B>Remove that mask!</B>"
					return
				var/obj/equip_e/human/O = new /obj/equip_e/human(  )
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = loc
				O.place = "CPR"
				requests += O
				spawn( 0 )
					O.process()
					return
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt" && !(M.gloves && M.gloves.elecgen == 1))
				var/damage = rand(1, 9)
				if (prob(90))
					if (M.mutations & 8)
						damage += 5
						spawn(0)
							paralysis += 1
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)
					if (damage > 4.9)
						if (weakened < 10)
							weakened = rand(10, 15)
						for(var/mob/O in viewers(M, null))
							O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
					bruteloss += damage


					updatehealth()
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				if (!( lying ) && !(M.gloves && M.gloves.elecgen == 1))
					var/randn = rand(1, 100)
					if (randn <= 25)
						weakened = 2
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has pushed down []!</B>", M, src), 1)
					else
						if (randn <= 60)
							drop_item()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has disarmed []!</B>", M, src), 1)
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has attempted to disarm []!</B>", M, src), 1)
	return

/* aliens attacking each other!!
/mob/living/carbon/alien/humanoid/attack_alien()
//todo, put code here
	return
*/


/mob/living/carbon/alien/humanoid/restrained()
	if (handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? text("[]", l_hand) : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? text("[]", r_hand) : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head ? text("[]", head) : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit ? text("[]", wear_suit) : "Nothing")]</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return



