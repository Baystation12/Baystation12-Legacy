/mob/living/silicon/ai/Logout()
	..()
	for(var/obj/machinery/ai_status_display/O in world) //change status
		spawn( 0 )
		O.mode = 0
	if(!isturf(src.loc))
		src.client.eye = src.loc
		src.client.perspective = EYE_PERSPECTIVE
	if (src.stat == 2)
		src.verbs += /mob/proc/ghostize
	return