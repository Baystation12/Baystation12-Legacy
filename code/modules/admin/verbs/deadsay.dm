/client/proc/dsay(msg as text)
	set category = "Special Verbs"
	set name = "dsay"
	set hidden = 1
	//	All admins should be authenticated, but... what if?
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(!src.mob)
		return
	if(src.mob.muted)
		return

	msg = copytext(sanitize(msg), 1, MAX_MESSAGE_LEN)
	log_admin("[key_name(src)] : [msg]")

	if (!msg)
		return

	var/rendered = "<span class='game deadsay'><span class='prefix'>DEAD:</span> <span class='name'>ADMIN([src.stealth ? pick("BADMIN", "ViktoriaSA", "Drunkwaffel", "Android Datuhh") : src.key])</span> says, <span class='message'>\"[msg]\"</span></span>"

	for (var/client/C)
		if(C.mob.stat == 2 || (C.holder))
			C.mob.show_message(rendered, 2)