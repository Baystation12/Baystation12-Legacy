var/database/dbcon = new("luna4lyfe.db")

var/motdmysql = null
/client/proc/showmotd()
	if(!motdmysql)
		var/database/query/r_query = new("SELECT * FROM `config`")
		if(!r_query.Execute(dbcon))
			diary << "Failed-[r_query.ErrorMsg()]"
		else
			var/lawl
			while(r_query.NextRow())
				var/list/column_data = r_query.GetRowData()
				lawl = column_data["motd"]
			if(!lawl)
				src << "ERROR GETTING MOTD"
				return
			motdmysql += "[lawl]"
			motdmysql += "<BR><center><a href=?src=\ref[src];closemotd=1>Close</a></center>"
			motdmysql += "</body>"

			usr << browse(motdmysql,"window=motd;size=800x600")
	else
		usr << browse(motdmysql,"window=motd;size=800x600")

client/Topic(href, href_list[])
	if(href_list["closemotd"])
		src << browse(null,"window=motd;")
	..()
