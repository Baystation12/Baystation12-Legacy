/mob/proc/unlock_medal(title, announce, desc, diff)

	spawn ()
		if (ismob(src) && src.key)
		//	var/list/keys = list()
			var/database/query/cquery = new("SELECT `medal` FROM `medals` WHERE ckey=?", ckey)
			if(!cquery.Execute(dbcon))
				message_admins(cquery.ErrorMsg())
				#ifdef DEBUG
				debug(cquery.ErrorMsg())
				#endif
			else
				while(cquery.NextRow())
					var/list/column_data = cquery.GetRowData()
					if(title == column_data["medal"])
						return
			var/database/query/query = new("REPLACE INTO `medals` (`ckey`, `medal`, `medaldesc`, `medaldiff`) VALUES (?, ?, ?, ?)", ckey, title, desc, diff)
			if(!query.Execute(dbcon))
				message_admins(query.ErrorMsg())
				#ifdef DEBUG
				debug(query.ErrorMsg())
				#endif
				src << "Medal save failed"
			var/H
			switch(diff)
				if ("medium")
					H = "#EE9A4D"
				if ("easy")
					H = "green"
				if ("hard")
					H = "red"
			if (announce)
				world << "<b>Achievement Unlocked!: [src.key] unlocked the '<font color = [H]>[title]</font color>' achievement.</b></font>"
				src << text("[desc]")
			else if (!announce)
				src << "<b>Achievement Unlocked!: You unlocked the '<font color = [H]>[title]</font color>' achievement.</b></font>"
				src << text("[desc]")

mob/verb/show_medal()
	set name = "Show Achievements"
	set category = "Commands"
	var/database/query/xquery = new("SELECT `ckey` FROM `medals` WHERE ckey=?", ckey)
	var/database/query/gquery = new("SELECT * FROM `medals` WHERE ckey=?", ckey)
	var/list/keys = list()
	if(xquery.Execute(dbcon))
		while(xquery.NextRow())
			keys = xquery.GetRowData()
	else
		src << "You have no medals"
		message_admins(xquery.ErrorMsg())
		#ifdef DEBUG
		debug(xquery.ErrorMsg())
		#endif
	if(gquery.Execute(dbcon))
		while(gquery.NextRow())
			var/list/column_data = gquery.GetRowData()
			for(var/P in keys)
				var/title = column_data["medal"]
				var/desc = column_data["medaldesc"]
				var/diff = column_data["medaldiff"]
				var/H
				switch(diff)
					if ("medium")
						H = "#EE9A4D"
					if ("easy")
						H = "green"
					if ("hard")
						H = "red"
				src << "<font color = [H]>[title]</font color></b></font>"
				src << text("[desc]")