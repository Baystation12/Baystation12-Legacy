/mob/living/carbon/human/Login()
	..()

	update_clothing()

	if (!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /mob/proc/ghostize

	return