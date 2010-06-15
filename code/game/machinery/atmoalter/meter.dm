/obj/machinery/meter/New()
	..()

	src.target = locate(/obj/machinery/atmospherics/pipe) in loc

	return 1

/obj/machinery/meter/process()
	if(!target)
		icon_state = "meterX"
		return 0

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return 0

	use_power(5)

	var/datum/gas_mixture/environment = target.return_air()
	if(!environment)
		icon_state = "meterX"
		return 0

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15*ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5)-0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59*ONE_ATMOSPHERE)
		var/val = round(env_pressure/(ONE_ATMOSPHERE*5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

	if(frequency)
		var/datum/radio_frequency/radio_connection = radio_controller.return_frequency("[frequency]")

		if(!radio_connection) return

		var/datum/signal/signal = new
		signal.source = src
		signal.transmission_method = 1

		signal.data["tag"] = id
		signal.data["device"] = "AM"
		signal.data["pressure"] = round(env_pressure)

		radio_connection.post_signal(src, signal)

/obj/machinery/meter/examine()
	set src in oview(1)

	var/t = "A gas flow meter. "
	if (src.target)
		var/datum/gas_mixture/environment = target.return_air()
		if(environment)
			t += text("The pressure gauge reads [] kPa", round(environment.return_pressure(), 0.1))
		else
			t += "The sensor error light is blinking."
	else
		t += "The connect error light is blinking."

	usr << t



/obj/machinery/meter/Click()

	if(stat & (NOPOWER|BROKEN))
		return

	var/t = null
	if (get_dist(usr, src) <= 3 || istype(usr, /mob/living/silicon/ai))
		if (src.target)
			var/datum/gas_mixture/environment = target.return_air()
			if(environment)
				t = text("<B>Pressure:</B> [] kPa", round(environment.return_pressure(), 0.1))
			else
				t = "\red <B>Results: Sensor Error!</B>"
		else
			t = "\red <B>Results: Connection Error!</B>"
	else
		usr << "\blue <B>You are too far away.</B>"

	usr << t
	return
