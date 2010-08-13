datum
	objective
		var/datum/mind/owner
		var/explanation_text

		New(var/text)
			if(text)
				src.explanation_text = text

		proc
			check_completion()
				return 1

		assassinate
			var/datum/mind/target

			proc/find_target()
				var/list/possible_targets = list()

				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target

				if(possible_targets.len > 0)
					target = pick(possible_targets)

				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target

			proc/find_target_by_role(var/role)
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
						target = possible_target
						break

				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target

			check_completion()
				if(target && target.current)
					if(target.current.stat == 2)
						return 1
					else
						return 0
				else
					return 1

		hijack
			explanation_text = "Hijack the emergency shuttle by escaping alone."

			check_completion()
				if(main_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat ==2)
					return 0
				for(var/datum/shuttle/s in shuttles)
					var/area/shuttle = locate(s.centcom)

					for(var/mob/living/player in world)
						if (player.mind && (player.mind != owner))
							if (player.stat != 2) //they're not dead
								if (get_turf(player) in shuttle)
									return 0

				return 1

		escape
			explanation_text = "Escape on the shuttle alive, without being arrested"

			check_completion()
				if(main_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat ==2)
					return 0

				var/turf/location = get_turf(owner.current.loc)
				if(!location)
					return 0

				if(owner.current:handcuffed)
					return 0

				var/area/check_area = location.loc

				for(var/datum/shuttle/s in shuttles)
					if(istype(check_area, s.centcom))
						return 1

				return 0

		survive
			explanation_text = "Stay alive until the end"

			check_completion()
				if(!owner.current || owner.current.stat == 2)
					return 0

				return 1


		steal
			var/obj/item/steal_target
			var/target_name
			proc/find_target()
				var/list/items = list("captain's antique laser gun", "hand teleporter", "RCD", "jetpack", "captains jumpsuit")

				target_name = pick(items)
				switch(target_name)
					if("captain's antique laser gun")
						steal_target = /obj/item/weapon/gun/energy/laser_gun/captain
					if("hand teleporter")
						steal_target = /obj/item/weapon/hand_tele
					if("RCD")
						steal_target = /obj/item/weapon/rcd
					if("jetpack")
						steal_target = /obj/item/weapon/tank/jetpack
					if("captains jumpsuit")
						steal_target = /obj/item/clothing/under/rank/captain


				explanation_text = "Steal a [target_name]."

				return steal_target

			check_completion()
				if(steal_target)
					if(owner.current.check_contents_for(steal_target))
						return 1
					else
						return 0

		nuclear
			explanation_text = "Destroy the station with a nuclear device."


