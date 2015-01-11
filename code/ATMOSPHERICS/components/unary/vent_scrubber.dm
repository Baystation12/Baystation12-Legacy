/obj/machinery/atmospherics/unary/vent_scrubber
	icon = 'icons/obj/atmospherics/vent_scrubber.dmi'
	icon_state = "off"

	name = "Air Scrubber"
	desc = "Has a valve and pump attached to it"

	level = 1

	var/on = 0
	var/scrubbing = 1 //0 = siphoning, 1 = scrubbing
	var/scrub_CO2 = 1
	var/scrub_Toxins = 1
	var/srub_sleep = 1

	var/volume_rate = 1000

	update_icon()
		if(on&&node)
			if(scrubbing)
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[level == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0

		return

	process()
		..()
		if(!on || istype(loc,/turf/space))
			return 0

		var/datum/gas_mixture/environment = loc.return_air()

		if(scrubbing)
			if((environment.gas["phoron"]>0) || (environment.gas["carbon_dioxide"]>0.1))
				var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles

				var/list/filter = new()
				if(scrub_Toxins)
					filter += "phoron"
				if(scrub_CO2)
					filter += "carbon_dioxide"

				scrub_gas(src,filter,environment,air_contents,transfer_moles)

				if(network)
					network.update = 1

			var/turf/simulated/T = loc
			if(T.air && T.air.return_pressure() > ONE_ATMOSPHERE*1.05)
				var/transfer_moles = environment.total_moles*(volume_rate/environment.volume)
				pump_gas(src,environment,air_contents,transfer_moles)
				if(network)
					network.update = 1

		else //Just siphoning all air
			var/transfer_moles = environment.total_moles*(volume_rate/environment.volume)

			pump_gas(src,environment,air_contents,transfer_moles)

			if(network)
				network.update = 1

		return 1

	hide(var/i) //to make the little pipe section invisible, the icon changes.
		if(on&&node)
			if(scrubbing)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]on"
			else
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]in"
		else
			icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]off"
			on = 0
		return