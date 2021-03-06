datum/preferences
	var/real_name
	var/gender = MALE
	var/age = 30.0
	var/bloodtype = "A+"

	var/be_syndicate = 0
	var/be_nuke_agent = 0
	var/be_takeover_agent = 0
	var/be_random_name = 0
	var/underwear = 1

	var/occupation1 = "No Preference"
	var/occupation2 = "No Preference"
	var/occupation3 = "No Preference"
	var/title1
	var/title2
	var/title3
	var/hairstyle = "Short Hair"
	var/facialstyle = "Shaved"
	var/slotname
	var/hair_color = "#ffffff"
	var/show = 1
	var/facial_color = "#ffffff"
	var/bio = "bio goes here"
	var/skintone = 0.0
	var/eyecolor = "#ffffff"
	var/curslot = 0
	var/disabilities = 0
	var/icon/preview_icon = null

	New()
		randomize_name()
		..()

	proc/randomize_name()
		if (gender == MALE)
			real_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			real_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
	proc/randomize_name_ret() // fix this at some point
		if (gender == MALE)
			return capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
		else
			return capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
	proc/update_preview_icon()
		del(preview_icon)

		var/g = "m"
		if (gender == MALE)
			g = "m"
		else if (gender == FEMALE)
			g = "f"

		preview_icon = new /icon('icons/mob/human.dmi', "body_[g]_s")

		// Skin tone
		if (skintone >= 0)
			preview_icon.Blend(rgb(skintone, skintone, skintone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-skintone,  -skintone,  -skintone), ICON_SUBTRACT)

		if (underwear > 0)
			preview_icon.Blend(new /icon('icons/mob/human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)

		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_s")
		eyes_s.Blend(eyecolor, ICON_ADD)

		var/hairstyle_r = null
		switch(hairstyle)
			if("Short Hair")
				hairstyle_r = "hair_a"
			if("Long Hair")
				hairstyle_r = "hair_b"
			if("Cut Hair")
				hairstyle_r = "hair_c"
			if("Mohawk")
				hairstyle_r = "hair_d"
			if("Balding")
				hairstyle_r = "hair_e"
			if("Wave")
				hairstyle_r = "hair_f"
			if("Bedhead")
				hairstyle_r = "hair_bedhead"
			if("Dreadlocks")
				hairstyle_r = "hair_dreads"
			if("Ponytail")
				hairstyle_r = "hair_ponytail"
			if("Alternate Ponytail")
				hairstyle_r = "hair_pa"
			if("Medium Long")
				hairstyle_r = "hair_old"
			else
				hairstyle_r = "bald"

		var/facialstyle_r = null
		switch(facialstyle)
			if ("Watson")
				facialstyle_r = "facial_watson"
			if ("Chaplin")
				facialstyle_r = "facial_chaplin"
			if ("Selleck")
				facialstyle_r = "facial_selleck"
			if ("Neckbeard")
				facialstyle_r = "facial_neckbeard"
			if ("Full Beard")
				facialstyle_r = "facial_fullbeard"
			if ("Long Beard")
				facialstyle_r = "facial_longbeard"
			if ("Van Dyke")
				facialstyle_r = "facial_vandyke"
			if ("Elvis")
				facialstyle_r = "facial_elvis"
			if ("Abe")
				facialstyle_r = "facial_abe"
			if ("Chinstrap")
				facialstyle_r = "facial_chin"
			if ("Hipster")
				facialstyle_r = "facial_hip"
			if ("Goatee")
				facialstyle_r = "facial_gt"
			if ("Hogan")
				facialstyle_r = "facial_hogan"
			else
				facialstyle_r = "bald"

		var/icon/hair_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[hairstyle_r]_s")
		hair_s.Blend(hair_color, ICON_ADD)

		var/icon/facial_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[facialstyle_r]_s")
		facial_s.Blend(facial_color, ICON_ADD)

		var/icon/mouth_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "mouth_[g]_s")

		eyes_s.Blend(hair_s, ICON_OVERLAY)
		eyes_s.Blend(mouth_s, ICON_OVERLAY)
		eyes_s.Blend(facial_s, ICON_OVERLAY)

		preview_icon.Blend(eyes_s, ICON_OVERLAY)

		del(mouth_s)
		del(facial_s)
		del(hair_s)
		del(eyes_s)

	proc/ShowChoices(mob/user)
		update_preview_icon()
		user << browse_rsc(preview_icon, "previewicon.png")

		var/list/destructive = assistant_occupations.Copy()
		var/dat = "<html><body>"
		dat += "<b>Name:</b> "
		dat += "<a href=\"byond://?src=\ref[user];preferences=1;real_name=input\"><b>[real_name]</b></a> "
		dat += "(<a href=\"byond://?src=\ref[user];preferences=1;real_name=random\">&reg;</A>) "
		dat += "(&reg; = <a href=\"byond://?src=\ref[user];preferences=1;b_random_name=1\">[be_random_name ? "Yes" : "No"]</a>)"
		dat += "<br>"

		dat += "<b>Gender:</b> <a href=\"byond://?src=\ref[user];preferences=1;gender=input\"><b>[gender == MALE ? "Male" : "Female"]</b></a><br>"
		dat += "<b>Age:</b> <a href='byond://?src=\ref[user];preferences=1;age=input'>[age]</a>"

		dat += "<hr><b>Occupation Choices</b><br>"
		if (destructive.Find(occupation1))
			dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>[occupation1]</b></a><br>"
		else
			if (jobban_isbanned(user, occupation1))
				occupation1 = "Unassigned"
			if (jobban_isbanned(user, occupation2))
				occupation2 = "Unassigned"
			if (jobban_isbanned(user, occupation3))
				occupation3 = "Unassigned"
			if (occupation1 != "No Preference")
				dat += "\tFirst Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=1\"><b>[occupation1]</b></a><br>"
				if(HasTitles(occupation1))
					if(!title1)
						title1 = occupation1
					dat += "\t [occupation1] Title: <a href=\"byond://?src=\ref[user];preferences=1;occ=1;showtitle=1\"><b>[title1]</b></a><br>"
				if (destructive.Find(occupation2))
					dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\"><b>[occupation2]</b></a><BR>"

				else
					if (occupation2 != "No Preference")
						dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\"><b>[occupation2]</b></a><BR>"
						if(HasTitles(occupation2))
							if(!title2)
								title2 = occupation2
							dat += "\t [occupation2] Title: <a href=\"byond://?src=\ref[user];preferences=1;occ=2;showtitle=1\"><b>[title2]</b></a><br>"
						dat += "\tLast Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=3\"><b>[occupation3]</b></a><BR	>"
						if(HasTitles(occupation3))
							if(!title3)
								title3 = occupation3
							dat += "\t [occupation3] Title: <a href=\"byond://?src=\ref[user];preferences=1;occ=3;showtitle=1\"><b>[title3]</b></a><br>"

					else
						dat += "\tSecond Choice: <a href=\"byond://?src=\ref[user];preferences=1;occ=2\">No Preference</a><br>"
			else
				dat += "\t<a href=\"byond://?src=\ref[user];preferences=1;occ=1\">No Preference</a><br>"

		dat += "<hr><table><tr><td><b>Body</b><br>"
		dat += "Blood Type: <a href='byond://?src=\ref[user];preferences=1;b_type=input'>[bloodtype]</a><br>"
		dat += "Skin Tone: <a href='byond://?src=\ref[user];preferences=1;skintone=input'>[-skintone + 35]/220</a><br>"
		if (!IsGuestKey(user.key))
			dat += "Underwear: <a href =\"byond://?src=\ref[user];preferences=1;underwear=1\"><b>[underwear == 1 ? "Yes" : "No"]</b></a><br>"
		dat += "</td><td><b>Preview</b><br><img src=previewicon.png height=64 width=64></td></tr></table>"

		dat += "<hr><b>Hair</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;hair=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[hair_color]\"><table bgcolor=\"#[hair_color]\"><tr><td>IM</td></tr></table></font>"

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;hairstyle=input'>[hairstyle]</a>"

		dat += "<hr><b>Facial</b><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;facial=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[facial_color]\"><table bgcolor=\"#[facial_color]\"><tr><td>GO</td></tr></table></font>"

		dat += "Style: <a href='byond://?src=\ref[user];preferences=1;facialstyle=input'>[facialstyle]</a>"

		dat += "<hr><b>Eyes</b><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;eyes=input'>Change Color</a> <font face=\"fixedsys\" size=\"3\" color=\"#[eyecolor]\"><table bgcolor=\"#[eyecolor]\"><tr><td>KU</td></tr></table></font>"

		dat += "<hr><b>Disabilities: </b><a href=\"byond://?src=\ref[user];preferences=1;disabilities=1\">[disabilities]</a><br>"
		dat += "<hr>"
		if(!jobban_isbanned(user, "Syndicate"))
			dat += "<b>Be syndicate?:</b> <a href =\"byond://?src=\ref[user];preferences=1;b_syndicate=1\"><b>[(be_syndicate ? "Yes" : "No")]</b></a><br>"
			dat += "<b>Be nuke agent?:</b> <a href =\"byond://?src=\ref[user];preferences=1;b_nuke_agent=1\"><b>[(be_nuke_agent ? "Yes" : "No")]</b></a><br>"
			dat += "<b>Be takeover agent?:</b> <a href =\"byond://?src=\ref[user];preferences=1;b_takeover_agent=1\"><b>[(be_takeover_agent ? "Yes" : "No")]</b></a><br>"
		else
			dat += "<b> You are banned from being syndicate.</b>"
			be_syndicate = 0
			be_nuke_agent = 0
			be_takeover_agent = 0
		dat += "<a href =\"byond://?src=\ref[user];preferences=1;editbio=1\">Edit Biography</a><br>"
		//dat += "<b>Show Profile?:</b> <a href =\"byond://?src=\ref[user];preferences=1;b_syndicate=1\"><b>[(be_syndicate ? "Yes" : "No")]</b></a><br>
		dat += "<hr>"

		if (!IsGuestKey(user.key))
			if(!curslot)
				dat += "<a href='byond://?src=\ref[user];preferences=1;saveslot=1'>Save Slot 1</a><br>"
			else
				dat += "<a href='byond://?src=\ref[user];preferences=1;saveslot=[curslot]'>Save Slot [curslot]</a><br>"
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot2=1'>Load</a><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;createslot=1'>Create New Slot</a><br>"
		dat += "<a href='byond://?src=\ref[user];preferences=1;reset_all=1'>Reset Setup</a><br>"
		dat += "</body></html>"

		user << browse(dat, "window=preferences;size=300x640")
	proc/loadsave(mob/user)
		var/dat = "<body>"
		dat += "<tt><center>"
		var/list/slot = list()
		var/list/slots = list()
		var/database/query/query = new("SELECT `slot`,`slotname` FROM `players` WHERE ckey=?", usr.ckey)
		if(!query.Execute(dbcon))
			usr << "ERROR"
		while(query.NextRow())
			var/list/row = query.GetRowData()
			slot += row["slot"]
			var/T = row["slot"]
			var/K = row["slotname"]
			slots += row["slotname"]
			dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=[T]'>Load Slot [T]([K]) </a><a href='byond://?src=\ref[user];preferences=1;removeslot=[T]'>(R)</a><br><br>"

		dat += "<a href='byond://?src=\ref[user];preferences=1;loadslot=CLOSE'>Close</a><br>"
		dat += "</center></tt>"
		user << browse(dat, "window=saves;size=300x640")
	proc/closesave(mob/user)
		user << browse(null, "window=saves;size=300x640")
	proc/SetChoices(mob/user, occ=1)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		switch(occ)
			if(1.0)
				HTML += "<b>Which occupation would you like most?</b><br><br>"
			if(2.0)
				HTML += "<b>Which occupation would you like if you couldn't have your first?</b><br><br>"
			if(3.0)
				HTML += "<b>Which occupation would you like if you couldn't have the others?</b><br><br>"
			else
		for(var/job in uniquelist(occupations + assistant_occupations) )
			if ((job!="AI" || config.allow_ai) && !jobban_isbanned(user, job))
				HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=[job]\">[job]</a><br>"

		if(!jobban_isbanned(user, "Captain"))
			HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=Captain\">Captain</a><br>"
		HTML += "<br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];job=No Preference\">\[No Preference\]</a><br>"
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[occ];cancel=1\">\[Cancel\]</a>"
		HTML += "</center></tt>"

		user << browse(null, "window=preferences")
		user << browse(HTML, "window=mob_occupation;size=320x500")
		return

	proc/ShowTitle(mob/user,choice=1)
		var/HTML = "<body>"
		HTML += "<tt><center>"
		switch(choice)
			if(1.0)
				HTML += "<b>Which title would you for [occupation1].</b><br><br>"
				for(var/datum/title/T in titles)
					if(T.jobname == occupation1)
						for(var/A in T.title)
							HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[choice];title=[A]\">[A]</a><br>"
						break
			if(2.0)
				HTML += "<b>Which title would you for [occupation2].</b><br><br>"
				for(var/datum/title/T in titles)
					if(T.jobname == occupation2)
						for(var/A in T.title)
							HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[choice];title=[A]\">[A]</a><br>"
						break
			if(3.0)
				HTML += "<b>Which title would you for [occupation3].</b><br><br>"
				for(var/datum/title/T in titles)
					if(T.jobname == occupation3)
						for(var/A in T.title)
							HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[choice];title=[A]\">[A]</a><br>"
						break
		HTML += "<a href=\"byond://?src=\ref[user];preferences=1;occ=[choice];cancel=1\">\[Cancel\]</a>"
		HTML += "</center></tt>"
		user << browse(null, "window=preferences")
		user << browse(HTML, "window=mob_title;size=320x500")

	proc/SetTitle(mob/user,choice,title)
		switch(choice)
			if(1.0)
				title1 = title
			if(2.0)
				title2 = title
			if(3.0)
				title3 = title
		user << browse(null, "window=mob_title")
		ShowChoices(user)
		return
	proc/SetJob(mob/user, occ=1, job="Captain")
		if ((!( occupations.Find(job) ) && !( assistant_occupations.Find(job) ) && job != "Captain") && job != "No Preference")
			return
		if (job=="AI" && (!config.allow_ai))
			return
		if (jobban_isbanned(user, job))
			return

		switch(occ)
			if(1.0)
				if (job == occupation1)
					user << browse(null, "window=mob_occupation")
					return
				else
					title1 = null
					if (job == "No Preference")
						occupation1 = "No Preference"
						ShowChoices(user)
					else
						if (job == occupation2)
							job = occupation1
							occupation1 = occupation2
							occupation2 = job
						else
							if (job == occupation3)
								job = occupation1
								occupation1 = occupation3
								occupation3 = job
							else
								occupation1 = job
			if(2.0)
				if (job == occupation2)
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				else
					title2 = null
					if (job == "No Preference")
						if (occupation3 != "No Preference")
							occupation2 = occupation3
							occupation3 = "No Preference"
						else
							occupation2 = "No Preference"
					else
						if (job == occupation1)
							if (occupation2 == "No Preference")
								user << browse(null, "window=mob_occupation")
								return
							job = occupation2
							occupation2 = occupation1
							occupation1 = job
						else
							if (job == occupation3)
								job = occupation2
								occupation2 = occupation3
								occupation3 = job
							else
								occupation2 = job
			if(3.0)
				if (job == occupation3)
					user << browse(null, "window=mob_occupation")
					ShowChoices(user)
				else
					title3 = null
					if (job == "No Preference")
						occupation3 = "No Preference"
					else
						if (job == occupation1)
							if (occupation3 == "No Preference")
								user << browse(null, "window=mob_occupation")
								return
							job = occupation3
							occupation3 = occupation1
							occupation1 = job
						else
							if (job == occupation2)
								if (occupation3 == "No Preference")
									user << browse(null, "window=mob_occupation")
									return
								job = occupation3
								occupation3 = occupation2
								occupation2 = job
							else
								occupation3 = job

		user << browse(null, "window=mob_occupation")
		ShowChoices(user)

		return 1

	proc/process_link(mob/user, list/link_tags)

		if (link_tags["occ"])
			if (link_tags["cancel"])
				user << browse(null, "window=mob_occupation")
				ShowChoices(user)
			else if(link_tags["showtitle"])
				ShowTitle(user,text2num(link_tags["occ"]))
			else if(link_tags["job"])
				SetJob(user, text2num(link_tags["occ"]), link_tags["job"])
			else if(link_tags["title"])
				SetTitle(user,text2num(link_tags["occ"]),link_tags["title"])
			else
				SetChoices(user, text2num(link_tags["occ"]))

			return 1

		if (link_tags["real_name"])
			var/new_name

			switch(link_tags["real_name"])
				if("input")
					new_name = input(user, "Please select a name:", "Character Generation")  as text
					var/list/bad_characters = list("_", "'", "\"", "<", ">", ";", "[", "]", "{", "}", "|", "\\")
					for(var/c in bad_characters)
						new_name = dd_replacetext(new_name, c, "")
					if(!new_name || (new_name == "Unknown"))
						alert("Don't do this")
						return

				if("random")
					if (gender == MALE)
						new_name = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
					else
						new_name = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if(new_name)
				if(length(new_name) >= 26)
					new_name = copytext(new_name, 1, 26)
				//arright gonna do some automatic capitalization, but only first and last words because von, van etc
				var/lastspace = 1
				while(findtext(new_name, " ", lastspace + 1))
					lastspace = findtext(new_name, " ", lastspace + 1)//find last space used later
				if(lastspace == 1)
					new_name = addtext(uppertext(copytext(new_name, 1, 2)), copytext(new_name, 2)) //they only have a one word name, might want to put an alert or something in here to tell them that we want surnames
				else
					new_name = addtext(uppertext(copytext(new_name, 1, 2)), copytext(new_name, 2, lastspace + 1), uppertext(copytext(new_name, lastspace + 1, lastspace + 2)), copytext(new_name, lastspace + 2)) //this ended up longer than expected...
				real_name = new_name

		if (link_tags["age"])
			var/new_age = input(user, "Please select type in age: 20-45", "Character Generation")  as num

			if(new_age)
				age = max(min(round(text2num(new_age)), 45), 20)

		if (link_tags["b_type"])
			var/new_b_type = input(user, "Please select a blood type:", "Character Generation")  as null|anything in list( "A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-" )

			if (new_b_type)
				bloodtype = new_b_type

		if (link_tags["hair"])
			var/new_hair = input(user, "Please select hair color.", "Character Generation") as color
			if(new_hair)
				hair_color = new_hair
		if (link_tags["facial"])
			var/new_facial = input(user, "Please select facial hair color.", "Character Generation") as color
			if(new_facial)
				facial_color = new_facial
		if (link_tags["eyes"])
			var/new_eyes = input(user, "Please select eye color.", "Character Generation") as color
			if(new_eyes)
				eyecolor = new_eyes
		if (link_tags["skintone"])
			var/new_tone = input(user, "Please select skin tone level: 1-220 (1=albino, 35=caucasian, 150=black, 220='very' black)", "Character Generation")  as text

			if (new_tone)
				skintone = max(min(round(text2num(new_tone)), 220), 1)
				skintone =  -skintone + 35

		if (link_tags["hairstyle"])
			var/new_style = input(user, "Please select hair style", "Character Generation")  as null|anything in list( "Cut Hair", "Short Hair", "Long Hair", "Mohawk", "Balding", "Wave", "Bedhead", "Dreadlocks", "Ponytail", "Alternate Ponytail", "Medium Long", "Bald" )

			if (new_style)
				hairstyle = new_style

		if (link_tags["facialstyle"])
			var/new_style = input(user, "Please select facial style", "Character Generation")  as null|anything in list("Watson", "Chaplin", "Selleck", "Full Beard", "Long Beard", "Neckbeard", "Van Dyke", "Elvis", "Abe", "Chinstrap", "Hipster", "Goatee", "Hogan", "Shaved")

			if (new_style)
				facialstyle = new_style

		if (link_tags["gender"])
			if (gender == MALE)
				gender = FEMALE
			else
				gender = MALE

		if (link_tags["underwear"])
			if(!IsGuestKey(user.key))
				if (underwear == 1)
					underwear = 0
				else
					underwear = 1

		if (link_tags["b_syndicate"])
			be_syndicate = !( be_syndicate )

		if (link_tags["b_nuke_agent"])
			be_nuke_agent = !( be_nuke_agent )

		if (link_tags["b_takeover_agent"])
			be_takeover_agent = !( be_takeover_agent )

		if (link_tags["b_random_name"])
			be_random_name = !be_random_name
		if(link_tags["editbio"])
			bio = input(usr,"Write your biography.","Biography",bio) as message
		if(!IsGuestKey(user.key))
			if(link_tags["saveslot"])
				var/slot = link_tags["saveslot"]
				savefile_save(user,slot)
			else if(link_tags["loadslot"])
				var/slot = link_tags["loadslot"]
				if(slot == "CLOSE")
					closesave(user)
					return
				if(!savefile_load(user, 0,slot))
					alert(user, "You do not have a savefile.")
				else
					curslot = slot
					loadsave(user)
		if(link_tags["removeslot"])
			var/slot = link_tags["removeslot"]
			if(!slot)
				return
			var/database/query/query = new("DELETE FROM `players`WHERE ckey=? AND slot=?", usr.ckey, slot)
			if(!query.Execute(dbcon))
				usr << query.ErrorMsg()
				usr << "Report this."
			else
				usr << "Slot [slot] Deleted."
				loadsave(usr)
		if(link_tags["loadslot2"])
			loadsave(user)
		if(link_tags["createslot"])
			CreateFile(user)
		if (link_tags["reset_all"])
			gender = MALE
			randomize_name()
			age = 30
			occupation1 = "No Preference"
			occupation2 = "No Preference"
			occupation3 = "No Preference"
			underwear = 1
			be_syndicate = 0
			be_random_name = 0
			hair_color = rgb(0,0,0)
			facial_color = rgb(0,0,0)
			hairstyle = "Short Hair"
			facialstyle = "Shaved"
			eyecolor = rgb(0,0,0)
			skintone = 0.0
			bloodtype = "A+"
			disabilities = 0
		if(link_tags["disabilities"])
			disabilities = input(usr,"Disability number","Disabilities",disabilities) as num


		ShowChoices(user)

	proc/copy_to(mob/living/carbon/human/character)
		if(be_random_name)
			randomize_name()
		character.real_name = real_name
		character.be_syndicate = be_syndicate

		character.gender = gender

		character.age = age
		character.b_type = bloodtype

		// hate myself for this, but cant be arsed to rewrite human updateicon
		character.r_eyes = hex2num(copytext(eyecolor, 2, 4))
		character.g_eyes = hex2num(copytext(eyecolor, 4, 6))
		character.b_eyes = hex2num(copytext(eyecolor, 6, 8))

		character.r_hair = hex2num(copytext(hair_color, 2, 4))
		character.g_hair = hex2num(copytext(hair_color, 4, 6))
		character.b_hair = hex2num(copytext(hair_color, 6, 8))

		character.r_facial = hex2num(copytext(facial_color, 2, 4))
		character.g_facial = hex2num(copytext(facial_color, 4, 6))
		character.b_facial = hex2num(copytext(facial_color, 6, 8))

		character.s_tone = skintone

		character.h_style = hairstyle
		character.f_style = facialstyle

		switch(hairstyle)
			if("Short Hair")
				character.hair_icon_state = "hair_a"
			if("Long Hair")
				character.hair_icon_state = "hair_b"
			if("Cut Hair")
				character.hair_icon_state = "hair_c"
			if("Mohawk")
				character.hair_icon_state = "hair_d"
			if("Balding")
				character.hair_icon_state = "hair_e"
			if("Wave")
				character.hair_icon_state = "hair_f"
			if("Bedhead")
				character.hair_icon_state = "hair_bedhead"
			if("Dreadlocks")
				character.hair_icon_state = "hair_dreads"
			if("Ponytail")
				character.hair_icon_state = "hair_ponytail"
			if("Alternate Ponytail")
				character.hair_icon_state = "hair_pa"
			if("Medium Long")
				character.hair_icon_state = "hair_old"
			else
				character.hair_icon_state = "bald"

		switch(facialstyle)
			if ("Watson")
				character.face_icon_state = "facial_watson"
			if ("Chaplin")
				character.face_icon_state = "facial_chaplin"
			if ("Selleck")
				character.face_icon_state = "facial_selleck"
			if ("Neckbeard")
				character.face_icon_state = "facial_neckbeard"
			if ("Full Beard")
				character.face_icon_state = "facial_fullbeard"
			if ("Long Beard")
				character.face_icon_state = "facial_longbeard"
			if ("Van Dyke")
				character.face_icon_state = "facial_vandyke"
			if ("Elvis")
				character.face_icon_state = "facial_elvis"
			if ("Abe")
				character.face_icon_state = "facial_abe"
			if ("Chinstrap")
				character.face_icon_state = "facial_chin"
			if ("Hipster")
				character.face_icon_state = "facial_hip"
			if ("Goatee")
				character.face_icon_state = "facial_gt"
			if ("Hogan")
				character.face_icon_state = "facial_hogan"
			else
				character.face_icon_state = "bald"

		if (underwear == 1)
			character.underwear = pick(1,2,3,4,5)
		else
			character.underwear = 0

		character.update_face()
		character.update_body()

	proc/copydisabilities(mob/living/carbon/human/character)
		//if(disabilities & 1)
			//blurry eyes
		if(disabilities & 2)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,HEADACHEBLOCK,toggledblock(getblock(character.dna.struc_enzymes,HEADACHEBLOCK,3)),3)
		if(disabilities & 4)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,COUGHBLOCK,toggledblock(getblock(character.dna.struc_enzymes,COUGHBLOCK,3)),3)
		if(disabilities & 8)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,TWITCHBLOCK,toggledblock(getblock(character.dna.struc_enzymes,TWITCHBLOCK,3)),3)
		if(disabilities & 16)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,NERVOUSBLOCK,toggledblock(getblock(character.dna.struc_enzymes,NERVOUSBLOCK,3)),3)
		if(disabilities & 32)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,DEAFBLOCK,toggledblock(getblock(character.dna.struc_enzymes,DEAFBLOCK,3)),3)
		//if(disabilities & 64)
			//mute
		if(disabilities & 128)
			character.dna.struc_enzymes = setblock(character.dna.struc_enzymes,BLINDBLOCK,toggledblock(getblock(character.dna.struc_enzymes,BLINDBLOCK,3)),3)
		character.disabilities = disabilities

