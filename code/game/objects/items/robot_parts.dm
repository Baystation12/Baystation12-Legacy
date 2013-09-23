/obj/item/weapon/optical_unit
	name = "optical sensor unit"
	icon = 'icons/obj/items.dmi'
	icon_state = "optical_unit"
	item_state = "electronic"
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/robot_parts
	name = "robot parts"
	icon = 'icons/obj/robot_parts.dmi'
	item_state = "buildpipe"
	icon_state = "blank"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT

/obj/item/robot_parts/l_arm
	name = "robot left arm"
	icon_state = "l_arm"

/obj/item/robot_parts/r_arm
	name = "robot right arm"
	icon_state = "r_arm"

/obj/item/robot_parts/l_leg
	name = "robot left leg"
	icon_state = "l_leg"

/obj/item/robot_parts/r_leg
	name = "robot right leg"
	icon_state = "r_leg"

/obj/item/robot_parts/chest
	name = "robot chest"
	icon_state = "chest"
	var/wires = 0.0
	var/obj/item/weapon/cell/cell = null

/obj/item/robot_parts/head
	name = "robot head"
	icon_state = "head"
	var/obj/item/weapon/optical_unit/opt1 = null
	var/obj/item/weapon/optical_unit/opt2 = null

/obj/item/robot_parts/robot_suit
	name = "robot suit"
	icon_state = "robo_suit"
	var/obj/item/robot_parts/l_arm/l_arm = null
	var/obj/item/robot_parts/r_arm/r_arm = null
	var/obj/item/robot_parts/l_leg/l_leg = null
	var/obj/item/robot_parts/r_leg/r_leg = null
	var/obj/item/robot_parts/chest/chest = null
	var/obj/item/robot_parts/head/head = null
	var/obj/item/brain/brain = null

/obj/item/robot_parts/robot_suit/New()
	..()
	src.updateicon()

/obj/item/robot_parts/robot_suit/proc/updateicon()
	src.overlays = null
	if(src.l_arm)
		src.overlays += "l_arm+o"
	if(src.r_arm)
		src.overlays += "r_arm+o"
	if(src.chest)
		src.overlays += "chest+o"
	if(src.l_leg)
		src.overlays += "l_leg+o"
	if(src.r_leg)
		src.overlays += "r_leg+o"
	if(src.head)
		src.overlays += "head+o"

/obj/item/robot_parts/robot_suit/proc/check_completion()
	if(src.l_arm && src.r_arm)
		if(src.l_leg && src.r_leg)
			if(src.chest && src.head)
				return 1
	return 0

/obj/item/robot_parts/robot_suit/attackby(obj/item/W as obj, mob/user as mob)

	if(istype(W, /obj/item/robot_parts/l_leg))
		if(src.l_leg)
			return
		user.drop_item()
		W.loc = src
		src.l_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_leg))
		if(src.r_leg)
			return
		user.drop_item()
		W.loc = src
		src.r_leg = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/l_arm))
		if(src.l_arm)
			return
		user.drop_item()
		W.loc = src
		src.l_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/r_arm))
		if(src.r_arm)
			return
		user.drop_item()
		W.loc = src
		src.r_arm = W
		src.updateicon()

	if(istype(W, /obj/item/robot_parts/chest))
		if(src.chest)
			return
		if(W:wires && W:cell)
			user.drop_item()
			W.loc = src
			src.chest = W
			src.updateicon()
		else if(!W:wires)
			user << "\blue You need to attach wires to it first!"
		else
			user << "\blue You need to attach a cell to it first!"

	if(istype(W, /obj/item/robot_parts/head))
		if(src.head)
			return
		if(W:opt2 && W:opt1)
			user.drop_item()
			W.loc = src
			src.head = W
			src.updateicon()
		else
			user << "\blue You need to attach an optical sensor to it first!"

	if(istype(W, /obj/item/brain))
		if(src.check_completion())
			user.drop_item() // Move the brain inside the robo suit
			W.loc = src
			src.brain = W

			src.state("Linking the neural networks.", "blue")

			// Check if player wants to respawn as cyborg
			if (src.brain.owner.client)
				src.brain.owner.client.mob << 'sound/machines/chime.ogg'
				var/answer = alert(src.brain.owner.client.mob,"Do you want to return to life?","Cyborgization","Yes","No")
				if(answer == "No")
					src.state("The inserted brain is not compatible with this suit's circuits.", "blue")
					src.brain = null
					W.loc = get_turf(src) // Drop the brain on the ground
					return
				else
					src.state("Brain insertion complete.", "blue")
					roundinfo.revies++
			else
				for(var/mob/dead/observer/G in world)
					if(G.corpse == src.brain.owner && G.client)
						var/answer = alert(G.client.mob,"Do you want to return to life?","Cyborgization","Yes","No")
						if(answer == "No")
							src.state("The inserted brain is not compatible with this suit's circuits.", "blue")
							src.brain = null
							W.loc = get_turf(src) // Drop the brain on the ground
							return
						else
							src.state("Brain insertion complete.", "blue")
							roundinfo.revies++

			// Create the robo suit
			var/mob/living/silicon/robot/O = new /mob/living/silicon/robot(get_turf(src.loc))
			O.gender = src.brain.owner.gender
			//O.start = 1
			O.invisibility = 0
			O.name = "Cyborg"
			O.real_name = "Cyborg"

			if (src.brain.owner.client)
				O.lastKnownIP = src.brain.owner.client.address
				src.brain.owner.client.mob = O
			else
				for(var/mob/dead/observer/G in world)
					if(G.corpse == src.brain.owner && G.client)
						G.client.mob = O
						del(G)
						break

			src.brain.owner.mind.transfer_to(O)		//Added to fix robot gibbing disconnecting the player. - Strumpetplaya

			O.loc = get_turf(src.loc)
			O << "<B>You are playing a Robot. The Robot can interact with most electronic objects in its view point.</B>"
			O << "<B>You must follow the laws that the AI has. You are the AI's assistant to the station basically.</B>"
			O << "To use something, simply double-click it."
			O << {"Use say ":s to speak to fellow cyborgs and the AI through binary."}

			//SN src = null
			O.job = "Cyborg"

			O.cell = src.chest.cell
			O.cell.loc = O

			del(W)
			del(src)
		else
			user << "\blue The brain must go in after everything else!"

	return

/obj/item/robot_parts/chest/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/cell))
		if(src.cell)
			user << "\blue You have already inserted a cell!"
			return
		else
			user.drop_item()
			W.loc = src
			src.cell = W
			user << "\blue You insert the cell!"
	if(istype(W, /obj/item/weapon/CableCoil))
		var/obj/item/weapon/CableCoil/coil = W
		if(src.wires)
			user << "\blue You have already inserted wire!"
			return
		else
			if (coil.CableType != /obj/cabling/power)
				user << "This is the wrong cable type, you need electrical cable!"
				return
			coil.UseCable(1)
			src.wires = 1.0
			user << "\blue You insert the wire!"
	return

/obj/item/robot_parts/head/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/optical_unit))
		if(src.opt1 && src.opt2)
			user << "\blue You have already inserted the eyes!"
			return
		else if(src.opt1)
			user.drop_item()
			W.loc = src
			src.opt2 = W
			user << "\blue You insert the optical sensor into the eye socket!"
		else
			user.drop_item()
			W.loc = src
			src.opt1 = W
			user << "\blue You insert the optical sensor into the eye socket!"
	return

