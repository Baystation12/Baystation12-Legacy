/datum/recipe
	var/egg_amount = 0
	var/flour_amount = 0
	var/water_amount = 0
	var/monkeymeat_amount = 0
	var/humanmeat_amount = 0
	var/donkpocket_amount = 0
	var/obj/extra_item = null // This is if an extra item is needed, eg a butte for an assburger
	var/creates = "" // The item that is spawned when the recipe is made

/datum/recipe/donut
	egg_amount = 1
	flour_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/donut"

/datum/recipe/monkeyburger
	egg_amount = 0
	flour_amount = 1
	monkeymeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/monkeyburger"

/datum/recipe/humanburger
	flour_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/humanburger"

/datum/recipe/brainburger
	flour_amount = 1
	extra_item = /obj/item/brain
	creates = "/obj/item/weapon/reagent_containers/food/snacks/brainburger"

/datum/recipe/roburger/
	flour_amount = 1
	extra_item = /obj/item/robot_parts/head
	creates = "/obj/item/weapon/reagent_containers/food/snacks/roburger"

/datum/recipe/waffles
	egg_amount = 2
	flour_amount = 2
	creates = "/obj/item/weapon/reagent_containers/food/snacks/waffles"

/datum/recipe/faggot
	monkeymeat_amount = 1
	humanmeat_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/faggot"

/datum/recipe/pie
	flour_amount = 2
	extra_item = /obj/item/weapon/banana
	creates = "/obj/item/weapon/reagent_containers/food/snacks/pie"

/datum/recipe/donkpocket
	flour_amount = 1
	extra_item = /obj/item/weapon/reagent_containers/food/snacks/faggot
	creates = "/obj/item/weapon/reagent_containers/food/snacks/donkpocket"

/datum/recipe/donkpocket_warm
	donkpocket_amount = 1
	creates = "/obj/item/weapon/reagent_containers/food/snacks/donkpocket"


/obj/machinery/microwave/New() // *** After making the recipe in defines\obj\food.dmi, add it in here! ***
	..()
	src.available_recipes += new /datum/recipe/donut(src)
//	src.available_recipes += new /datum/recipe/monkeyburger(src)
//	src.available_recipes += new /datum/recipe/humanburger(src)
	src.available_recipes += new /datum/recipe/waffles(src)
//	src.available_recipes += new /datum/recipe/brainburger(src)
//	src.available_recipes += new /datum/recipe/faggot(src)
//	src.available_recipes += new /datum/recipe/roburger(src)
//	src.available_recipes += new /datum/recipe/donkpocket(src)
//	src.available_recipes += new /datum/recipe/donkpocket_warm(src)
	src.available_recipes += new /datum/recipe/pie(src)


/*******************
*   Item Adding
********************/

obj/machinery/microwave/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if(src.broken > 0)
		if(src.broken == 2 && istype(O, /obj/item/weapon/screwdriver)) // If it's broken and they're using a screwdriver
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes part of the microwave."))
			src.broken = 1 // Fix it a bit
		else if(src.broken == 1 && istype(O, /obj/item/weapon/wrench)) // If it's broken and they're doing the wrench
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to fix part of the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] fixes the microwave!"))
			src.icon_state = "mw"
			src.broken = 0 // Fix it!
		else
			user << "It's broken!"
	else if(src.dirty) // The microwave is all dirty so can't be used!
		if(istype(O, /obj/item/weapon/cleaner)) // If they're trying to clean it then let them
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] starts to clean the microwave."))
			sleep(20)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] has cleaned the microwave!"))
			src.dirty = 0 // It's cleaned!
			src.icon_state = "mw"
		else //Otherwise bad luck!!
			return
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/egg)) // If an egg is used, add it
		if(src.egg_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds an egg to the microwave."))
			src.egg_amount++
			del(O)
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/flour)) // If flour is used, add it
		if(src.flour_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some flour to the microwave."))
			src.flour_amount++
			del(O)
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/monkeymeat))
		if(src.monkeymeat_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some meat to the microwave."))
			src.monkeymeat_amount++
			del(O)
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/humanmeat))
		if(src.humanmeat_amount < 5)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds some meat to the microwave."))
			src.humanmeat_name = O:subjectname
			src.humanmeat_job = O:subjectjob
			src.humanmeat_amount++
			del(O)
	else if(istype(O, /obj/item/weapon/reagent_containers/food/snacks/donkpocket))
		if(src.donkpocket_amount < 2)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds a donk-pocket to the microwave."))
			src.donkpocket_amount++
			del(O)
	else
		if(!istype(extra_item, /obj/item)) //Allow one non food item to be added!
			user.u_equip(O)
			extra_item = O
			O.loc = src
			if((user.client  && user.s_active != src))
				user.client.screen -= O
			O.dropped(user)
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] adds [O] to the microwave."))
		else
			user << "There already seems to be an unusual item inside, so you don't add this one too." //Let them know it failed for a reason though

obj/machinery/microwave/attack_paw(user as mob)
	return src.attack_hand(user)


/*******************
*   Microwave Menu
********************/

/obj/machinery/microwave/attack_hand(user as mob) // The microwave Menu
	var/dat
	if(src.broken > 0)
		dat = {"
<TT>Bzzzzttttt</TT>
		"}
	else if(src.operating)
		dat = {"
<TT>Microwaving in progress!<BR>
Please wait...!</TT><BR>
<BR>
"}
	else if(src.dirty)
		dat = {"
<TT>This microwave is dirty!<BR>
Please clean it before use!</TT><BR>
<BR>
"}
	else
		dat = {"
<B>Eggs:</B>[src.egg_amount] eggs<BR>
<B>Flour:</B>[src.flour_amount] cups of flour<BR>
<B>Monkey Meat:</B>[src.monkeymeat_amount] slabs of meat<BR>
<B>Meat Turnovers:</B>[src.donkpocket_amount] turnovers<BR>
<B>Other Meat:</B>[src.humanmeat_amount] slabs of meat<BR><HR>
<BR>
<A href='?src=\ref[src];cook=1'>Turn on!<BR>
<A href='?src=\ref[src];cook=2'>Dispose contents!<BR>
"}

	user << browse("<HEAD><TITLE>Microwave Controls</TITLE></HEAD><TT>[dat]</TT>", "window=microwave")
	onclose(user, "microwave")
	return



/***********************************
*   Microwave Menu Handling/Cooking
************************************/

/obj/machinery/microwave/Topic(href, href_list)
	if(..())
		return

	usr.machine = src
	src.add_fingerprint(usr)

	if(href_list["cook"])
		if(!src.operating)
			var/operation = text2num(href_list["cook"])

			var/cook_time = 200 // The time to wait before spawning the item
			var/cooked_item = ""

			if(operation == 1) // If cook was pressed
				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue The microwave turns on."))
				for(var/datum/recipe/R in src.available_recipes) //Look through the recipe list we made above
					if(src.egg_amount == R.egg_amount && src.flour_amount == R.flour_amount && src.monkeymeat_amount == R.monkeymeat_amount && src.humanmeat_amount == R.humanmeat_amount && src.donkpocket_amount == R.donkpocket_amount) // Check if it's an accepted recipe
						if(R.extra_item == null || src.extra_item.type == R.extra_item) // Just in case the recipe doesn't have an extra item in it
							src.egg_amount = 0 // If so remove all the eggs
							src.flour_amount = 0 // And the flour
							src.water_amount = 0 //And the water
							src.monkeymeat_amount = 0
							src.humanmeat_amount = 0
							src.donkpocket_amount = 0
							src.extra_item = null // And the extra item
							cooked_item = R.creates // Store the item that will be created

				if(cooked_item == "") //Oops that wasn't a recipe dummy!!!
					if(src.egg_amount > 0 || src.flour_amount > 0 || src.water_amount > 0 || src.monkeymeat_amount > 0 || src.humanmeat_amount > 0 || src.donkpocket_amount > 0 && src.extra_item == null) //Make sure there's something inside though to dirty it
						src.operating = 1 // Turn it on
						src.icon_state = "mw1"
						src.updateUsrDialog()
						src.egg_amount = 0 //Clear all the values as this crap is what makes the mess inside!!
						src.flour_amount = 0
						src.water_amount = 0
						src.humanmeat_amount = 0
						src.monkeymeat_amount = 0
						src.donkpocket_amount = 0
						sleep(40) // Half way through
						playsound(src.loc, 'splat.ogg', 50, 1) // Play a splat sound
						icon_state = "mwbloody1" // Make it look dirty!!
						sleep(40) // Then at the end let it finish normally
						playsound(src.loc, 'ding.ogg', 50, 1)
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The microwave gets covered in muck!"))
						src.dirty = 1 // Make it dirty so it can't be used util cleaned
						src.icon_state = "mwbloody" // Make it look dirty too
						src.operating = 0 // Turn it off again aferwards
						// Don't clear the extra item though so important stuff can't be deleted this way and
						// it prolly wouldn't make a mess anyway

					else if(src.extra_item != null) // However if there's a weird item inside we want to break it, not dirty it
						src.operating = 1 // Turn it on
						src.icon_state = "mw1"
						src.updateUsrDialog()
						src.egg_amount = 0 //Clear all the values as this crap is gone when it breaks!!
						src.flour_amount = 0
						src.water_amount = 0
						src.humanmeat_amount = 0
						src.monkeymeat_amount = 0
						src.donkpocket_amount = 0
						sleep(60) // Wait a while
						var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
						s.set_up(2, 1, src)
						s.start()
						icon_state = "mwb" // Make it look all busted up and shit
						for(var/mob/V in viewers(src, null))
							V.show_message(text("\red The microwave breaks!")) //Let them know they're stupid
						src.broken = 2 // Make it broken so it can't be used util fixed
						src.operating = 0 // Turn it off again aferwards
						src.extra_item.loc = get_turf(src) // Eject the extra item so important shit like the disk can't be destroyed in there
						src.extra_item = null

					else //Otherwise it was empty, so just turn it on then off again with nothing happening
						src.operating = 1
						src.icon_state = "mw1"
						src.updateUsrDialog()
						sleep(80)
						src.icon_state = "mw"
						playsound(src.loc, 'ding.ogg', 50, 1)
						src.operating = 0

			if(operation == 2) // If dispose was pressed, empty the microwave
				src.egg_amount = 0
				src.flour_amount = 0
				src.water_amount = 0
				src.humanmeat_amount = 0
				src.monkeymeat_amount = 0
				src.donkpocket_amount = 0
				if(src.extra_item != null)
					src.extra_item.loc = get_turf(src) // Eject the extra item so important shit like the disk can't be destroyed in there
					src.extra_item = null
				usr << "You dispose of the microwave contents."

			var/cooking = text2path(cooked_item) // Get the item that needs to be spanwed
			if(!isnull(cooking))
				for(var/mob/V in viewers(src, null))
					V.show_message(text("\blue The microwave begins cooking something!"))
				src.operating = 1 // Turn it on so it can't be used again while it's cooking
				src.icon_state = "mw1" //Make it look on too
				src.updateUsrDialog()
				src.being_cooked = new cooking(src)

				spawn(cook_time) //After the cooking time
					if(!isnull(src.being_cooked))
						playsound(src.loc, 'ding.ogg', 50, 1)
						if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/humanburger))
							src.being_cooked.name = humanmeat_name + src.being_cooked.name
							src.being_cooked:job = humanmeat_job
						if(istype(src.being_cooked, /obj/item/weapon/reagent_containers/food/snacks/donkpocket))
							src.being_cooked:warm = 1
							src.being_cooked.name = "warm " + src.being_cooked.name
							src.being_cooked:cooltime()
						src.being_cooked.loc = get_turf(src) // Create the new item
						src.being_cooked = null // We're done!

					src.operating = 0 // Turn the microwave back off
					src.icon_state = "mw"
			else
				return