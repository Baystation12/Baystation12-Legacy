// Controls the emergency shuttle


// these define the time taken for the shuttle to get to SS13
// and the time before it leaves again
#define SHUTTLEARRIVETIME 600		// 10 minutes = 600 seconds
#define SHUTTLELEAVETIME 180		// 3 minutes = 180 seconds

var/global/datum/shuttle/main_shuttle

var/global/list/datum/shuttle/shuttles = list()



datum/shuttle
	var
		name = "Shuttle"
		location = 0 //0 = somewhere far away, 1 = at SS13, 2 = returned from SS13
		online = 0
		direction = 1 //-1 = going back to central command, 1 = going back to SS13

		area
			centcom
			station

		endtime			// timeofday that shuttle arrives
		//timeleft = 360 //600


	// call the shuttle
	// if not called before, set the endtime to T+600 seconds
	// otherwise if outgoing, switch to incoming
	proc/incall()
		if(endtime)
			if(direction == -1)
				setdirection(1)
		else
			settimeleft(SHUTTLEARRIVETIME)
			online = 1

	proc/recall()
		if(direction == 1)
			setdirection(-1)
			online = 1


	// returns the time (in seconds) before shuttle arrival
	// note if direction = -1, gives a count-up to SHUTTLEARRIVETIME
	proc/timeleft()
		if(online)
			var/timeleft = round((endtime - world.timeofday)/10 ,1)
			if(direction == 1)
				return timeleft
			else
				return SHUTTLEARRIVETIME-timeleft
		else
			return SHUTTLEARRIVETIME

	// sets the time left to a given delay (in seconds)
	proc/settimeleft(var/delay)
		endtime = world.timeofday + delay * 10

	// sets the shuttle direction
	// 1 = towards SS13, -1 = back to centcom
	proc/setdirection(var/dirn)
		if(direction == dirn)
			return
		direction = dirn
		// if changing direction, flip the timeleft by SHUTTLEARRIVETIME
		var/ticksleft = endtime - world.timeofday
		endtime = world.timeofday + (SHUTTLEARRIVETIME*10 - ticksleft)
		return

	proc
		process()
			if(!online) return
			var/timeleft = timeleft()
			if(timeleft > 1e5)		// midnight rollover protection
				timeleft = 0
			switch(location)
				if(0)
					if(timeleft>SHUTTLEARRIVETIME)
						online = 0
						direction = 1
						endtime = null

						return 0

					else if(timeleft <= 0)
						location = 1

						var/area/start_location = locate(centcom)
						var/area/end_location = locate(station)

						var/list/dstturfs = list()
						var/throwy = world.maxy

						for(var/turf/T in end_location)
							dstturfs += T
							if(T.y < throwy)
								throwy = T.y

						// hey you, get out of the way!
						for(var/turf/T in dstturfs)
							// find the turf to move things to
							var/turf/D = locate(T.x, throwy - 1, 1)
							//var/turf/E = get_step(D, SOUTH)
							for(var/atom/movable/AM as mob|obj in T)
								AM.Move(D)
								// NOTE: Commenting this out to avoid recreating mass driver glitch
								/*
								spawn(0)
									AM.throw_at(E, 1, 1)
									return
								*/
							if(istype(T, /turf/simulated))
								del(T)

						start_location.move_contents_to(end_location)
						settimeleft(SHUTTLELEAVETIME)
						world << "<B>The Emergency Shuttle has docked with the station! You have [timeleft()/60] minutes to board the Emergency Shuttle.</B>"

						return 1

				if(1)
					if(timeleft>0)
						return 0

					else
						location = 2
						var/area/start_location = locate(station)
						var/area/end_location = locate(centcom)

						start_location.move_contents_to(end_location)
						online = 0

						return 1

				else
					return 1
