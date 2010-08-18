//GUYS REMEMBER TO ADD A += to UPDATE_ADMINS
//AND A -= TO CLEAR_ADMIN_VERBS

/client/proc/update_admins(var/rank)

	if(!src.holder)
		src.holder = new /obj/admins(src)

	src.holder.rank = rank

	if(!src.holder.state)
		var/state = alert("Which state do you the admin to begin in?", "Admin-state", "Play", "Observe", "Neither")
		if(state == "Play")
			src.holder.state = 1
			src.admin_play()
			return
		else if(state == "Observe")
			src.holder.state = 2
			src.admin_observe()
			return
		else
			del(src.holder)
			return

	switch (rank)
		if ("Host")
			src.deadchat = 1
			src.holder.level = 6
			src.verbs += /client/proc/cmd_admin_delete
			src.verbs += /proc/possess
			src.verbs += /client/proc/cmd_admin_add_random_ai_law
			src.verbs += /proc/release
			src.verbs += /proc/givetestverbs
			src.verbs += /client/proc/debug_variables
			src.verbs += /client/proc/cmd_modify_object_variables
			src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/cmd_admin_check_contents
			src.verbs += /client/proc/cmd_debug_del_all
			src.verbs += /client/proc/play_sound
			src.verbs += /client/proc/modifytemperature
			src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_explode_turf
			src.verbs += /client/proc/cmd_admin_gib_self
			src.verbs += /proc/toggle_adminmsg
//				src.verbs += /client/proc/grillify
			src.verbs += /client/proc/jumptomob
			src.verbs += /client/proc/Jump
			src.verbs += /client/proc/jumptoturf
			src.verbs += /client/proc/cmd_admin_rejuvenate
			src.verbs += /client/proc/cmd_admin_robotize
			src.verbs += /client/proc/cmd_admin_alienize
			src.verbs += /client/proc/cmd_admin_changelinginize
			src.verbs += /client/proc/Cell
			src.verbs += /client/proc/ticklag
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_godmode
			src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
//			src.verbs += /client/proc/getmobs
//			src.verbs += /client/proc/cmd_admin_list_admins
			src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /proc/togglebuildmode
			src.verbs += /client/proc/jumptokey
			src.verbs += /client/proc/Getmob
			src.verbs += /client/proc/jobbans
			src.verbs += /client/proc/sendmob
			src.verbs += /client/proc/Debug2					//debug toggle switch
			src.verbs += /client/proc/callproc
			src.verbs += /client/proc/funbutton
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggletraitorscaling	//toggle traitor scaling
			src.verbs += /obj/admins/proc/startnow				//start now bitch
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/cmd_admin_remove_plasma
			src.verbs += /client/proc/LSD_effect
			src.verbs += /client/proc/general_report
			//src.verbs += /client/proc/air_report
			//src.verbs += /client/proc/air_status
			src.verbs += /client/proc/fix_next_move

			src.verbs += /client/proc/toggle_view_range
			src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /client/proc/warn
			src.verbs += /client/proc/delay
			src.verbs += /client/proc/hubvis
			src.verbs += /client/proc/toggleinvite
			src.verbs += /client/proc/new_eventa
			src.verbs += /client/proc/toggleevents
		if ("Coder")
			src.deadchat = 1
			src.holder.level = 5
			src.verbs += /client/proc/LSD_effect
			src.verbs += /client/proc/cmd_explode_turf
			src.verbs += /client/proc/toggleevents
			src.verbs += /client/proc/cmd_admin_delete
			src.verbs += /proc/possess
			src.verbs += /client/proc/cmd_admin_add_random_ai_law
			src.verbs += /proc/release
			src.verbs += /proc/givetestverbs
			src.verbs += /client/proc/debug_variables
			src.verbs += /client/proc/cmd_debug_tog_aliens
			src.verbs += /client/proc/cmd_modify_object_variables
			src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/cmd_admin_check_contents
			src.verbs += /client/proc/cmd_debug_del_all
			src.verbs += /client/proc/play_sound
			src.verbs += /client/proc/modifytemperature
			src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
//			src.verbs += /proc/toggleai
			src.verbs += /proc/toggle_adminmsg
			src.verbs += /proc/togglebuildmode
//				src.verbs += /client/proc/grillify
			src.verbs += /client/proc/jumptomob
			src.verbs += /client/proc/Jump
			src.verbs += /client/proc/jumptoturf
			src.verbs += /client/proc/cmd_admin_rejuvenate
			src.verbs += /client/proc/cmd_admin_robotize
			src.verbs += /client/proc/cmd_admin_alienize
			src.verbs += /client/proc/cmd_admin_changelinginize
			src.verbs += /client/proc/Cell
			src.verbs += /client/proc/ticklag
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_godmode
			src.verbs += /client/proc/get_admin_state
			src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
//			src.verbs += /client/proc/getmobs
//			src.verbs += /client/proc/cmd_admin_list_admins
			src.verbs += /client/proc/cmd_admin_list_occ
			src.verbs += /client/proc/jumptokey
			src.verbs += /client/proc/Getmob
			src.verbs += /client/proc/jobbans
			src.verbs += /client/proc/sendmob
			src.verbs += /client/proc/Debug2					//debug toggle switch
			src.verbs += /client/proc/callproc
			src.verbs += /client/proc/funbutton
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggletraitorscaling
			src.verbs += /obj/admins/proc/startnow				//start now bitch
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/cmd_admin_remove_plasma

			src.verbs += /client/proc/general_report
			//src.verbs += /client/proc/air_report
			//src.verbs += /client/proc/air_status
			src.verbs += /client/proc/fix_next_move
			src.verbs += /obj/admins/proc/spawn_atom

			src.verbs += /client/proc/toggle_view_range
			src.verbs += /obj/admins/proc/toggle_aliens
			src.verbs += /client/proc/warn
			src.verbs += /client/proc/delay
			src.verbs += /client/proc/hubvis
			src.verbs += /client/proc/toggleinvite

			src.verbs += /client/proc/Zone_Info
		if ("Super Administrator")
			src.deadchat = 1
			src.holder.level = 4
			src.verbs += /client/proc/LSD_effect
			src.verbs += /client/proc/toggleevents
			src.verbs += /client/proc/debug_variables
			src.verbs += /proc/possess
			src.verbs += /client/proc/cmd_admin_add_random_ai_law
			src.verbs += /client/proc/cmd_modify_object_variables
			src.verbs += /client/proc/cmd_modify_ticker_variables
			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/cmd_explode_turf
			src.verbs += /client/proc/play_sound
			src.verbs += /client/proc/cmd_admin_gib
			src.verbs += /client/proc/cmd_admin_gib_self
			src.verbs += /client/proc/jumptomob
			src.verbs += /client/proc/modifytemperature
			src.verbs += /proc/toggle_adminmsg
//				src.verbs += /client/proc/grillify
			src.verbs += /client/proc/cmd_admin_check_contents
			src.verbs += /proc/togglebuildmode
			src.verbs += /client/proc/Jump
			src.verbs += /client/proc/jumptoturf
			src.verbs += /client/proc/cmd_admin_rejuvenate
			src.verbs += /client/proc/cmd_admin_delete
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_drop_everything
			src.verbs += /client/proc/cmd_admin_robotize
			src.verbs += /client/proc/cmd_admin_godmode
			src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
			src.verbs += /client/proc/funbutton
			src.verbs += /client/proc/jumptokey
//			src.verbs += /client/proc/cmd_admin_list_admins
			src.verbs += /client/proc/Getmob
			src.verbs += /client/proc/sendmob
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /client/proc/Debug2
			src.verbs += /client/proc/jobbans
			src.verbs += /client/proc/deadchat					//toggles deadchat
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggletraitorscaling
			src.verbs += /obj/admins/proc/startnow				//start now bitch
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
			src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /obj/admins/proc/adrev					//toggle admin revives
			src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
			src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /client/proc/cmd_admin_remove_plasma
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /client/proc/cmd_admin_subtle_message

			src.verbs += /client/proc/general_report
			//src.verbs += /client/proc/air_report
			//src.verbs += /client/proc/air_status
			src.verbs += /client/proc/fix_next_move

			src.verbs += /client/proc/toggle_view_range
			src.verbs += /client/proc/warn
			src.verbs += /client/proc/delay
			src.verbs += /client/proc/hubvis
			src.verbs += /client/proc/toggleinvite
			src.verbs += /client/proc/Zone_Info
		if ("Primary Administrator")

			src.deadchat = 1
			src.holder.level = 3

			if(src.holder.state == 2) //observing

				src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
				src.verbs += /obj/admins/proc/toggletraitorscaling
				src.verbs += /client/proc/cmd_admin_drop_everything
				src.verbs += /client/proc/debug_variables
				src.verbs += /client/proc/cmd_modify_object_variables
				src.verbs += /client/proc/cmd_modify_ticker_variables
//				src.verbs += /client/proc/cmd_admin_gib
				src.verbs += /client/proc/jumptokey
				src.verbs += /client/proc/jumptomob
				src.verbs += /client/proc/Jump
				src.verbs += /client/proc/jumptoturf
				src.verbs += /client/proc/Getmob
				src.verbs += /client/proc/sendmob
				src.verbs += /client/proc/cmd_admin_add_freeform_ai_law
				src.verbs += /client/proc/cmd_admin_rejuvenate
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /client/proc/toggle_view_range
			src.verbs += /client/proc/toggleevents
			src.verbs += /client/proc/debug_variables
			src.verbs += /proc/togglebuildmode
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggletraitorscaling
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/cmd_admin_add_random_ai_law
			src.verbs += /client/proc/cmd_explode_turf
			src.verbs += /client/proc/play_sound
//			src.verbs += /client/proc/cmd_admin_list_admins
			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_check_contents
			src.verbs += /client/proc/cmd_admin_gib_self
			src.verbs += /client/proc/cmd_admin_remove_plasma
			src.verbs += /client/proc/delay
			src.verbs += /client/proc/LSD_effect

//				src.verbs += /client/proc/modifytemperature
//				src.verbs += /client/proc/grillify

			src.verbs += /client/proc/cmd_admin_prison

			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/startnow				//start now bitch
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI

			src.verbs += /obj/admins/proc/delay					//game start delay
			src.verbs += /client/proc/deadchat					//toggles deadchat
//				src.verbs += /obj/admins/proc/adrev					//toggle admin revives
//				src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//				src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/warn
			src.verbs += /client/proc/hubvis

		if ("Administrator")

			src.holder.level = 2

			if(src.holder.state == 2) //observing
				src.deadchat = 1
				src.verbs += /client/proc/Jump
				src.verbs += /client/proc/cmd_admin_check_contents
				src.verbs += /client/proc/jumptomob
				src.verbs += /client/proc/jumptokey
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /client/proc/deadchat					//toggles deadchat

			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/cmd_admin_gib_self
//				src.verbs += /client/proc/play_sound
			src.verbs += /client/proc/cmd_admin_mute
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /client/proc/cmd_explode_turf
			src.verbs += /client/proc/cmd_admin_add_random_ai_law
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/toggletraitorscaling
			src.verbs += /obj/admins/proc/startnow				//start now bitch
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleAI
			src.verbs += /client/proc/delay				//Toggle the AI

			src.verbs += /obj/admins/proc/delay					//game start delay

//				src.verbs += /obj/admins/proc/adrev					//toggle admin revives
//				src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//				src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/warn
			src.verbs += /client/proc/hubvis
			src.verbs += /client/proc/toggleevents
		if ("Secondary Administrator")
			src.holder.level = 1

			if(src.holder.state == 2) //observing
				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
				src.verbs += /client/proc/cmd_admin_check_contents

			src.verbs += /client/proc/cmd_admin_pm

			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /client/proc/cmd_admin_gib_self
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
			src.verbs += /obj/admins/proc/restart				//restart
			src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/startnow				//start now bitch
			src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI

			src.verbs += /obj/admins/proc/delay					//game start delay
//				src.verbs += /obj/admins/proc/adrev					//toggle admin revives
//				src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//				src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /client/proc/cmd_admin_create_centcom_report
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/warn
			src.verbs += /client/proc/delay

		if ("Moderator")
			src.holder.level = 0
			src.verbs += /client/proc/cmd_admin_pm
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/dsay
			src.verbs += /client/proc/cmd_admin_prison
			src.verbs += /client/proc/cmd_admin_gib_self
			src.verbs += /obj/admins/proc/vmode   				//start vote
			src.verbs += /obj/admins/proc/votekill 				//abort vote
			src.verbs += /obj/admins/proc/voteres 				//toggle votes
//				src.verbs += /obj/admins/proc/restart				//restart
//				src.verbs += /obj/admins/proc/boot					//boot someone
//				src.verbs += /obj/admins/proc/immreboot				//immediate reboot
			src.verbs += /obj/admins/proc/announce				//global announce
			src.verbs += /obj/admins/proc/toggleooc				//toggle ooc
			src.verbs += /obj/admins/proc/startnow				//start now
//				src.verbs += /obj/admins/proc/toggleenter			//Toggle enterting
			src.verbs += /obj/admins/proc/toggleAI				//Toggle the AI
//				src.verbs += /obj/admins/proc/toggleaban			//abandon mob
			src.verbs += /obj/admins/proc/delay					//game start delay
//				src.verbs += /obj/admins/proc/adrev					//toggle admin revives
//				src.verbs += /obj/admins/proc/adspawn				//toggle admin item spawning
//				src.verbs += /obj/admins/proc/adjump				//toggle admin jumping
			src.verbs += /obj/admins/proc/unprison
			src.verbs += /client/proc/cmd_admin_subtle_message
			src.verbs += /client/proc/warn
			src.verbs += /client/proc/delay

		if ("Goat Fart")
			src.holder.level = -1
			src.verbs += /client/proc/cmd_admin_say
			src.verbs += /client/proc/cmd_admin_gib_self

		if ("Banned")
			del(src)
			return

		else
			del(src.holder)
			return

	if (src.holder)
		src.holder.owner = src
		if (src.holder.level > -1)
			src.verbs += /client/proc/admin_play
			src.verbs += /client/proc/admin_observe
			src.verbs += /client/proc/voting
			src.verbs += /client/proc/game_panel
			src.verbs += /client/proc/unban_panel
			src.verbs += /client/proc/invite_panel
			src.verbs += /client/proc/player_panel

		if(src.holder.level > 1)
			src.verbs += /client/proc/stealth
			src.verbs += /client/proc/admin_invis

		if(( src.holder.state == 2 ) || ( src.holder.level > 3 ))
			src.verbs += /client/proc/secrets

/client/proc/clear_admin_verbs()
	src.deadchat = 0
	src.verbs -= /client/proc/debug_variables
	src.verbs -= /client/proc/cmd_modify_object_variables
	src.verbs -= /client/proc/cmd_modify_ticker_variables
	src.verbs -= /client/proc/cmd_admin_pm
	src.verbs -= /client/proc/cmd_admin_say
	src.verbs -= /client/proc/dsay
	src.verbs -= /client/proc/play_sound
	src.verbs -= /client/proc/cmd_admin_gib
	src.verbs -= /client/proc/cmd_admin_gib_self
//				src.verbs -= /client/proc/modifytemperature
//				src.verbs -= /client/proc/grillify
	src.verbs -= /client/proc/Jump
	src.verbs -= /client/proc/cmd_admin_rejuvenate
	src.verbs -= /client/proc/funbutton
	src.verbs -= /client/proc/cmd_admin_delete
	src.verbs -= /client/proc/cmd_admin_mute
	src.verbs -= /client/proc/cmd_admin_drop_everything
	src.verbs -= /client/proc/cmd_debug_tog_aliens
	src.verbs -= /client/proc/cmd_admin_godmode
	src.verbs -= /client/proc/cmd_admin_add_freeform_ai_law
	src.verbs -= /client/proc/cmd_admin_check_contents
	src.verbs -= /client/proc/jumptomob
	src.verbs -= /client/proc/jumptokey
	src.verbs -= /client/proc/cmd_admin_alienize
	src.verbs -= /client/proc/cmd_admin_changelinginize
//	src.verbs -= /client/proc/cmd_admin_list_admins
	src.verbs -= /client/proc/Getmob
	src.verbs -= /client/proc/sendmob
	src.verbs -= /client/proc/cmd_admin_prison
	src.verbs -= /client/proc/Debug2
	src.verbs -= /client/proc/jobbans
	src.verbs -= /client/proc/deadchat					//toggles deadchat
	src.verbs -= /obj/admins/proc/immreboot				//immediate reboot
	src.verbs -= /obj/admins/proc/vmode   				//start vote
	src.verbs -= /obj/admins/proc/votekill 				//abort vote
	src.verbs -= /obj/admins/proc/voteres 				//toggle votes
	src.verbs -= /obj/admins/proc/restart				//restart
	src.verbs -= /obj/admins/proc/announce				//global announce
	src.verbs -= /obj/admins/proc/toggleooc				//toggle ooc
	src.verbs -= /obj/admins/proc/startnow				//start now bitch
	src.verbs -= /obj/admins/proc/toggleenter			//Toggle enterting
	src.verbs -= /obj/admins/proc/toggleAI				//Toggle the AI
	src.verbs -= /obj/admins/proc/toggleaban			//abandon mob
	src.verbs -= /obj/admins/proc/delay					//game start delay
	src.verbs -= /obj/admins/proc/adrev					//toggle admin revives
	src.verbs -= /obj/admins/proc/adspawn				//toggle admin item spawning
	src.verbs -= /obj/admins/proc/adjump				//toggle admin jumping
	src.verbs -= /obj/admins/proc/unprison
	src.verbs -= /client/proc/cmd_admin_create_centcom_report
	src.verbs -= /client/proc/game_panel
	src.verbs -= /client/proc/player_panel
	src.verbs -= /client/proc/unban_panel
	src.verbs -= /client/proc/invite_panel
	src.verbs -= /client/proc/secrets
	src.verbs -= /client/proc/voting
	src.verbs -= /client/proc/admin_play
	src.verbs -= /client/proc/admin_observe
	src.verbs -= /client/proc/stealth

	src.verbs -= /client/proc/general_report
	//src.verbs -= /client/proc/air_report
	//src.verbs -= /client/proc/air_status

	src.verbs -= /client/proc/toggle_view_range
	src.verbs -= /obj/admins/proc/toggle_aliens
	if(src.holder)
		src.holder.level = 0


/client/proc/admin_observe()
	set category = "Admin"
	set name = "Set Observe"
	if(!src.holder)
		alert("You are not an admin")
		return
/*
	if(!src.mob.start)
		alert("You cannot observe while in the starting position")
		return
*/
	src.verbs -= /client/proc/admin_play
	spawn( 1200 )										//change this to 1200
		src.verbs += /client/proc/admin_play
	var/rank = src.holder.rank
	clear_admin_verbs()
	src.holder.state = 2
	update_admins(rank)
	if(!istype(src.mob, /mob/dead/observer))
		src.mob.ghostize()
	src << "\blue You are now observing"

/client/proc/admin_play()
	set category = "Admin"
	set name = "Set Play"
	if(!src.holder)
		alert("You are not an admin")
		return
	src.verbs -= /client/proc/admin_observe
	spawn( 1200 )										//change this to 1200
		src.verbs += /client/proc/admin_observe
	var/rank = src.holder.rank
	clear_admin_verbs()
	src.holder.state = 1
	update_admins(rank)
	if(istype(src.mob, /mob/dead/observer))
		src.mob:reenter_corpse()
	src << "\blue You are now playing"

/client/proc/get_admin_state()
	set category = "Debug"
	for(var/mob/M in world)
		if(M.client && M.client.holder)
			if(M.client.holder.state == 1)
				src << "[M.key] is playing - [M.client.holder.state]"
			else if(M.client.holder.state == 2)
				src << "[M.key] is observing - [M.client.holder.state]"
			else
				src << "[M.key] is undefined - [M.client.holder.state]"

//admin client procs ported over from mob.dm

/client/proc/player_panel()
	set name = "Player Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.player()
	return

/client/proc/jobbans()
	set category = "Debug"
	if(src.holder)
		src.holder.Jobbans()
	return

/client/proc/unban_panel()
	set name = "Unban Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.unbanpanel()
	return
/client/proc/invite_panel()
	set name = "Invite Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.invite_panel()
	return

/client/proc/game_panel()
	set name = "Game Panel"
	set category = "Admin"
	if (src.holder)
		src.holder.Game()
	return

/client/proc/secrets()
	set name = "Secrets"
	set category = "Admin"
	if (src.holder)
		src.holder.Secrets()
	return

/*/client/proc/goons()
	set name = "Goons"
	set category = "Admin"
	if (src.holder)
		src.holder.goons()
	return

/client/proc/beta_testers()
	set name = "Testers"
	set category = "Admin"
	if (src.holder)
		src.holder.beta_testers()
	return*/

/client/proc/voting()
	set name = "Voting"
	set category = "Admin"
	if (src.holder)
		src.holder.Voting()

/client/proc/funbutton()
	set category = "Debug"
	set name = "Boom Boom Boom Shake The Room"
	if(!src.holder)
		src << "Only administrators may use this command."
		return

	for(var/turf/simulated/floor/T in world)
		if(prob(4) && T.z == 1 && istype(T))
			spawn(50+rand(0,3000))
				explosion(T, 3, 1)

	usr << "\blue Blowing up station ..."

	log_admin("[key_name(usr)] has used boom boom boom shake the room")
	message_admins("[key_name_admin(usr)] has used boom boom boom shake the room", 1)

/client/proc/stealth()
	set category = "Admin"
	set name = "Stealth Mode"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	src.stealth = !src.stealth
	if(src.stealth)
		var/new_key = trim(input("Enter your desired display name.", "Fake Key", src.key))
		if(!new_key)
			src.stealth = 0
			return
		new_key = strip_html(new_key)
		if(length(new_key) >= 26)
			new_key = copytext(new_key, 1, 26)
		src.fakekey = new_key
	else
		src.fakekey = null
	log_admin("[key_name(usr)] has turned stealth mode [src.stealth ? "ON" : "OFF"]")
	message_admins("[key_name_admin(usr)] has turned stealth mode [src.stealth ? "ON" : "OFF"]", 1)

/client/proc/admin_invis()
	set category = "Admin"
	set name = "Invisibility"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	src.admin_invis =! src.admin_invis
	if(src.mob)
		var/mob/m = src.mob//probably don't need this cast, but I'm too lazy to check if /client.mob is of type /mob or not
		m.update_clothing()
	log_admin("[key_name(usr)] has turned their invisibility [src.admin_invis ? "ON" : "OFF"]")
	message_admins("[key_name_admin(usr)] has turned their invisibility [src.admin_invis ? "ON" : "OFF"]", 1)



/client/proc/warn(var/mob/M in world)
	set category = "Special Verbs"
	set name = "Warn"
	set desc = "Warn a player"
	if(!src.holder)
		src << "Only administrators may use this command."
		return
	if(M.client && M.client.holder && (M.client.holder.level >= src.holder.level))
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return
	if(!M.client.warned)
		M << "\red <B>You have been warned by an administrator. This is the only warning you will recieve.</B>"
		M.client.warned = 1
		message_admins("\blue [src.ckey] warned [M.ckey].")
	else
		AddBan(M.ckey, M.computer_id, "Autobanning due to previous warn", src.ckey, 1, 10)
		M << "\red<BIG><B>You have been autobanned by [src.ckey]. This is what we in the biz like to call a \"second warning\".</B></BIG>"
		M << "\red This is a temporary ban; it will automatically be removed in 10 minutes."
		log_admin("[src.ckey] warned [M.ckey], resulting in a 10 minute autoban.")
		message_admins("\blue [src.ckey] warned [M.ckey], resulting in a 10 minute autoban.")

		del(M.client)
		del(M)

/client/proc/delay()
	set category = "Admin"
	set name = "Delay start"
	if(delay_start == 0)
		delay_start = 1
		world << "\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Delays the game</b>"
	else
		delay_start = 0
		world << "\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Undelays the game</b>"

/client/proc/hubvis()
	set category = "Admin"
	set name = "Toggle hub visibility"
	if(world.visibility == 0)
		world.visibility = 1
		message_admins("\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Makes the game visible on the byond hub</b>")
	else
		world.visibility = 0
		message_admins("\blue <b>[usr.client.stealth ? "Administrator" : usr.key] Removes the game from the byond hub</b>")

/client/proc/toggleinvite()
	set category = "Admin"
	set name = "Toggle invite only status"
	if(config.invite_only)
		config.invite_only = 0
		world << "\blue <b> People without an invitation may now join the game"
	else
		config.invite_only = 1
		world << "\blue <b> This game has been set to invite only"
		for(var/mob/new_player/M in world)
			if(!invite_isallowed(M))
				M.ready = 0
				M << "\blue <b> You do not have an invite to participate in this game</b>"
	message_admins("\blue <b> By [usr.client.key]</b>")

/client/proc/toggleevents()
	set category = "Admin"
	set name = "Toggle random events"
	if(eventson)
		message_admins("\blue <b> Events toggled off by [usr.client.key]</b>")
		eventson = 0
	else
		message_admins("\blue <b> Events toggled on by [usr.client.key]</b>")
		eventson = 1

/client/proc/LSD_effect(var/mob/p in world)
	set category = "Debug"
	set name = "Fake attack"
	fake_attack(p)
	return
/client/proc/new_eventa(sev as text)
	set category = "Debug"
	set name = "Spawn event"
	new_event(sev)
	return