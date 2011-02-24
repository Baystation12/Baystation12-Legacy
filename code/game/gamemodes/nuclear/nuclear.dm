/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	enabled = 1

	var/list/datum/mind/syndicates = list()
	var/finished = 0
	var/nuke_detonated = 0 //Has the nuke gone off?
	var/const/agents_possible = 5 //If we ever need more syndicate agents.

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_items = {"/obj/item/weapon/storage/syndie_kit/imp_freedom (3);/obj/item/weapon/storage/syndie_kit/imp_compress (5);
/obj/item/weapon/storage/syndie_kit/imp_alien (10);/obj/item/weapon/storage/syndie_kit/imp_vfac (5);
/obj/item/weapon/storage/syndie_kit/imp_explosive (6);/obj/item/device/hacktool (4);
/obj/item/clothing/under/chameleon (3);/obj/item/weapon/gun/revolver (7);
/obj/item/weapon/ammo/a357 (3);/obj/item/weapon/card/emag (3);
/obj/item/weapon/card/id/syndicate (3);/obj/item/weapon/cloaking_device (5);
/obj/item/weapon/storage/emp_kit (4);/obj/item/device/powersink (5);
/obj/item/weapon/cartridge/syndicate (3);/obj/item/device/chameleon (4);
/obj/item/weapon/sword (5);/obj/item/weapon/pen/sleepypen (4);
/obj/item/weapon/gun/energy/crossbow (5);/obj/spawner/newbomb/timer/syndicate (4);
/obj/item/clothing/mask/gas/voice (3);/obj/item/weapon/aiModule/freeform (3)"}

	uplink_uses = 10

/datum/game_mode/nuclear/announce()
	world << "<B>The current game mode is - Nuclear Emergency!</B>"
//	world << "<B>A [syndicate_name()] Strike Force is approaching [station_name()]!</B>"
//	world << "A nuclear explosive was being transported by NanoTrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by NanoTrasen as a nuclear auth. disk and now Syndicate Operatives have arrived to retake the disk and detonate NSV Luna! Also, most likely Syndicate star ships are in the vicinity so take care not to lose the disk!\n<B>Syndicate</B>: Reclaim the disk and detonate the nuclear bomb anywhere on Luna.\n<B>Personnel</B>: Hold the disk and <B>escape with the disk</B> on the shuttle!"


/datum/game_mode/nuclear/pre_setup()
	var/list/possible_syndicates = list()
	possible_syndicates = get_possible_syndicates()
	var/agent_number = 0

	if(possible_syndicates.len < 1)
		return 0

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(possible_syndicates)
		syndicates += new_syndicate
		possible_syndicates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.

	return 1


/datum/game_mode/nuclear/post_setup()
	var/obj/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
	var/obj/landmark/nuke_spawn = locate("landmark*Nuclear-Bomb")
	var/obj/landmark/closet_spawn = locate("landmark*Nuclear-Closet")

	var/nuke_code = "[rand(10000, 99999.0)]"
	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	var/leader_selected = 0
	var/agent_number = 1

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.current.loc = get_turf(synd_spawn)

		var/datum/objective/nuclear/syndobj = new
		syndobj.owner = synd_mind
		synd_mind.objectives += syndobj

		var/obj_count = 1
		synd_mind.current << "\blue You are a [syndicate_name()] agent!"
		for(var/datum/objective/objective in synd_mind.objectives)
			synd_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++

		if(!leader_selected)
			synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
			synd_mind.store_memory("<B>Syndicate Nuclear Bomb Code</B>: [nuke_code]", 0, 0)
			synd_mind.current << "The nuclear authorization code is: <B>[nuke_code]</B>\]"
			synd_mind.current << "Nuclear Explosives 101:\n\tHello and thank you for choosing the Syndicate for your nuclear information needs.\nToday's crash course will deal with the operation of a Fusion Class NanoTrasen made Nuclear Device.\nFirst and foremost, DO NOT TOUCH ANYTHING UNTIL THE BOMB IS IN PLACE.\nPressing any button on the compacted bomb will cause it to extend and bolt itself into place.\nIf this is done to unbolt it one must compeltely log in which at this time may not be possible.\nTo make the device functional:\n1. Place bomb in designated detonation zone\n2. Extend and anchor bomb (attack with hand).\n3. Insert Nuclear Auth. Disk into slot.\n4. Type numeric code into keypad ([nuke_code]).\n\tNote: If you make a mistake press R to reset the device.\n5. Press the E button to log onto the device\nYou now have activated the device. To deactivate the buttons at anytime for example when\nyou've already prepped the bomb for detonation remove the auth disk OR press the R ont he keypad.\nNow the bomb CAN ONLY be detonated using the timer. A manual det. is not an option.\n\tNote: NanoTrasen is a pain in the neck.\nToggle off the SAFETY.\n\tNote: You wouldn't believe how many Syndicate Operatives with doctorates have forgotten this step\nSo use the - - and + + to set a det time between 5 seconds and 10 minutes.\nThen press the timer toggle button to start the countdown.\nNow remove the auth. disk so that the buttons deactivate.\n\tNote: THE BOMB IS STILL SET AND WILL DETONATE\nNow before you remove the disk if you need to move the bomb you can:\nToggle off the anchor, move it, and re-anchor.\n\nGood luck. Remember the order:\nDisk, Code, Safety, Timer, Disk, RUN\nGood luck.\nIntelligence Analysts believe that they are hiding the disk in the bridge."
			var/obj/item/weapon/paper/P = new /obj/item/weapon/paper(synd_mind.current.loc)
			P.info = "The nuclear authorization code is: <b>[nuke_code]</b>"
			P.name = "nuclear bomb code"
			leader_selected = 1
		else
			synd_mind.current.real_name = "[syndicate_name()] Operative #[agent_number]"
			agent_number++

		equip_syndicate(synd_mind.current)

	if(nuke_spawn)
		var/obj/machinery/nuclearbomb/the_bomb = new /obj/machinery/nuclearbomb(nuke_spawn.loc)
		the_bomb.r_code = nuke_code

	if(closet_spawn)
		new /obj/closet/syndicate/nuclear(closet_spawn.loc)

	for (var/obj/landmark/A in world)
		if (A.name == "Syndicate-Gear-Closet")
			new /obj/closet/syndicate/personal(A.loc)
			del(A)
			continue

		if (A.name == "Syndicate-Bomb")
			var/O = new /obj/spawner/newbomb/timer/syndicate(A.loc)
			del(A)
			del O // Spawners need to have del called on them to avoid leaving a marker behind
			continue

	spawn (rand(waittime_l, waittime_h)*tick_multiplier)
		send_intercept()

	return
obj/landmark/synd_spawn
	name = "Syndicate-Spawn"
obj/landmark/nuke_spawn
	name = "Nuclear-Bomb"
obj/landmark/closet_spawn
	name = "Nuclear-Closet"
/obj/landmark/gearcloset
	name = "Syndicate-Gear-Closet"
obj/landmark/synbomb
	name = "Syndicate-Bomb"
/datum/game_mode/nuclear/proc/equip_syndicate(mob/living/carbon/human/synd_mob)
	var/radio_freq = random_radio_frequency()

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_if_possible(R, synd_mob.slot_ears)

	synd_mob.equip_if_possible(new /obj/item/clothing/under/syndicate(synd_mob), synd_mob.slot_w_uniform)
	synd_mob.equip_if_possible(new /obj/item/clothing/shoes/black(synd_mob), synd_mob.slot_shoes)
	synd_mob.equip_if_possible(new /obj/item/clothing/suit/armor/vest(synd_mob), synd_mob.slot_wear_suit)
	synd_mob.equip_if_possible(new /obj/item/clothing/gloves/swat(synd_mob), synd_mob.slot_gloves)
	synd_mob.equip_if_possible(new /obj/item/clothing/head/helmet/swat(synd_mob), synd_mob.slot_head)

	synd_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(synd_mob), synd_mob.slot_back)
	synd_mob.equip_if_possible(new /obj/item/weapon/ammo/a357(synd_mob), synd_mob.slot_in_backpack)
	synd_mob.equip_if_possible(new /obj/item/weapon/reagent_containers/pill/tox(synd_mob), synd_mob.slot_in_backpack)
	var/obj/item/weapon/gun/revolver/G = new /obj/item/weapon/gun/revolver(synd_mob)
	G.bullets = 7
	synd_mob.equip_if_possible(G, synd_mob.slot_belt)

/datum/game_mode/nuclear/check_win()
	if (src.nuke_detonated)
		finished = 1
		return

	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(istype(disk_area, /area/shuttle/escape/centcom))
			finished = 2
			break

	return

/datum/game_mode/nuclear/check_finished()
	if((src.finished) || (main_shuttle.location==2))
		return 1
	else
		return 0

/datum/game_mode/nuclear/declare_completion()
	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(istype(disk_area, /area/shuttle/escape/centcom))
			finished = 2
			break

	switch(finished)
		if(0)
			world << "<FONT size = 3><B>Neutral Victory</B></FONT>"
			world << "<B>[syndicate_name()] operatives recovered the abandoned authentication disk but detonation of [station_name()] was averted.</B> Next time, don't lose the disk!"

		if(1)
			world << "<B>[syndicate_name()] operatives have destroyed [station_name()]!</B>"
			for(var/datum/mind/M in syndicates)
				if(!M.current)
					continue
				if(M.current.client)
					world << text("<B>[M.current.key] was [M.current.real_name]</B> [M.current.stat == 2 ? "(DEAD)" : ""]")

		if(2)
			world << "<FONT size = 3><B>The Research Staff has stopped the [syndicate_name()] Operatives!</B></FONT>"
			for(var/datum/mind/M in ticker.minds)
				if (!M.current)
					continue
				if ((M.current.client) && !(locate(M) in syndicates))
					world << text("<B>[M.current.key] was [M.current.real_name]</B> [M.current.stat == 2 ? "(DEAD)" : ""]")
	check_round()
	return 1

/datum/game_mode/nuclear/proc/get_possible_syndicates()
	var/list/candidates = list()

	for(var/mob/new_player/player in world)
		if((player.client) &&  (player.ready))
			if(player.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if((player.client) && (player.ready))
				candidates += player.mind

	if(candidates.len < 1)
		return null
	else
		return candidates

/datum/game_mode/nuclear/proc/random_radio_frequency()
	var/f = 0

	do
		f = rand(1441, 1489)
		f = sanitize_frequency(f)
	while (f == 0 || f == 1459)

	return f