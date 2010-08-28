/proc/start_events()
	if (!event && prob(eventchance))
		meteor()
		hadevent = 1
		spawn(1300)
			event = 0
		spawn(1200)
		start_events()
	return // Stub

/proc/meteor()
	event = 1
//	command_alert("Meteors have been detected on collision course with the station.", "Meteor Alert")
	spawn(100)
		meteor_wave()
		meteor_wave()
	spawn(500)
		meteor_wave()
		meteor_wave()

/proc/event(var/eventnum = 0)
	if(eventson == 0)
		return
	if(!eventnum)
		eventnum = rand(1,6)
	switch(eventnum)
		if(1)
			event = 1
			command_alert("Meteors have been detected on collision course with the ship.", "Meteor Alert")
			spawn(100)
				meteor_wave()
				meteor_wave()
			spawn(500)
				meteor_wave()
				meteor_wave()

		if(2)
			event = 1
			command_alert("Gravitational anomalies detected on the ship. There is no additional data.", "Anomaly Alert")
			var/turf/T = pick(blobstart)
			var/obj/bhole/bh = new /obj/bhole( T.loc, 30 )
			spawn(rand(50, 300))
				del(bh)

		if(3)
			event = 1
			command_alert("Space-time anomalies detected on the ship. There is no additional data.", "Anomaly Alert")
			var/list/turfs = list(	)
			var/turf/picked
			for(var/turf/T in world)
				if(T.z == 1 && istype(T,/turf/simulated/floor) && !istype(T,/turf/space))
					turfs += T
			for(var/turf/T in world)
				if(prob(20) && (T.z >= 1 && T.z <= 4) && istype(T,/turf/simulated/floor))
					spawn(50+rand(0,3000))
						picked = pick(turfs)
						var/obj/portal/P = new /obj/portal( T )
						P.target = picked
						P.creator = null
						P.icon = 'objects.dmi'
						P.failchance = 0
						P.icon_state = "anom"
						P.name = "wormhole"
						spawn(rand(300,600))
							del(P)
		if(4)
			event = 1
			command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
			var/turf/T = pick(blobstart)
			var/obj/blob/bl = new /obj/blob( T.loc, 30 )
			spawn(0)
				bl.Life()
				bl.Life()
				bl.Life()
				bl.Life()
				bl.Life()
			blobevent = 1
			dotheblobbaby()
			spawn(3000)
				blobevent = 0
			//start loop here


		if(5)
			event = 1
			command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange.", "Anomaly Alert")
			for(var/mob/living/carbon/human/H in world)
				H.radiation += rand(5,25)
				if (prob(5))
					H.radiation += rand(30,50)
				if (prob(25))
					if (prob(75))
						randmutb(H)
						domutcheck(H,null,1)
					else
						randmutg(H)
						domutcheck(H,null,1)
			for(var/mob/living/carbon/monkey/M in world)
				M.radiation += rand(5,25)
		if(6)
			event = 1
			viral_outbreak()


/proc/new_event(var/severity)
	if(severity == 1)
		switch(rand(1,2))
			if(1)
				event_meteors()
			if(2)
				event_apcoverload()
	else if(severity == 2)
		switch(rand(1,2))
			if(1)
				event_portal()
			if(2)
				viral_outbreak()
	else if(severity == 3)
		switch(rand(1,2))
			if(1)
				event_apcoverload()
				spawn(100)
					event_meteors()
			if(2)
				event_bh()
	return



/proc/event_blob()
	event = 1
	command_alert("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
	var/turf/T = pick(blobstart)
	var/obj/blob/bl = new /obj/blob( T.loc, 30 )
	spawn(0)
		bl.Life()
		bl.Life()
		bl.Life()
		bl.Life()
		bl.Life()
	blobevent = 1
	dotheblobbaby()
	spawn(3000)
		blobevent = 0

/proc/event_bh()
	event = 1
	command_alert("Gravitational anomalies detected on the ship. There is no additional data.", "Anomaly Alert")
	var/turf/T = pick(blobstart)
	var/obj/bhole/bh = new /obj/bhole( T.loc, 30 )
	spawn(rand(50, 300))
		del(bh)

/proc/event_portal()
	event = 1
	command_alert("Space-time anomalies detected on the ship. There is no additional data.", "Anomaly Alert")
	var/list/turfs = list(	)
	var/turf/picked
	for(var/turf/T in world)
		if(T.z == 1 && istype(T,/turf/simulated/floor) && !istype(T,/turf/space))
			turfs += T
	for(var/turf/T in world)
		if(prob(20) && T.z == 1 && istype(T,/turf/simulated/floor))
			spawn(50+rand(0,3000))
				picked = pick(turfs)
				var/obj/portal/P = new /obj/portal( T )
				P.target = picked
				P.creator = null
				P.icon = 'objects.dmi'
				P.failchance = 0
				P.icon_state = "anom"
				P.name = "wormhole"
				spawn(rand(300,600))
					del(P)


/proc/event_apcoverload()
	event = 1
	command_alert("An electrical storm has been detected, electrical equipment may be effected.", "Electrical Storm")
	for(var/obj/machinery/power/apc/a in world)
		//Crit is a new var, to stop the AI room APC from instantly killing the AI
		if(prob(8) && a.crit == 0)
			spawn(rand(100,500))
				a.overload_lighting()
				a.set_broken()
	for(var/obj/machinery/door/airlock/b in world)
		if(prob(8))
			spawn(rand(100,500))
				b.cut(1)
				b.cut(2)
				b.cut(3)
				b.cut(4)
				b.cut(5)
				b.cut(6)
				b.cut(7)
				b.cut(8)
				b.cut(9)


/proc/event_meteors()
	event = 1
	command_alert("Meteors have been detected on collision course with the ship.", "Meteor Alert")
	spawn(100)
		meteor_wave()
		meteor_wave()
	spawn(500)
		meteor_wave()
		meteor_wave()



/proc/dotheblobbaby()
	if (blobevent)
		for(var/obj/blob/B in world)
			if (prob (40))
				B.Life()
		spawn(30)
			dotheblobbaby()

/obj/bhole/New()
	src.smoke = new /datum/effects/system/harmless_smoke_spread()
	src.smoke.set_up(5, 0, src)
	src.smoke.attach(src)
	src:life()

/obj/bhole/Bumped(atom/A)
	var/mob/dead/observer/newmob
	if (istype(A,/mob/living) && A:client)
		newmob = new/mob/dead/observer(A)
		A:client:mob = newmob
		newmob:client:eye = newmob
		del(A)
	else if (istype(A,/mob/living) && !A:client)
		del(A)
	else
		A:ex_act(1.0)


/obj/bhole/proc/life() //Oh man , this will LAG

	if (prob(10))
		src.anchored = 0
		step(src,pick(alldirs))
		if (prob(30))
			step(src,pick(alldirs))
		src.anchored = 1

	for (var/atom/X in orange(9,src))
		if ((istype(X,/obj) || istype(X,/mob/living)) && prob(7))
			if (!X:anchored)
				step_towards_3d(X,src)

	for (var/atom/B in orange(7,src))
		if (istype(B,/obj))
			if (!B:anchored && prob(50))
				step_towards_3d(B,src)
				if(prob(10)) B:ex_act(3.0)
			else
				B:anchored = 0
				//step_towards_3d(B,src)
				//B:anchored = 1
				if(prob(10)) B:ex_act(3.0)
		else if (istype(B,/turf))
			if (istype(B,/turf/simulated) && (prob(1) && prob(75)))
				src.smoke.start()
				B:ReplaceWithSpace()
		else if (istype(B,/mob/living))
			step_towards_3d(B,src)


	for (var/atom/A in orange(4,src))
		if (istype(A,/obj))
			if (!A:anchored && prob(90))
				step_towards_3d(A,src)
				if(prob(30)) A:ex_act(2.0)
			else
				A:anchored = 0
				//step_towards_3d(A,src)
				//A:anchored = 1
				if(prob(30)) A:ex_act(2.0)
		else if (istype(A,/turf))
			if (istype(A,/turf/simulated) && prob(1))
				src.smoke.start()
				A:ReplaceWithSpace()
		else if (istype(A,/mob/living))
			step_towards_3d(A,src)


	for (var/atom/D in orange(1,src))
		//if (hascall(D,"blackholed"))
		//	call(D,"blackholed")(null)
		//	continue
		var/mob/dead/observer/newmob
		if (istype(D,/mob/living) && D:client)
			newmob = new/mob/dead/observer(D)
			D:client:mob = newmob
			newmob:client:eye = newmob
			del(D)
		else if (istype(D,/mob/living) && !D:client)
			del(D)
		else
			D:ex_act(1.0)

	spawn(17)
		life()

/proc/power_failure()
	command_alert("Abnormal activity detected in [station_name()]'s powernet. As a precautionary measure, the station's power will be shut off for an indeterminate duration.", "Critical Power Failure")
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = 0
	for(var/obj/machinery/power/smes/S in world)
		if(istype(get_area(S), /area/turret_protected) || S.z != 1)
			continue
		S.charge = 0
		S.output = 0
		S.online = 0
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 0
			A.power_equip = 0
			A.power_environ = 0
			A.power_change()

/proc/power_restore()
	command_alert("Power has been restored to [station_name()]. We apologize for the inconvenience.", "Power Systems Nominal")
	for(var/obj/machinery/power/apc/C in world)
		if(C.cell && C.z == 1)
			C.cell.charge = C.cell.maxcharge
	for(var/obj/machinery/power/smes/S in world)
		if(S.z != 1)
			continue
		S.charge = S.capacity
		S.output = 200000
		S.online = 1
		S.updateicon()
		S.power_change()
	for(var/area/A in world)
		if(A.name != "Space" && A.name != "Engine Walls" && A.name != "Chemical Lab Test Chamber" && A.name != "space" && A.name != "Escape Shuttle" && A.name != "Arrival Area" && A.name != "Arrival Shuttle" && A.name != "start area" && A.name != "Engine Combustion Chamber")
			A.power_light = 1
			A.power_equip = 1
			A.power_environ = 1
			A.power_change()

/proc/viral_outbreak()
	command_alert("Confirmed outbreak of level 7 viral biohazard aboard [station_name()]. All personnel must contain the outbreak.", "Biohazard Alert")
	var/virus_type = /datum/disease/cold
	for(var/mob/living/carbon/human/H in world)
		if((H.virus) || (H.stat == 2))
			continue
		if(virus_type == /datum/disease/dnaspread) //Dnaspread needs strain_data set to work.
			if((!H.dna) || (H.sdisabilities & 1)) //A blindness disease would be the worst.
				continue
			var/datum/disease/dnaspread/D = new
			D.strain_data["name"] = H.real_name
			D.strain_data["UI"] = H.dna.uni_identity
			D.strain_data["SE"] = H.dna.struc_enzymes
			D.carrier = 1
			D.affected_mob = H
			H.virus = D
			break
		else
			H.virus = new virus_type
			H.virus.affected_mob = H
			H.virus.carrier = 1
			break