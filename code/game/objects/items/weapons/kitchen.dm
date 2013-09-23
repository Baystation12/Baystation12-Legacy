/*
CONTAINS:
FORK
ROLLING PIN
KNIFE
SPOON
*/

/obj/item/weapon/kitchen
	icon = 'icons/obj/kitchen.dmi'

/obj/item/weapon/kitchen/utensil
	w_class = 1.0
	flags = FPRINT | TABLEPASS | CONDUCT
	force = 2
	throwforce = 4
	throw_speed = 3
	throw_range = 5

/obj/item/weapon/kitchen/utensil/New()
	if (prob(60))
		src.pixel_y = rand(0, 4)
	return


// FORK

/obj/item/weapon/kitchen/utensil/fork
	name = "fork"
	icon_state = "fork"

/obj/item/weapon/kitchen/utensil/fork/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(!istype(M, /mob))
		return

	if((usr.mutations & 16) && prob(50))
		M << "\red You stab yourself in the eye."
		M.disabilities |= 128
		M.weakened += 4
		M.bruteloss += 10

	src.add_fingerprint(user)
	if(!(user.zone_sel.selecting == ("eyes" || "head")))
		return ..()
	var/mob/living/carbon/human/H = M
	if(istype(M, /mob/living/carbon/human) && ((H.head && H.head.flags & HEADCOVERSEYES) || (H.wear_mask && H.wear_mask.flags & MASKCOVERSEYES) || (H.glasses && H.glasses.flags & GLASSESCOVERSEYES)))
		// you can't stab someone in the eyes wearing a mask!
		user << "\blue You're going to need to remove that mask/helmet/glasses first."
		return
	for(var/mob/O in viewers(M, null))
		if(O == (user || M))	continue
		if(M == user)	O.show_message(text("\red [] has stabbed themself with []!", user, src), 1)
		else	O.show_message(text("\red [] has been stabbed in the eye with [] by [].", M, src, user), 1)
	if(M != user)
		M << "\red [user] stabs you in the eye with [src]!"
		user << "\red You stab [M] in the eye with [src]!"
	else
		user << "\red You stab yourself in the eyes with [src]!"
	if(istype(M, /mob/living/carbon/human))
		var/datum/organ/external/affecting = M.organs["head"]
		affecting.take_damage(7)
	else
		M.bruteloss += 7
	M.eye_blurry += rand(3,4)
	M.eye_stat += rand(2,4)
	if (M.eye_stat >= 10)
		M << "\red Your eyes start to bleed profusely!"
		M.eye_blurry += 15+(0.1*M.eye_blurry)
		M.disabilities |= 1
		if(M.stat == 2)	return
		if(prob(50))
			M << "\red You drop what you're holding and clutch at your eyes!"
			M.eye_blurry += 10
			M.paralysis += 1
			M.weakened += 4
			M.drop_item()
		if (prob(M.eye_stat - 10 + 1))
			M << "\red You go blind!"
			M.disabilities |= 128
	return




// ROLLING PIN

/obj/item/weapon/kitchen/rollingpin
	name = "rolling pin"
	icon_state = "rolling_pin"
	force = 3.0
	throwforce = 10.0
	throw_speed = 2
	throw_range = 7
	w_class = 3.0

/obj/item/weapon/kitchen/rollingpin/attack(mob/M as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red The [src] slips out of your hand and hits your head."
		usr.bruteloss += 10
		usr.paralysis += 2
		return
	if (M.stat < 2 && M.health < 50 && prob(90))
		var/mob/H = M
		// ******* Check
		if ((istype(H, /mob/living/carbon/human) && istype(H, /obj/item/clothing/head) && H.flags & 8 && prob(80)))
			M << "\red The helmet protects you from being hit hard in the head!"
			return
		var/time = rand(2, 6)
		if (prob(75))
			if (M.paralysis < time && (!(M.mutations & 8)) )
				M.paralysis = time
		else
			if (M.stunned < time && (!(M.mutations & 8)) )
				M.stunned = time
		if(M.stat != 2)	M.stat = 1
		for(var/mob/O in viewers(M, null))
			O.show_message(text("\red <B>[] has been knocked unconscious!</B>", M), 1, "\red You hear someone fall.", 2)
	else
		M << text("\red [] tried to knock you unconcious!",user)
		M.eye_blurry += 3

	return





// KNIFE

/obj/item/weapon/kitchen/utensil/knife
	name = "knife"
	icon_state = "knife"
	slash = 1
	var/butter = 0
	throwforce = 6.0

/obj/item/weapon/kitchen/utensil/knife/attack(target as mob, mob/user as mob)
	if ((usr.mutations & 16) && prob(50))
		usr << "\red You accidentally cut yourself with the [src]."
		usr.bruteloss += 20
		return


// SPOON

/obj/item/weapon/kitchen/utensil/spoon
	name = "spoon"
	desc = "He will chase you to the ends of the world..."
	icon_state = "spoon"
	force = 0
	throwforce = 0

obj/item/weapon/kitchen/utensil/admin_spoon
	name = "spoon"
	desc = "It's just a spoon... Or is it."
	icon_state = "spoon"
	slash = 1
	force = 50.0
	throwforce = 20.0
	throw_speed = 20
	throw_range = 10