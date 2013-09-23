obj/machinery/aiconstruct
	name = "AI CONSTRUCT"
	var/buildstate = 0
	icon = 'icons/mob/mob.dmi'
	icon_state = "ai_new0"
	var/mob/bb
obj/machinery/aiconstruct/attack_hand(mob/user)
	if(user.stat >= 2)
		return
	switch(buildstate)
		if(0)
			user << "Looks like it's missing some circurity."
		if(1)
			user << "You wiggle the circurity."
		if(2)
			user << "It seems like its missing some cables."
		if(3)
			user << "It's seems to be missing a power source."
		if(4)
			user << "It's missing a glass pane"
		if(5)
			user << "It's missing a brain..."
		if(6)
			if(istype(src.loc.loc,/area/turret_protected/ai))
				user << "You boot up the AI"
				src.boot()
			else
				user << "It needs to be in a specialy built AI room.."
				return

obj/machinery/aiconstruct/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(user.stat >= 2)
		return
	switch(buildstate)
		if(0)
			if(istype(W,/obj/item/weapon/circuitry))
				user << "You place the [W] inside the [src]."
				del(W)
				buildstate++
				icon_state = "ai_new1"
		if(1)
			if(istype(W,/obj/item/weapon/screwdriver))
				user << "You screw the circuitry in place with [W]."
				buildstate++
		if(2)
			if(istype(W,/obj/item/weapon/CableCoil))
				var/obj/item/weapon/CableCoil/Coil = W
				if (Coil.CableType != /obj/cabling/power)
					user << "That's the wrong cable type, you need electrical cable!"
					return
				if(!Coil.UseCable(3))
					user << "Not enough cable."
					return
				user << "You wire up the inside of the [src]."
				buildstate++
				icon_state = "ai_new2"
		if(3)
			if(istype(W,/obj/item/weapon/cell))
				user << "You place the [W] inside the [src]."
				del(W)
				buildstate++
				icon_state = "ai_new3"
		if(4)
			if(istype(W,/obj/item/weapon/sheet/glass))
				if(W:amount < 1)
					user << "Not enough glass."
					return
				user << "You place the [W] inside the [src]."
				W:amount -= 1
				if(W:amount <= 0)
					del(W)
				buildstate++
				icon_state = "ai_new4"
		if(5)
			if(istype(W,/obj/item/brain))
				user << "You place the [W] inside the [src]."
				//user.u_equip(W)
				//user.drop_item()
				//W.dropped()
				//W.loc = src
				bb = W:owner
				del(W)
				buildstate++
				icon_state = "ai_new5"
obj/machinery/aiconstruct/proc/boot()
	if(bb)
		log_admin("Starting AI construct (1/3)")
		for(var/mob/M in world) if(M.client && M.client.key == bb.mind.key)
			bb = M
			break
		if(!bb.client)
			return
		var/mob/ting = bb.client.CarbonCopy(bb) as mob
		sleep(10)
		ting << 'sound/machines/chime.ogg'
		roundinfo.revies++
		log_admin("Starting AI construct (2/3)")
		ting.AIize()
		log_admin("Starting AI construct (3/3)")
		del(src)
mob/living/verb/head()
	set hidden = 1
	usr.unlock_medal("Find Head", 0, "You found head!", "medium")
