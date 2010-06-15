/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	var/obj/item/clothing/suit/wear_suit = null
	var/obj/item/clothing/head/head = null
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null

	var/icon/stand_icon = null
	var/icon/lying_icon = null

	var/last_b_state = 1.0

	var/image/face_standing = null
	var/image/face_lying = null

	var/list/body_standing = list(  )
	var/list/body_lying = list(  )

/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"

	health = 250
	icon_state = "queen_s"