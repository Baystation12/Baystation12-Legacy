/mob/living/var/t_plasma = null
/mob/living/var/t_oxygen = null
/mob/living/var/t_sl_gas = null
/mob/living/var/t_n2 = null
/mob/living/var/now_pushing = null
/mob/living/var/cameraFollow = null
/mob/living/var/lasthandcuff = null
/mob/living/var/obj/item/clothing/suit/wear_suit = null
/mob/living/var/obj/item/clothing/under/w_uniform = null
///mob/living/carbon/human/var/obj/item/device/radio/w_radio = null
/mob/living/var/obj/item/clothing/shoes/shoes = null
/mob/living/var/obj/item/weapon/belt = null
/mob/living/var/obj/item/clothing/gloves/gloves = null
/mob/living/var/obj/item/clothing/glasses/glasses = null
/mob/living/var/obj/item/clothing/head/head = null
/mob/living/var/obj/item/clothing/ears/ears = null

/mob/living/movement_delay()
	. = ..()
	if(shoes)
		if(shoes.type == /obj/item/clothing/shoes/magnetic) . += 4

// overwritten by individual subtypes
mob/living/proc/radiate(amount)


mob/living/proc/adjustBruteLoss(amount)
	if(amount > 0) // damage
		var/dmg = amount / src.organs2.len
		for(var/datum/organ/external/A in src.organs2)
			A.take_damage(dmg,0)
	else
		var/list/damagedOrgans = new()
		for(var/datum/organ/external/organ in src.organs2)
			if(organ.brute_dam)
				damagedOrgans.Add(organ)
		var/dmg = amount / damagedOrgans.len
		for(var/datum/organ/external/organ in damagedOrgans)
			organ.heal_damage(dmg,0,1)

mob/living/proc/adjustFireLoss(amount)
	if(amount > 0) // damage
		var/dmg = amount / src.organs2.len
		for(var/datum/organ/external/A in src.organs2)
			A.take_damage(0,dmg)
	else
		var/list/damagedOrgans = new()
		for(var/datum/organ/external/organ in src.organs2)
			if(organ.burn_dam)
				damagedOrgans.Add(organ)
		var/dmg = amount / damagedOrgans.len
		for(var/datum/organ/external/organ in damagedOrgans)
			organ.heal_damage(dmg,0,1)
mob/living/proc/adjustToxLoss(amount)
	src.toxloss = max(0,src.toxloss + (amount))
mob/living/proc/adjustOxyLoss(amount)
	src.oxyloss = max(0,src.oxyloss + (amount))
mob/living/proc/adjustBrainLoss(amount)
	src.brainloss = max(0,src.brainloss + (amount))