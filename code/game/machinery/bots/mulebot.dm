// Mulebot - carries crates around for Quartermaster
// Navigates via floor navbeacons
// Remote Controlled from QM's PDA


/obj/machinery/bot/mulebot
	name = "Mulebot"
	desc = "A Multiple Utility Load Effector bot."
	icon_state = "mulebot0"
	layer = MOB_LAYER
	density = 1
	anchored = 1
	animate_movement=1
	var/locked = 1
	var/atom/movable/load = null		// the loaded crate (usually)

	var/beacon_freq = 1445
	var/control_freq = 1447

	suffix = ""

	var/turf/target				// this is turf to navigate to (location of beacon)
	var/loaddir = 0				// this the direction to unload onto/load from
	var/new_destination = ""	// pending new destination (waiting for beacon response)
	var/destination = ""		// destination description
	var/home_destination = "" 	// tag of home beacon
	req_access = list(access_cargo, access_cargo_bot)

	var/mode = 0		//0 = idle/ready
						//1 = loading/unloading
						//2 = moving to deliver
						//3 = returning to home
						//4 = blocked
						//5 = computing navigation
						//6 = waiting for nav computation
						//7 = no destination beacon found (or no route)

	var/blockcount	= 0		//number of times retried a blocked path
	var/reached_target = 1 	//true if already reached the target

	var/refresh = 1		// true to refresh dialogue
	var/auto_return = 1	// true if auto return to home beacon after unload
	var/auto_pickup = 1 // true if auto-pickup at beacon

	var/open = 0		// true if maint hatch is open
	var/obj/item/weapon/cell/cell
						// the installed power cell

	// constants for internal wiring bitflags
	var/const
		wire_power1 = 1			// power connections
		wire_power2 = 2
		wire_mobavoid = 4		// mob avoidance
		wire_loadcheck = 8		// load checking (non-crate)
		wire_motor1 = 16		// motor wires
		wire_motor2 = 32		//
		wire_remote_rx = 64		// remote recv functions
		wire_remote_tx = 128	// remote trans status
		wire_beacon_rx = 256	// beacon ping recv
		wire_beacon_tx = 512	// beacon ping trans

	var/wires = 1023		// all flags on

	var/list/wire_text	// list of wire colours
	var/list/wire_order	// order of wire indices


	var/bloodiness = 0		// count of bloodiness

	New()
		..()
		botcard = new(src)
		botcard.access = get_access("Quartermaster")
		cell = new(src)
		cell.charge = 2000
		cell.maxcharge = 2000
		setup_wires()

		spawn(5)	// must wait for map loading to finish
			if(radio_controller)
				radio_controller.add_object(src, "[control_freq]")
				radio_controller.add_object(src, "[beacon_freq]")

			var/count = 0
			for(var/obj/machinery/bot/mulebot/other in world)
				count++
			if(!suffix)
				suffix = "#[count]"
			name = "Mulebot ([suffix])"

		verbs -= /atom/movable/verb/pull


	// set up the wire colours in random order
	// and the random wire display order
	// needs 10 wire colours
	proc/setup_wires()
		var/list/colours = list("Red", "Green", "Blue", "Magenta", "Cyan", "Yellow", "Black", "White", "Orange", "Grey")
		var/list/orders = list("0","1","2","3","4","5","6","7","8","9")
		wire_text = list()
		wire_order = list()
		while(colours.len > 0)
			var/colour = colours[ rand(1,colours.len) ]
			wire_text += colour
			colours -= colour

			var/order = orders[ rand(1,orders.len) ]
			wire_order += text2num(order)
			orders -= order



	// attack by item
	// emag : lock/unlock,
	// screwdriver: open/close hatch
	// cell: insert it
	// other: chance to knock rider off bot
	attackby(var/obj/item/I, var/mob/user)
		if(istype(I,/obj/item/weapon/card/emag))
			locked = !locked
			user << "\blue You [locked ? "lock" : "unlock"] the mulebot's controls!"
			flick("mulebot-emagged", src)
			playsound(src.loc, 'sparks1.ogg', 100, 0)
		else if(istype(I,/obj/item/weapon/cell) && open && !cell)
			var/obj/item/weapon/cell/C = I
			user.drop_item()
			C.loc = src
			cell = C
			updateDialog()
		else if(istype(I,/obj/item/weapon/screwdriver))
			if(locked)
				user << "\blue The maintenance hatch cannot be opened or closed while the controls are locked."
				return

			open = !open
			if(open)
				src.visible_message("[user] opens the maintenance hatch of [src]", "\blue You open [src]'s maintenance hatch.")
				on = 0
				icon_state="mulebot-hatch"
			else
				src.visible_message("[user] closes the maintenance hatch of [src]", "\blue You close [src]'s maintenance hatch.")
				icon_state = "mulebot0"

			updateDialog()
		else if(load && ismob(load))  // chance to knock off rider
			if(prob(1+I.force * 2))
				unload(0)
				user.visible_message("\red [user] knocks [load] off [src] with \the [I]!", "\red You knock [load] off [src] with \the [I]!")
			else
				user << "You hit [src] with \the [I] but to no effect."
		else
			..()
		return


	ex_act(var/severity)
		unload(0)
		switch(severity)
			if(1)
				del(src)
			if(2)
				wires &= ~(1 << rand(0,9))
				wires &= ~(1 << rand(0,9))
				wires &= ~(1 << rand(0,9))
			if(3)
				wires &= ~(1 << rand(0,9))

		return

	bullet_act()
		if(prob(50))
			load.bullet_act()
			unload(0)
		if(prob(25))
			src.visible_message("Something shorts out inside [src]!")
			var/index = 1<< (rand(0,9))
			if(wires & index)
				wires &= ~index
			else
				wires |= index


	attack_ai(var/mob/user)
		interact(user, 1)

	attack_hand(var/mob/user)
		interact(user, 0)

	proc/interact(var/mob/user, var/ai=0)
		var/dat
		dat += "<TT><B>Multiple Utility Load Effector Mk. III</B></TT><BR><BR>"
		dat += "ID: [suffix]<BR>"
		dat += "Power: [on ? "On" : "Off"]<BR>"

		if(!open)

			dat += "Status: "
			switch(mode)
				if(0)
					dat += "Ready"
				if(1)
					dat += "Loading/Unloading"
				if(2)
					dat += "Navigating to Delivery Location"
				if(3)
					dat += "Navigating to Home"
				if(4)
					dat += "Waiting for clear path"
				if(5,6)
					dat += "Calculating navigation path"
				if(7)
					dat += "Unable to locate destination"


			dat += "<BR>Current Load: [load ? load.name : "<i>none</i>"]<BR>"
			dat += "Destination: [!destination ? "<i>none</i>" : destination]<BR>"
			dat += "Power level: [cell ? cell.percent() : 0]%<BR>"

			if(locked && !ai)
				dat += "<HR>Controls are locked <A href='byond://?src=\ref[src];op=unlock'><I>(unlock)</I></A>"
			else
				dat += "<HR>Controls are unlocked <A href='byond://?src=\ref[src];op=lock'><I>(lock)</I></A><BR><BR>"

				dat += "<A href='byond://?src=\ref[src];op=power'>Toggle Power</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=stop'>Stop</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=go'>Proceed</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=home'>Return to Home</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=destination'>Set Destination</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=setid'>Set Bot ID</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=sethome'>Set Home</A><BR>"
				dat += "<A href='byond://?src=\ref[src];op=autoret'>Toggle Auto Return Home</A> ([auto_return ? "On":"Off"])<BR>"
				dat += "<A href='byond://?src=\ref[src];op=autopick'>Toggle Auto Pickup Crate</A> ([auto_pickup ? "On":"Off"])<BR>"

				if(load)
					dat += "<A href='byond://?src=\ref[src];op=unload'>Unload Now</A><BR>"
				dat += "<HR>The maintenance hatch is closed.<BR>"

		else
			if(!ai)
				dat += "The maintenance hatch is open.<BR><BR>"
				dat += "Power cell: "
				if(cell)
					dat += "<A href='byond://?src=\ref[src];op=cellremove'>Installed</A><BR>"
				else
					dat += "<A href='byond://?src=\ref[src];op=cellinsert'>Removed</A><BR>"

				dat += wires()
			else
				dat += "The bot is in maintenance mode and cannot be controlled.<BR>"

		user << browse("<HEAD><TITLE>Mulebot [suffix ? "([suffix])" : ""]</TITLE></HEAD>[dat]", "window=mulebot;size=350x500")
		onclose(user, "mulebot")
		return

	// returns the wire panel text
	proc/wires()
		var/t = ""
		for(var/i = 0 to 9)
			var/index = 1<<wire_order[i+1]
			t += "[wire_text[i+1]] wire: "
			if(index & wires)
				t += "<A href='byond://?src=\ref[src];op=wirecut;wire=[index]'>(cut)</A> <A href='byond://?src=\ref[src];op=wirepulse;wire=[index]'>(pulse)</A><BR>"
			else
				t += "<A href='byond://?src=\ref[src];op=wiremend;wire=[index]'>(mend)</A><BR>"

		return t




	Topic(href, href_list)
		if(..())
			return
		if (usr.stat)
			return
		if ((in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
			usr.machine = src

			switch(href_list["op"])
				if("lock", "unlock")
					if(src.allowed(usr))
						locked = !locked
						updateDialog()
					else
						usr << "\red Access denied."
						return
				if("power")
					on = !on
					if(!cell || open)
						on = 0
						return
					usr << "You switch [on ? "on" : "off"] [src]."
					for(var/mob/M in viewers(src))
						if(M==usr) continue
						M << "[usr] switches [on ? "on" : "off"] [src]."
					updateDialog()


				if("cellremove")
					if(open && cell && !usr.equipped())
						cell.loc = usr
						cell.layer = 20
						if(usr.hand)
							usr.l_hand = cell
						else
							usr.r_hand = cell

						cell.add_fingerprint(usr)
						cell.updateicon()
						cell = null

						usr.visible_message("\blue [usr] removes the power cell from [src].", "\blue You remove the power cell from [src].")
						updateDialog()

				if("cellinsert")
					if(open && !cell)
						var/obj/item/weapon/cell/C = usr.equipped()
						if(istype(C))
							usr.drop_item()
							cell = C
							C.loc = src
							C.add_fingerprint(usr)

							usr.visible_message("\blue [usr] inserts a power cell into [src].", "\blue You insert the power cell into [src].")
							updateDialog()


				if("stop")
					if(mode >=2)
						mode = 0
						updateDialog()

				if("go")
					if(mode == 0)
						start()
						updateDialog()

				if("home")
					if(mode == 0 || mode == 2)
						start_home()
						updateDialog()

				if("destination")
					refresh=0
					var/new_dest = input("Enter new destination tag", "Mulebot [suffix ? "([suffix])" : ""]", destination) as text|null
					refresh=1
					if(new_dest)
						set_destination(new_dest)


				if("setid")
					refresh=0
					var/new_id = input("Enter new bot ID", "Mulebot [suffix ? "([suffix])" : ""]", suffix) as text|null
					refresh=1
					if(new_id)
						suffix = new_id
						name = "Mulebot ([suffix])"
						updateDialog()

				if("sethome")
					refresh=0
					var/new_home = input("Enter new home tag", "Mulebot [suffix ? "([suffix])" : ""]", home_destination) as text|null
					refresh=1
					if(new_home)
						home_destination = new_home
						updateDialog()

				if("unload")
					if(load && mode !=1)
						if(loc == target)
							unload(loaddir)
						else
							unload(0)

				if("autoret")
					auto_return = !auto_return

				if("autopick")
					auto_pickup = !auto_pickup

				if("close")
					usr.machine = null
					usr << browse(null,"window=mulebot")


				if("wirecut")
					if(istype(usr.equipped(), /obj/item/weapon/wirecutters))
						var/wirebit = text2num(href_list["wire"])
						wires &= ~wirebit
					else
						usr << "\blue You need wirecutters!"
				if("wiremend")
					if(istype(usr.equipped(), /obj/item/weapon/wirecutters))
						var/wirebit = text2num(href_list["wire"])
						wires |= wirebit
					else
						usr << "\blue You need wirecutters!"

				if("wirepulse")
					if(istype(usr.equipped(), /obj/item/device/multitool))
						switch(href_list["wire"])
							if("1","2")
								usr << "\blue \icon[src] The charge light flickers."
							if("4")
								usr << "\blue \icon[src] The external warning lights flash briefly."
							if("8")
								usr << "\blue \icon[src] The load platform clunks."
							if("16", "32")
								usr << "\blue \icon[src] The drive motor whines briefly."
							else
								usr << "\blue \icon[src] You hear a radio crackle."
					else
						usr << "\blue You need a multitool!"



			updateDialog()
		else
			usr << browse(null, "window=mulebot")
			usr.machine = null
		return



	// returns true if the bot has power
	proc/has_power()
		return !open && cell && cell.charge>0 && (wires & wire_power1) && (wires & wire_power2)

	// mousedrop a crate to load the bot
	// can load anything if emagged

	MouseDrop_T(var/atom/movable/C, mob/user)

		if(user.stat)
			return

		if (!on || !istype(C)|| C.anchored || get_dist(user, src) > 1 || get_dist(src,C) > 1 )
			return

		if(load)
			return

		load(C)


	// called to load a crate
	proc/load(var/atom/movable/C)
		if((wires & wire_loadcheck) && !istype(C,/obj/crate))
			src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
			playsound(src.loc, 'buzz-sigh.ogg', 50, 0)
			return		// if not emagged, only allow crates to be loaded

		if(get_dist(C, src) > 1 || load || !on)
			return
		mode = 1

		// if a create, close before loading
		var/obj/crate/crate = C
		if(istype(crate))
			crate.close()

		C.loc = src.loc
		sleep(2)
		C.loc = src
		load = C

		C.pixel_y += 9
		if(C.layer < layer)
			C.layer = layer + 0.1
		overlays += C

		if(ismob(C))
			var/mob/M = C
			if(M.client)
				M.client.perspective = EYE_PERSPECTIVE
				M.client.eye = src

		mode = 0
		send_status()

	// called to unload the bot
	// argument is optional direction to unload
	// if zero, unload at bot's location
	proc/unload(var/dirn = 0)
		if(!load)
			return

		mode = 1
		overlays = null

		load.loc = src.loc
		load.pixel_y -= 9
		load.layer = initial(load.layer)
		if(ismob(load))
			var/mob/M = load
			if(M.client)
				M.client.perspective = MOB_PERSPECTIVE
				M.client.eye = src


		if(dirn)
			step(load, dirn)

		load = null

		// in case non-load items end up in contents, dump every else too
		// this seems to happen sometimes due to race conditions
		// with items dropping as mobs are loaded

		for(var/atom/movable/AM in src)
			if(AM == cell || AM == botcard) continue

			AM.loc = src.loc
			AM.layer = initial(AM.layer)
			AM.pixel_y = initial(AM.pixel_y)
			if(ismob(AM))
				var/mob/M = AM
				if(M.client)
					M.client.perspective = MOB_PERSPECTIVE
					M.client.eye = src
		mode = 0


	process()
		if (!src.on)
			return
		if(!has_power())
			on = 0
			return
		var/speed = ((wires & wire_motor1) ? 1:0) + ((wires & wire_motor2) ? 2:0)
		//world << "speed: [speed]"
		switch(speed)
			if(0)
				// do nothing
			if(1)
				process_bot()
				spawn(3)
					process_bot()
					sleep(3)
					process_bot()
			if(2)
				process_bot()
				spawn(5)
					process_bot()
			if(3)
				process_bot()
		if(refresh) updateDialog()

	proc/process_bot()
		//if(mode) world << "Mode: [mode]"
		switch(mode)
			if(0)		// idle
				icon_state = "mulebot0"
				return
			if(1)		// loading/unloading
				return
			if(2,3,4)		// navigating to deliver,home, or blocked

				if(loc == target)		// reached target
					at_target()
					return

				else if(path.len > 0 && target)		// valid path

					var/turf/next = path[1]
					reached_target = 0
					if(next == loc)
						path -= next
						return


					if(istype( next, /turf/simulated))

						if(bloodiness && !istype(src.loc, /turf/space))
							var/obj/decal/cleanable/blood/tracks/B = new(loc)
							var/newdir = get_dir(next, loc)
							if(newdir == dir)
								B.dir = newdir
							else
								newdir = newdir | dir
								if(newdir == 3)
									newdir = 1
								else if(newdir == 12)
									newdir = 4
								B.dir = newdir
							bloodiness--


						var/moved = step_towards_3d(src, next)
						if(cell) cell.use(1)
						if(moved)
							blockcount = 0
							path -= loc


							if(mode==4)
								spawn(1)
									send_status()

							if(destination == home_destination)
								mode = 3
							else
								mode = 2

						else		// failed to move

							//world << "Unable to move."



							blockcount++
							mode = 4
							if(blockcount == 3)
								src.visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
								playsound(src.loc, 'buzz-two.ogg', 50, 0)

							if(blockcount > 5)	// attempt 5 times before recomputing
								// find new path excluding blocked turf
								src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
								playsound(src.loc, 'buzz-sigh.ogg', 50, 0)

								spawn(2)
									calc_path(target, next)
									if(path.len > 0)
										src.visible_message("[src] makes a delighted ping!", "You hear a ping.")
										playsound(src.loc, 'ping.ogg', 50, 0)
									mode = 4
								mode =6
								return
							return
					else
						src.visible_message("[src] makes an annoyed buzzing sound", "You hear an electronic buzzing sound.")
						playsound(src.loc, 'buzz-two.ogg', 50, 0)
						//world << "Bad turf."
						mode = 5
						return
				else
					//world << "No path."
					mode = 5
					return

			if(5)		// calculate new path
				//world << "Calc new path."
				mode = 6
				spawn(0)

					calc_path(target)

					if(path.len > 0)
						blockcount = 0
						mode = 4
						src.visible_message("[src] makes a delighted ping!", "You hear a ping.")
						playsound(src.loc, 'ping.ogg', 50, 0)

					else
						src.visible_message("[src] makes a sighing buzz.", "You hear an electronic buzzing sound.")
						playsound(src.loc, 'buzz-sigh.ogg', 50, 0)

						mode = 7
			//if(6)
				//world << "Pending path calc."
			//if(7)
				//world << "No dest / no route."
		return

	shutdowns()
		src.on = 0
	// sets the current destination
	// signals all beacons matching the delivery code
	// beacons will return a signal giving their locations
	proc/set_destination(var/new_dest)
		spawn(0)
			new_destination = new_dest
			post_signal(beacon_freq, "findbeacon", "delivery")
			updateDialog()

	// starts bot moving to current destination
	proc/start()
		if(destination == home_destination)
			mode = 3
		else
			mode = 2
		icon_state = "mulebot[(wires & wire_mobavoid) == wire_mobavoid]"

	// starts bot moving to home
	// sends a beacon query to find
	proc/start_home()
		spawn(0)
			set_destination(home_destination)
			mode = 4
		icon_state = "mulebot[(wires & wire_mobavoid) == wire_mobavoid]"

	// called when bot reaches current target
	proc/at_target()
		if(!reached_target)
			src.visible_message("[src] makes a chiming sound!", "You hear a chime.")
			playsound(src.loc, 'chime.ogg', 50, 0)
			reached_target = 1

			if(load)		// if loaded, unload at target
				unload(loaddir)
			else
				// not loaded
				if(auto_pickup)		// find a crate
					var/atom/movable/AM
					if(!(wires & wire_loadcheck))		// if emagged, load first unanchored thing we find
						for(var/atom/movable/A in get_step(loc, loaddir))
							if(!A.anchored)
								AM = A
								break
					else			// otherwise, look for crates only
						AM = locate(/obj/crate) in get_step(loc,loaddir)
					if(AM)
						load(AM)
			// whatever happened, check to see if we return home

			if(auto_return && destination != home_destination)
				// auto return set and not at home already
				start_home()
				mode = 4
			else
				mode = 0	// otherwise go idle

		send_status()	// report status to anyone listening

		return

	// called when bot bumps into anything
	Bump(var/atom/obs)
		if(!(wires & wire_mobavoid))		//usually just bumps, but if avoidance disabled knock over mobs
			var/mob/M = obs
			if(ismob(M))
				if(istype(M,/mob/living/silicon/robot))
					src.visible_message("\red [src] bumps into [M]!")
				else
					src.visible_message("\red [src] knocks over [M]!")
					M.pulling = null
					M.stunned = 8
					M.weakened = 5
					M.lying = 1
		..()

	alter_health()
		return get_turf(src)


	// called from mob/living/carbon/human/HasEntered()
	// when mulebot is in the same loc
	proc/RunOver(var/mob/living/carbon/human/H)
		src.visible_message("\red [src] drives over [H]!")
		playsound(src.loc, 'splat.ogg', 50, 1)


		if(ismob(load))
			var/mob/M = load
			if(M.reagents.has_reagent("beer"))
				M.unlock_medal("DUI", 1)
		//	if(M.reagents.has_reagent("space_drugs") && istype(H) && H.wear_id.assignment == "Security Officer")
			//	M.unlock_medel("Ridin Dirty",1)


		var/damage = rand(5,15)

		H.TakeDamage("head", 2*damage, 0)
		H.TakeDamage("chest",2*damage, 0)
		H.TakeDamage("l_leg",0.5*damage, 0)
		H.TakeDamage("r_leg",0.5*damage, 0)
		H.TakeDamage("l_arm",0.5*damage, 0)
		H.TakeDamage("r_arm",0.5*damage, 0)

		if(!istype(src.loc, /turf/space))
			var/obj/decal/cleanable/blood/B = new(src.loc)
			B.blood_DNA = H.dna.unique_enzymes
			B.blood_type = H.b_type
			B.virus2 = H.virus2.getcopy()

		bloodiness += 4

	// player on mulebot attempted to move
	relaymove(var/mob/user)
		if(user.stat)
			return
		if(load == user)
			unload(0)
		return

	// receive a radio signal
	// used for control and beacon reception

	receive_signal(datum/signal/signal)

		if(!on)
			return

		/*
		world << "rec signal: [signal.source]"
		for(var/x in signal.data)
			world << "* [x] = [signal.data[x]]"
		*/
		var/recv = signal.data["command"]
		// process all-bot input
		if(recv=="bot_status" && (wires & wire_remote_rx))
			send_status()


		recv = signal.data["command [suffix]"]
		if(wires & wire_remote_rx)
			// process control input
			switch(recv)
				if("stop")
					mode = 0
					return

				if("go")
					start()
					return

				if("target")
					set_destination(signal.data["destination"] )
					return

				if("unload")
					if(loc == target)
						unload(loaddir)
					else
						unload(0)
					return

				if("home")
					start_home()
					return

				if("bot_status")
					send_status()
					return

				if("autoret")
					auto_return = text2num(signal.data["value"])
					return

				if("autopick")
					auto_pickup = text2num(signal.data["value"])
					return

		// receive response from beacon
		recv = signal.data["beacon"]
		if(wires & wire_beacon_rx)
			if(recv == new_destination)	// if the recvd beacon location matches the set destination
										// the we will navigate there
				destination = new_destination
				target = signal.source.loc
				var/direction = signal.data["dir"]	// this will be the load/unload dir
				if(direction)
					loaddir = text2num(direction)
				else
					loaddir = 0
				icon_state = "mulebot[(wires & wire_mobavoid) == wire_mobavoid]"
				calc_path(target)
				updateDialog()

	// send a radio signal with a single data key/value pair
	proc/post_signal(var/freq, var/key, var/value)
		post_signal_multiple(freq, list("[key]" = value) )

	// send a radio signal with multiple data key/values
	proc/post_signal_multiple(var/freq, var/list/keyval)

		if(freq == beacon_freq && !(wires & wire_beacon_tx))
			return
		if(freq == control_freq && !(wires & wire_remote_tx))
			return

		var/datum/radio_frequency/frequency = radio_controller.return_frequency("[freq]")

		if(!frequency) return



		var/datum/signal/signal = new()
		signal.source = src
		signal.transmission_method = 1
		for(var/key in keyval)
			signal.data[key] = keyval[key]
			//world << "sent [key],[keyval[key]] on [freq]"
		frequency.post_signal(src, signal)

	// signals bot status etc. to controller
	proc/send_status()
		var/list/kv = new()
		kv["type"] = "mulebot"
		kv["name"] = suffix
		kv["loca"] = loc.loc	// area
		kv["mode"] = mode
		kv["powr"] = cell ? cell.percent() : 0
		kv["dest"] = destination
		kv["home"] = home_destination
		kv["load"] = load
		kv["retn"] = auto_return
		kv["pick"] = auto_pickup
		post_signal_multiple(control_freq, kv)



