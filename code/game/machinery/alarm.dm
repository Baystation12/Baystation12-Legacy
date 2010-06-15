/obj/machinery/alarm/New()
	..()

	if(!alarm_zone)
		var/area/A = get_area(loc)
		if(A.name)
			alarm_zone = A.name
		else
			alarm_zone = "Unregistered"

/obj/machinery/alarm/process()
	if (src.skipprocess)
		src.skipprocess--
		return

	var/turf/location = src.loc
	var/safe = 2

	if(stat & (NOPOWER|BROKEN))
		icon_state = "alarmp"
		return

	use_power(5, ENVIRON)

	if (!( istype(location, /turf) ))
		return 0

	var/datum/gas_mixture/environment = location.return_air()

	var/environment_pressure = environment.return_pressure()

	if((environment_pressure < ONE_ATMOSPHERE*0.90) || (environment_pressure > ONE_ATMOSPHERE*1.10))
		//Pressure sensor
		if((environment_pressure < ONE_ATMOSPHERE*0.80) || (environment_pressure > ONE_ATMOSPHERE*1.20))
			safe = 0
		else safe = 1

	if(safe && ((environment.oxygen < MOLES_O2STANDARD*0.90) || (environment.oxygen > MOLES_O2STANDARD*1.10)))
		//Oxygen Levels Sensor
		if(environment.oxygen < MOLES_O2STANDARD*0.80)
			safe = 0
		else safe = 1

	if(safe && ((environment.temperature < (T20C-10)) || (environment.temperature > (T20C+10))))
		//Oxygen Levels Sensor
		if((environment.temperature < (T20C-20)) || (environment.temperature > (T20C+10)))
			safe = 0
		else safe = 1

	if(safe && (environment.carbon_dioxide > 0.05))
		//CO2 Levels Sensor
		if(environment.carbon_dioxide > 0.1)
			safe = 0
		else safe = 1

	if(safe && (environment.toxins > 1))
		//Plasma Levels Sensor
		if(environment.toxins > 2)
			safe = 0
		else safe = 1

	src.icon_state = "alarm[!safe]"

	if(safe == 2) src.skipprocess = 1
	else if(alarm_frequency)
		post_alert(safe)

	return

/obj/machinery/alarm/proc/post_alert(alert_level)

	var/datum/radio_frequency/frequency = radio_controller.return_frequency(alarm_frequency)

	if(!frequency) return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = alarm_zone
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level==0)
		alert_signal.data["alert"] = "severe"
	else
		alert_signal.data["alert"] = "minor"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/attackby(W as obj, user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		stat ^= BROKEN
		src.add_fingerprint(user)
		for(var/mob/O in viewers(user, null))
			O.show_message(text("\red [] has []activated []!", user, (stat&BROKEN) ? "de" : "re", src), 1)
		return
	return ..()

/obj/machinery/alarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/alarm/Click()
	if(istype(usr, /mob/living/silicon/ai))
		return examine()
	return ..()

/obj/machinery/alarm/examine()
	set src in oview(1)
	/*
	if(usr.stat)
		return
	if(stat & (NOPOWER|BROKEN))
		return
	if(!(istype(usr, /mob/living/carbon/human) || ticker))
		if (!istype(usr, /mob/living/silicon/ai))
			usr << "\red You don't have the dexterity to do this!"
			return
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/living/silicon/ai))
		var/turf/T = src.loc
		if (!( istype(T, /turf) ))
			return

		var/turf_total = T.co2 + T.oxygen + T.poison + T.sl_gas + T.n2
		turf_total = max(turf_total, 1)
		usr.show_message("\blue <B>Results:</B>", 1)
		var/t = ""
		var/t1 = turf_total / CELLSTANDARD * 100
		if ((90 < t1 && t1 < 110))
			usr.show_message(text("\blue Air Pressure: []%", t1), 1)
		else
			usr.show_message(text("\blue Air Pressure:\red []%", t1), 1)
		t1 = T.n2 / turf_total * 100
		t1 = round(t1, 0.0010)
		if ((60 < t1 && t1 < 80))
			t += text("<font color=blue>Nitrogen: []</font> ", t1)
		else
			t += text("<font color=red>Nitrogen: []</font> ", t1)
		t1 = T.oxygen / turf_total * 100
		t1 = round(t1, 0.0010)
		if ((20 < t1 && t1 < 24))
			t += text("<font color=blue>Oxygen: []</font> ", t1)
		else
			t += text("<font color=red>Oxygen: []</font> ", t1)
		t1 = T.poison / turf_total * 100
		t1 = round(t1, 0.0010)
		if (t1 < 0.5)
			t += text("<font color=blue>Plasma: []</font> ", t1)
		else
			t += text("<font color=red>Plasma: []</font> ", t1)
		t1 = T.co2 / turf_total * 100
		t1 = round(t1, 0.0010)
		if (t1 < 1)
			t += text("<font color=blue>CO2: []</font> ", t1)
		else
			t += text("<font color=red>CO2: []</font> ", t1)
		t1 = T.sl_gas / turf_total * 100
		t1 = round(t1, 0.0010)
		if (t1 < 5)
			t += text("<font color=blue>NO2: []</font>", t1)
		else
			t += text("<font color=red>NO2: []</font>", t1)
		t1 = T.temp - T0C
		if (T.temp > 326.444 || T.temp < 282.591)
			t += text("<br><font color=red>Temperature: []</font>", t1)
		else
			t += text("<br><font color=blue>Temperature: []</font>", t1)
		usr.show_message(t, 1)
		return
	else
		usr << "\blue <B>You are too far away.</B>"
	*/


/obj/machinery/firealarm/temperature_expose(datum/gas_mixture/air, temperature, volume)
	if(src.detecting)
		if(temperature > T0C+200)
			src.alarm()			// added check of detector status here
	return

/obj/machinery/firealarm/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/bullet_act(BLAH)
	return src.alarm()

/obj/machinery/firealarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/firealarm/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if (istype(W, /obj/item/weapon/wirecutters))
		src.detecting = !( src.detecting )
		if (src.detecting)
			user.visible_message("\red [user] has reconnected [src]'s detecting unit!", "You have reconnected [src]'s detecting unit.")
		else
			user.visible_message("\red [user] has disconnected [src]'s detecting unit!", "You have disconnected [src]'s detecting unit.")
	else
		src.alarm()
	src.add_fingerprint(user)
	return

/obj/machinery/firealarm/process()
	if(stat & (NOPOWER|BROKEN))
		return

	use_power(10, ENVIRON)

	if (src.timing)
		if (src.time > 0)
			src.time = round(src.time) - 1
		else
			alarm()
			src.time = 0
			src.timing = 0
		src.updateDialog()
	return

/obj/machinery/firealarm/power_change()
	if(powered(ENVIRON))
		stat &= ~NOPOWER
		icon_state = "fire0"
	else
		spawn(rand(0,15))
			stat |= NOPOWER
			icon_state = "firep"

/obj/machinery/firealarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/area/A = src.loc
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		A = A.loc

		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>Reset - Lockdown</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>Alarm - Lockdown</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Fire alarm</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("Reset - Lockdown"))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("Alarm - Lockdown"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Fire alarm"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=firealarm")
		onclose(user, "firealarm")
	return

/obj/machinery/firealarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["reset"])
			src.reset()
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=firealarm")
		return
	return

/obj/machinery/firealarm/proc/reset()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.firereset()
	return

/obj/machinery/firealarm/proc/alarm()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	for(var/area/RA in A.related)
		RA.firealert()
	//playsound(src.loc, 'signal.ogg', 75, 0)
	return

/obj/machinery/partyalarm/attack_paw(mob/user as mob)
	return src.attack_hand(user)
/obj/machinery/partyalarm/attack_hand(mob/user as mob)
	if(user.stat || stat & (NOPOWER|BROKEN))
		return

	user.machine = src
	var/area/A = src.loc
	var/d1
	var/d2
	if (istype(user, /mob/living/carbon/human) || istype(user, /mob/living/silicon/ai))
		A = A.loc

		if (A.party)
			d1 = text("<A href='?src=\ref[];reset=1'>No Party :(</A>", src)
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>PARTY!!!</A>", src)
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>Stop Time Lock</A>", src)
		else
			d2 = text("<A href='?src=\ref[];time=1'>Initiate Time Lock</A>", src)
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>Party Button</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	else
		A = A.loc
		if (A.fire)
			d1 = text("<A href='?src=\ref[];reset=1'>[]</A>", src, stars("No Party :("))
		else
			d1 = text("<A href='?src=\ref[];alarm=1'>[]</A>", src, stars("PARTY!!!"))
		if (src.timing)
			d2 = text("<A href='?src=\ref[];time=0'>[]</A>", src, stars("Stop Time Lock"))
		else
			d2 = text("<A href='?src=\ref[];time=1'>[]</A>", src, stars("Initiate Time Lock"))
		var/second = src.time % 60
		var/minute = (src.time - second) / 60
		var/dat = text("<HTML><HEAD></HEAD><BODY><TT><B>[]</B> []\n<HR>\nTimer System: []<BR>\nTime Left: [][] <A href='?src=\ref[];tp=-30'>-</A> <A href='?src=\ref[];tp=-1'>-</A> <A href='?src=\ref[];tp=1'>+</A> <A href='?src=\ref[];tp=30'>+</A>\n</TT></BODY></HTML>", stars("Party Button"), d1, d2, (minute ? text("[]:", minute) : null), second, src, src, src, src)
		user << browse(dat, "window=partyalarm")
		onclose(user, "partyalarm")
	return

/obj/machinery/partyalarm/proc/reset()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	A.partyreset()
	return

/obj/machinery/partyalarm/proc/alarm()
	if (!( src.working ))
		return
	var/area/A = src.loc
	A = A.loc
	if (!( istype(A, /area) ))
		return
	A.partyalert()
	return

/obj/machinery/partyalarm/Topic(href, href_list)
	..()
	if (usr.stat || stat & (BROKEN|NOPOWER))
		return
	if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon/ai)))
		usr.machine = src
		if (href_list["reset"])
			src.reset()
		else
			if (href_list["alarm"])
				src.alarm()
			else
				if (href_list["time"])
					src.timing = text2num(href_list["time"])
				else
					if (href_list["tp"])
						var/tp = text2num(href_list["tp"])
						src.time += tp
						src.time = min(max(round(src.time), 0), 120)
		src.updateUsrDialog()

		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=partyalarm")
		return
	return