/client/proc/invisibility()
	set category = "Spells"
	set name = "Invisibility"
	if(usr.stat)
		usr << "Not when you're incapicated."
		return
	if(!istype(usr:wear_suit, /obj/item/clothing/suit/wizrobe))
		usr << "I don't feel strong enough without my robe."
		return
	if(!istype(usr:shoes, /obj/item/clothing/shoes/sandal))
		usr << "I don't feel strong enough without my sandals."
		return
	if(!istype(usr:head, /obj/item/clothing/head/wizard))
		usr << "I don't feel strong enough without my hat."
		return

	usr.verbs -= /client/proc/invisibility
	spawn(300)
		usr.verbs += /client/proc/invisibility

	spell_invisibility(usr)



/proc/spell_invisibility(var/mob/H, time = 50)
	if(H.stat) return
	spawn(0)
		var/mobloc = get_turf(H.loc)
		var/obj/dummy/spell_invis/holder = new /obj/dummy/spell_invis( mobloc )
		var/atom/movable/overlay/animation = new /atom/movable/overlay( mobloc )
		animation.name = "water"
		animation.density = 0
		animation.anchored = 1
		animation.icon = 'mob.dmi'
		animation.icon_state = "liquify"
		animation.layer = 5
		animation.master = holder
		flick("liquify",animation)
		H.loc = holder
		H.client.eye = holder
		var/datum/effects/system/steam_spread/steam = new /datum/effects/system/steam_spread()
		steam.set_up(10, 0, mobloc)
		steam.start()
		sleep(time)
		mobloc = get_turf(H.loc)
		animation.loc = mobloc
		steam.location = mobloc
		steam.start()
		H.canmove = 0
		sleep(20)
		flick("reappear",animation)
		sleep(5)
		H.loc = mobloc
		H.canmove = 1
		H.client.eye = H
		del(animation)
		del(holder)

/obj/dummy/spell_invis
	name = "water"
	icon = 'effects.dmi'
	icon_state = "nothing"
	invisibility = 101
	var/canmove = 1
	density = 0
	anchored = 1

/obj/dummy/spell_invis/relaymove(var/mob/user, direction)
	if (!src.canmove) return
	switch(direction)
		if(NORTH)
			src.y++
		if(SOUTH)
			src.y--
		if(EAST)
			src.x++
		if(WEST)
			src.x--
		if(NORTHEAST)
			src.y++
			src.x++
		if(NORTHWEST)
			src.y++
			src.x--
		if(SOUTHEAST)
			src.y--
			src.x++
		if(SOUTHWEST)
			src.y--
			src.x--
	src.canmove = 0
	spawn(2) src.canmove = 1

/obj/dummy/spell_invis/ex_act(blah)
	return
/obj/dummy/spell_invis/bullet_act(blah,blah)
	return