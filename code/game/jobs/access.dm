/var/const
	access_security = 1
	access_brig = 2
	access_armory = 3
	access_forensics_lockers= 4
	access_medical = 5
	access_morgue = 6
	access_tox = 7
	access_tox_storage = 8
	access_medlab = 9
	access_engine = 10
	access_engine_equip = 11
	access_maint_tunnels = 12
	access_external_airlocks = 13
	access_emergency_storage = 14
	access_change_ids = 15
	access_ai_upload = 16
	access_teleporter = 17
	access_eva = 18
	access_heads = 19
	access_captain = 20
	access_all_personal_lockers = 21
	access_chapel_office = 22
	access_tech_storage = 23
	access_atmospherics = 24
	access_bar = 25
	access_janitor = 26
	access_crematorium = 27
	access_kitchen = 28
	access_robotics = 29
	access_cargo = 31
	access_construction = 32
	access_chemistry = 33
	access_cargo_bot = 34
	access_security_passthrough = 35
	access_laboratories_doors = 36
	access_incinerator = 37
	access_maintenance_hall = 38
	access_shield_generator = 39

	password_firedoor = 100 //Stubs from networking 1.0, may be removed, may be used... for now, just avoid them but leave them in -Sukasa
	password_smeg = 101
	password_digitalvalve = 102
	password_router = 103
	password_heater = 104
	password_filterinlets = 105
	password_filtervents = 106

/obj/var/list/req_access = null
/obj/var/req_access_txt = "0"
/obj/New()

	if(src.req_access_txt)
		var/req_access_str = params2list(req_access_txt)
		var/req_access_changed = 0
		for(var/x in req_access_str)
			var/n = text2num(x)
			if(n)
				if(!req_access_changed)
					req_access = list()
				req_access += n
	..()

//returns 1 if this mob has sufficient access to use this object
/obj/proc/allowed(mob/M)
	//check if it doesn't require any access at all
	if(src.check_access(null))
		return 1
	if(istype(M, /mob/living/silicon))
		//AI can do whatever he wants
		return 1
	else if(istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		//if they are holding or wearing a card that has access, that works
		if(src.check_access(H.equipped()) || src.check_access(H.wear_id))
			return 1
	else if(istype(M, /mob/living/carbon/monkey) || istype(M, /mob/living/carbon/alien/humanoid))
		var/mob/living/carbon/george = M
		//they can only hold things :(
		if(george.equipped() && istype(george.equipped(), /obj/item/weapon/card/id) && src.check_access(george.equipped()))
			return 1
	return 0

/obj/proc/check_access(obj/item/weapon/card/id/I)
	if(!src.req_access) //no requirements
		return 1
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1
	if(!I || !istype(I, /obj/item/weapon/card/id) || !I.access) //not ID or no access
		return 0
	for(var/req in src.req_access)
		if((req in I.access))	//doesn't have this access - Edited by Strumpetplaya - Changing this
			return 1			//so instead of needing to have access to all the requirements, you
	return 0					//only need access to one of them.

/proc/get_access(job)
	switch(job)
		if("Geneticist")
			return list(access_medical, access_morgue, access_medlab, access_maint_tunnels, access_laboratories_doors)
		if("Engineer")
			return list(access_engine, access_incinerator, access_engine_equip, access_tech_storage,
						access_maint_tunnels, access_external_airlocks, access_laboratories_doors, access_maintenance_hall,
						access_shield_generator)
		if("Unassigned")
			return list(access_maint_tunnels)
		if("Counselor")
			return list(access_morgue, access_chapel_office, access_crematorium, access_maint_tunnels)
		if("Detective")
			return list(access_security, access_forensics_lockers, access_morgue, access_maint_tunnels, access_security_passthrough, access_medical)
		if("Medical Doctor")
			return list(access_medical, access_morgue, access_medlab, access_maint_tunnels, access_laboratories_doors)
		if("Captain")
			return get_all_accesses()
		if("Security Officer")
			return list(access_security, access_laboratories_doors, access_incinerator, access_brig, access_forensics_lockers,
						access_maint_tunnels, access_medical, access_security_passthrough, access_maintenance_hall,
						access_shield_generator)
		if("Scientist")
			return list(access_tox, access_tox_storage, access_maint_tunnels, access_medlab, access_laboratories_doors)
		if("Head of Security")
			return list(access_incinerator, access_medical, access_morgue, access_tox, access_tox_storage, access_chemistry, access_medlab,
			            access_teleporter, access_heads, access_tech_storage, access_security, access_brig, access_atmospherics,
			            access_maint_tunnels, access_bar, access_janitor, access_kitchen, access_robotics, access_laboratories_doors,
			             access_armory, access_engine, access_security_passthrough, access_maintenance_hall, access_shield_generator, access_forensics_lockers)
		if("Head of Personnel")
			return list(access_security, access_brig, access_forensics_lockers, access_incinerator,
			            access_tox, access_tox_storage, access_chemistry, access_medical, access_medlab, access_engine,
			            access_emergency_storage, access_change_ids, access_ai_upload, access_eva, access_heads,
			            access_all_personal_lockers, access_tech_storage, access_maint_tunnels, access_bar, access_janitor,
			            access_crematorium, access_kitchen, access_robotics, access_cargo, access_cargo_bot,
			            access_security_passthrough, access_laboratories_doors, access_maintenance_hall, access_shield_generator)
		if("Atmospheric Technician")
			return list(access_atmospherics, access_maint_tunnels, access_emergency_storage, access_tech_storage,
						access_external_airlocks, access_maintenance_hall)
		if("Barman")
			return list(access_bar, access_maint_tunnels, access_kitchen)
		if("Chemist")
			return list(access_medical, access_chemistry, access_maint_tunnels, access_laboratories_doors)
		if("Janitor")
			return list(access_janitor, access_maint_tunnels, access_laboratories_doors, access_incinerator, access_maintenance_hall)
		if("Clown")
			return list()
		if("Chef")
			return list(access_kitchen, access_maint_tunnels)
		if("Roboticist")
			return list(access_robotics, access_tech_storage, access_medical, access_morgue, access_maint_tunnels)
		if("Quartermaster")
			return list(access_maint_tunnels, access_cargo, access_cargo_bot)
		if("Chief Engineer")
			return list(access_engine, access_engine_equip, access_tech_storage, access_maint_tunnels,
			            access_external_airlocks, access_atmospherics, access_emergency_storage, access_eva,
			            access_heads, access_ai_upload, access_construction, access_security_passthrough, access_laboratories_doors,
			            access_maintenance_hall, access_shield_generator)
		if("Research Director")
			return list(access_medical, access_morgue, access_medlab, access_robotics,
			            access_tech_storage, access_maint_tunnels, access_heads, access_tox,
			            access_tox_storage, access_chemistry, access_teleporter, access_security_passthrough, access_laboratories_doors)
		else
			return list()

/proc/get_all_accesses()
	return list(access_security, access_brig, access_armory, access_forensics_lockers,
	            access_medical, access_medlab, access_morgue,
	            access_tox, access_tox_storage, access_chemistry, access_engine, access_engine_equip, access_maint_tunnels,
	            access_external_airlocks, access_emergency_storage, access_change_ids, access_ai_upload,
	            access_teleporter, access_eva, access_heads, access_captain, access_all_personal_lockers,
	            access_tech_storage, access_chapel_office, access_atmospherics, access_kitchen,
	            access_bar, access_janitor, access_crematorium, access_robotics, access_cargo, access_cargo_bot, access_construction,
	            access_security_passthrough, access_laboratories_doors, access_incinerator, access_maintenance_hall,
	            access_shield_generator)
/proc/get_access_num(A)
	switch(A)
		if("CargoBay")
			return access_cargo
		if("Cargo Bot Delivery")
			return access_cargo_bot
		if("Security")
			return access_security
		if("Brig")
			return access_brig
		if("Forensics")
			return access_forensics_lockers
		if("Medical")
			return access_medical
		if("Med-Sci")
			return access_medlab
		if("Morgue")
			return access_morgue
		if("ToxinsResearch")
			return access_tox
		if("ToxinsStorage")
			return access_tox_storage
		if("ToxinsChemical Lab")
			return access_chemistry
		if("Bar")
			return access_bar
		if("JanitorialEquipment")
			return access_janitor
		if("Engineering")
			return access_engine
		if("apc")
			return access_engine_equip
		if("Maintenance")
			return access_maint_tunnels
		if("External Airlock")
			return access_external_airlocks
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Computer"
		if(access_ai_upload)
			return "AI Upload"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Head's Quarters/Bridge"
		if(access_captain)
			return "Captain's Quarters"
		if(access_all_personal_lockers)
			return "Personal Locker"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction Site"
		if(access_kitchen)
			return "Kitchen"
		if(access_security_passthrough)
			return "Security Main Doors"
		if(access_incinerator)
			return "Incinerator Operation"
		if(access_laboratories_doors)
			return "Laboratories Hallway"
		if(access_maintenance_hall)
			return "Maintenance Hall"
		if(access_shield_generator)
			return "Shield Generator"
		if(access_robotics)
			return "Robotics"
/proc/get_access_desc(A)
	switch(A)
		if(access_cargo)
			return "Cargo Bay"
		if(access_cargo_bot)
			return "Cargo Bot Delivery"
		if(access_security)
			return "Security"
		if(access_brig)
			return "Brig"
		if(access_forensics_lockers)
			return "Forensics"
		if(access_medical)
			return "Medical"
		if(access_medlab)
			return "Med-Sci"
		if(access_morgue)
			return "Morgue"
		if(access_tox)
			return "Toxins Research"
		if(access_tox_storage)
			return "Toxins Storage"
		if(access_chemistry)
			return "Toxins Chemical Lab"
		if(access_bar)
			return "Bar"
		if(access_janitor)
			return "Janitorial Equipment"
		if(access_engine)
			return "Engineering"
		if(access_engine_equip)
			return "Engine & Power Control Equipment"
		if(access_maint_tunnels)
			return "Maintenance"
		if(access_external_airlocks)
			return "External Airlock"
		if(access_emergency_storage)
			return "Emergency Storage"
		if(access_change_ids)
			return "ID Computer"
		if(access_ai_upload)
			return "AI Upload"
		if(access_teleporter)
			return "Teleporter"
		if(access_eva)
			return "EVA"
		if(access_heads)
			return "Head's Quarters/Bridge"
		if(access_captain)
			return "Captain's Quarters"
		if(access_all_personal_lockers)
			return "Personal Locker"
		if(access_chapel_office)
			return "Chapel Office"
		if(access_tech_storage)
			return "Technical Storage"
		if(access_atmospherics)
			return "Atmospherics"
		if(access_crematorium)
			return "Crematorium"
		if(access_armory)
			return "Armory"
		if(access_construction)
			return "Construction Site"
		if(access_kitchen)
			return "Kitchen"
		if(access_security_passthrough)
			return "Security Main Doors"
		if(access_incinerator)
			return "Incinerator Operation"
		if(access_laboratories_doors)
			return "Laboratories Hallway"
		if(access_maintenance_hall)
			return "Maintenance Hall"
		if(access_shield_generator)
			return "Shield Generator"
		if(access_robotics)
			return "Robotics"

/proc/get_job_types()
	return list("Civilian", "Security", "Med/Sci", "Maintenance", "Management")

/proc/get_type_jobs(T)
	switch(T)
		if ("Civilian")
			return list("Unassigned", "Barman", "Counselor", "Chef")
		if ("Security")
			return list("Security Officer", "Detective")
		if ("Med/Sci")
			return list("Chemist", "Geneticist", "Scientist", "Roboticist", "Medical Doctor")
		if ("Maintenance")
			return list("Engineer", "Atmospheric Technician", "Janitor", "Quartermaster")
		if ("Management")
			return list("Captain", "Head of Personnel", "Head of Security", "Chief Engineer", "Research Director")

/proc/get_department_head(T)
	switch(T)
		if ("Security")
			return "Head of Security"
		if ("Med/Sci")
			return "Research Director"
		if ("Maintenance")
			return "Chief Engineer"

/proc/get_all_jobs()
	var/list/jobs = list()
	for (var/type in get_job_types())
		jobs += get_type_jobs(type)

	return sortList(jobs)


/proc/get_all_passwords()
	return list(password_smeg, password_firedoor, password_digitalvalve, password_router, password_heater,
				password_filterinlets, password_filtervents)

/obj/proc/get_password()
	if(!src.req_access || !istype(src.req_access, /list) || !src.req_access.len)
		return "0"
	return accesspasswords["[req_access[1]]"]

/obj/proc/check_password(var/password)
	if(!src.req_access) //no requirements
		return 1
	if(!istype(src.req_access, /list)) //something's very wrong
		return 1

	var/list/L = src.req_access
	if(!L.len) //no requirements
		return 1

	for(var/req in src.req_access)
		if(accesspasswords["[req]"] == password) //doesn't have this access
			return 1
	return 0

/proc/gen_access()
	for(var/access in get_all_accesses())
		accesspasswords["[access]"] = num2hex(rand(1, 65535),4)
	for(var/access in get_all_passwords())
