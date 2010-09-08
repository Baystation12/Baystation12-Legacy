/*
Maybe you could combine elements from the Blob mode into a new Alien mode since Blob rarely seems to get much
play these days, is hard as fuck to actually win, and gets more use as a random event these days.

The main Alien's objective is to corrupt, infest, whatever you want to call it to a certain % of the station.
Give it an ability which, every so often allows it to drop a bunch of slime which infests floors and walls. The
main alien would be poor at actually killing anyone, but very difficult to bring down - maybe it is immune to
brute and toxic damage, and fire kills it but takes a long exposure time to do so. Suffocation/exposure would
be the only reliable way to off it.

Like the Wizard, the Alien can select from a few abilities, though they center around building things in the
slime rather than being straight up attacks or spells. For instance, it might be able to build tunnels which
take it instantly from one slime patch to another, or pods which huff poison gas at anyone that gets too close.
It can only build in areas it slimed, and the abilities have long cooldowns. The structures can also be destroyed
by anyone determined enough.

Anyone who stays in the slime for too long will end up becoming a mutant which serves the main alien. This would
give the alien an incentive to try and incapacitate or find incapacitated people to drag back into its
territory to gain more slaves. The mutants are basically just monkeys - crippled with only a few equipment
slots, but share some of the alien's durability.

To get rid of the slime, you can weld it, taze/laser it, set it on fire, blow it up or get the janitor
to clean it up, or just beat the shit out of it (which takes ages).


[11:32] <&Rick> nah dont let it wear clothing
[11:32] <&Rick> but have alien items that replace suit functions
[11:32] <&Rick> like an item that lets them walk around in space with no penalty
[11:32] <&Nannek> yeah cool
[11:33] <&Nannek> thinking making it breathe plasma or would that make the aliens life too hard
[11:33] <&Rick> hmm
[11:33] <&Rick> maybe breathing plasma benefit it
[11:33] <&Rick> but not required
[11:33] <&Nannek> yeah makes them stronger/faster or something
[11:33] <&Rick> like have stamina or something that recharges when the alien is breathing plasma
[11:33] <&Nannek> which in turn lets it uses special alien abilities
[11:34] <&Rick> if theres something the alien should be able to wear
[11:34] <&Rick> is a full human skin body suit
[11:34] <&Nannek> oh
[11:34] <&Rick> make it so you can skin dead people
[11:34] <&Nannek> that could be fun
[11:34] <&Rick> 8)
[11:34] <&Rick> but no clothing even if wearing a human suit
[11:34] <&Nannek> then they can pretend to be the human for a limited time before the suit rips apart
[11:35] <&Rick> yeah
[11:35] <&Nannek> thinking not letting aliens understand humans and vice versa
[11:35] <&Rick> that would be hilarious
[11:35] <&Rick> have a universal translator item
[11:35] <&Rick> so if the alien loses it
[11:35] <&Rick> they lose being able to communicate
[11:35] <&Nannek> kk
*/

//This is fine right now, if we're adding organ specific damage this needs to be updated

/mob/living/carbon/alien/larva/name = "alien larva"
/mob/living/carbon/alien/larva/icon_state = "larva"
/mob/living/carbon/alien/larva/gender = NEUTER
/mob/living/carbon/alien/larva/flags = 258.0
/mob/living/carbon/alien/larva/health_full = 25

/mob/living/carbon/alien/larva/var/amount_grown = 0

/mob/living/carbon/alien/larva/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	if(name == "alien larva") name = text("alien larva ([rand(1, 1000)])")
	real_name = name
	src << "\blue Your icons have been generated!"

	update_clothing()


//This is fine, works the same as a human
/mob/living/carbon/alien/larva/Bump(atom/movable/AM as mob|obj, yes)

	spawn( 0 )
		if ((!( yes ) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && tmob.mutations & 32)
				if(prob(70))
					for(var/mob/M in viewers(src, null))
						if(M.client)
							M << "\red <B>[src] fails to push [tmob]'s fat ass out of the way.</B>"
					now_pushing = 0
					return
		now_pushing = 0
		..()
		if (!( istype(AM, /atom/movable) ))
			return
		if (!( now_pushing ))
			now_pushing = 1
			if (!( AM.anchored ))
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return

//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()

	statpanel("Status")
	if (client && client.holder)
		stat(null, "([x], [y], [z])")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")

	if (client.statpanel == "Status")
		stat(null, "Progress: [amount_grown]/200")
		stat(null, "Plasma Stored: [toxloss]")


//This is okay I guess unless we add alien shields or something. Should be cleaned up a bit.
/mob/living/carbon/alien/larva/bullet_act(flag, A as obj)

	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon.grab/G = r_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting
		if (safe)
			return safe.bullet_act(flag, A)
	if (flag == PROJECTILE_BULLET)
		var/d = 51

		if (stat != 2)
			bruteloss += d

			updatehealth()
			if (prob(50))
				if(weakened <= 5)	weakened = 5
		return
	else if (flag == PROJECTILE_TASER)
		if (prob(75) && stunned <= 10)
			stunned = 10
		else
			weakened = 10
		if (stuttering < 10)
			stuttering = 10
	else if(flag == PROJECTILE_LASER)
		var/d = 20

		if (!eye_blurry) eye_blurry = 4 //This stuff makes no sense but lasers need a buff.
		if (prob(25)) stunned++

		if (stat != 2)
			bruteloss += d

			updatehealth()
			if (prob(25))
				stunned = 1
	else if(flag == PROJECTILE_PULSE)
		var/d = 40

		if (stat != 2)
			bruteloss += d

			updatehealth()
			if (prob(50))
				stunned = min(stunned, 5)
	else if(flag == PROJECTILE_BOLT)
		toxloss += 3
		radiation += 100
		updatehealth()
		stuttering += 5
		drowsyness += 5
	return

/mob/living/carbon/alien/larva/ex_act(severity)
	flick("flash", flash)

	if (stat == 2 && client)
		gib(1)
		return

	else if (stat == 2 && !client)
		gibs(loc, virus)
		del(src)
		return

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			gib(1)
			return

		if (2.0)

			b_loss += 60

			f_loss += 60

			ear_damage += 30
			ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50))
				paralysis += 1
			ear_damage += 15
			ear_deaf += 60

	bruteloss += b_loss
	fireloss += f_loss

	updatehealth()



/mob/living/carbon/alien/larva/blob_act()
	if (stat == 2)
		return
	var/shielded = 0

	var/damage = null
	if (stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("\red The blob attacks you!")

	bruteloss += damage

	updatehealth()
	return

//can't unequip since it can't equip anything
/mob/living/carbon/alien/larva/u_equip(obj/item/W as obj)
	return

//can't equip anything
/mob/living/carbon/alien/larva/db_click(text, t1)
	return

/mob/living/carbon/alien/larva/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		bruteloss += (istype(O, /obj/meteor/small) ? 10 : 25)
		fireloss += 30

		updatehealth()
	return

/mob/living/carbon/alien/larva/Move(a, b, flag)

	var/t7 = 1
	if (restrained())
		for(var/mob/M in range(src, 1))
			if ((M.pulling == src && M.stat == 0 && !( M.restrained() )))
				t7 = null
	if ((t7 && (pulling && ((get_dist(src, pulling) <= 1 || pulling.loc == loc) && (client && client.moving)))))
		var/turf/T = loc
		. = ..()

		if (pulling && pulling.loc)
			if(!( isturf(pulling.loc) ))
				pulling = null
				return
			else
				if(Debug)
					check_diary()
					diary <<"pulling disappeared? at __LINE__ in mob.dm - pulling = [pulling]"
					diary <<"REPORT THIS"

		/////
		if(pulling && pulling.anchored)
			pulling = null
			return

		if (!restrained())
			var/diag = get_dir(src, pulling)
			if ((diag - 1) & diag)
			else
				diag = null
			if ((get_dist(src, pulling) > 1 || diag))
				if (ismob(pulling))
					var/mob/M = pulling
					var/ok = 1
					if (locate(/obj/item/weapon/grab, M.grabbed_by))
						if (prob(75))
							var/obj/item/weapon/grab/G = pick(M.grabbed_by)
							if (istype(G, /obj/item/weapon/grab))
								for(var/mob/O in viewers(M, null))
									O.show_message(text("\red [] has been pulled from []'s grip by []", G.affecting, G.assailant, src), 1)
								//G = null
								del(G)
						else
							ok = 0
						if (locate(/obj/item/weapon/grab, M.grabbed_by.len))
							ok = 0
					if (ok)
						var/t = M.pulling
						M.pulling = null
						step(pulling, get_dir(pulling.loc, T))
						M.pulling = t
				else
					if (pulling)
						step(pulling, get_dir(pulling.loc, T))
	else
		pulling = null
		. = ..()
	if ((s_active && !( s_active in contents ) ))
		s_active.close(src)
	return

/mob/living/carbon/alien/larva/update_clothing()
	..()

	if (monkeyizing)
		return


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

	if(client && client.admin_invis)
		invisibility = 100
	else if (alien_invis)
		invisibility = 2
	else
		invisibility = 0

	if (alien_invis)
		overlays += image("icon" = 'mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src))
			spawn (0)
				show_inv(M)
				return


/mob/living/carbon/alien/larva/hand_p(mob/M as mob)
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
			var/damage = rand(1, 3)

			bruteloss += damage

			updatehealth()

	return

/mob/living/carbon/alien/larva/attack_paw(mob/M as mob)
	if (M.a_intent == "help")
		sleeping = 0
		resting = 0
		if (paralysis >= 3) paralysis -= 3
		if (stunned >= 3) stunned -= 3
		if (weakened >= 3) weakened -= 3
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue The monkey shakes [src] trying to wake him up!", ), 1)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)

			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red <B>[M.name] has bit [src]!</B>"), 1)
			var/damage = rand(1, 3)

			bruteloss += damage

			updatehealth()
	return

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

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
			return

	if (M.a_intent == "help")
		if (health > 0)
			sleeping = 0
			resting = 0
			if (paralysis >= 3) paralysis -= 3
			if (stunned >= 3) stunned -= 3
			if (weakened >= 3) weakened -= 3
			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\blue [] shakes [] trying to wake [] up!", M, src, src), 1)
		else
			if (M.health >= -75.0)
				if ((M.head && M.head.flags & 4) || (M.wear_mask && !( M.wear_mask.flags & 32 )) )
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
			playsound(loc, 'thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt" && !(M.gloves && M.gloves.elecgen == 1))
				var/damage = rand(1, 9)

				if (prob(90))
					if (M.mutations & 8 && prob(90))
						damage += 5
						spawn(0)
							paralysis += 1
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has punched []!</B>", M, src), 1)

					bruteloss += damage

					updatehealth()
				else
					playsound(loc, 'punchmiss.ogg', 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has attempted to punch []!</B>", M, src), 1)
					return
			else
				return
	return

/*
/mob/living/carbon/alien/larva/attack_alien()
//todo, put code here
	return
*/





/mob/living/carbon/alien/larva/restrained()
	return 0

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/alien/larva/show_inv(mob/user as mob)

	user.machine = src
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR><BR>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return

