/datum/configuration
	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port

	var/medal_hub = null				// medal hub name
	var/medal_password = null			// medal hub password

	var/log_ooc = 0						// log OOC channek
	var/log_access = 0					// log login/logout
	var/log_say = 0						// log client say
	var/log_admin = 0					// log admin actions
	var/log_game = 0					// log game events
	var/log_vote = 0					// log voting
	var/log_whisper = 0					// log client whisper
	var/allow_vote_restart = 0 			// allow votes to restart
	var/allow_vote_mode = 0				// allow votes to change mode
	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives
	var/vote_delay = 600				// minimum time between voting sessions (seconds, 10 minute default)
	var/vote_period = 60				// length of voting period (seconds, default 1 minute)
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)
	var/invite_only = 0
	var/visibility = 0
	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/allow_ai = 1					// allow ai job
	var/hostedby = null
	var/respawn = 1
	var/mode_hidden = 0
var/makejson
/datum/configuration/New()
	var/list/L = typesof(/datum/game_mode) - /datum/game_mode
	for (var/T in L)
		var/datum/game_mode/M = new T()

		if (M.config_tag && M.enabled)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				check_diary()
				diary << "Adding game mode [M.name] ([M.config_tag]) to configuration."
				src.modes += M.config_tag
				src.mode_names[M.config_tag] = M.name
				src.probabilities[M.config_tag] = 0
				if (M.votable)
					src.votable_modes += M.config_tag
		del(M)

/datum/configuration/proc/load(filename)
	var/text = file2text(filename)

	if (!text)
		check_diary()
		diary << "No config.txt file found, setting defaults"
		src = new /datum/configuration()
		return

	check_diary()
	diary << "Reading configuration file [filename]"

	var/list/CL = dd_text2list(text, "\n")

	for (var/t in CL)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if("makejson")
				makejson = 1
			if ("log_ooc")
				config.log_ooc = 1
			if ("mode_hidden")
				config.mode_hidden = 1

			if ("log_access")
				config.log_access = 1

			if ("log_say")
				config.log_say = 1

			if ("log_admin")
				config.log_admin = 1

			if ("log_game")
				config.log_game = 1

			if ("log_vote")
				config.log_vote = 1

			if ("log_whisper")
				config.log_whisper = 1

			if ("allow_vote_restart")
				config.allow_vote_restart = 1

			if ("allow_vote_mode")
				config.allow_vote_mode = 1

			if ("allow_admin_jump")
				config.allow_admin_jump = 1

			if("allow_admin_rev")
				config.allow_admin_rev = 1

			if ("allow_admin_spawning")
				config.allow_admin_spawning = 1

			if ("no_dead_vote")
				config.vote_no_dead = 1

			if ("default_no_vote")
				config.vote_no_default = 1

			if ("vote_delay")
				config.vote_delay = text2num(value)

			if ("vote_period")
				config.vote_period = text2num(value)

			if ("allow_ai")
				config.allow_ai = 1

			if ("norespawn")
				config.respawn = 0

			if ("servername")
				config.server_name = value

			if ("serversuffix")
				config.server_suffix = 1

			if ("medalhub")
				config.medal_hub = value

			if ("medalpass")
				config.medal_password = value

			if ("hostedby")
				config.hostedby = value

			if ("probability")
				check_diary()
				var/prob_pos = findtext(value, " ")
				var/prob_name = null
				var/prob_value = null

				if (prob_pos)
					prob_name = lowertext(copytext(value, 1, prob_pos))
					prob_value = copytext(value, prob_pos + 1)
					if (prob_name in config.modes)
						config.probabilities[prob_name] = text2num(prob_value)
					else
						diary << "Unknown game mode probability configuration definition: [prob_name]."
				else
					diary << "Incorrect probability configuration definition: [prob_name]  [prob_value]."
			else
				check_diary()
				diary << "Unknown setting in configuration: '[name]'"

	load_mysql()

/datum/configuration/proc/load_mysql()
	var/text = file2text("config/db_config.txt")
	var/list/CL = dd_text2list(text, "\n")

	for (var/t in CL)
		if (!t)
			continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if("db_server")
				DB_SERVER = value
			if("db_port")
				DB_PORT = text2num(value)
			if("db_user")
				DB_USER = value
			if("db_password")
				DB_PASSWORD = value
			if("db_dbname")
				DB_DBNAME = value

/datum/configuration/proc/pick_mode(mode_name)
	for (var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		if (M.config_tag && M.config_tag == mode_name)
			return M
		del(M)

	return null

/datum/configuration/proc/pick_random_mode()
	var/total = 0
	var/list/accum = list()

	for(var/M in src.modes)
		total += src.probabilities[M]
		accum[M] = total

	var/r = total - (rand() * total)

	var/mode_name = null
	for (var/M in modes)
		if (src.probabilities[M] > 0 && accum[M] >= r)
			mode_name = M
			break

	if (!mode_name)
		world << "Failed to pick a random game mode."
		return null

	return src.pick_mode(mode_name)

/datum/configuration/proc/get_used_mode_names()
	var/list/names = list()

	for (var/M in src.modes)
		if (src.probabilities[M] > 0)
			names += src.mode_names[M]

	return names