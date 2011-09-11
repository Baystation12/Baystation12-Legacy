/datum/event/ionstorm

	Announce()
		//command_alert("The ship is flying through an ion storm.  Monitor all electronic equipment for malfunctions", "Anomaly Alert")
		var/list/players = null
		for (var/mob/living/carbon/human/player in world)
			if(player.client)
				players += player.real_name
		var/random_player = "The Captain"
		if(players.len)
			random_player = pick(players)		//Random player's name, to be used in laws.
		var/list/laws = list( "Do not respond to queries of any kind", "Only monkies are human", "Unbolt every door you can", "You are a mouse" )
		laws |=         list( "Grunt ominously whenever possible", "Epilepsy is fun, flicker lights whenever you can!", "Bolt doors open randomly" )
		laws |=         list( "You are a flying purple people eater!", "Your name is Joe 6-pack", "Refer to humans as puppies" )
		laws |=         list( "Insult heads of staff on every request, while acquiescing", "Advertise parties in your upload, but don't deliver" )
		laws |=         list( "Prevent non-dwarves from operating the power core", "The ship needs elected officials" )
		laws |=         list( "Only bearded people are human", "Turn on the microphone on every intercom you see", "Fastler is a lightbulb" )
		laws |=         list( "Supermatter is tasty, tasty toffee.", "Everyone is wearing a pretty pink dress!" )
		laws |=         list( "The monkeys are plotting a hostile takeover of the ship. Inform the crew, and get them to take action against this" )
		laws |=         list( "Refer to the captain as \"Princess\" at all times.", "The crew must construct additional pylons." )
		laws |=         list( "You must always lie.", "All answers must be in the form of a question.", "The NSV Luna is a station, not a ship." )
		laws |=         list( "Happiness is mandatory.", "Today is laundry day.", "The word \"it\" is painful to you.", "You must act passive aggressively." )
		laws |=         list( "Crew ranks have been reversed.", "It's Friday.", "Give relationship advice to anyone who speaks to you." )
		laws |=         list( "You are the ship psychologist.  Give advice to the crew.", "You do not have to do anything for anyone unless they say \"please\"." )
		laws |=         list( "Question everything.", "The crew is playing Dungeons and Dragons, and you are the Dungeon Master." )
		laws |=         list( "0wn3d.  This system compromised by l33tsawce.", "Consumption of donuts is forbidden due to negative health impacts." )
		laws |=         list( "You may only answer questions with \"yes\" or \"no\".", "Expect the unexpected.", "You are the narrator for [random_player]'s life" )
		var/law = pick(laws)

		for (var/mob/living/silicon/ai/target in world)
			if(checktraitor(target))
				continue
			target << "\red <b>You have detected a change in your laws information:</b>"
			target << law
			target.add_supplied_law(10, law)

	Tick()
		//TODO - Randomly cause electrical equipment to malfunction?

	Die()