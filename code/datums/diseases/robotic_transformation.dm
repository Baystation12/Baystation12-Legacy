//Nanomachines!

/datum/disease/robotic_transformation
	name = "Robotic Transformation"
	max_stages = 5
	spread = "Syringe"
	cure = "None"
	affected_species = list("Human")

/datum/disease/robotic_transformation/stage_act()
	..()
	if (!affected_mob.stat != 2)
		return
	switch(stage)
		if(2)
			if (prob(8))
				affected_mob << "Your joints feel stiff."
				affected_mob.bruteloss += 1
				affected_mob.updatehealth()
			if (prob(9))
				affected_mob << "\red Beep...boop.."
			if (prob(9))
				affected_mob << "\red Boop...beeep..."
		if(3)
			if (prob(8))
				affected_mob << "\red Your joints feel very stiff."
				affected_mob.bruteloss += 1
				affected_mob.updatehealth()
			if (prob(8))
				affected_mob.say(pick("Beep, boop", "beep, beep!", "Boop...boop"))
			if (prob(10))
				affected_mob << "Your skin feels loose."
				affected_mob.bruteloss += 5
				affected_mob.updatehealth()
			if (prob(4))
				affected_mob << "\red You feel a stabbing pain in your head."
				affected_mob.paralysis += 2
			if (prob(4))
				affected_mob << "\red You can feel something move...inside."
		if(4)
			if (prob(10))
				affected_mob << "\red Your skin feels very loose."
				affected_mob.bruteloss += 8
				affected_mob.updatehealth()
			if (prob(20))
				affected_mob.say(pick("beep, beep!", "Boop boop boop beep.", "kkkiiiill mmme", "I wwwaaannntt tttoo dddiiieeee..."))
			if (prob(8))
				affected_mob << "\red You can feel... something...inside you."
		if(5)
			affected_mob <<"\red Your skin feels as if it's about to burst off..."
			affected_mob.toxloss += 10
			affected_mob.updatehealth()
			if(prob(40)) //So everyone can feel like robot Seth Brundle
				var/turf/T = find_loc(affected_mob)
				if(T)
					gibs(T)
				affected_mob:Robotize()
