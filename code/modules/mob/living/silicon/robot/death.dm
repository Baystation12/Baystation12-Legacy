/mob/living/silicon/robot/death(gibbed)
	var/cancel
	src.stat = 2
	src.canmove = 0

	src.camera.status = 0.0

	if(src.blind)
		src.blind.layer = 0
	src.sight |= SEE_TURFS
	src.sight |= SEE_MOBS
	src.sight |= SEE_OBJS

	src.see_in_dark = 8
	src.see_invisible = 2
	src.updateicon()

	var/tod = time2text(world.realtime,"hh:mm:ss") //weasellos time of death patch
	store_memory("Time of death: [tod]", 0)

	for(var/mob/M in world)
		if ((M.client && !( M.stat )))
			cancel = 1
			break
	if (!( cancel ))
		world << "<B>Everyone is dead! Resetting in 30 seconds!</B>"
		spawn( 300 )
			log_game("Rebooting because of no live players")
			world.Reboot()
			return
	if (src.client)
		spawn(50)
			if(src.client && src.stat == 2)
				src.verbs += /mob/proc/ghostize
	return ..(gibbed)