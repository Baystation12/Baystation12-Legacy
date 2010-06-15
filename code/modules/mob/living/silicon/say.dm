/mob/living/silicon/say(var/message)
	if (!message)
		return

	if (src.muted)
		return

	if (src.stat == 2)
		message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
		return src.say_dead(message)

	// wtf?
	if (src.stat)
		return

	if (length(message) >= 2)
		if (copytext(message, 1, 3) == ":s")
			message = copytext(message, 3)
			message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))
			src.robot_talk(message)
		else
			return ..(message)
	else
		return ..(message)


/mob/living/silicon/proc/robot_talk(var/message)

	log_say("[key_name(src)] : [message]")

	message = trim(message)

	if (!message)
		return

	var/message_a = src.say_quote(message)
	var/rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[src.name]</span> <span class='message'>[message_a]</span></span></i>"
	for (var/mob/living/silicon/S in world)
		if(!S.stat)
			S.show_message(rendered, 2)

	var/list/listening = hearers(1, src)
	listening -= src
	listening += src

	var/list/heard = list()
	for (var/mob/M in listening)
		if(!istype(M, /mob/living/silicon))
			heard += M


	if (length(heard))
		var/message_b

		message_b = "beep beep beep"
		message_b = src.say_quote(message_b)
		message_b = "<i>[message_b]</i>"

		rendered = "<i><span class='game say'><span class='name'>[src.voice_name]</span> <span class='message'>[message_b]</span></span></i>"

		for (var/mob/M in heard)
			M.show_message(rendered, 2)

	message = src.say_quote(message)

	rendered = "<i><span class='game say'>Robotic Talk, <span class='name'>[src.name]</span> <span class='message'>[message_a]</span></span></i>"

	for (var/mob/M in world)
		if (istype(M, /mob/new_player))
			continue
		if (M.stat > 1)
			M.show_message(rendered, 2)