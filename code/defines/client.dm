/client
	var/obj/admins/holder = null
	var/listen_ooc = 1
	var/move_delay = 1
	var/moving = null
	var/vote = null
	var/showvote = null
	var/adminobs = null
	var/deadchat = 0.0
	var/changes = 0
	var/canplaysound = 1
	var/ambience_playing = null
	var/no_ambi = 0
	var/playadminsound = 1
	var/area = null
	var/played = 0
	var/team = null
	var/buildmode = 0
	var/stealth = 0
	var/fakekey = null
	var/warned = 0
	var/admin_invis = 0
	var/list/ctab_settings = list()

	// comment out the line below when debugging locally to enable the options & messages menu
	control_freak = 1