atom/movable/var/pressure_resistance = 20
atom/movable/var/last_forced_movement = 0

atom/movable/proc/experience_pressure_difference(pressure_difference, direction)
	if(last_forced_movement >= air_master.current_cycle)
		return 0
	else if(!anchored)
		if(pressure_difference > pressure_resistance)
			last_forced_movement = air_master.current_cycle
			spawn step(src, direction)
		return 1

turf
	assume_air(datum/gas_mixture/giver) //use this for machines to adjust air
		//First, ensure there is no movable shuttle or what not on tile that is taking over
//		var/obj/movable/floor/movable_on_me = locate(/obj/movable/floor) in src
//		if(istype(movable_on_me))
//			return movable_on_me.assume_air(giver)

		del(giver)
		return 0

	return_air()
		//First, ensure there is no movable shuttle or what not on tile that is taking over
//		var/obj/movable/floor/movable_on_me = locate(/obj/movable/floor) in src
//		if(istype(movable_on_me))
//			return movable_on_me.return_air()

		//Create gas mixture to hold data for passing
		var/datum/gas_mixture/GM = new

		GM.oxygen = oxygen
		GM.carbon_dioxide = carbon_dioxide
		GM.nitrogen = nitrogen
		GM.toxins = toxins

		GM.temperature = temperature

		return GM

	remove_air(amount as num)
		//First, ensure there is no movable shuttle or what not on tile that is taking over
//		var/obj/movable/floor/movable_on_me = locate(/obj/movable/floor) in src
//		if(istype(movable_on_me))
//			return movable_on_me.remove_air(amount)

		var/datum/gas_mixture/GM = new

		var/sum = oxygen + carbon_dioxide + nitrogen + toxins
		if(sum>0)
			GM.oxygen = (oxygen/sum)*amount
			GM.carbon_dioxide = (carbon_dioxide/sum)*amount
			GM.nitrogen = (nitrogen/sum)*amount
			GM.toxins = (toxins/sum)*amount

		GM.temperature = temperature

		return GM

turf
	var/pressure_difference = 0
	var/pressure_direction = 0

	proc
		high_pressure_movements()

			for(var/atom/movable/in_tile in src)
				in_tile.experience_pressure_difference(pressure_difference, pressure_direction)

			pressure_difference = 0

		consider_pressure_difference(connection_difference, connection_direction)
			if(connection_difference < 0)
				connection_difference = -connection_difference
				connection_direction = turn(connection_direction,180)

			if(connection_difference > pressure_difference)
				if(!pressure_difference)
					air_master.high_pressure_delta += src
				pressure_difference = connection_difference
				pressure_direction = connection_direction

	simulated
		proc
			consider_pressure_difference_space(connection_difference)
				for(var/direction in cardinal)
					if(direction&group_border)
						if(istype(get_step(src,direction),/turf/space))
							if(!pressure_difference)
								air_master.high_pressure_delta += src
							pressure_direction = direction
							pressure_difference = connection_difference
							return 1

turf
	simulated

		var/current_graphic = null

		var/tmp
			datum/gas_mixture/air

			processing = 1
			datum/air_group/turf/parent
			group_border = 0
			length_space_border = 0

			air_check_directions = 0 //Do not modify this, just add turf to air_master.tiles_to_update

			archived_cycle = 0
			current_cycle = 0

			obj/hotspot/active_hotspot

			temperature_archived //USED ONLY FOR SOLIDS
			being_superconductive = 0

			dbg_processing = 0


		proc
			process_cell()
			update_air_properties()
			archive()

			mimic_air_with_tile(turf/model)
			share_air_with_tile(turf/simulated/sharer)

			mimic_temperature_with_tile(turf/model)
			share_temperature_with_tile(turf/simulated/sharer)

			super_conduct()

			update_visuals(datum/gas_mixture/model)
				overlays = null

				switch(model.graphic)
					if("plasma")
						overlays.Add(plmaster)
					if("sleeping_agent")
						overlays.Add(slmaster)
					else
						overlays = null

		New()
			..()

			if(!blocks_air)
				air = new

				air.oxygen = oxygen
				air.carbon_dioxide = carbon_dioxide
				air.nitrogen = nitrogen
				air.toxins = toxins

				air.temperature = temperature

				if(air_master)
					air_master.tiles_to_update.Add(src)

					find_group()
					if(!zone && !stop_zones) add_to_other_zone()

//				air.parent = src //TODO DEBUG REMOVE

			else
				if(air_master)
					for(var/direction in cardinal)
						var/turf/simulated/floor/target = get_step_3d(src,direction)
						if(istype(target))
							air_master.tiles_to_update.Add(target)

		Del()
			if(air_master)
				if(zone && !stop_zones)
					zone.RemoveTurf(src)
				if(parent)
					air_master.groups_to_rebuild.Add(parent)
					parent.members.Remove(src)
				else
					air_master.active_singletons.Remove(src)
			if(active_hotspot)
				del(active_hotspot)
			if(blocks_air)
				for(var/direction in list(NORTH, SOUTH, EAST, WEST, UP, DOWN))
					var/turf/simulated/tile = get_step_3d(src,direction)
					if(istype(tile) && !tile.blocks_air)
						air_master.tiles_to_update.Add(tile)
			..()

		assume_air(datum/gas_mixture/giver)
			if(zone) //Update zone values.
				zone.add_oxygen(giver.oxygen)
				zone.add_nitrogen(giver.nitrogen)
				zone.add_co2(giver.carbon_dioxide)
			if(air)
				if(parent&&parent.group_processing)
					if(!parent.air.check_then_merge(giver))
						parent.suspend_group_processing()
						air.merge(giver)
				else
					air.merge(giver)

					if(!processing)
						if(air.check_tile_graphic())
							update_visuals(air)

				return 1

			else return ..()

		archive()
			if(air) //For open space like floors
				air.archive()

			temperature_archived = temperature
			archived_cycle = air_master.current_cycle

		share_air_with_tile(turf/simulated/T)
			return air.share(T.air)

		mimic_air_with_tile(turf/T)
			return air.mimic(T)

		return_air(observe_only)
			if(air)
				if(parent && parent.group_processing)
					if(zone)
						parent.air.oxygen = zone.oxygen()
						parent.air.nitrogen = zone.nitrogen()
						parent.air.carbon_dioxide = zone.co2()
						if(!observe_only)
							parent.air.zone_oxygen = parent.air.oxygen
							parent.air.zone_nitrogen = parent.air.nitrogen
							parent.air.zone_co2 = parent.air.carbon_dioxide
							zone.update_mixtures.Add(parent.air)
					return parent.air
				else
					if(zone)
						air.oxygen = zone.oxygen()
						air.nitrogen = zone.nitrogen()
						air.carbon_dioxide = zone.co2()
						if(!observe_only)
							air.zone_oxygen = air.oxygen
							air.zone_nitrogen = air.nitrogen
							air.zone_co2 = air.carbon_dioxide
							zone.update_mixtures.Add(air)
					return air

			else
				return ..()

		remove_air(amount as num)
			if(air)
				var/datum/gas_mixture/removed = null

				if(zone)
					air.oxygen = zone.oxygen()
					air.nitrogen = zone.nitrogen()
					air.carbon_dioxide = zone.co2()

				if(parent&&parent.group_processing)
					removed = parent.air.check_then_remove(amount)
					if(!removed)
						parent.suspend_group_processing()
						removed = air.remove(amount)
				else
					removed = air.remove(amount)

					if(!processing)
						if(air.check_tile_graphic())
							update_visuals(air)

				if(removed && zone)
					zone.add_oxygen(-removed.oxygen)
					zone.add_nitrogen(-removed.nitrogen)
					zone.add_co2(-removed.carbon_dioxide)

				return removed

			else
				return ..()

		update_air_properties()//OPTIMIZE
			//var/old_air_directions = air_check_directions
			air_check_directions = 0
			floodupdate = 1
			//if(!zone && !blocks_air)
			//	if(CanPass(null,src,0,1))
			//		add_to_other_zone()
			//		if(!zone)
			//			spawn new/zone(src)

			for(var/direction in cardinal)
				if(CanPass(null, get_step(src,direction), 0, 0))
					air_check_directions |= direction

		//	if(ticker) overlays += 'debug_update.dmi'

			if(zone)
				for(var/direction in cardinal)
					if(air_check_directions&direction)
					//	if(ticker) overlays += image('turf_analysis.dmi',src,"arrow",dir=direction)
						var/turf/simulated/T = get_step(src,direction)

						//See if actually a border
						//if(istype(T,/turf/space) && direction & (16|32)) continue
						if(!istype(T))
							//if(ticker) world << "Update: Non-simulated T detected."

							//See what kind of border it is
							if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor/hull))
								//if(ticker) world << "Space connections handled."
								zone.space_connections -= T
								zone.space_connections += T

						else
							if(T.zone != src.zone)
								//if(!T.zone && CanPass(null,T,0,1))
								//	zone.AddTurf(T)
								if(!(T.zone in zone.connections))
									zone.Connect(src,T)
					else
					//	if(ticker) overlays += image('turf_analysis.dmi',src,"red_arrow",dir=direction)
						var/turf/simulated/T = get_step(src,direction)
						if(T)
							//if((T in zone.members) && !(T.HasDoor() && !T.blocks_air))
							//	zone.RemoveTurf(T)
							if(T.zone in zone.connections)
								zone.Disconnect(src,T)
							if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor/hull))
								//if(!CanPass(null,T,0,0))
								zone.space_connections -= T
			if(parent)
				if(parent.borders)
					parent.borders -= src
				if(length_space_border > 0)
					parent.length_space_border -= length_space_border
					length_space_border = 0

				group_border = 0
				for(var/direction in cardinal)
					if(air_check_directions&direction)
						//(ticker) overlays += image('turf_analysis.dmi',src,"arrow",dir=direction)
						var/turf/simulated/T = get_step(src,direction)

						//See if actually a border
						//if(istype(T,/turf/space) && direction & (16|32)) continue
						if(!istype(T) || (T.parent!=parent))
							//if(ticker) world << "Update: Non-simulated T detected."

							//See what kind of border it is
							if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor/hull))
								//if(ticker) world << "Update: Space tile handled."
								if(parent.space_borders)
									parent.space_borders -= src
									parent.space_borders += src
								else
									parent.space_borders = list(src)
								length_space_border++

								if(zone)
									//if(ticker) world << "Space connections handled."
									zone.space_connections -= T
									zone.space_connections += T

							else
								if(parent.borders)
									parent.borders -= src
									parent.borders += src
								else
									parent.borders = list(src)


							group_border |= direction

						else if(zone)
							if(T.zone != src.zone)
								//if(!T.zone && CanPass(null,T,0,1))
								//	zone.AddTurf(T)
								if(!(T.zone in zone.connections))
									zone.Connect(src,T)
					else
						//if(ticker) overlays += image('turf_analysis.dmi',src,"red_arrow",dir=direction)
						if(zone)
							var/turf/simulated/T = get_step_3d(src,direction)
							if(T)
								//if((T in zone.members) && !(T.HasDoor() && !T.blocks_air))
								//	zone.RemoveTurf(T)
								if(T.zone in zone.connections)
									zone.Disconnect(src,T)
								if(istype(T,/turf/space) || istype(T,/turf/unsimulated/floor/hull))
									//if(!CanPass(null,T,0,0))
									zone.space_connections -= T
							//if(direction & old_air_directions)
								//if(!ticker || !old_air_directions || !air_check_directions) return
								//else
									//SplitCheck(T)
								//world << "Space connection removed."
				/*if(istype(src,/turf/simulated/floor/open))
					var/turf/simulated/D = get_step(src,DOWN)
					if(D)
						world << "Connection occurred between z-levels."
						zone.Connect(src,D)
				else
					var/turf/simulated/D = get_step(src,DOWN)
					if(D)
						if(D.zone in zone.connections)
							world << "Disconnection occurred between z-levels."
							zone.Disconnect(src,D)*/

				parent.length_space_border += length_space_border

			if(air_check_directions)
				processing = 1
				if(!parent)
					air_master.add_singleton(src)
			else
				processing = 0
				//if(zone)
					//overlays += ad_process

		process_cell()
			var/turf/simulated/list/possible_fire_spreads = list()
			if(processing)
				if(archived_cycle < air_master.current_cycle) //archive self if not already done
					archive()
				current_cycle = air_master.current_cycle

				for(var/direction in cardinal)
					if(air_check_directions&direction) //Grab all valid bordering tiles
						var/turf/simulated/enemy_tile = get_step_3d(src, direction)
						if(dbg_processing && (direction == 16 || direction == 32))
							world << "Direction [direction]: [enemy_tile]"
						var/connection_difference = 0

						if(istype(enemy_tile))
							if(enemy_tile.archived_cycle < archived_cycle) //archive bordering tile information if not already done
								enemy_tile.archive()
							if(enemy_tile.parent && enemy_tile.parent.group_processing) //apply tile to group sharing
								if(enemy_tile.parent.current_cycle < current_cycle)
									if(enemy_tile.parent.air.check_gas_mixture(air))
										connection_difference = air.share(enemy_tile.parent.air)
									else
										enemy_tile.parent.suspend_group_processing()
										connection_difference = air.share(enemy_tile.air)
										//group processing failed so interact with individual tile
							else
								if(enemy_tile.current_cycle < current_cycle)
									connection_difference = air.share(enemy_tile.air)
							if(active_hotspot)
								possible_fire_spreads += enemy_tile
						else
							connection_difference = mimic_air_with_tile(enemy_tile)
								//bordering a tile with fixed air properties

						if(connection_difference)
							if(connection_difference > 0)
								consider_pressure_difference(connection_difference, direction)
							else
								enemy_tile.consider_pressure_difference(connection_difference, direction)
			else
				air_master.active_singletons -= src //not active if not processing!

			var/turf/simulated/above = get_step_3d(src,UP)
			if(istype(above,/turf/simulated/floor/open) && active_hotspot)
				possible_fire_spreads += above
			if(istype(src,/turf/simulated/floor/open))
				if(active_hotspot && istype(src:floorbelow,/turf/simulated))
					possible_fire_spreads += src:floorbelow

			air.react()

			if(active_hotspot)
				active_hotspot.process(possible_fire_spreads)

			if(air.temperature > MINIMUM_TEMPERATURE_START_SUPERCONDUCTION)
				consider_superconductivity(starting = 1)

			if(air.check_tile_graphic())
				update_visuals(air)

			if(air.temperature > FIRE_MINIMUM_TEMPERATURE_TO_EXIST)
				hotspot_expose(air.temperature, CELL_VOLUME)
				for(var/atom/movable/item in src)
					item.temperature_expose(air, air.temperature, CELL_VOLUME)
				temperature_expose(air, air.temperature, CELL_VOLUME)

			return 1

		super_conduct()
			var/conductivity_directions = 0
			if(blocks_air)
				//Does not participate in air exchange, so will conduct heat across all four borders at this time
				conductivity_directions = NORTH|SOUTH|EAST|WEST

				if(archived_cycle < air_master.current_cycle)
					archive()

			else
				//Does particate in air exchange so only consider directions not considered during process_cell()
				conductivity_directions = ~air_check_directions & (NORTH|SOUTH|EAST|WEST)

			if(conductivity_directions>0)
				//Conduct with tiles around me
				for(var/direction in cardinal)
					if(conductivity_directions&direction)
						var/turf/neighbor = get_step(src,direction)

						if(istype(neighbor, /turf/simulated)) //anything under this subtype will share in the exchange
							var/turf/simulated/modeled_neighbor = neighbor

							if(modeled_neighbor.archived_cycle < air_master.current_cycle)
								modeled_neighbor.archive()

							if(modeled_neighbor.air)
								if(air) //Both tiles are open

									if(modeled_neighbor.parent && modeled_neighbor.parent.group_processing)
										if(parent && parent.group_processing)
											//both are acting as a group
											//modified using construct developed in datum/air_group/share_air_with_group(...)

											var/result = parent.air.check_both_then_temperature_share(modeled_neighbor.parent.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
											if(result==0)
												//have to deconstruct parent air group

												parent.suspend_group_processing()
												if(!modeled_neighbor.parent.air.check_me_then_temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT))
													//may have to deconstruct neighbors air group

													modeled_neighbor.parent.suspend_group_processing()
													air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
											else if(result==-1)
												// have to deconstruct neightbors air group but not mine

												modeled_neighbor.parent.suspend_group_processing()
												parent.air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
										else
											air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
									else
										if(parent && parent.group_processing)
											if(!parent.air.check_me_then_temperature_share(air, WINDOW_HEAT_TRANSFER_COEFFICIENT))
												//may have to deconstruct neighbors air group

												parent.suspend_group_processing()
												air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)

										else
											air.temperature_share(modeled_neighbor.air, WINDOW_HEAT_TRANSFER_COEFFICIENT)
						//			world << "OPEN, OPEN"

								else //Solid but neighbor is open
									if(modeled_neighbor.parent && modeled_neighbor.parent.group_processing)
										if(!modeled_neighbor.parent.air.check_me_then_temperature_turf_share(src, modeled_neighbor.thermal_conductivity))

											modeled_neighbor.parent.suspend_group_processing()
											modeled_neighbor.air.temperature_turf_share(src, modeled_neighbor.thermal_conductivity)
									else
										modeled_neighbor.air.temperature_turf_share(src, modeled_neighbor.thermal_conductivity)
						//			world << "SOLID, OPEN"

							else
								if(air) //Open but neighbor is solid
									if(parent && parent.group_processing)
										if(!parent.air.check_me_then_temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity))
											parent.suspend_group_processing()
											air.temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity)
									else
										air.temperature_turf_share(modeled_neighbor, modeled_neighbor.thermal_conductivity)
						//			world << "OPEN, SOLID"

								else //Both tiles are solid
									share_temperature_mutual_solid(modeled_neighbor, modeled_neighbor.thermal_conductivity)
						//			world << "SOLID, SOLID"

							modeled_neighbor.consider_superconductivity()

						else
							if(air) //Open
								if(parent && parent.group_processing)
									if(!parent.air.check_me_then_temperature_mimic(neighbor, neighbor.thermal_conductivity))
										parent.suspend_group_processing()
										air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
								else
									air.temperature_mimic(neighbor, neighbor.thermal_conductivity)
							else
								mimic_temperature_solid(neighbor, neighbor.thermal_conductivity)

			//Radiate excess tile heat to space
			var/turf/space/sample_space = locate(/turf/space)
			if(sample_space && (temperature > T0C))
			//Considering 0 degC as te break even point for radiation in and out
				mimic_temperature_solid(sample_space, FLOOR_HEAT_TRANSFER_COEFFICIENT)

			//Conduct with air on my tile if I have it
			if(air)
				if(parent && parent.group_processing)
					if(!parent.air.check_me_then_temperature_turf_share(src, thermal_conductivity))
						parent.suspend_group_processing()
						air.temperature_turf_share(src, thermal_conductivity)
				else
					air.temperature_turf_share(src, thermal_conductivity)


			//Make sure still hot enough to continue conducting heat
			if(air)
				if(air.temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
					being_superconductive = 0
					air_master.active_super_conductivity -= src
					return 0

			else
				if(temperature < MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION)
					being_superconductive = 0
					air_master.active_super_conductivity -= src
					return 0

		proc/mimic_temperature_solid(turf/model, conduction_coefficient)
			var/delta_temperature = (temperature_archived - model.temperature)
			if((heat_capacity > 0) && (abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER))

				var/heat = conduction_coefficient*delta_temperature* \
					(heat_capacity*model.heat_capacity/(heat_capacity+model.heat_capacity))
				temperature -= heat/heat_capacity

		proc/share_temperature_mutual_solid(turf/simulated/sharer, conduction_coefficient)
			var/delta_temperature = (temperature_archived - sharer.temperature_archived)
			if(abs(delta_temperature) > MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER)

				var/heat = conduction_coefficient*delta_temperature* \
					(heat_capacity*sharer.heat_capacity/(heat_capacity+sharer.heat_capacity))

				temperature -= heat/heat_capacity
				sharer.temperature += heat/sharer.heat_capacity

		proc/consider_superconductivity(starting)

			if(being_superconductive || !thermal_conductivity)
				return 0

			if(air)
				if(air.temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
					return 0
				if(air.heat_capacity() < MOLES_CELLSTANDARD*0.1*0.05)
					return 0
			else
				if(temperature < (starting?MINIMUM_TEMPERATURE_START_SUPERCONDUCTION:MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION))
					return 0

			being_superconductive = 1

			air_master.active_super_conductivity += src
