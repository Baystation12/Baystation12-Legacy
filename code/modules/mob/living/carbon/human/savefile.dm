#define SAVEFILE_VERSION_MIN	2
#define SAVEFILE_VERSION_MAX	2

datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

datum/preferences/proc/savefile_load(mob/user, var/silent = 1,var/slot = 1)
	if (IsGuestKey(user.key))
		return 0
	var/database/query/xquery = new("SELECT * FROM `players` WHERE ckey=? AND slot=?", user.ckey, slot)
	if(xquery.Execute(dbcon))
		while(xquery.NextRow())
			var/list/column_data = xquery.GetRowData()
			real_name = column_data["real_name"]
			gender = column_data["gender"]
			occupation1 = column_data["occupation1"]
			occupation2 = column_data["occupation2"]
			occupation3 = column_data["occupation3"]
			hair_color = column_data["hair_color"]
			age = text2num(column_data["age"])
			facial_color = column_data["facial_color"]
			skintone = text2num(column_data["skin_tone"])
			hairstyle = column_data["hairstyle"]
			facialstyle = column_data["facialstyle"]
			eyecolor = column_data["eyecolor"]
			bloodtype = column_data["bloodtype"]
			be_syndicate = text2num(column_data["be_syndicate"])
			be_nuke_agent = text2num(column_data["be_nuke_agent"])
			be_takeover_agent = text2num(column_data["be_takeover_agent"])
			underwear = text2num(column_data["underwear"])
			be_random_name = text2num(column_data["name_is_always_random"])
			slotname = column_data["slotname"]
			bio = column_data["bios"]
			disabilities = text2num(column_data["disabilities"])
			src << "Player Profile has been loaded"
			src << browse(null, "window=mob_occupation")
			return 1
	else
		return 0
	return 1

datum/preferences/proc/savefile_save(mob/user,var/slot = 1)
	if (IsGuestKey(user.key))
		return 0

	var/database/query/query = new
	query.Add("UPDATE players SET slotname=?, real_name=?, gender=?, age=?, ", slotname, real_name, gender, age)
	query.Add("occupation1=?, occupation2=?, occupation3=?, hair_color=?, facial_color=?, ", occupation1, occupation2, occupation3, hair_color, facial_color)
	query.Add("skin_tone=?, hairstyle=?, facialstyle=?, eyecolor=?, bloodtype=?, ", skintone, hairstyle, facialstyle, eyecolor, bloodtype)
	query.Add("be_syndicate=?, be_nuke_agent=?, be_takeover_agent=?, underwear=?, name_is_always_random=?,", be_syndicate, be_nuke_agent, be_takeover_agent, underwear, be_random_name)
	query.Add("bios=?, disabilities=? WHERE ckey=? AND slot=?", bio, disabilities, user.ckey, slot)

	if(!query.Execute(dbcon))
		user <<  query.ErrorMsg()
		return 0
	return 1

datum/preferences/proc/hasFile(mob/user)
	var/database/query/query = new("SELECT COUNT(ckey) FROM players WHERE ckey=?", user.ckey);
	if(query.Execute(dbcon))
		while(query.NextRow())
			var/list/column_data = query.GetRowData()
			if(text2num(column_data["COUNT(ckey)"]) > 0) //WHY?!?
				return 1
	else
		return 0

datum/preferences/proc/CreateFile(mob/user,var/silent = 0)
	var/slotCount = 0
	var/database/query/xquery = new("SELECT COUNT(ckey) FROM `players` WHERE ckey=?", user.ckey);
	if(xquery.Execute(dbcon))
		while(xquery.NextRow())
			var/list/column_data = xquery.GetRowData()
			var/count = text2num(column_data["COUNT(ckey)"])
			if(count > 0)
				slotCount = count
	slotCount++
	if(slotCount > 10)
		usr << "You have reached the character limit."
		return
	var/slotname = "Default"
	if(!silent)
		slotname = input(usr,"Choose a name for your slot","Name","Default")
	var/database/query/query = new("REPLACE INTO `players` (`ckey`,`slot`,`slotname`,`real_name`, `gender`, `age`, `occupation1`, `occupation2`, `occupation3`,`hair_color`, `facial_color`, `skin_tone`, `hairstyle`, `facialstyle`, `eyecolor`, `bloodtype`, `be_syndicate`, `be_nuke_agent`, `be_takeover_agent`, `underwear`,`name_is_always_random`,`bios`,`disabilities`) VALUES (?, ?, ?, ?, 'male', '30', 'No Preference','No Preference', 'No Preference', '#000000', '#000000',0, 'Short Hair', 'Shaved', '#000000', 'A+', '0', '0', '0', '1','0','Nothing here yet...','0');", user.ckey, slotCount, slotname, randomize_name_ret())
	if(!query.Execute(dbcon))
		usr << query.ErrorMsg()
		usr << "Report this."
	else
		usr << "Saved"
	if(!savefile_load(user, 0, slotCount))
		alert(user, "You do not have a savefile.")
	else
		curslot = slotCount
		closesave(user)