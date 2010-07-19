
/atom/proc/MouseDrop_T()
	return

/atom/proc/attack_hand(mob/user as mob)
	return

/atom/proc/attack_paw(mob/user as mob)
	return

/atom/proc/attack_ai(mob/user as mob)
	return

//for aliens, it works the same as monkeys except for alien-> mob interactions which will be defined in the
//appropiate mob files
/atom/proc/attack_alien(mob/user as mob)
	src.attack_paw(user)
	return

/atom/proc/hand_h(mob/user as mob)
	return

/atom/proc/hand_p(mob/user as mob)
	return

/atom/proc/hand_a(mob/user as mob)
	return

/atom/proc/hand_al(mob/user as mob)
	src.hand_p(user)
	return


/atom/proc/hitby(atom/movable/AM as mob|obj)
	return

/atom/proc/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/device/detective_scanner))
		for(var/mob/O in viewers(src, null))
			if ((O.client && !( O.blinded )))
				O << text("\red [src] has been scanned by [user] with the [W]")
	else
		if (!( istype(W, /obj/item/weapon/grab) ) || !(istype(W, /obj/item/weapon/cleaner)))
			for(var/mob/O in viewers(src, null))
				if ((O.client && !( O.blinded )))
					O << text("\red <B>[] has been hit by [] with []</B>", src, user, W)
	return

/atom/proc/add_fingerprint(mob/living/carbon/human/M as mob)
	if ((!( istype(M, /mob/living/carbon/human) ) || !( istype(M.dna, /datum/dna) )))
		return 0
	if (!( src.flags ) & 256)
		return
	if (M.gloves)
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += text("(Wearing gloves). Real name: [], Key: []",M.real_name, M.key)
			src.fingerprintslast = M.key
		return 0
	if (!( src.fingerprints ))
		src.fingerprints = text("[]", md5(M.dna.uni_identity))
		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += text("Real name: [], Key: []",M.real_name, M.key)
			src.fingerprintslast = M.key
		return 1
	else
		var/list/L = params2list(src.fingerprints)
		L -= md5(M.dna.uni_identity)
		while(L.len >= 3)
			L -= L[1]
		L += md5(M.dna.uni_identity)
		src.fingerprints = list2params(L)

		if(src.fingerprintslast != M.key)
			src.fingerprintshidden += text("Real name: [], Key: []",M.real_name, M.key)
			src.fingerprintslast = M.key
	return

/atom/proc/add_blood(mob/living/carbon/human/M as mob)
	if (!( istype(M, /mob/living/carbon/human) ))
		return 0
	if (!( src.flags ) & 256)
		return
	if (!( src.blood_DNA ))
		if (istype(src, /obj/item))
			var/obj/item/source2 = src
			source2.icon_old = src.icon
			var/icon/I = new /icon(src.icon, src.icon_state)
			I.Blend(new /icon('blood.dmi', "thisisfuckingstupid"),ICON_ADD)
			I.Blend(new /icon('blood.dmi', "itemblood"),ICON_MULTIPLY)
			I.Blend(new /icon(src.icon, src.icon_state),ICON_UNDERLAY)
			src.icon = I
			src.blood_DNA = M.dna.unique_enzymes
			src.blood_type = M.b_type
		else if (istype(src, /turf/simulated))
			var/turf/simulated/source2 = src
			var/list/objsonturf = range(0,src)
			var/i
			for(i=1, i<=objsonturf.len, i++)
				if(istype(objsonturf[i],/obj/decal/cleanable/blood))
					return
			var/obj/decal/cleanable/blood/this = new /obj/decal/cleanable/blood(source2)
			this.blood_DNA = M.dna.unique_enzymes
			this.blood_type = M.b_type
			this.virus = M.virus
		else if (istype(src, /mob/living/carbon/human))
			src.blood_DNA = M.dna.unique_enzymes
			src.blood_type = M.b_type
		else
			return
	else
		var/list/L = params2list(src.blood_DNA)
		L -= M.dna.unique_enzymes
		while(L.len >= 3)
			L -= L[1]
		L += M.dna.unique_enzymes
		src.blood_DNA = list2params(L)
	return

/atom/proc/clean_blood()

	if (!( src.flags ) & 256)
		return
	if ( src.blood_DNA )
		if (istype (src, /obj/item))
			var/obj/item/source2 = src
			source2.blood_DNA = null
			var/icon/I = new /icon(source2.icon_old, source2.icon_state)
			source2.icon = I
		else if (istype(src, /turf/simulated))
			var/obj/item/source2 = src
			source2.blood_DNA = null
			var/icon/I = new /icon(source2.icon_old, source2.icon_state)
			source2.icon = I
	return

/atom/MouseDrop(atom/over_object as mob|obj|turf|area)
	spawn( 0 )
		if (istype(over_object, /atom))
			over_object.MouseDrop_T(src, usr)
		return
	..()
	return

/atom/Click(location,control,params)
	//world << "atom.Click() on [src] by [usr] : src.type is [src.type]"

	if(usr.client.buildmode)
		build_click(usr, usr.client.buildmode, location, control, params, src)
		return

	return DblClick()

/atom/DblClick() //TODO: DEFERRED: REWRITE
	if (world.time <= usr:lastDblClick+2)
		//world << "BLOCKED atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		return
	else
		//world << "atom.DblClick() on [src] by [usr] : src.type is [src.type]"
		usr:lastDblClick = world.time

	..()

	usr.log_m("Clicked on [src]")

	if(usr.in_throw_mode)
		return usr:throw_item(src)

	var/obj/item/W = usr.equipped()

	if(istype(usr, /mob/living/silicon/robot))
		var/count
		var/list/objects = list()
		if(usr:module_state_1)
			objects += usr:module_state_1
			count++
		if(usr:module_state_2)
			objects += usr:module_state_2
			count++
		if(usr:module_state_3)
			objects += usr:module_state_3
			count++
		if(count > 1)
			var/input = input("Please, select an item!", "Item", null, null) as obj in objects
			W = input
		else if(count != 0)
			for(var/obj in objects)
				W = obj
		else if(count == 0)
			W = null

	if (W == src && usr.stat == 0)
		spawn (0)
			W.attack_self(usr)
		return

	if (((usr.paralysis || usr.stunned || usr.weakened) && !istype(usr, /mob/living/silicon/ai)) || usr.stat != 0)
		return

	if ((!( src in usr.contents ) && (((!( isturf(src) ) && (!( isturf(src.loc) ) && (src.loc && !( isturf(src.loc.loc) )))) || !( isturf(usr.loc) )) && (src.loc != usr.loc && (!( istype(src, /obj/screen) ) && !( usr.contents.Find(src.loc) ))))))
		return

	var/t5 = in_range(src, usr) || src.loc == usr

	if (istype(usr, /mob/living/silicon/ai))
		t5 = 1

	if (istype(usr, /mob/living/silicon/robot) && W == null)
		t5 = 1

	if (istype(src, /datum/organ) && src in usr.contents)
		return

	if (((t5 || (W && (W.flags & 16))) && !( istype(src, /obj/screen) )))
		if (usr.next_move < world.time)
			usr.prev_move = usr.next_move
			usr.next_move = world.time + 10
		else
			return
		if ((src.loc && (get_dist(src, usr) < 2 || src.loc == usr.loc)))
			var/direct = get_dir(usr, src)
			var/obj/item/weapon/dummy/D = new /obj/item/weapon/dummy( usr.loc )
			var/ok = 0
			if ( (direct - 1) & direct)
				var/turf/Step_1
				var/turf/Step_2
				switch(direct)
					if(5.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, EAST)

					if(6.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, EAST)

					if(9.0)
						Step_1 = get_step(usr, NORTH)
						Step_2 = get_step(usr, WEST)

					if(10.0)
						Step_1 = get_step(usr, SOUTH)
						Step_2 = get_step(usr, WEST)

					else
				if(Step_1 && Step_2)
					var/check_1 = 0
					var/check_2 = 0
					if(step_to(D, Step_1))
						check_1 = 1
						for(var/obj/border_obstacle in Step_1)
							if(border_obstacle.flags & ON_BORDER)
								if(!border_obstacle.CheckExit(D, src))
									check_1 = 0
						for(var/obj/border_obstacle in get_turf(src))
							if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
								if(!border_obstacle.CanPass(D, D.loc, 1, 0))
									check_1 = 0

					D.loc = usr.loc
					if(step_to(D, Step_2))
						check_2 = 1

						for(var/obj/border_obstacle in Step_2)
							if(border_obstacle.flags & ON_BORDER)
								if(!border_obstacle.CheckExit(D, src))
									check_2 = 0
						for(var/obj/border_obstacle in get_turf(src))
							if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
								if(!border_obstacle.CanPass(D, D.loc, 1, 0))
									check_2 = 0
					if(check_1 || check_2)
						ok = 1
			else
				if(loc == usr.loc)
					ok = 1
				else
					ok = 1

					//Now, check objects to block exit that are on the border
					for(var/obj/border_obstacle in usr.loc)
						if(border_obstacle.flags & ON_BORDER)
							if(!border_obstacle.CheckExit(D, src))
								ok = 0

					//Next, check objects to block entry that are on the border
					for(var/obj/border_obstacle in get_turf(src))
						if((border_obstacle.flags & ON_BORDER) && (src != border_obstacle))
							if(!border_obstacle.CanPass(D, D.loc, 1, 0))
								ok = 0

			del(D)
			if (!( ok ))

				return 0

		if (!( usr.restrained() ))
			if (W)
				if (t5)
					src.alog(W,usr)
					src.attackby(W, usr)
				if (W)
					W.afterattack(src, usr, (t5 ? 1 : 0))
			else
				if (istype(usr, /mob/living/carbon/human))
					src.attack_hand(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/monkey))
						src.attack_paw(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/alien/humanoid))
							src.attack_alien(usr, usr.hand)
						else
							if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
								src.attack_ai(usr, usr.hand)
		else
			if (istype(usr, /mob/living/carbon/human))
				src.hand_h(usr, usr.hand)
			else
				if (istype(usr, /mob/living/carbon/monkey))
					src.hand_p(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/alien/humanoid))
						src.hand_al(usr, usr.hand)
					else
						if (istype(usr, /mob/living/silicon/ai) || istype(usr, /mob/living/silicon/robot))
							src.hand_a(usr, usr.hand)

	else
		if (istype(src, /obj/screen))
			usr.prev_move = usr.next_move
			if (usr.next_move < world.time)
				usr.next_move = world.time + 10
			else
				return
			if (!( usr.restrained() ))
				if ((W && !( istype(src, /obj/screen) )))
					src.alog(W,usr)
					src.attackby(W, usr)

					if (W)
						W.afterattack(src, usr)
				else
					if (istype(usr, /mob/living/carbon/human))
						src.attack_hand(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/monkey))
							src.attack_paw(usr, usr.hand)
						else
							if (istype(usr, /mob/living/carbon/alien/humanoid))
								src.attack_alien(usr, usr.hand)
			else
				if (istype(usr, /mob/living/carbon/human))
					src.hand_h(usr, usr.hand)
				else
					if (istype(usr, /mob/living/carbon/monkey))
						src.hand_p(usr, usr.hand)
					else
						if (istype(usr, /mob/living/carbon/alien/humanoid))
							src.hand_al(usr, usr.hand)
	return

/atom/proc/alog(var/atom/device,var/mob/mb)
	src.logs += "[src.name] used by a [device.name] by [mb.real_name]([mb.key])"
	mb.log_m("[src.name] used by a [device.name]")



/atom/proc/addoverlay(var/icon/overlay)
	src.overlaylist += overlay
	src.overlays += overlay

/atom/proc/removeoverlay(var/icon/overlay)
	src.overlaylist -= overlay
	src.overlays -= overlay