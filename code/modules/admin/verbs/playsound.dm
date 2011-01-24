/client/proc/play_sound(S as sound)
	set category = "Special Verbs"
	set name = "play sound"

	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(src.ckey == "wrongnumber")
		return

	var/sound/uploaded_sound = sound(S,0,1,0)
	uploaded_sound.priority = 255
	uploaded_sound.wait = 1

	if(src.holder.rank == "Host" || src.holder.rank == "Coder" || src.holder.rank == "Super Administrator")
		log_admin("[key_name(src)] played sound [S]")
		message_admins("[key_name_admin(src)] played sound [S]", 1)
		world << uploaded_sound
	else
		if(usr.client.canplaysound)
			usr.client.canplaysound = 0
			log_admin("[key_name(src)] played sound [S]")
			message_admins("[key_name_admin(src)] played sound [S]", 1)
			world << uploaded_sound
		else
			usr << "You already used up your jukebox monies this round!"
			del(uploaded_sound)
//	else
//		usr << "Can't play Sound."


	//else
	//	alert("Debugging is disabled")
	//	return