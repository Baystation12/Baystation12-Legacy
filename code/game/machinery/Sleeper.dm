/////////////////////////////////////////
// SLEEPER CONSOLE
/////////////////////////////////////////

/obj/machinery/sleep_console
	name = "Sleeper Console"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeperconsole"
	var/obj/machinery/sleeper/connected = null
	anchored = 1 //About time someone fixed this.
	density = 1

/obj/machinery/sleep_console/New()
	..()
	spawn( 10 )
		src.connected = locate(/obj/machinery/sleeper, get_step(src, WEST))
		return
	return

/obj/machinery/sleep_console/ex_act(severity)
	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/sleep_console/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/sleep_console/attack_hand(mob/user as mob)
	if(..())
		return
	if (src.connected)
		var/mob/occupant = src.connected.occupant
		var/dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>"
		if (occupant)
			var/t1
			switch(occupant.stat)
				if(0)
					t1 = "Conscious"
				if(1)
					t1 = "Unconscious"
				if(2)
					t1 = "*dead*"

			dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
			dat += text("[]\t-Brute Damage %: []</FONT><BR>", (occupant.bruteloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.bruteloss)
			dat += text("[]\t-Respiratory Damage %: []</FONT><BR>", (occupant.oxyloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.oxyloss)
			dat += text("[]\t-Toxin Content %: []</FONT><BR>", (occupant.toxloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.toxloss)
			dat += text("[]\t-Burn Severity %: []</FONT><BR>", (occupant.fireloss < 60 ? "<font color='blue'>" : "<font color='red'>"), occupant.fireloss)
			dat += text("<BR>Paralysis Summary %: [] ([] seconds left!)</FONT><BR>", occupant.paralysis, round(occupant.paralysis / 4))
			dat += text("<HR><A href='?src=\ref[];refresh=1'>Refresh</A><BR><A href='?src=\ref[];rejuv=1'>Inject Rejuvenators</A>", src, src)
		else
			dat += "The sleeper is empty."
		dat += text("<BR><BR><A href='?src=\ref[];mach_close=sleeper'>Close</A>", user)
		user << browse(dat, "window=sleeper;size=400x500")
		onclose(user, "sleeper")
	return

/obj/machinery/sleep_console/Topic(href, href_list)
	if(..())
		return

	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["rejuv"])
			if (src.connected)
				src.connected.inject(usr)
		if (href_list["refresh"])
			src.updateUsrDialog()
		src.add_fingerprint(usr)

	return

/obj/machinery/sleep_console/process()
	if(stat & (NOPOWER|BROKEN))
		return
	src.updateUsrDialog()
	return

/obj/machinery/sleep_console/power_change()
	return
	// no change - sleeper works without power (you just can't inject more)







/////////////////////////////////////////
// THE SLEEPER ITSELF
/////////////////////////////////////////

/obj/machinery/sleeper
	name = "Sleeper"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	var/mob/occupant = null
	anchored = 1

/*/obj/machinery/sleeper/allow_drop()
	return 0*/

/obj/machinery/sleeper/process()
	//src.updateDialog()
	return

/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
	return

/obj/machinery/sleeper/blob_act()
	if(prob(75))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
			A.blob_act()
		del(src)
	return

/obj/machinery/sleeper/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The sleeper is already occupied!</B>"
		return
	if (G.affecting.abiotic())
		user << "Subject may not have abiotic items on."
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "sleeper_1"
	for(var/obj/O in src)
		O.loc = src.loc
	src.add_fingerprint(user)
	del(G)
	return

/obj/machinery/sleeper/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				del(src)
				return
		else
	return

/obj/machinery/sleeper/alter_health(mob/M as mob)
	if (M.health > 0)
		if (M.oxyloss >= 10)
			var/amount = max(0.15, 1)
			M.oxyloss -= amount
		else
			M.oxyloss = 0
		M.updatehealth()
	M.paralysis -= 4
	M.weakened -= 4
	M.stunned -= 4
	if (M.paralysis <= 1)
		M.paralysis = 3
	if (M.weakened <= 1)
		M.weakened = 3
	if (M.stunned <= 1)
		M.stunned = 3
	if (M:reagents.get_reagent_amount("inaprovaline") < 5)
		M:reagents.add_reagent("inaprovaline", 5)
	return

/obj/machinery/sleeper/proc/go_out()
	if (!src.occupant)
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "sleeper_0"
	return

/obj/machinery/sleeper/proc/inject(mob/user as mob)
	if (src.occupant)
		if (src.occupant.reagents.get_reagent_amount("inaprovaline") < 60)
			src.occupant.reagents.add_reagent("inaprovaline", 30)
		user << text("Occupant now has [] units of rejuvenation in his/her bloodstream.", src.occupant.reagents.get_reagent_amount("inaprovaline"))
	else
		user << "No occupant!"
	return

/obj/machinery/sleeper/proc/check(mob/user as mob)
	if (src.occupant)
		user << text("\blue <B>Occupant ([]) Statistics:</B>", src.occupant)
		var/t1
		switch(src.occupant.stat)
			if(0.0)
				t1 = "Conscious"
			if(1.0)
				t1 = "Unconscious"
			if(2.0)
				t1 = "*dead*"
			else
		user << text("[]\t Health %: [] ([])", (src.occupant.health > 50 ? "\blue " : "\red "), src.occupant.health, t1)
		user << text("[]\t -Core Temperature: []&deg;C ([]&deg;F)</FONT><BR>", (src.occupant.bodytemperature > 50 ? "<font color='blue'>" : "<font color='red'>"), src.occupant.bodytemperature-T0C, src.occupant.bodytemperature*1.8-459.67)
		user << text("[]\t -Brute Damage %: []", (src.occupant.bruteloss < 60 ? "\blue " : "\red "), src.occupant.bruteloss)
		user << text("[]\t -Respiratory Damage %: []", (src.occupant.oxyloss < 60 ? "\blue " : "\red "), src.occupant.oxyloss)
		user << text("[]\t -Toxin Content %: []", (src.occupant.toxloss < 60 ? "\blue " : "\red "), src.occupant.toxloss)
		user << text("[]\t -Burn Severity %: []", (src.occupant.fireloss < 60 ? "\blue " : "\red "), src.occupant.fireloss)
		user << "\blue Expected time until the occupant can safely awake: (note: If health is below 20% these times are inaccurate)"
		user << text("\blue \t [] second\s (if around 1 or 2 the sleeper is keeping them asleep.)", src.occupant.paralysis / 5)
	else
		user << "\blue There is no one inside!"
	return

/obj/machinery/sleeper/verb/eject()
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/verb/move_inside()
	set src in oview(1)

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The sleeper is already occupied!</B>"
		return
	if (usr.abiotic())
		usr << "Subject may not have abiotic items on."
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "sleeper_1"
	for(var/obj/O in src)
		del(O)
	src.add_fingerprint(usr)
	return