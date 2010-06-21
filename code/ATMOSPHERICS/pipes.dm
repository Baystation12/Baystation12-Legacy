obj/machinery/atmospherics/pipe

	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent

	var/volume = 0
	var/nodealert = 0

	var/alert_pressure = 80*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called

	proc/pipeline_expansion()
		return null

	proc/check_pressure(pressure)
		//Return 1 if parent should continue checking other pipes
		//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null

		return 1

	return_air()
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.air

	build_network()
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.return_network()

	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.network_expand(new_network, reference)

	return_network(obj/machinery/atmospherics/reference)
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.return_network(reference)

	Del()
		del(parent)
		if(air_temporary)
			loc.assume_air(air_temporary)

		..()

	simple
		icon = 'pipes.dmi'
		icon_state = "intact-f"

		name = "pipe"
		desc = "A one meter section of regular pipe"

		volume = 70

		dir = SOUTH
		initialize_directions = SOUTH|NORTH

		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2

		var/minimum_temperature_difference = 300
		var/thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT

		var/maximum_pressure = 70*ONE_ATMOSPHERE
		var/fatigue_pressure = 55*ONE_ATMOSPHERE
		alert_pressure = 55*ONE_ATMOSPHERE


		level = 1

		New()
			..()
			switch(dir)
				if(SOUTH || NORTH)
					initialize_directions = SOUTH|NORTH
				if(EAST || WEST)
					initialize_directions = EAST|WEST
				if(NORTHEAST)
					initialize_directions = NORTH|EAST
				if(NORTHWEST)
					initialize_directions = NORTH|WEST
				if(SOUTHEAST)
					initialize_directions = SOUTH|EAST
				if(SOUTHWEST)
					initialize_directions = SOUTH|WEST


		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? 101 : 0
			update_icon()

		process()
			if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
				..()

			if(!node1)
				parent.mingle_with_turf(loc, volume)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1

			else if(!node2)
				parent.mingle_with_turf(loc, volume)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1


			else if(parent)
				var/environment_temperature = 0

				if(istype(loc, /turf/simulated/))
					if(loc:blocks_air)
						environment_temperature = loc:temperature
					else
						var/datum/gas_mixture/environment = loc.return_air()
						environment_temperature = environment.temperature

				else
					environment_temperature = loc:temperature

				var/datum/gas_mixture/pipe_air = return_air()

				if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
					parent.temperature_interact(loc, volume, thermal_conductivity)

		check_pressure(pressure)
			var/datum/gas_mixture/environment = loc.return_air()

			var/pressure_difference = pressure - environment.return_pressure()

			if(pressure_difference > maximum_pressure)
				del(src)

			else if(pressure_difference > fatigue_pressure)
				if(prob(5))
					del(src)

			else return 1

		Del()
			if(node1)
				node1.disconnect(src)
			if(node2)
				node2.disconnect(src)

			..()

		pipeline_expansion()
			return list(node1, node2)

		update_icon()
			if(node1&&node2)
				icon_state = "intact[invisibility ? "-f" : "" ]"

				var/node1_direction = get_dir(src, node1)
				var/node2_direction = get_dir(src, node2)

				dir = node1_direction|node2_direction
				if(dir==3) dir = 1
				else if(dir==12) dir = 4

			else
				icon_state = "exposed[invisibility ? "-f" : "" ]"

				if(node1)
					dir = get_dir(src,node1)

				else if(node2)
					dir = get_dir(src,node2)

				else
					del(src)

		initialize()
			var/connect_directions

			switch(dir)
				if(NORTH)
					connect_directions = NORTH|SOUTH
				if(SOUTH)
					connect_directions = NORTH|SOUTH
				if(EAST)
					connect_directions = EAST|WEST
				if(WEST)
					connect_directions = EAST|WEST
				else
					connect_directions = dir

			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node1 = target
							break

					connect_directions &= ~direction
					break


			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node2 = target
							break

					connect_directions &= ~direction
					break

			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			//update_icon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/atmospherics/pipe))
					del(parent)
				node2 = null

			update_icon()

			return null

	simple/multiz
		icon = 'multiz_pipe.dmi'
		var/dir2 = 0

		up
			dir2 = UP
			icon_state = "up"

			hide()
				update_icon()

		down
			dir2 = DOWN
			icon_state = "down"

		New()
			..()
			initialize_directions = dir | dir2

		update_icon()
			if(node1&&node2)

				var/node1_direction = get_dir_3d(src, node1)
				var/node2_direction = get_dir_3d(src, node2)

				if(node1_direction > node2_direction)
					var/t = node1_direction
					node1_direction = node2_direction
					node2_direction = t

				icon_state = "[dir2 == UP ? "up" : "down"][invisibility ? "-f" : "" ]"

				dir = (node1_direction|node2_direction) & (NORTH|EAST|SOUTH|WEST)


	simple/insulated
		icon = 'red_pipe.dmi'
		icon_state = "intact"

		minimum_temperature_difference = 10000
		thermal_conductivity = 0
		maximum_pressure = 1000*ONE_ATMOSPHERE
		fatigue_pressure = 900*ONE_ATMOSPHERE
		alert_pressure = 900*ONE_ATMOSPHERE

		level = 2


	simple/junction
		icon = 'junction.dmi'
		icon_state = "intact"
		level = 2

		update_icon()
			if(istype(node1, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
				dir = get_dir(src, node1)

				if(node2)
					icon_state = "intact"
				else
					icon_state = "exposed"

			else if(istype(node2, /obj/machinery/atmospherics/pipe/simple/heat_exchanging))
				dir = get_dir(src, node2)

				if(node1)
					icon_state = "intact"
				else
					icon_state = "exposed"

			else
				icon_state = "exposed"

	simple/heat_exchanging
		icon = 'heat.dmi'
		icon_state = "3"
		level = 2

		minimum_temperature_difference = 20
		thermal_conductivity = WINDOW_HEAT_TRANSFER_COEFFICIENT

		update_icon()
			if(node1&&node2)
				icon_state = "intact"

				var/node1_direction = get_dir(src, node1)
				var/node2_direction = get_dir(src, node2)

				icon_state = "[node1_direction|node2_direction]"

	tank
		icon = 'pipe_tank.dmi'
		icon_state = "intact"

		name = "Pressure Tank"
		desc = "A large vessel containing pressurized gas."

		volume = 1620 //in liters, 0.9 meters by 0.9 meters by 2 meters

		dir = SOUTH
		initialize_directions = SOUTH
		density = 1

		var/obj/machinery/atmospherics/node1

		New()
			initialize_directions = dir
			..()

		process()
			..()
			if(!node1)
				parent.mingle_with_turf(loc, 200)

		carbon_dioxide
			name = "Pressure Tank (Carbon Dioxide)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		toxins
			icon = 'orange_pipe_tank.dmi'
			name = "Pressure Tank (Plasma)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.toxins = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		oxygen_agent_b
			icon = 'red_orange_pipe_tank.dmi'
			name = "Pressure Tank (Oxygen + Plasma)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T0C

				var/datum/gas/oxygen_agent_b/trace_gas = new
				trace_gas.moles = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				air_temporary.trace_gases += trace_gas

				..()

		oxygen
			icon = 'blue_pipe_tank.dmi'
			name = "Pressure Tank (Oxygen)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.oxygen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		nitrogen
			icon = 'red_pipe_tank.dmi'
			name = "Pressure Tank (Nitrogen)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.nitrogen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		air
			icon = 'red_pipe_tank.dmi'
			name = "Pressure Tank (Air)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
				air_temporary.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		Del()
			if(node1)
				node1.disconnect(src)

			..()

		pipeline_expansion()
			return list(node1)

		update_icon()
			if(node1)
				icon_state = "intact"

				dir = get_dir(src, node1)

			else
				icon_state = "exposed"

		initialize()
			var/connect_direction = dir

			for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			update_icon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			update_icon()

			return null

		attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
			if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1)
				for (var/mob/O in viewers(user, null))
					O << "\red [user] has used the analyzer on \icon[icon]"

				var/pressure = parent.air.return_pressure()
				var/total_moles = parent.air.total_moles()

				user << "\blue Results of analysis of \icon[icon]"
				if (total_moles>0)
					var/o2_concentration = parent.air.oxygen/total_moles
					var/n2_concentration = parent.air.nitrogen/total_moles
					var/co2_concentration = parent.air.carbon_dioxide/total_moles
					var/plasma_concentration = parent.air.toxins/total_moles

					var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

					user << "\blue Pressure: [round(pressure,0.1)] kPa"
					user << "\blue Nitrogen: [round(n2_concentration*100)]%"
					user << "\blue Oxygen: [round(o2_concentration*100)]%"
					user << "\blue CO2: [round(co2_concentration*100)]%"
					user << "\blue Plasma: [round(plasma_concentration*100)]%"
					if(unknown_concentration>0.01)
						user << "\red Unknown: [round(unknown_concentration*100)]%"
					user << "\blue Temperature: [round(parent.air.temperature-T0C)]&deg;C"
				else
					user << "\blue Tank is empty!"

	vent
		icon = 'pipe_vent.dmi'
		icon_state = "intact"

		name = "Vent"
		desc = "A large air vent"

		level = 1

		volume = 250

		dir = SOUTH
		initialize_directions = SOUTH

		var/obj/machinery/atmospherics/node1
		New()
			initialize_directions = dir
			..()

		process()
			..()
			if(parent)
				parent.mingle_with_turf(loc, 250)

		Del()
			if(node1)
				node1.disconnect(src)

			..()

		pipeline_expansion()
			return list(node1)

		update_icon()
			if(node1)
				icon_state = "intact"

				dir = get_dir(src, node1)

			else
				icon_state = "exposed"

		initialize()
			var/connect_direction = dir

			for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			update_icon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			update_icon()

			return null

		hide(var/i) //to make the little pipe section invisible, the icon changes.
			if(node1)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
				dir = get_dir(src, node1)
			else
				icon_state = "exposed"

	manifold
		icon = 'pipe_manifold.dmi'
		icon_state = "manifold-f"

		name = "pipe manifold"
		desc = "A manifold composed of regular pipes"

		volume = 105

		dir = SOUTH
		initialize_directions = EAST|NORTH|WEST

		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2
		var/obj/machinery/atmospherics/node3

		level = 1

		New()
			switch(dir)
				if(NORTH)
					initialize_directions = EAST|SOUTH|WEST
				if(SOUTH)
					initialize_directions = WEST|NORTH|EAST
				if(EAST)
					initialize_directions = SOUTH|WEST|NORTH
				if(WEST)
					initialize_directions = NORTH|EAST|SOUTH

			..()



		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? 101 : 0
			update_icon()

		pipeline_expansion()
			return list(node1, node2, node3)

		process()
			..()

			if(!node1)
				parent.mingle_with_turf(loc, 70)

			else if(!node2)
				parent.mingle_with_turf(loc, 70)

			else if(!node3)
				parent.mingle_with_turf(loc, 70)

		Del()
			if(node1)
				node1.disconnect(src)
			if(node2)
				node2.disconnect(src)
			if(node3)
				node3.disconnect(src)

			..()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/atmospherics/pipe))
					del(parent)
				node2 = null

			if(reference == node3)
				if(istype(node3, /obj/machinery/atmospherics/pipe))
					del(parent)
				node3 = null

			update_icon()

			..()

		update_icon()
			if(node1&&node2&&node3)
				icon_state = "manifold[invisibility ? "-f" : ""]"

			else
				var/connected = 0
				var/unconnected = 0
				var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

				if(node1)
					connected |= get_dir(src, node1)
				if(node2)
					connected |= get_dir(src, node2)
				if(node3)
					connected |= get_dir(src, node3)

				unconnected = (~connected)&(connect_directions)

				icon_state = "manifold_[connected]_[unconnected]"

				if(!connected)
					del(src)

			return

		initialize()
			var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node1 = target
							break

					connect_directions &= ~direction
					break


			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node2 = target
							break

					connect_directions &= ~direction
					break


			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node3 = target
							break

					connect_directions &= ~direction
					break

			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			//update_icon()
