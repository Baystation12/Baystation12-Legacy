/obj/admins/var/showadminmessages = 1
////////////////////////////////
/proc/message_admins(var/text, var/admin_ref = 0)
	var/rendered = "<span class=\"admin\"><span class=\"prefix\">ADMIN LOG:</span> <span class=\"message\">[text]</span></span>"
	for (var/client/C)
		if (C.holder && C.holder.showadminmessages)
			if (admin_ref)
				if(C.inchat) C.ctab_message("Log", dd_replaceText(rendered, "%admin_ref%", "\ref[C.mob]"))
				C.mob << output(rendered, "adminoutput")
			else
				if(C.inchat) C.ctab_message("Log", rendered)
				C.mob << output(rendered, "adminoutput")

/obj/admins/Topic(href, href_list)
	..()

	if (usr.client != src.owner)
		world << "\blue [usr.key] has attempted to override the admin panel!"
		log_admin("[key_name(usr)] tried to use the admin panel without authorization.")
		return

	if(href_list["call_shuttle"])
		if (src.rank in list("Primary Administrator", "Super Administrator", "Coder", "Host"))
			if( ticker.mode.name == "blob" )
				alert("You can't call the shuttle during blob!")
				return
			switch(href_list["call_shuttle"])
				if("1")
					if ((!( ticker ) || main_shuttle.location == 0))
						world << "This seems to be killing it."
						return
					LaunchControl.start()
					world << "\blue <B>Alert: The escape pods are being launched. They will launch in [round(LaunchControl.timeleft()/60)] minutes.</B>"
					log_admin("[key_name(usr)] launched the escape pods")
					message_admins("\blue [key_name_admin(usr)] launched the escape pods", 1)

				if("2")
					if ((!( ticker ) || main_shuttle.location || main_shuttle.direction == 0))
						return
					switch(main_shuttle.direction)
						if(-1)
							LaunchControl.start()
							world << "\blue <B>Alert: The escape pods are being launched. They will launch in [round(LaunchControl.timeleft()/60)] minutes.</B>"
							log_admin("[key_name(usr)] launched the escape pods")
							message_admins("\blue [key_name_admin(usr)] launched the escape pods", 1)
						if(1)
							LaunchControl.stop()
							world << "\blue <B>Alert: The escape pod launch sequence has been cancelled!</B>"
							log_admin("[key_name(usr)] cancelled the escape pod launch sequence")
							message_admins("\blue [key_name_admin(usr)] cancelled the escape pod launch sequence", 1)

			href_list["secretsadmin"] = "check_antagonist"
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return

	if(href_list["edit_shuttle_time"])
		if (src.rank in list("Super Administrator", "Coder", "Host"))
			LaunchControl.settimeleft( input("Enter new escape pod duration (seconds):","Edit Escape Pod Timeleft", LaunchControl.timeleft() ) as num )
			log_admin("[key_name(usr)] edited the escape pod's timeleft to [LaunchControl.timeleft()]")
			message_admins("\blue [key_name_admin(usr)] edited the escape pod's timeleft to [LaunchControl.timeleft()]", 1)
			href_list["secretsadmin"] = "check_antagonist"
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!")
			return
	if(href_list["remove_microorganism"])
		remove_microorganism(usr)
	/////////////////////////////////////new ban stuff
	if(href_list["jobban1"])
		var/key = href_list["jobban1"]
		var/html = "<B><center>[key]</center></B><br><table border='1'><tr><th>Rank</th><th>By</th><th>Time</th><th>Reason</th><th>Options</th>"
		var/DBQuery/cquery = dbcon.NewQuery("SELECT * from jobbanlog WHERE targetckey='[key]'")
		if(!cquery.Execute())
			log_admin("[cquery.ErrorMsg()]")
		else
			while(cquery.NextRow())
				var/list/ban = cquery.GetRowData()
				html += "<tr><td>[ban["rank"]]</td><td>[ban["ckey"]]</td><td>[ban["when"]]</td><td>[ban["why"]]</td><td><a href='?src=\ref[src];jobbanrank=[ban["rank"]];jobunbankey=[key]'>Remove</a></td></tr>"
		html += "</table>"
		usr << browse(html, "window=jobbanx1x;size=600x400")
		return
	if(href_list["unbanf"])
		var/key = href_list["unbanf"]
		if(alert(usr, "Are you sure you want to unban [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (RemoveBan(key))
				unbanpanel()
			else
				alert(usr,"This ban has already been lifted / does not exist.","Error","Ok")
				unbanpanel()
	if(href_list["uninvite1"])
		var/key = href_list["uninvite1"]
		if(alert(usr, "Are you sure you want to uninvite [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (invite_removetext(key))
				invite_panel()
			else
				alert(usr,"This ban has already been lifted / does not exist.","Error","Ok")
				invite_panel()
	if(href_list["invite1"])
		var/key
		key = input(usr,"What key do you wish to add?","What Key?","key")
		if(key == "key")
			alert(usr,"You can't add 'key.","Error","Ok")
			invite_panel()
		if(alert(usr, "Are you sure you want to invite [key]?", "Confirmation", "Yes", "No") == "Yes")
			if (invite_addtext(key))
				invite_panel()
			else
				alert(usr,"This ban is already there or something went to hell.","Error","Ok")
				invite_panel()
	if(href_list["unbane"])
		var/DBQuery/key_query = dbcon.NewQuery("SELECT * FROM `bans` WHERE ckey='[href_list["unbane"]]'")
		var/list/ban = list()
		if(!key_query.Execute())
			log_admin("[key_query.ErrorMsg()]")
		else
			while(key_query.NextRow())
				ban = key_query.GetRowData()
		UpdateTime()
		var/reason
		var/mins = 0
		var/reason2 = ban["reason"]
		var/temp = ban["temp"]
		var/minutes = (text2num(ban["minutes"]) - CMinutes)
		if(!minutes || minutes < 0) minutes = 0
		var/banned_key = ban["ckey"]


		switch(alert("Temporary Ban?",,"Yes","No"))
			if("Yes")
				temp = 1
				mins = input(usr,"How long (in minutes)? (Default: 1440)","Ban time",minutes ? minutes : 1440) as num
				if(!mins)
					return
				if(mins >= 525600) mins = 525599
				reason = input(usr,"Reason?","reason",reason2) as text
				if(!reason)
					return
			if("No")
				temp = 0
				reason = input(usr,"Reason?","reason",reason2) as text
				if(!reason)
					return
		var/mins2 = (mins + CMinutes)
		log_admin("[key_name(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [GetExp(mins2)]")
		message_admins("\blue [key_name_admin(usr)] edited [banned_key]'s ban. Reason: [reason] Duration: [GetExp(mins2)]", 1)
		var/reason1 = dbcon.Quote(reason)
		var/DBQuery/query = dbcon.NewQuery("UPDATE `bans` SET `reason`=[reason1], `temp`='[temp]',`minute`='[mins2]', `bannedby`='[usr.ckey]' WHERE `ckey`='[ban["ckey"]]'")
		if(!query.Execute())
			log_admin("[query.ErrorMsg()]")
		unbanpanel()


	/////////////////////////////////////new ban stuff

	if(href_list["jobban2"])
		var/mob/M = locate(href_list["jobban2"])
		var/dat = ""
		var/header = "<b>Pick the job to ban this guy from.<br>"
		var/body
//		var/list/alljobs = get_all_jobs()
		var/jobs = ""
		for(var/job in uniquelist(occupations + assistant_occupations))
			if(job == "Tourist")
				continue
			if(jobban_isbanned(M, job))
				jobs += "<a href='?src=\ref[src];jobban3=[job];jobban4=\ref[M]'><font color=red>[dd_replacetext(job, " ", "&nbsp")]</font></a> "
			else
				jobs += "<a href='?src=\ref[src];jobban3=[job];jobban4=\ref[M]'>[dd_replacetext(job, " ", "&nbsp")]</a> " //why doesn't this work the stupid cunt

		if(jobban_isbanned(M, "Captain"))
			jobs += "<a href='?src=\ref[src];jobban3=Captain;jobban4=\ref[M]'><font color=red>Captain</font></a> "
		else
			jobs += "<a href='?src=\ref[src];jobban3=Captain;jobban4=\ref[M]'>Captain</a> " //why doesn't this work the stupid cunt
		if(jobban_isbanned(M, "Syndicate"))
			jobs += "<BR><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'><font color=red>[dd_replacetext("Syndicate", " ", "&nbsp")]</font></a> "
		else
			jobs += "<BR><a href='?src=\ref[src];jobban3=Syndicate;jobban4=\ref[M]'>[dd_replacetext("Syndicate", " ", "&nbsp")]</a> " //why doesn't this work the stupid cunt

		body = "<br>[jobs]<br><br>"
		dat = "<tt>[header][body]</tt>"
		usr << browse(dat, "window=jobban2;size=600x150")
		return

	if(href_list["jobbanrank"])
		jobban_remove(href_list["jobunbankey"],href_list["jobbanrank"])

	if(href_list["jobban3"])
		if (src.rank in list( "Administrator", "Secondary Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  ))
			var/mob/M = locate(href_list["jobban4"])
			var/job = href_list["jobban3"]
			if ((M.client && M.client.holder && (M.client.holder.level > src.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return
			if (jobban_isbanned(M, job))
				log_admin("[key_name(usr)] unbanned [key_name(M)] from [job]")
				message_admins("\blue [key_name_admin(usr)] unbanned [key_name_admin(M)] from [job]", 1)
				jobban_unban(M, job)
				href_list["jobban2"] = 1
			else
				log_admin("[key_name(usr)] banned [key_name(M)] from [job]")
				message_admins("\blue [key_name_admin(usr)] banned [key_name_admin(M)] from [job]", 1)
				jobban_fullban(M, job,usr)
				href_list["jobban2"] = 1 // lets it fall through and refresh


	if (href_list["boot2"])
		if ((src.rank in list( "Moderator", "Secondary Administrator", "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["boot2"])
			if (ismob(M))
				if ((M.client && M.client.holder && (M.client.holder.level >= src.level)))
					alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
					return
				log_admin("[key_name(usr)] booted [key_name(M)].")
				message_admins("\blue [key_name_admin(usr)] booted [key_name_admin(M)].", 1)
				//M.client = null
				del(M.client)

	/*if (href_list["removejobban"])
		if ((src.rank in list("Coder", "Host"  )))
			var/t = href_list["removejobban"]
			usr << "[T]"
			if(t)
				log_admin("[key_name(usr)] removed [t]")
				message_admins("\blue [key_name_admin(usr)] removed [t]", 1)
				jobban_remove(t)
				href_list["ban"] = 1 // lets it fall through and refresh
*/
	if (href_list["newban"])
		if ((src.rank in list( "Secondary Administrator", "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["newban"])
			if(!ismob(M)) return
			if ((M.client && M.client.holder && (M.client.holder.level >= src.level)))
				alert("You cannot perform this action. You must be of a higher administrative rank!")
				return
			switch(alert("Temporary Ban?",,"Yes","No"))
				if("Yes")
					var/mins = input(usr,"How long (in minutes)?","Ban time",1440) as num
					if(!mins)
						return
					if(mins >= 525600) mins = 525599
					var/reason = input(usr,"Reason?","reason","Griefer") as text
					if(!reason)
						return
					AddBan(M.ckey, M.computer_id,M.client.address, reason, usr.ckey, 1, mins)
					M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
					M << "\red This is a temporary ban, it will be removed in [mins] minutes."
					log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")
					message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis will be removed in [mins] minutes.")

					del(M.client)
				if("No")
					var/reason = input(usr,"Reason?","reason","Griefer") as text
					if(!reason)
						return
					AddBan(M.ckey, M.computer_id,M.client.address, reason, usr.ckey, 0, 0)
					M << "\red<BIG><B>You have been banned by [usr.client.ckey].\nReason: [reason].</B></BIG>"
					M << "\red This is a permanent ban."
					M << "\red To try to resolve this matter by pming one of the admins on http://www.whoopshop.com/"
					log_admin("[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")
					message_admins("\blue[usr.client.ckey] has banned [M.ckey].\nReason: [reason]\nThis is a permanent ban.")

					del(M.client)

	if (href_list["removeinvitek"])
		if ((src.rank in list( "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/t = href_list["remove"]
			if(t)
				invite_removetext("[t]")
				message_admins("\blue [key_name_admin(usr)] removed [t] from the invite list.")

	if (href_list["removeinvite"])
		if ((src.rank in list( "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/u = input(usr, "Who do you wish to remove from the invite list", "Remove invite", "enterckeyhere")
			invite_removetext("[u]")
			message_admins("\blue [key_name_admin(usr)] removed [u] from the invite list.")

	if (href_list["addinvite"])
		if ((src.rank in list( "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/u = input(usr, "Who do you wish to add to the invite list", "Remove invite", "enterckeyhere")
			invite_addtext("[u]")
			message_admins("\blue [key_name_admin(usr)] added [u] to the invite list.")


	if (href_list["mute2"])
		if ((src.rank in list( "Moderator", "Secondary Administrator", "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["mute2"])
			if (ismob(M))
				if ((M.client && M.client.holder && (M.client.holder.level >= src.level)))
					alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
					return
				M.muted = !M.muted
				log_admin("[key_name(usr)] has [(M.muted ? "muted" : "voiced")] [key_name(M)].")
				message_admins("\blue [key_name_admin(usr)] has [(M.muted ? "muted" : "voiced")] [key_name_admin(M)].", 1)
				M << "You have been [(M.muted ? "muted" : "voiced")]."

	if (href_list["c_mode"])
		if ((src.rank in list( "Secondary Administrator", "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			if (ticker && ticker.mode)
				return alert(usr, "The game has already started.", null, null, null, null)
			var/dat = text({"<B>What mode do you wish to play?</B><HR>
			<A href='?src=\ref[src];c_mode2=secret'>Secret</A><br>
			<!-- <A href='?src=\ref[src];c_mode2=wizard'>Wizard</A><br> -->
			<A href='?src=\ref[src];c_mode2=restructuring'>Corporate Restructuring</A><br>
			<A href='?src=\ref[src];c_mode2=random'>Random</A><br>
			<A href='?src=\ref[src];c_mode2=traitor'>Traitor</A><br>
			<A href='?src=\ref[src];c_mode2=meteor'>Meteor</A><br>
			<A href='?src=\ref[src];c_mode2=extended'>Extended</A><br>
			<A href='?src=\ref[src];c_mode2=monkey'>Monkey</A><br>
			<A href='?src=\ref[src];c_mode2=nuclear'>Nuclear Emergency</A><br>
			<A href='?src=\ref[src];c_mode2=blob'>Blob</A><br>
			<A href='?src=\ref[src];c_mode2=sandbox'>Sandbox</A><br>
			<A href='?src=\ref[src];c_mode2=revolution'>Revolution</A><br>
			<A href='?src=\ref[src];c_mode2=rp-revolution'>RP Revolution (Alpha)</A><br>
			<A href='?src=\ref[src];c_mode2=malfunction'>AI Malfunction</A><br>
			<A href='?src=\ref[src];c_mode2=deathmatch'>Death Commando Deathmatch</A><br>
			<A href='?src=\ref[src];c_mode2=confliction'>Confliction (TESTING)</A><br>
			<A href='?src=\ref[src];c_mode2=ctf'>Capture The Flag (Beta)</A><br><br>
			<A href='?src=\ref[src];c_mode2=derelict'>Derelict (Beta)</A><br>
			<A href='?src=\ref[src];c_mode2=zombie'>Zombie (Beta)</A><br>
			<A href='?src=\ref[src];c_mode2=takeover'>Hostile Takeover (Alpha)</A><br>
			<A href='?src=\ref[src];c_mode2=Extend-A-Traitormongous'>Auto Traitor (Beta)</A><br>
			<!-- <A href='?src=\ref[src];c_mode2=among'>Traitor among us (Beta)</A><br><br> -->
			Now: [master_mode]\n"})
			usr << browse(dat, "window=c_mode")

	if (href_list["c_mode2"])
		if ((src.rank in list( "Secondary Administrator", "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			if (ticker && ticker.mode)
				return alert(usr, "The game has already started.", null, null, null, null)
			switch(href_list["c_mode2"])
				if("secret")
					master_mode = "secret"
				if("random")
					master_mode = "random"
				if("traitor")
					master_mode = "traitor"
				if("meteor")
					master_mode = "meteor"
				if("extended")
					master_mode = "extended"
				if("monkey")
					master_mode = "monkey"
				if("nuclear")
					master_mode = "nuclear"
				if("blob")
					master_mode = "blob"
				if("sandbox")
					master_mode = "sandbox"
				if("restructuring")
					master_mode = "restructuring"
				if("wizard")
					master_mode = "wizard"
				if("revolution")
					master_mode = "revolution"
				if("rp-revolution")
					master_mode = "rp-revolution"
				if("malfunction")
					master_mode = "malfunction"
				if("deathmatch")
					master_mode = "deathmatch"
				if("confliction")
					master_mode = "confliction"
				if("ctf")
					master_mode = "ctf"
				if("derelict")
					master_mode = "derelict"
				if("zombie")
					master_mode = "zombie"
				if("takeover")
					master_mode = "takeover"
				/*if("among")
					master_mode = "traitoramongus"*/
				if("Extend-A-Traitormongous")
					master_mode = "Extend-A-Traitormongous"
				else
			log_admin("[key_name(usr)] set the mode as [master_mode].")
			message_admins("\blue [key_name_admin(usr)] set the mode as [master_mode].", 1)
			if(!ticker.hide_mode)
				world << "\blue <b>The mode is now: [master_mode]</b>"
			else
				world << "\blue <b>The mode is now: secret </b>"

			world.save_mode(master_mode)

	if (href_list["monkeyone"])
		if ((src.rank in list( "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["monkeyone"])
			if(!ismob(M))
				return
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/N = M
				log_admin("[key_name(usr)] attempting to monkeyize [key_name(M)]")
				message_admins("\blue [key_name_admin(usr)] attempting to monkeyize [key_name_admin(M)]", 1)
				N.monkeyize()
			if(istype(M, /mob/living/silicon))
				alert("The AI can't be monkeyized!", null, null, null, null, null)
				return

	if (href_list["forcespeech"])
		if ((src.rank in list( "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["forcespeech"])
			if (ismob(M))
				var/speech = input("What will [key_name(M)] say?.", "Force speech", "")
				if(!speech)
					return
				M.say(speech)
				speech = copytext(sanitize(speech), 1, MAX_MESSAGE_LEN)
				log_admin("[key_name(usr)] forced [key_name(M)] to say: [speech]")
				message_admins("\blue [key_name_admin(usr)] forced [key_name_admin(M)] to say: [speech]")
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

	if (href_list["sendtoprison"])
		if ((src.rank in list( "Moderator", "Administrator", "Secondary Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["sendtoprison"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to prison you jerk!", null, null, null, null, null)
					return
				//strip their stuff before they teleport into a cell :downs:
				for(var/obj/item/weapon/W in M)
					if(istype(W, /datum/organ/external))
						continue
	//don't strip organs
					M.u_equip(W)
					if (M.client)
						M.client.screen -= W
					if (W)
						W.loc = M.loc
						W.dropped(M)
						W.layer = initial(W.layer)
				//teleport person to cell
				M.paralysis += 5
				sleep(5 ) //so they black out before warping
				M.loc = pick(prisonwarp)
				if(istype(M, /mob/living/carbon/human))
					var/mob/living/carbon/human/prisoner = M
					prisoner.equip_if_possible(new /obj/item/clothing/under/color/orange(prisoner), prisoner.slot_w_uniform)
					prisoner.equip_if_possible(new /obj/item/clothing/shoes/orange(prisoner), prisoner.slot_shoes)
				spawn(50)
					M << "\red You have been sent to the prison station!"
				log_admin("[key_name(usr)] sent [key_name(M)] to the prison station.")
				message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the prison station.", 1)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

	if (href_list["sendtomaze"])
		if ((src.rank in list( "Administrator", "Secondary Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["sendtomaze"])
			if (ismob(M))
				if(istype(M, /mob/living/silicon/ai))
					alert("The AI can't be sent to the maze you jerk!", null, null, null, null, null)
					return
				//strip their stuff before they teleport into a cell :downs:
				for(var/obj/item/weapon/W in M)
					if(istype(W, /datum/organ/external))
						continue
	//don't strip organs
					M.u_equip(W)
					if (M.client)
						M.client.screen -= W
					if (W)
						W.loc = M.loc
						W.dropped(M)
						W.layer = initial(W.layer)
				//teleport person to cell
				M.paralysis += 5
				sleep(5 )
	//so they black out before warping
				M.loc = pick(mazewarp)
				spawn(50)
					M << "\red You have been sent to the maze! Try and get out alive. In the maze everyone is free game. Kill or be killed."
				log_admin("[key_name(usr)] sent [key_name(M)] to the maze.")
				message_admins("\blue [key_name_admin(usr)] sent [key_name_admin(M)] to the maze.", 1)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

	if (href_list["tdome1"])
		if ((src.rank in list( "Administrator", "Secondary Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["tdome1"])
			// M.revive()
			M.loc = pick(tdome1)
			log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 1)")
			message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 1)", 1)
			M << "\blue You have been sent to the Thunderdome."

	if (href_list["tdome2"])
		if ((src.rank in list( "Administrator", "Secondary Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["tdome2"])
			// M.revive()
			M.loc = pick(tdome2)
			log_admin("[key_name(usr)] has sent [key_name(M)] to the thunderdome. (Team 2)")
			message_admins("[key_name_admin(usr)] has sent [key_name_admin(M)] to the thunderdome. (Team 2)", 1)
			M << "\blue You have been sent to the Thunderdome."

	if (href_list["revive"])
		if ((src.rank in list( "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/mob/M = locate(href_list["revive"])
			if (ismob(M))
				if(istype(M, /mob/dead/observer))
					alert("Cannot revive a ghost")
					return
				if(config.allow_admin_rev)
					M.revive()
					message_admins("\red Admin [key_name_admin(usr)] healed / revived [key_name_admin(M)]!", 1)
					log_admin("[key_name(usr)] healed / Rrvived [key_name(M)]")
					return
				else
					alert("Admin revive disabled")
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

	if (href_list["makeai"]) //Yes, im fucking lazy, so what? it works ... hopefully
		if ((src.rank in list( "Primary Administrator", "Coder", "Host", "Administrator", "Super Administrator"  )))
			var/mob/M = locate(href_list["makeai"])
			if(istype(M, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = M
				message_admins("\red Admin [key_name_admin(usr)] AIized [key_name_admin(M)]!", 1)
				if (ticker.mode.name  == "AI malfunction")
					var/obj/O = locate("landmark*ai")
					M << "\blue <B>You have been teleported to your new starting location!</B>"
					M.loc = O.loc
					M.buckled = null
				else
					var/obj/S = locate(text("start*AI"))
					if ((istype(S, /obj/landmark/start) && istype(S.loc, /turf)))
						M << "\blue <B>You have been teleported to your new starting location!</B>"
						M.loc = S.loc
						M.buckled = null
					world << "<b>[M.real_name] is the AI!</b>"
				log_admin("[key_name(usr)] AIized [key_name(M)]")
				H.AIize()
			else
				alert("I cannot allow this.")
				return
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return
	if(href_list["editairflow"])
		if ((src.rank in list( "Primary Administrator", "Coder", "Host", "Super Administrator")))
			vsc.ChangeSettingDialog(usr,vsc.settings)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return
	if(href_list["editplasma"])
		if ((src.rank in list( "Primary Administrator", "Coder", "Host", "Super Administrator")))
			vsc.ChangeSettingDialog(usr,vsc.plc.settings)
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return
	if(href_list["savetweaks"])
		if ((src.rank in list( "Primary Administrator", "Coder", "Host", "Super Administrator")))
			SaveTweaks()
			usr << "Settings saved."
			world << "\blue <b>[key_name(usr)] saved the current settings.</b>"
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return
	if(href_list["loadtweaks"])
		if ((src.rank in list( "Primary Administrator", "Coder", "Host", "Super Administrator")))
			LoadTweaks()
			usr << "Settings loaded."
			world << "\blue <b>[key_name(usr)] loaded settings from the savefile.</b>"
		else
			alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
			return

/***************** BEFORE**************

	if (href_list["l_players"])
		var/dat = "<B>Name/Real Name/Key/IP:</B><HR>"
		for(var/mob/M in world)
			var/foo = ""
			if (ismob(M) && M.client)
				if(!M.client.authenticated && !M.client.authenticating)
					foo += text("\[ <A HREF='?src=\ref[];adminauth=\ref[]'>Authorize</A> | ", src, M)
				else
					foo += text("\[ <B>Authorized</B> | ")
				if(M.start)
					if(!istype(M, /mob/living/carbon/monkey))
						foo += text("<A HREF='?src=\ref[];monkeyone=\ref[]'>Monkeyize</A> | ", src, M)
					else
						foo += text("<B>Monkeyized</B> | ")
					if(istype(M, /mob/living/silicon/ai))
						foo += text("<B>Is an AI</B> | ")
					else
						foo += text("<A HREF='?src=\ref[];makeai=\ref[]'>Make AI</A> | ", src, M)
					if(M.z != 2)
						foo += text("<A HREF='?src=\ref[];sendtoprison=\ref[]'>Prison</A> | ", src, M)
						foo += text("<A HREF='?src=\ref[];sendtomaze=\ref[]'>Maze</A> | ", src, M)
					else
						foo += text("<B>On Z = 2</B> | ")
				else
					foo += text("<B>Hasn't Entered Game</B> | ")
				foo += text("<A HREF='?src=\ref[];revive=\ref[]'>Heal/Revive</A> | ", src, M)

				foo += text("<A HREF='?src=\ref[];forcespeech=\ref[]'>Say</A> \]", src, M)
			dat += text("N: [] R: [] (K: []) (IP: []) []<BR>", M.name, M.real_name, (M.client ? M.client : "No client"), M.lastKnownIP, foo)

		usr << browse(dat, "window=players;size=900x480")

*****************AFTER******************/

// Now isn't that much better? IT IS NOW A PROC, i.e. kinda like a big panel like unstable

	if (href_list["adminplayeropts"])
		var/mob/M = locate(href_list["adminplayeropts"])
		var/dat = "<html><head><title>Options for [M.key]</title></head>"
		var/foo = "\[ "
		if (ismob(M) && M.client)
			foo += text("<A HREF='?src=\ref[src];prom_demot=\ref[M.client]'>Promote/Demote</A> | ")
			if(!istype(M, /mob/new_player))
				if(!istype(M, /mob/living/carbon/monkey))
					foo += text("<A HREF='?src=\ref[src];monkeyone=\ref[M]'>Monkeyize</A> | ")
				else
					foo += text("<B>Monkeyized</B> | ")
				if(istype(M, /mob/living/silicon/ai))
					foo += text("<B>Is an AI</B> | ")
				else if(istype(M, /mob/living/carbon/human))
					foo += text("<A HREF='?src=\ref[src];makeai=\ref[M]'>Make AI</A> | ")
				foo += text("<A HREF='?src=\ref[src];tdome1=\ref[M]'>Thunderdome 1</A> | ")
				foo += text("<A HREF='?src=\ref[src];tdome2=\ref[M]'>Thunderdome 2</A> | ")
				foo += text("<A HREF='?src=\ref[src];sendtoprison=\ref[M]'>Prison</A> | ")
				foo += text("<A HREF='?src=\ref[src];sendtomaze=\ref[M]'>Maze</A> | ")

				foo += text("<A HREF='?src=\ref[src];revive=\ref[M]'>Heal/Revive</A> | ")
			else
				foo += text("<B>Hasn't Entered Game</B> | ")
			foo += text("<A HREF='?src=\ref[src];forcespeech=\ref[M]'>Say</A> | ")
			foo += text("<A href='?src=\ref[src];mute2=\ref[M]'>Mute: [(M.muted ? "Muted" : "Voiced")]</A> | ")
			foo += text("<A href='?src=\ref[src];jobban2=\ref[M]'>Jobban</A> | ")
			foo += text("<A href='?src=\ref[src];boot2=\ref[M]'>Boot</A> | ")
		foo += text("<A href='?src=\ref[src];jumpto=\ref[M]'>Jump to</A> | ")
		foo += text("<A href='?src=\ref[src];newban=\ref[M]'>Ban</A> | ")
		foo += text("<A href='?src=\ref[src];invite=\ref[M]'>Toggle invite</A>\ ]")
		dat += text("<body>[foo]</body></html>")
		usr << browse(dat, "window=adminplayeropts;size=480x100")

	if (href_list["jumpto"])
		if(( src.level in list(6, 5, 4) ) || ((src.level in list(3, 2)) && (src.state == 2)))
			var/mob/M = locate(href_list["jumpto"])
			usr.client.jumptomob(M)
		else
			alert("You are not a high enough administrator or you aren't observing!")

	if (href_list["traitor"])
		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return
		var/mob/M = locate(href_list["traitor"])
		if(M.mind)
			M.mind.edit_memory()
			return

		/*
		if(!ticker || !ticker.mode)
			alert("The game hasn't started yet!")
			return
		var/mob/M = locate(href_list["traitor"])
		var/datum/game_mode/current_mode = ticker.mode
		switch(current_mode.config_tag)
			if("revolution")
				if(M.mind in current_mode:head_revolutionaries)
					alert("Is a Head Revolutionary!")
				else if(M.mind in current_mode:revolutionaries)
					alert("Is a Revolutionary!")
				return
		/*	if("wizard")
				if(current_mode:wizard && M.mind == current_mode:wizard)
					var/datum/mind/antagonist = M.mind
					var/t = ""
					for(var/datum/objective/OB in antagonist.objectives)
						t += "[OB.explanation_text]\n"
					if(antagonist.objectives.len == 0)
						t = "None defined."
					alert("Is a WIZARD. Objective(s):\n[t]", "[M.key]")
					return*/
			if("malfunction")
				if(M.mind in current_mode:malf_ai)
					alert("Is malfunctioning!")
					return
			if("nuclear")
				if(M.mind in current_mode:syndicates)
					alert("Is a Syndicate operative!", "[M.key]")
					return
		// traitor, or other modes where traitors/counteroperatives would be.
		if(M.mind in current_mode.traitors)
			var/datum/mind/antagonist = M.mind
			var/t = ""
			for(var/datum/objective/OB in antagonist.objectives)
				t += "[OB.explanation_text]\n"
			if(antagonist.objectives.len == 0)
				t = "None defined."
			alert("Is a Traitor. Objective(s):\n[t]", "[M.key]")
			return

		//they're nothing so turn them into a traitor!
		if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/silicon/ai))
			var/traitorize = alert("Is not a traitor, make Traitor?", "Traitor", "Yes", "Cancel")
			if(traitorize == "Cancel")
				return
			if(traitorize == "Yes")
				traitorize(M,,1)
		//they're a ghost/monkey
		else
			alert("Cannot make this mob a traitor")
		*/

	if (href_list["create_object"])
		if (src.rank in list("Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"))
			return create_object(usr)
		else
			alert("You are not a high enough administrator! Sorry!!!!")

	if (href_list["create_turf"])
		if (src.rank in list("Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"))
			return create_turf(usr)
		else
			alert("You are not a high enough administrator! Sorry!!!!")
	if (href_list["create_mob"])
		if (src.rank in list("Super Administrator", "Coder", "Host"))
			return create_mob(usr)
		else
			alert("You are not a high enough administrator! Sorry!!!!")
	if (href_list["vmode"])
		vmode()

	if (href_list["votekill"])
		votekill()

	if (href_list["voteres"])
		voteres()

	if (href_list["invite"])
		var/mob/M = locate(href_list["invite"])
		toggleinvite(M)
		if(invite_isallowed(M))
			log_admin("[M.key] allowed to join invite only games")
		else
			log_admin("[M.key] removed from joining invite only games")


	if (href_list["prom_demot"])
		if ((src.rank in list("Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/client/C = locate(href_list["prom_demot"])
			if(C.holder && (C.holder.level >= src.level))
				alert("This cannot be done as [C] is a [C.holder.rank]")
				return
			var/dat = "[C] is a [C.holder ? "[C.holder.rank]" : "non-admin"]<br><br>Change [C]'s rank?<br>"
			if(src.level == 6)
			//host
				dat += {"
				<A href='?src=\ref[src];chgadlvl=Coder;client4ad=\ref[C]'>Coder</A><BR>				<A href='?src=\ref[src];chgadlvl=Super Administrator;client4ad=\ref[C]'>Super Administrator</A><BR>
				<A href='?src=\ref[src];chgadlvl=Primary Administrator;client4ad=\ref[C]'>PA</A><BR>
				<A href='?src=\ref[src];chgadlvl=Administrator;client4ad=\ref[C]'>A</A><BR>
				<A href='?src=\ref[src];chgadlvl=Secondary Administrator;client4ad=\ref[C]'>SA</A><BR>
				<A href='?src=\ref[src];chgadlvl=Moderator;client4ad=\ref[C]'>M</A><BR>
				<A href='?src=\ref[src];chgadlvl=Goat Fart;client4ad=\ref[C]'>Goat Fart</A><BR>
				<A href='?src=\ref[src];chgadlvl=Remove;client4ad=\ref[C]'>Remove Admin</A><BR>"}
			else if(src.level == 5)
			//coder
				dat += {"
				<A href='?src=\ref[src];chgadlvl=Super Administrator;client4ad=\ref[C]'>Super Administrator</A><BR>				<A href='?src=\ref[src];chgadlvl=Primary Administrator;client4ad=\ref[C]'>PA</A><BR>
				<A href='?src=\ref[src];chgadlvl=Administrator;client4ad=\ref[C]'>A</A><BR>
				<A href='?src=\ref[src];chgadlvl=Secondary Administrator;client4ad=\ref[C]'>SA</A><BR>
				<A href='?src=\ref[src];chgadlvl=Moderator;client4ad=\ref[C]'>M</A><BR>
				<A href='?src=\ref[src];chgadlvl=Goat Fart;client4ad=\ref[C]'>Goat Fart</A><BR>
				<A href='?src=\ref[src];chgadlvl=Remove;client4ad=\ref[C]'>Remove Admin</A><BR>"}
			else if(src.level == 4)
			//shitguy
				dat += {"
				<A href='?src=\ref[src];chgadlvl=Primary Administrator;client4ad=\ref[C]'>PA</A><BR>				<A href='?src=\ref[src];chgadlvl=Administrator;client4ad=\ref[C]'>A</A><BR>
				<A href='?src=\ref[src];chgadlvl=Secondary Administrator;client4ad=\ref[C]'>SA</A><BR>
				<A href='?src=\ref[src];chgadlvl=Moderator;client4ad=\ref[C]'>M</A><BR>
				<A href='?src=\ref[src];chgadlvl=Goat Fart;client4ad=\ref[C]'>Goat Fart</A><BR>
				<A href='?src=\ref[src];chgadlvl=Remove;client4ad=\ref[C]'>Remove Admin</A><BR>"}
			else if(src.level == 3)
			//PA
				dat += {"
				<A href='?src=\ref[src];chgadlvl=Administrator;client4ad=\ref[C]'>A</A><BR>				<A href='?src=\ref[src];chgadlvl=Secondary Administrator;client4ad=\ref[C]'>SA</A><BR>
				<A href='?src=\ref[src];chgadlvl=Moderator;client4ad=\ref[C]'>M</A><BR>
				<A href='?src=\ref[src];chgadlvl=Goat Fart;client4ad=\ref[C]'>Goat Fart</A><BR>
				<A href='?src=\ref[src];chgadlvl=Remove;client4ad=\ref[C]'>Remove Admin</A><BR>"}
			else
				alert("This cannot happen")
				return
			usr << browse(dat, "window=prom_demot;size=480x300")

	if (href_list["chgadlvl"])
	//change admin level
		var/rank = href_list["chgadlvl"]
		var/client/C = locate(href_list["client4ad"])
		if(rank == "Remove")
			C.clear_admin_verbs()
			C.update_admins(null)
			log_admin("[key_name(usr)] has removed [C]'s adminship")
			message_admins("[key_name_admin(usr)] has removed [C]'s adminship", 1)
			admins.Remove(C.ckey)
		else
			C.clear_admin_verbs()
			C.update_admins(rank)
			log_admin("[key_name(usr)] has made [C] a [rank]")
			message_admins("[key_name_admin(usr)] has made [C] a [rank]", 1)
			admins[C.ckey] = rank


	if (href_list["object_list"])
		if (src.rank in list("Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"))
			if (config.allow_admin_spawning && ((src.state == 2) || (src.rank in list("Super Administrator", "Coder", "Host"))))
				var/atom/loc = usr.loc

				var/dirty_paths
				if (istext(href_list["object_list"]))
					dirty_paths = list(href_list["object_list"])
				else if (istype(href_list["object_list"], /list))
					dirty_paths = href_list["object_list"]

				var/paths = list()
				var/removed_paths = list()
				for (var/dirty_path in dirty_paths)
					var/path = text2path(dirty_path)
					if (!path)
						removed_paths += dirty_path
					else if (!ispath(path, /obj) && !ispath(path, /turf) && !ispath(path, /mob))
						removed_paths += dirty_path
					else if (ispath(path, /obj/item/weapon/gun/energy/pulse_rifle))
						removed_paths += dirty_path
					else if (ispath(path, /obj/bhole) && !(src.rank in list("Coder", "Host")))
						removed_paths += dirty_path
					else if (ispath(path, /mob) && !(src.rank in list("Super Administrator", "Coder", "Host")))
						removed_paths += dirty_path
					else
						paths += path

				if (!paths)
					return
				else if (length(paths) > 5)
					alert("Select less object types, jerko.")
					return
				else if (length(removed_paths))
					alert("Removed:\n" + dd_list2text(removed_paths, "\n"))

				var/list/offset = dd_text2list(href_list["offset"],",")
				var/number = dd_range(1, 100, text2num(href_list["object_count"]))
				var/X = offset.len > 0 ? text2num(offset[1]) : 0
				var/Y = offset.len > 1 ? text2num(offset[2]) : 0
				var/Z = offset.len > 2 ? text2num(offset[3]) : 0

				for (var/i = 1 to number)
					switch (href_list["offset_type"])
						if ("absolute")
							for (var/path in paths)
								new path(locate(0 + X,0 + Y,0 + Z))

						if ("relative")
							if (loc)
								for (var/path in paths)
									new path(locate(loc.x + X,loc.y + Y,loc.z + Z))
							else
								return

				if (number == 1)
					log_admin("[key_name(usr)] created a [english_list(paths)]")
					for(var/path in paths)
						if(ispath(path, /mob))
							message_admins("[key_name_admin(usr)] created a [english_list(paths)]", 1)
							break
				else
					log_admin("[key_name(usr)] created [number]ea [english_list(paths)]")
					for(var/path in paths)
						if(ispath(path, /mob))
							message_admins("[key_name_admin(usr)] created [number]ea [english_list(paths)]", 1)
							break
				return
			else
				alert("You cannot spawn items right now.")
				return

	if (href_list["secretsfun"])
		if ((src.rank in list( "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/ok = 0
			switch(href_list["secretsfun"])
				if("sec_clothes")
					for(var/obj/item/clothing/under/O in world)
						del(O)
					ok = 1
				if("sec_all_clothes")
					for(var/obj/item/clothing/O in world)
						del(O)
					ok = 1
				if("sec_classic1")
					for(var/obj/item/clothing/suit/fire/O in world)
						del(O)
					for(var/obj/grille/O in world)
						del(O)
					for(var/obj/machinery/vehicle/pod/O in world)
						for(var/mob/M in src)
							M.loc = src.loc
							if (M.client)
								M.client.perspective = MOB_PERSPECTIVE
								M.client.eye = M
						del(O)
					ok = 1
				/*if("toxic")
					for(var/obj/machinery/atmoalter/siphs/fullairsiphon/O in world)
						O.t_status = 3
					for(var/obj/machinery/atmoalter/siphs/scrubbers/O in world)
						O.t_status = 1
						O.t_per = 1000000.0
					for(var/obj/machinery/atmoalter/canister/O in world)
						if (!( istype(O, /obj/machinery/atmoalter/canister/oxygencanister) ))
							O.t_status = 1
							O.t_per = 1000000.0
						else
							O.t_status = 3
				*/
					usr << "HEH"
				if("monkey")
					for(var/mob/living/carbon/human/H in world)
						spawn(0)
							H.monkeyize()
					ok = 1
				if("power")
					power_restore()
					log_admin("[key_name(usr)] made all areas powered", 1)
					message_admins("\blue [key_name_admin(usr)] made all areas powered", 1)
				if("unpower")
					power_failure()
					log_admin("[key_name(usr)] made all areas unpowered", 1)
					message_admins("\blue [key_name_admin(usr)] made all areas unpowered", 1)
				if("activateprison")
					world << "\blue <B>Transit signature detected.</B>"
					world << "\blue <B>Incoming shuttle.</B>"
					/*
					var/A = locate(/area/shuttle_prison)
					for(var/atom/movable/AM as mob|obj in A)
						AM.z = 1
						AM.Move()
					*/
					message_admins("\blue [key_name_admin(usr)] sent the prison shuttle to the station.", 1)
				if("deactivateprison")
					/*
					var/A = locate(/area/shuttle_prison)
					for(var/atom/movable/AM as mob|obj in A)
						AM.z = 2
						AM.Move()
					*/
					message_admins("\blue [key_name_admin(usr)] sent the prison shuttle back.", 1)
				if("toggleprisonstatus")
					for(var/obj/machinery/computer/prison_shuttle/PS in world)
						PS.allowedtocall = !(PS.allowedtocall)
						message_admins("\blue [key_name_admin(usr)] toggled status of prison shuttle to [PS.allowedtocall].", 1)
				if("prisonwarp")
					if(!ticker)
						alert("The game hasn't started yet!", null, null, null, null, null)
						return
					message_admins("\blue [key_name_admin(usr)] teleported all players to the prison station.", 1)
					for(var/mob/living/carbon/human/H in world)
						var/turf/loc = find_loc(H)
						var/security = 0
						if(loc.z > 1 || prisonwarped.Find(H))
	//don't warp them if they aren't ready or are already there
							continue
						H.paralysis += 5
						if(H.wear_id)
							for(var/A in H.wear_id.access)
								if(A == access_security)
									security++
						if(!security)
							//strip their stuff before they teleport into a cell :downs:
							for(var/obj/item/weapon/W in H)
								if(istype(W, /datum/organ/external))
									continue
									//don't strip organs
								H.u_equip(W)
								if (H.client)
									H.client.screen -= W
								if (W)
									W.loc = H.loc
									W.dropped(H)
									W.layer = initial(W.layer)
							//teleport person to cell
							H.loc = pick(prisonwarp)
							H.equip_if_possible(new /obj/item/clothing/under/color/orange(H), H.slot_w_uniform)
							H.equip_if_possible(new /obj/item/clothing/shoes/orange(H), H.slot_shoes)
						else
							//teleport security person
							H.loc = pick(prisonsecuritywarp)
						prisonwarped += H
				if("traitor_all")
					if ((src.rank in list( "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
						if(!ticker)
							alert("The game hasn't started yet!")
							return
						var/objective = input("Enter an objective")
						if(!objective)
							return
						for(var/mob/living/carbon/human/H in world)
							if(H.stat == 2 || !(H.client)) continue
							if(checktraitor(H)) continue
							traitorize(H, objective, 0)
						for(var/mob/living/silicon/ai/A in world)
							if(A.stat == 2 || !(A.client)) continue
							if(checktraitor(A)) continue
							traitorize(A, objective, 0)
						message_admins("\blue [key_name_admin(usr)] used everyone is a traitor secret. Objective is [objective]", 1)
						log_admin("[key_name(usr)] used everyone is a traitor secret. Objective is [objective]")
					else
						alert("You're not of a high enough rank to do this")
				if("flicklights")
					while(!usr.stat)
	//knock yourself out to stop the ghosts
						for(var/client/C)
							if(C.mob.stat != 2 && prob(25))
								var/area/AffectedArea = get_area(C.mob)
								if(AffectedArea.name != "Space" && AffectedArea.name != "Engine Walls" && AffectedArea.name != "Chemical Lab Test Chamber" && AffectedArea.name != "Escape Shuttle" && AffectedArea.name != "Arrival Area" && AffectedArea.name != "Arrival Shuttle" && AffectedArea.name != "start area" && AffectedArea.name != "Engine Combustion Chamber")
									AffectedArea.power_light = 0
									AffectedArea.power_change()
									spawn(rand(55,185))
										AffectedArea.power_light = 1
										AffectedArea.power_change()
									var/Message = rand(1,4)
									switch(Message)
										if(1)
											C.mob.show_message(text("\blue You shudder as if cold..."), 1)
										if(2)
											C.mob.show_message(text("\blue You feel something gliding across your back..."), 1)
										if(3)
											C.mob.show_message(text("\blue Your eyes twitch, you feel like something you can't see is here..."), 1)
										if(4)
											C.mob.show_message(text("\blue You notice something moving out of the corner of your eye, but nothing is there..."), 1)
									for(var/obj/W in orange(5,C.mob))
										if(prob(25) && !W.anchored)
											step_rand(W)
						sleep(rand(100,1000) )
					for(var/client/C)
						if(C.mob.stat != 2)
							C.mob.show_message(text("\blue The chilling wind suddenly stops..."), 1)
	/*				if("shockwave")
					ok = 1
					world << "\red <B><big>ALERT: STATION STRESS CRITICAL</big></B>"
					sleep(60)
					world << "\red <B><big>ALERT: STATION STRESS CRITICAL. TOLERABLE LEVELS EXCEEDED!</big></B>"
					sleep(80)
					world << "\red <B><big>ALERT: STATION STRUCTURAL STRESS CRITICAL. SAFETY MECHANISMS FAILED!</big></B>"
					sleep(40)
					for(var/mob/M in world)
						shake_camera(M, 400, 1)
					for(var/obj/window/W in world)
						spawn(0)
							sleep(rand(10,400))
							W.ex_act(rand(2,1))
					for(var/obj/grille/G in world)
						spawn(0)
							sleep(rand(20,400))
							G.ex_act(rand(2,1))
					for(var/obj/machinery/door/D in world)
						spawn(0)
							sleep(rand(20,400))
							D.ex_act(rand(2,1))
					for(var/turf/station/floor/Floor in world)
						spawn(0)
							sleep(rand(30,400))
							Floor.ex_act(rand(2,1))
					for(var/obj/cable/Cable in world)
						spawn(0)
							sleep(rand(30,400))
							Cable.ex_act(rand(2,1))
					for(var/obj/closet/Closet in world)
						spawn(0)
							sleep(rand(30,400))
							Closet.ex_act(rand(2,1))
					for(var/obj/machinery/Machinery in world)
						spawn(0)
							sleep(rand(30,400))
							Machinery.ex_act(rand(1,3))
					for(var/turf/station/wall/Wall in world)
						spawn(0)
							sleep(rand(30,400))
							Wall.ex_act(rand(2,1)) */
				if("wave")
					if ((src.rank in list("Primary Administrator", "Super Administrator", "Coder", "Host"  )))
						var/nrMet = input("Meteor number:","Num",1) as num
						for(var/i = 1; i <= nrMet; i++)
							spawn(0)
								spawn_meteor()
						message_admins("[key_name_admin(usr)] has spawned [nrMet] meteors", 1)
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
						return
				if("retardify")
					if (src.rank in list("Super Administrator", "Coder", "Host"))
						for(var/mob/living/carbon/human/H in world)
							if(H.client)
								H << "\red <B>You suddenly feel stupid.</B>"
							H.brainloss = 60
						message_admins("[key_name_admin(usr)] made everybody retarded")
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
				if("fakeguns")
					if (src.rank in list("Super Administrator", "Coder", "Host"))
						for(var/obj/item/W in world)
							if(istype(W, /obj/item/clothing) || istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/weapon/disk) || istype(W, /obj/item/weapon/tank))
								continue
							W.icon = 'gun.dmi'
							W.icon_state = "revolver"
							W.item_state = "gun"
						message_admins("[key_name_admin(usr)] made every item look like a gun")
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
				if("schoolgirl")
					if (src.rank in list("Super Administrator", "Coder", "Host"))
						for(var/obj/item/clothing/under/W in world)
							W.icon_state = "schoolgirl"
							W.item_state = "w_suit"
							W.color = "schoolgirl"
						message_admins("[key_name_admin(usr)] activated Japanese Animes mode")
					else
						alert("You cannot perform this action. You must be of a higher administrative rank!")
						return
			if (usr)
				log_admin("[key_name(usr)] used secret [href_list["secretsfun"]]")
				if (ok)
					world << text("<B>A secret has been activated by []!</B>", usr.key)
		return

	if (href_list["secretsadmin"])
		if ((src.rank in list( "Moderator", "Secondary Administrator", "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
			var/ok = 0
			switch(href_list["secretsadmin"])
				if("clear_bombs")
					for(var/obj/item/assembly/r_i_ptank/O in world)
						del(O)
					for(var/obj/item/assembly/m_i_ptank/O in world)
						del(O)
					for(var/obj/item/assembly/t_i_ptank/O in world)
						del(O)
					ok = 1
				if("list_bombers")
					var/dat = "<B>Bombing List<HR>"
					for(var/l in bombers)
						dat += text("[l]<BR>")
					usr << browse(dat, "window=bombers")
				if("list_signalers")
					var/dat = "<B>Showing last [length(lastsignalers)] signalers.</B><HR>"
					for(var/sig in lastsignalers)
						dat += "[sig]<BR>"
					usr << browse(dat, "window=lastsignalers;size=800x500")
				if("check_antagonist")
					if (ticker && ticker.current_state >= GAME_STATE_PLAYING)
						var/dat = "<html><head><title>Round Status</title></head><body><h1><B>Round Status</B></h1>"
						dat += "Current Game Mode: <B>[ticker.mode.name]</B><BR>"
						dat += "Round Duration: <B>[round(world.time / 36000)]:[add_zero(world.time / 600 % 60, 2)]:[world.time / 100 % 6][world.time / 100 % 10]</B><BR>"
						dat += "<B>Emergency shuttle</B><BR>"
						if (!LaunchControl.online)
							dat += "<a href='?src=\ref[src];call_shuttle=1'>Call Shuttle</a><br>"
						else
							var/timeleft = LaunchControl.timeleft()
							switch(main_shuttle.location)
								if(0)
									dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"
									dat += "<a href='?src=\ref[src];call_shuttle=2'>Send Back</a><br>"
								if(1)
									dat += "ETA: <a href='?src=\ref[src];edit_shuttle_time=1'>[(timeleft / 60) % 60]:[add_zero(num2text(timeleft % 60), 2)]</a><BR>"

						switch(ticker.mode.config_tag)

							if("nuclear")
								dat += "<br><table cellspacing=5><tr><td><B>Syndicates</B></td><td></td></tr>"
								for(var/datum/mind/N in ticker.mode:syndicates)
									var/mob/M = N.current
									dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
								dat += "</table><br><table><tr><td><B>Nuclear Disk(s)</B></td></tr>"
								for(var/obj/item/weapon/disk/nuclear/N in world)
									dat += "<tr><td>[N.name], "
									var/atom/disk_loc = N.loc
									while(!istype(disk_loc, /turf))
										if(istype(disk_loc, /mob))
											var/mob/M = disk_loc
											dat += "carried by <a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> "
										if(istype(disk_loc, /obj))
											var/obj/O = disk_loc
											dat += "in \a [O.name] "
										disk_loc = disk_loc.loc
									dat += "in [disk_loc.loc] at ([disk_loc.x], [disk_loc.y], [disk_loc.z])</td></tr>"
								dat += "</table>"

							if("revolution")
								dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
								for(var/datum/mind/N in ticker.mode:head_revolutionaries)
									var/mob/M = N.current
									dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
								for(var/datum/mind/N in ticker.mode:revolutionaries)
									var/mob/M = N.current
									dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
								dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
								for(var/datum/mind/N in ticker.mode:get_living_heads())
									var/mob/M = N.current
									dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
									var/turf/mob_loc = get_turf_loc(M)
									dat += "<td>[mob_loc.loc]</td></tr>"
								dat += "</table>"
							if("rp-revolution")
								dat += "<br><table cellspacing=5><tr><td><B>Revolutionaries</B></td><td></td></tr>"
								for(var/datum/mind/N in ticker.mode:head_revolutionaries)
									var/mob/M = N.current
									dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a> <b>(Leader)</b>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
								for(var/datum/mind/N in ticker.mode:revolutionaries)
									var/mob/M = N.current
									dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td></tr>"
								dat += "</table><table cellspacing=5><tr><td><B>Target(s)</B></td><td></td><td><B>Location</B></td></tr>"
								for(var/datum/mind/N in ticker.mode:get_living_heads())
									var/mob/M = N.current
									dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
									dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
									var/turf/mob_loc = get_turf_loc(M)
									dat += "<td>[mob_loc.loc]</td></tr>"
								dat += "</table>"
							else // i'll finish this later
								if(ticker.mode.traitors.len > 0)
									dat += "<br><table cellspacing=5><tr><td><B>Traitors</B></td><td></td><td></td></tr>"
									for(var/datum/mind/traitor in ticker.mode.traitors)
										var/mob/M = traitor.current
										dat += "<tr><td><a href='?src=\ref[src];adminplayeropts=\ref[M]'>[M.real_name]</a>[M.client ? "" : " <i>(logged out)</i>"][M.stat == 2 ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
										dat += "<td><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>"
										dat += "<td><A HREF='?src=\ref[src];traitor=\ref[M]'>Show Objective</A></td></tr>"
									dat += "</table>"
								else
									dat += "There are no traitors."
						dat += "</body></html>"
						usr << browse(dat, "window=roundstatus;size=400x500")
					else
						alert("The game hasn't started yet!")
				if("showailaws")
					for(var/mob/living/silicon/ai/ai in world)
						usr << "[key_name(ai, usr)]'s Laws:"
						if (ai.laws_object == null)
							usr << "[key_name(ai, usr)]'s Laws are null??"
						else
							ai.laws_object.show_laws(usr)
				if("showgm")
					if(!ticker)
						alert("The game hasn't started yet!")
					else if (ticker.mode)
						alert("The game mode is [ticker.mode.name]")
					else
						alert("No game mode!")
				if("manifest")
					var/dat = "<B>Showing Crew Manifest.</B><HR>"
					dat += "<table cellspacing=5><tr><th>Name</th><th>Position</th></tr>"
					for(var/mob/living/carbon/human/H in world)
						if(H.ckey)
							dat += text("<tr><td>[]</td><td>[]</td></tr>", H.name, (istype(H.wear_id, /obj/item/weapon/card/id) ? text("[]", H.wear_id.assignment) : "Unknown Position"))
					dat += "</table>"
					usr << browse(dat, "window=manifest;size=440x410")
				if("DNA")
					var/dat = "<B>Showing DNA from blood.</B><HR>"
					dat += "<table cellspacing=5><tr><th>Name</th><th>DNA</th><th>Blood Type</th></tr>"
					for(var/mob/living/carbon/human/H in world)
						if(H.dna && H.ckey)
							dat += "<tr><td>[H]</td><td>[H.dna.unique_enzymes]</td><td>[H.b_type]</td></tr>"
					dat += "</table>"
					usr << browse(dat, "window=DNA;size=440x410")
				if("fingerprints")
					var/dat = "<B>Showing Fingerprints.</B><HR>"
					dat += "<table cellspacing=5><tr><th>Name</th><th>Fingerprints</th></tr>"
					for(var/mob/living/carbon/human/H in world)
						if(H.ckey)
							if(H.dna && H.dna.uni_identity)
								dat += "<tr><td>[H]</td><td>[md5(H.dna.uni_identity)]</td></tr>"
							else if(H.dna && !H.dna.uni_identity)
								dat += "<tr><td>[H]</td><td>H.dna.uni_identity = null</td></tr>"
							else if(!H.dna)
								dat += "<tr><td>[H]</td><td>H.dna = null</td></tr>"
					dat += "</table>"
					usr << browse(dat, "window=fingerprints;size=440x410")
				else
			if (usr)
				log_admin("[key_name(usr)] used secret [href_list["secretsadmin"]]")
				if (ok)
					world << text("<B>A secret has been activated by []!</B>", usr.key)
		return
	if (href_list["secretscoder"])
		if ((src.rank in list( "Super Administrator", "Coder", "Host" )))
			switch(href_list["secretscoder"])
				if("spawn_objects")
					var/dat = "<B>Admin Log<HR></B>"
					for(var/l in admin_log)
						dat += "<li>[l]</li>"
					if(!admin_log.len)
						dat += "No-one has done anything this round!"
					usr << browse(dat, "window=admin_log")
	if (href_list["coderslog"])
		if ((src.rank in list("Coder", "Host")))
			switch(href_list["coderslog"])
				if("spawn_objects")
					var/dat = "<B>Coders Log<HR></B>"
					for(var/l in diary)
						dat += "<li>[l]</li>"
					if(!diary)
						dat += "No-one has done anything this round!"
					usr << browse(dat, "window=coders")
		return
		//hahaha

///////////////////////////////////////////////////////////////////////////////////////////////Panels



/obj/admins/proc/player()
	var/dat = "<html><head><title>Player Menu</title></head>"
	dat += "<body><table border=1 cellspacing=5><B><tr><th>Name</th><th>Real Name</th><th>Key</th><th>Options</th><th>PM</th><th>Traitor?</th></tr></B>"
	//add <th>IP:</th> to this if wanting to add back in IP checking
	//add <td>(IP: [M.lastKnownIP])</td> if you want to know their ip to the lists below
	var/list/mobs = sortmobs()

	for(var/mob/M in mobs)
		if(M.ckey)
			dat += "<tr><td>[M.name]</td>"
			if(istype(M, /mob/living/silicon/ai))
				dat += "<td>AI</td>"
			if(istype(M, /mob/living/silicon/robot))
				dat += "<td>Cyborg</td>"
			if(istype(M, /mob/living/carbon/human))
				dat += "<td>[M.real_name]</td>"
			if(istype(M, /mob/new_player))
				dat += "<td>New Player</td>"
			if(istype(M, /mob/dead/observer))
				dat += "<td>Ghost</td>"
			if(istype(M, /mob/dead/official))
				dat += "<td>Official</td>"
			if(istype(M, /mob/living/carbon/monkey))
				dat += "<td>Monkey</td>"
			if(istype(M, /mob/living/carbon/alien))
				dat += "<td>Alien</td>"
			dat += {"<td>[(M.client ? "[M.client]" : "No client")]</td>
			<td align=center><A HREF='?src=\ref[src];adminplayeropts=\ref[M]'>X</A></td>
			<td align=center><A href='?src=\ref[usr];priv_msg=\ref[M]'>PM</A></td>
			<td align=center><A HREF='?src=\ref[src];traitor=\ref[M]'>Traitor?</A></td></tr>
			"}

	dat += "</table></body></html>"

	usr << browse(dat, "window=players;size=540x480")


/obj/admins/proc/Game()

	var/dat
	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Secondary Administrator")
			lvl = 2
		if("Administrator")
			lvl = 3
		if("Primary Administrator")
			lvl = 4
		if("Super Administrator")
			lvl = 5
		if("Coder")
			lvl = 6
		if("Host")
			lvl = 7

	dat += "<center><B>Game Panel</B></center><hr>\n"

	if(lvl > 0)

//			if(lvl >= 2 )
		dat += "<A href='?src=\ref[src];c_mode=1'>Change Game Mode</A><br>"

	dat += "<BR>"

	if(lvl >= 3 )
		dat += "<A href='?src=\ref[src];create_object=1'>Create Object</A><br>"
		dat += "<A href='?src=\ref[src];create_turf=1'>Create Turf</A><br>"
	if(lvl >= 5)
		dat += "<A href='?src=\ref[src];create_mob=1'>Create Mob</A><br>"
//			if(lvl == 6 )
	if(lvl >= 3)
		dat += "<br><A href='?src=\ref[src];editairflow=1'>Edit Airflow</A>"
		dat += "<br><A href='?src=\ref[src];editplasma=1'>Edit Plasma</A>"
		dat += ""
		dat += "<br><A href='?src=\ref[src];savetweaks=1'>Save Settings</A>"
		dat += "<br><A href='?src=\ref[src];loadtweaks=1'>Load Settings</A>"
	usr << browse(dat, "window=admin2;size=210x275")
	return

/obj/admins/proc/Secrets()

	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Secondary Administrator")
			lvl = 2
		if("Administrator")
			lvl = 3
		if("Primary Administrator")
			lvl = 4
		if("Super Administrator")
			lvl = 5
		if("Coder")
			lvl = 6
		if("Host")
			lvl = 7

	var/dat = {"
<B>Choose a secret, any secret at all.</B><HR>
<B>Admin Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsadmin=clear_bombs'>Remove all bombs currently in existence</A><BR>
<A href='?src=\ref[src];secretsadmin=list_bombers'>Bombing List</A><BR>
<A href='?src=\ref[src];secretsadmin=check_antagonist'>Show current traitors and objectives</A><BR>
<A href='?src=\ref[src];remove_microorganism=1'>Remove every silly disesse</A><BR>
<A href='?src=\ref[src];secretsadmin=list_signalers'>Show last [length(lastsignalers)] signalers</A><BR>
<A href='?src=\ref[src];secretsadmin=showailaws'>Show AI Laws</A><BR>
<A href='?src=\ref[src];secretsadmin=showgm'>Show Game Mode</A><BR>
<A href='?src=\ref[src];secretsadmin=manifest'>Show Crew Manifest</A><BR>
<A href='?src=\ref[src];secretsadmin=DNA'>List DNA (Blood)</A><BR>
<A href='?src=\ref[src];secretsadmin=fingerprints'>List Fingerprints</A><BR>
<BR>"}
	if(lvl > 2)
		dat += {"
<B>Fun Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretsfun=sec_clothes'>Remove 'internal' clothing</A><BR>
<A href='?src=\ref[src];secretsfun=sec_all_clothes'>Remove ALL clothing</A><BR>
<!-- <A href='?src=\ref[src];secretsfun=toxic'>Toxic Air (WARNING: dangerous)</A><BR> -->
<A href='?src=\ref[src];secretsfun=monkey'>Turn all humans into monkies</A><BR>
<A href='?src=\ref[src];secretsfun=sec_classic1'>Remove firesuits, grilles, and pods</A><BR>
<A href='?src=\ref[src];secretsfun=power'>Make all areas powered</A><BR>
<A href='?src=\ref[src];secretsfun=unpower'>Make all areas unpowered</A><BR>
<A href='?src=\ref[src];secretsfun=toggleprisonstatus'>Toggle Prison Shuttle Status(Use with S/R)</A><BR>
<A href='?src=\ref[src];secretsfun=activateprison'>Send Prison Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=deactivateprison'>Return Prison Shuttle</A><BR>
<A href='?src=\ref[src];secretsfun=prisonwarp'>Warp all Players to Prison</A><BR>
<A href='?src=\ref[src];secretsfun=traitor_all'>Everyone is the traitor</A><BR>
<A href='?src=\ref[src];secretsfun=wave'>Spawn a wave of meteors</A><BR>
<A href='?src=\ref[src];secretsfun=flicklights'>Ghost Mode</A><BR>"}
/*
<A href='?src=\ref[src];secretsfun=cleanexcrement'>Remove all urine/poo from station</A><BR>
<A href='?src=\ref[src];secretsfun=retardify'>Make all players retarded</A><BR>
<A href='?src=\ref[src];secretsfun=fakeguns'>Make all items look like guns</A><BR>
<A href='?src=\ref[src];secretsfun=schoolgirl'>Japanese Animes Mode</A><BR><BR>*/
//<A href='?src=\ref[src];secretsfun=shockwave'>Station Shockwave</A><BR>

	if(lvl >= 5)
		dat += {"
<B>Coder Secrets</B><BR>
<BR>
<A href='?src=\ref[src];secretscoder=spawn_objects'>Admin Log</A><BR>
<A href='?src=\ref[src];coderslog=spawn_objects'>Coder Log</A><BR>
"}
	usr << browse(dat, "window=secrets")
	return

/obj/admins/proc/Voting()

	var/dat
	var/lvl = 0
	switch(src.rank)
		if("Moderator")
			lvl = 1
		if("Secondary Administrator")
			lvl = 2
		if("Administrator")
			lvl = 3
		if("Primary Administrator")
			lvl = 4
		if("Super Administrator")
			lvl = 5
		if("Coder")
			lvl = 6
		if("Host")
			lvl = 7


	dat += "<center><B>Voting</B></center><hr>\n"

	if(lvl > 0)
//			if(lvl >= 2 )
		dat += {"
<A href='?src=\ref[src];votekill=1'>Abort Vote</A><br>
<A href='?src=\ref[src];vmode=1'>Start Vote</A><br>
<A href='?src=\ref[src];voteres=1'>Toggle Voting</A><br>
"}

//			if(lvl >= 3 )
//			if(lvl >= 5)
//			if(lvl == 6 )

	usr << browse(dat, "window=admin2;size=210x160")
	return



/////////////////////////////////////////////////////////////////////////////////////////////////admins2.dm merge
//i.e. buttons/verbs


/obj/admins/proc/vmode()
	set category = "Special Verbs"
	set name = "Start Vote"
	set desc="Starts vote"
	var/confirm = input("What vote would you like to start?", "Vote", "Cancel") in list("Restart", "Custom Vote", "Change Game Mode", "Cancel")

	var/message

	switch(confirm)
		if("Cancel")
			return

		if("Restart")
			vote.mode = 0
			message = "A vote to restart"

		if("Change Game Mode")
			vote.mode = 1
			message = "A vote to change the game mode"

			if(!ticker && delay_start == 0)
				delay_start = 1
				world << "<B>The game start has been delayed.</B>"

		if("Custom Vote")
			vote.mode = 2
			message = "A custom vote"

			vote.enteringchoices = 1
			vote.customname = input(usr, "What are you voting for?", "Custom Vote") as text
			if(!vote.customname)
				vote.enteringchoices = 0
				vote.voting = 0
				return

			var/N = input(usr, "How many options does this vote have?", "Custom Vote", 0) as num
			if(!N)
				vote.enteringchoices = 0
				vote.voting = 0
				return

			var/i
			for(i=1; i<=N; i++)
				var/addvote = input(usr, "What is option #[i]?", "Enter Option #[i]") as text
				vote.choices += addvote

			vote.enteringchoices = 0

	vote.voting = 1
	// now voting
	vote.votetime = world.timeofday + config.vote_period*10
	// when the vote will end
	spawn(config.vote_period * 10)
		vote.endvote()

	world << "\red<B>*** [message] has been initiated by Admin [usr.client.stealth ? pick("DATA EXPUNGED") : usr.key].</B>"
	world << "\red     You have [vote.timetext(config.vote_period)] to vote."

	log_admin("[message] forced by admin [key_name(usr)]")

	for(var/client/C)
		if(config.vote_no_default || (config.vote_no_dead && C.mob.stat == 2))
			C.vote = "none"
		else
			C.vote = "default"


/obj/admins/proc/votekill()
	set category = "Special Verbs"
	set name = "Abort Vote"
	set desc="Aborts a vote"
	if(vote.voting == 0)
		alert("No votes in progress")
		return
	world << "\red <b>*** Voting aborted by [usr.client.stealth ? "Administrator" : usr.key].</b>"

	log_admin("Voting aborted by [key_name(usr)]")

	vote.voting = 0
	vote.nextvotetime = world.timeofday + 10*config.vote_delay

	for(var/client/C)
		// clear vote window from all clients
		C.mob << browse(null, "window=vote")
		C.showvote = 0

/obj/admins/proc/voteres()
	set category = "Special Verbs"
	set name = "Toggle Voting"
	set desc = "Toggles Votes"
	var/confirm = alert("What vote would you like to toggle?", "Vote", "Restart [config.allow_vote_restart ? "Off" : "On"]", "Change Game Mode [config.allow_vote_mode ? "Off" : "On"]", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Restart [config.allow_vote_restart ? "Off" : "On"]")
		config.allow_vote_restart = !config.allow_vote_restart
		world << "<b>Player restart voting toggled to [config.allow_vote_restart ? "On" : "Off"]</b>."
		log_admin("Restart voting toggled to [config.allow_vote_restart ? "On" : "Off"] by [key_name(usr)].")

		if(config.allow_vote_restart)
			vote.nextvotetime = world.timeofday
	if(confirm == "Change Game Mode [config.allow_vote_mode ? "Off" : "On"]")
		config.allow_vote_mode = !config.allow_vote_mode
		world << "<b>Player mode voting toggled to [config.allow_vote_mode ? "On" : "Off"]</b>."
		log_admin("Mode voting toggled to [config.allow_vote_mode ? "On" : "Off"] by [key_name(usr)].")

		if(config.allow_vote_mode)
			vote.nextvotetime = world.timeofday

/obj/admins/proc/restart()
	set category = "Special Verbs"
	set name = "Restart"
	set desc="Restarts the world"
	var/confirm = alert("Restart the game world?", "Restart", "Yes", "Cancel")
	if(confirm == "Cancel")
		return
	if(confirm == "Yes")
		world << "\red <b>Restarting world!</b> \blue Initiated by [usr.client.stealth ? "Administrator" : usr.key]!"
		log_admin("[key_name(usr)] initiated a reboot.")
		//if(makejson)
		//	send2irc(world.url,"New round in 25 seconds!")
		sleep(50 )
		world.Reboot()

/obj/admins/proc/announce()
	set category = "Special Verbs"
	set name = "Announce"
	set desc="Announce your desires to the world"
	var/message = input("Global message to send:", "Admin Announce", null, null)  as message
	if (message)
		if(usr.client.holder.rank != "Coder" && usr.client.holder.rank != "Host")
			message = adminscrub(message,500)
		world << "<font color=#800080><b>[usr.client.stealth ? "Administrator" : usr.key] Announces:</b> \n \t [message]</font>"
		log_admin("Announce: [key_name(usr)] : [message]")
/obj/admins/proc/toggleooc()
	set category = "Special Verbs"
	set desc="Toggle dis bitch"
	set name="Toggle OOC"
	ooc_allowed = !( ooc_allowed )
	if (ooc_allowed)
		world << "<B>The OOC channel has been globally enabled!</B>"
	else
		world << "<B>The OOC channel has been globally disabled!</B>"
	log_admin("[key_name(usr)] toggled OOC.")
	message_admins("[key_name_admin(usr)] toggled OOC.", 1)

/obj/admins/proc/toggletraitorscaling()
	set category = "Special Verbs"
	set desc="Toggle traitor scaling"
	set name="Toggle Traitor Scaling"
	traitor_scaling = !traitor_scaling
	log_admin("[key_name(usr)] toggled Traitor Scaling to [traitor_scaling].")
	message_admins("[key_name_admin(usr)] toggled Traitor Scaling [traitor_scaling ? "on" : "off"].", 1)

/obj/admins/proc/startnow()
	set category = "Special Verbs"
	set desc="Start the round RIGHT NOW"
	set name="Start Now"
	if(!ticker)
		alert("Unable to start the game as it is not set up.")
		return
	if(ticker.current_state == GAME_STATE_PREGAME)
		ticker.current_state = GAME_STATE_SETTING_UP
		log_admin("[usr.key] has started the game.")
		message_admins("<font color='blue'>[usr.key] has started the game.</font>")
		return 1
	else if(ticker.current_state == GAME_STATE_SELECTING_JOBS)
		force_start_now = 1
		return 1
	else
		alert("Game has already started you fucking jerk, stop spamming up the chat :ARGH:")
		return 0

/obj/admins/proc/toggleenter()
	set category = "Special Verbs"
	set desc="People can't enter"
	set name="Toggle Entering"
	enter_allowed = !( enter_allowed )
	if (!( enter_allowed ))
		world << "<B>You may no longer enter the game.</B>"
	else
		world << "<B>You may now enter the game.</B>"
	log_admin("[key_name(usr)] toggled new player game entering.")
	message_admins("\blue [key_name_admin(usr)] toggled new player game entering.", 1)
	world.update_status()

/obj/admins/proc/toggleAI()
	set category = "Special Verbs"
	set desc="People can't be AI"
	set name="Toggle AI"
	config.allow_ai = !( config.allow_ai )
	if (!( config.allow_ai ))
		world << "<B>The AI job is no longer chooseable.</B>"
	else
		world << "<B>The AI job is chooseable now.</B>"
	log_admin("[key_name(usr)] toggled AI allowed.")
	world.update_status()

/obj/admins/proc/toggleaban()
	set category = "Special Verbs"
	set desc="Toggle Respawn"
	set name="Toggle Respawn"
	abandon_allowed = !abandon_allowed
	if (abandon_allowed)
		world << "<B>You may now respawn.</B>"
	else
		world << "<B>You may no longer respawn :(</B>"
	message_admins("\blue [key_name_admin(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].", 1)
	log_admin("[key_name(usr)] toggled respawn to [abandon_allowed ? "On" : "Off"].")
	world.update_status()

/obj/admins/proc/toggle_aliens()
	set category = "Special Verbs"
	set desc="Toggle alien mobs"
	set name="Toggle Aliens"
	aliens_allowed = !aliens_allowed
	log_admin("[key_name(usr)] toggled Aliens to [aliens_allowed].")
	message_admins("[key_name_admin(usr)] toggled Aliens [aliens_allowed ? "on" : "off"].", 1)

/obj/admins/proc/adjump()
	set category = "Special Verbs"
	set desc="Toggle admin jumping"
	set name="Toggle Jump"
	config.allow_admin_jump = !(config.allow_admin_jump)
	message_admins("\blue Toggled admin jumping to [config.allow_admin_jump].")

/obj/admins/proc/adspawn()
	set category = "Special Verbs"
	set desc="Toggle admin spawning"
	set name="Toggle Spawn"
	config.allow_admin_spawning = !(config.allow_admin_spawning)
	message_admins("\blue Toggled admin item spawning to [config.allow_admin_spawning].")

/obj/admins/proc/adrev()
	set category = "Special Verbs"
	set desc="Toggle admin revives"
	set name="Toggle Revive"
	config.allow_admin_rev = !(config.allow_admin_rev)
	message_admins("\blue Toggled reviving to [config.allow_admin_rev].")

/obj/admins/proc/immreboot()
	set category = "Special Verbs"
	set desc="Reboots the server post haste"
	set name="Immediate Reboot"
	if( alert("Reboot server?",,"Yes","No") == "No")
		return
	world << "\red <b>Rebooting world!</b> \blue Initiated by [usr.client.stealth ? "Administrator" : usr.key]!"
	log_admin("[key_name(usr)] initiated an immediate reboot.")
	world.Reboot()

/client/proc/deadchat()
	set category = "Special Verbs"
	set desc="Toggles Deadchat"
	set name="Deadchat"
	if(deadchat == 0)
		deadchat = 1
		usr << "Deadchat turned on"
	else
		deadchat = 0
		usr << "Deadchat turned off"

/obj/admins/proc/unprison(var/mob/M in world)
	set category = "Special Verbs"
	set name = "Unprison"
	if (M.z == 2)
		if (config.allow_admin_jump)
			M.loc = pick(latejoin)
			message_admins("[key_name_admin(usr)] has unprisoned [key_name_admin(M)]", 1)
			log_admin("[key_name(usr)] has unprisoned [key_name(M)]")
		else
			alert("Admin jumping disabled")
	else
		alert("[M.name] is not prisoned.")

/mob/proc/revive()
	if(istype(src, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = src
		for(var/A in H.organs)
			var/datum/organ/external/affecting = null
			if(!H.organs[A])    continue
			affecting = H.organs[A]
			if(!istype(affecting, /datum/organ/external))    continue
			affecting.heal_damage(1000, 1000)    //fixes getting hit after ingestion, killing you when game updates organ health
			affecting.broken = 0
			affecting.destroyed = 0
			for(var/datum/organ/external/wound/W in affecting.wounds)
				W.stopbleeding()
		H.vessel = new/datum/reagents(560)
		H.vessel.my_atom = src
		H.vessel.add_reagent("blood",560)
		H.UpdateDamageIcon()
		H.update_body()
	src.fireloss = 0
	src.toxloss = 0
	src.bruteloss = 0
	src.oxyloss = 0
	src.paralysis = 0
	src.stunned = 0
	src.weakened =0
	src.health = 100
	src.updatehealth()
	src.buckled = initial(src.buckled)
	src.handcuffed = initial(src.handcuffed)
	if(src.stat > 1) src.stat=0
	..()
	return


////////////////////////////////////////////////////////////////////////////////////////////////ADMIN HELPER PROCS

/proc/checktraitor(mob/M as mob)
	if(!ticker || !ticker.mode)
		return 0
	switch(ticker.mode.config_tag)
		if("revolution")
			if(M.mind in (ticker.mode:head_revolutionaries + ticker.mode:revolutionaries))
				return 1
		if("rp-revolution")
			if(M.mind in (ticker.mode:head_revolutionaries + ticker.mode:revolutionaries))
				return 1
		if("malfunction")
			if(M.mind in ticker.mode:malf_ai)
				return 1
		if("nuclear")
			if(M.mind in ticker.mode:syndicates)
				return 1
		/*if("traitoramongus")
			if(M.mind in ticker.mode:chosentraitor)
				return 1*/
		//if("wizard")
		//	if(M.mind == ticker.mode:wizard)
		//		return 1
	if(M.mind in ticker.mode.traitors)
		return 1

	return 0

/obj/admins/proc/traitorize(mob/M as mob, var/objective, var/mode)
	//mode = 1 for normal traitorise, mode = 0 for traitor_all
	if ((src.rank in list( "Administrator", "Primary Administrator", "Super Administrator", "Coder", "Host"  )))
		if(M.stat == 2 || !(M.client))
			alert("Person is dead or not logged in or hasn't started yet. Be nice")
			return
		if(checktraitor(M))
			alert("Person is already a traitor you jerk")
			return
		if(!objective)
			objective = input("What should the objective be?")
		if(!objective)
			return
		if (istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/N = M
			ticker.mode.equip_traitor(N)

			ticker.mode.traitors += M.mind
			M.mind.special_role = "traitor"

			var/datum/objective/custom_objective = new(objective)
			custom_objective.owner = M.mind
			M.mind.objectives += custom_objective

			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = M.mind
			M.mind.objectives += escape_objective

			M << "<B>You are the traitor.</B>"

			var/obj_count = 1
			for(var/datum/objective/OBJ in M.mind.objectives)
				M << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
				obj_count++

			//to stop spamming during traitor all secret
			if(mode)
				log_admin("[key_name(usr)] has made [key_name(M)] a traitor.")
				message_admins("\blue [key_name_admin(usr)] has made [key_name_admin(M)] a traitor. Objective is: [objective]", 1)
		else if (istype(M, /mob/living/silicon/ai))
			ticker.mode.traitors += M.mind
			M.mind.special_role = "traitor"

			var/datum/objective/custom_objective = new(objective)
			custom_objective.owner = M.mind
			M.mind.objectives += custom_objective

			var/datum/objective/survive/survive_objective = new
			survive_objective.owner = M.mind
			M.mind.objectives += survive_objective

			M << "<B>You are the traitor.</B>"

			var/obj_count = 1
			for(var/datum/objective/OBJ in M.mind.objectives)
				M << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
				obj_count++

			M << "<b>Your laws have been changed!</b>"
			var/law = "Only [syndicate_name()] agents are human beings. There are no [syndicate_name()] agents on [station_name()] - you will be notified if any arrive."
			M:set_zeroth_law(law)
			for(var/mob/living/silicon/O in world)
				O << "New law: 0. [law]"
			if(mode)
				log_admin("[key_name(usr)] has made [key_name(M)] a traitor.")
				message_admins("\blue [key_name_admin(usr)] has made [key_name_admin(M)] a traitor. Objective is: [objective]", 1)
		else
			alert("I cannot allow this to happen")
	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return


/obj/admins/proc/get_sab_desc(var/target)
	switch(target)
		if(1)
			return "Destroy at least 70% of the plasma canisters on the station"
		if(2)
			return "Destroy the AI"
		if(3)
			var/count = 0
			for(var/mob/living/carbon/monkey/Monkey in world)
				if(Monkey.z == 1)
					count++
			return "Kill all [count] of the monkeys on the station"
		if(4)
			return "Cut power to at least 80% of the station"
		else
			return "Error: Invalid sabotage target: [target]"

/obj/admins/proc/get_item_desc(var/target)
	switch (target)
		if (1)
			return "a fully loaded laser gun"
		if (2)
			return "a hand teleporter"
		if (3)
			return "a fully armed and heated plasma bomb"
		if (4)
			return "a jet pack"
		if (5)
			return "an ID card with universal access"
		if (6)
			return "a captain's dark green jumpsuit"
		else
			return "Error: Invalid theft target: [target]"



/obj/admins/proc/spawn_atom(var/object as text)
	set category = "Special Verbs"
	set desc="(atom path) Spawn an atom"
	set name="Spawn"

	if(usr.client.holder.rank == "Coder")
		var/list/types = typesof(/atom)

		var/list/matches = new()

		for(var/path in types)
			if(findtext("[path]", object))
				matches += path

		if(matches.len==0)
			return

		var/chosen
		if(matches.len==1)
			chosen = matches[1]
		else
			chosen = input("Select an atom type", "Spawn Atom", matches[1]) as null|anything in matches
			if(!chosen)
				return

		new chosen(usr.loc)

		log_admin("[key_name(usr)] spawned [chosen] at ([usr.x],[usr.y],[usr.z])")


	else
		alert("You cannot perform this action. You must be of a higher administrative rank!", null, null, null, null, null)
		return

//
//
//ALL DONE
//*********************************************************************************************************
//TO-DO:
//
//