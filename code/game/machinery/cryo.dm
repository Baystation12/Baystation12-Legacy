/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'Cryogenic2.dmi'
	icon_state = "celltop-P"
	density = 1
	anchored = 1.0
	layer = 5
	flags = FPRINT | NOSPLASH

	var/on = 0
	var/temperature_archived
	var/obj/overlay/O1 = null
	var/mob/occupant = null
	var/beaker = null
	var/next_trans = 0

	var/current_heat_capacity = 50



	New()

		..()
		build_icon()
		initialize_directions = SOUTH

	initialize()
		if(node) return
		var/node_connect = SOUTH
		for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
			if(target.initialize_directions & get_dir(target,src))
				node = target
				break

	process()
		..()
		if(!node)
			return
		if(!on)
			src.updateUsrDialog()
			return

		if(src.occupant)
			if(occupant.stat != 2)
				process_occupant()

		if(air_contents)
			temperature_archived = air_contents.temperature
			//heat_gas_contents()
			expel_gas()

		if(abs(temperature_archived-air_contents.temperature) > 1)
			network.update = 1

		src.updateUsrDialog()
		return 1


	/*allow_drop()
		return 0*/


	relaymove(mob/user as mob)
		if(user.stat)
			return
		src.go_out()
		return

	attack_hand(mob/user as mob)
		user.machine = src
		var/beaker_text = ""
		var/health_text = ""
		var/temp_text = ""
		if(src.occupant)
			if(src.occupant.health <= -100)
				health_text = "<FONT color=red>Dead</FONT>"
			else if(src.occupant.health < 0)
				health_text = "<FONT color=red>[src.occupant.health]</FONT>"
			else
				health_text = "[src.occupant.health]"
		if(air_contents.temperature > T0C)
			temp_text = "<FONT color=red>[air_contents.temperature]</FONT>"
		else if(air_contents.temperature > 225)
			temp_text = "<FONT color=black>[air_contents.temperature]</FONT>"
		else
			temp_text = "<FONT color=blue>[air_contents.temperature]</FONT>"
		if(src.beaker)
			beaker_text = "<B>Beaker:</B> <A href='?src=\ref[src];eject=1'>Eject</A>"
		else
			beaker_text = "<B>Beaker:</B> <FONT color=red>No beaker loaded</FONT>"
		var/dat = {"<B>Cryo cell control system</B><BR>
			<B>Current cell temperature:</B> [temp_text]K<BR>
			<B>Cryo status:</B> [ src.on ? "<A href='?src=\ref[src];start=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];start=1'>On</A>"]<BR>
			[beaker_text]<BR><BR>
			<B>Current occupant:</B> [src.occupant ? "<BR>Name: [src.occupant]<BR>Health: [health_text]<BR>Oxygen deprivation: [src.occupant.oxyloss]<BR>Brute damage: [src.occupant.bruteloss]<BR>Fire damage: [src.occupant.fireloss]<BR>Toxin damage: [src.occupant.toxloss]<BR>Body temperature: [src.occupant.bodytemperature]" : "<FONT color=red>None</FONT>"]<BR>

		"}

		user << browse(dat, "window=cryo")
		onclose(user, "cryo")

	Topic(href, href_list)
		if (( usr.machine==src && ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
			if(href_list["start"])
				src.on = !src.on
				build_icon()
			if(href_list["eject"])
				beaker:loc = src.loc
				beaker = null

			src.updateUsrDialog()
			src.add_fingerprint(usr)
			return

	attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
		if(istype(G, /obj/item/weapon/reagent_containers/glass))
			if(src.beaker)
				user << "A beaker is already loaded into the machine."
				return

			src.beaker =  G
			user.drop_item()
			G.loc = src
			user.visible_message("[user] adds a beaker to \the [src]!", "You add a beaker to the [src]!")
		else if(istype(G, /obj/item/weapon/grab))
			if(!ismob(G:affecting))
				return
			if (src.occupant)
				user << "\blue <B>The cryo cell is already occupied!</B>"
				return
			if (G:affecting.abiotic())
				user << "Subject may not have abiotic items on."
				return
			var/mob/M = G:affecting
			if (M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src
			M.loc = src
			src.occupant = M
			src.add_fingerprint(user)
			build_icon()
			del(G)
		src.updateUsrDialog()
		return

	proc
		add_overlays()
			src.addalloverlays(list(O1))

		build_icon()
			if(on)
				if(src.occupant)
					icon_state = "celltop_1"
				else
					icon_state = "celltop"
			else
				icon_state = "celltop-p"
			O1 = new /obj/overlay(  )
			O1.icon = 'Cryogenic2.dmi'
			if(src.node)
				O1.icon_state = "cryo_bottom_[src.on]"
			else
				O1.icon_state = "cryo_bottom"
			O1.pixel_y = -32.0
			src.pixel_y = 32
			add_overlays()

		process_occupant()
			if(air_contents.total_moles() < 10)
				return
			if(occupant)
				if(occupant.stat == 2)
					return
				occupant.bodytemperature += 2*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + air_contents.heat_capacity())
				occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
				occupant.stat = 1
				if(occupant.bodytemperature < T0C)
					occupant.sleeping = max(5, (1/occupant.bodytemperature)*2000)
					occupant.paralysis += 0.5
					if(air_contents.oxygen > 2)
						if(occupant.oxyloss) occupant.oxyloss = max(0, occupant.oxyloss - 1)
					else
						occupant.oxyloss -= 1
					if(occupant.bodytemperature < 225)
						if(ishuman(occupant))
							for(var/datum/organ/external/O in occupant:organs2)
								if(!O.destroyed)//FIND BACK
									if(occupant.bruteloss) O.heal_damage(1,0,0)
									if(occupant.fireloss) O.heal_damage(0,1,0)
							if(occupant.toxloss) occupant.toxloss = max(0, occupant.toxloss - 1)
						else
							if(occupant.bruteloss) occupant.bruteloss = max(0, occupant.bruteloss - 1)
							if(occupant.fireloss) occupant.fireloss = max(0, occupant.fireloss - 1)
							if(occupant.toxloss) occupant.toxloss = max(0, occupant.toxloss - 1)
				if(beaker && (next_trans == 0))
					beaker:reagents.trans_to(occupant, 1, 10)
					beaker:reagents.reaction(occupant)
			next_trans++
			if(next_trans == 10)
				next_trans = 0

		heat_gas_contents()
			if(air_contents.total_moles() < 1)
				return
			var/air_heat_capacity = air_contents.heat_capacity()
			var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
			if(combined_heat_capacity > 0)
				var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
				air_contents.temperature = combined_energy/combined_heat_capacity

		expel_gas()
			if(air_contents.total_moles() < 1)
				return
			var/datum/gas_mixture/expel_gas = new
			var/remove_amount = air_contents.total_moles()/100
			expel_gas = air_contents.remove(remove_amount)
			expel_gas.temperature = T20C // Lets expel hot gas and see if that helps people not die as they are removed
			loc.assume_air(expel_gas)

		go_out()
			if(!( src.occupant ))
				return
			//for(var/obj/O in src)
			//	O.loc = src.loc
			if (src.occupant.client)
				src.occupant.client.eye = src.occupant.client.mob
				src.occupant.client.perspective = MOB_PERSPECTIVE
			src.occupant.loc = src.loc
			src.occupant = null
			build_icon()
			return

	verb
		move_eject()
			set src in oview(1)
			if (usr.stat != 0)
				return
			src.go_out()
			add_fingerprint(usr)
			return

		move_inside()
			set src in oview(1)
			if (usr.stat != 0 || stat & (NOPOWER|BROKEN))
				return
			if (src.occupant)
				usr << "\blue <B>The cell is already occupied!</B>"
				return
			if (usr.abiotic())
				usr << "Subject may not have abiotic items on."
				return
			if(!src.node)
				usr << "The cell is not corrrectly connected to its pipe network!"
				return
			usr.pulling = null
			usr.client.perspective = EYE_PERSPECTIVE
			usr.client.eye = src
			usr.loc = src
			src.occupant = usr
			/*for(var/obj/O in src)
				O.loc = src.loc*/
			src.add_fingerprint(usr)
			build_icon()
			return





/mob/living/carbon/human/abiotic()
	if ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.ears || src.gloves || src.handcuffed))
		return 1
	else
		return 0
	return

/mob/proc/abiotic()
	if ((src.l_hand && !( src.l_hand.abstract )) || (src.r_hand && !( src.r_hand.abstract )) || src.back || src.wear_mask || src.handcuffed)
		return 1
	else
		return 0
	return

/datum/data/function/proc/reset()
	return

/datum/data/function/proc/r_input(href, href_list, mob/user as mob)
	return

/datum/data/function/proc/display()
	return