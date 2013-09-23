

/obj/hud/proc/larva_hud()

	adding = list(  )
	other = list(  )
	intents = list(  )
	mon_blo = list(  )
	m_ints = list(  )
	mov_int = list(  )
	vimpaired = list(  )
	darkMask = list(  )

	g_dither = new h_type( src )
	g_dither.screen_loc = "WEST,SOUTH to EAST,NORTH"
	g_dither.name = "Mask"
	g_dither.icon_state = "dither12g"
	g_dither.layer = 18
	g_dither.mouse_opacity = 0

	alien_view = new h_type(src)
	alien_view.screen_loc = "WEST,SOUTH to EAST,NORTH"
	alien_view.name = "Alien"
	alien_view.icon_state = "alien"
	alien_view.layer = 18
	alien_view.mouse_opacity = 0

	blurry = new h_type( src )
	blurry.screen_loc = "WEST,SOUTH to EAST,NORTH"
	blurry.name = "Blurry"
	blurry.icon_state = "blurry"
	blurry.layer = 17
	blurry.mouse_opacity = 0

	druggy = new h_type( src )
	druggy.screen_loc = "WEST,SOUTH to EAST,NORTH"
	druggy.name = "Druggy"
	druggy.icon_state = "druggy"
	druggy.layer = 17
	druggy.mouse_opacity = 0

	// station explosion cinematic
	station_explosion = new h_type( src )
	station_explosion.icon = 'icons/effects/station_explosion.dmi'
	station_explosion.icon_state = "start"
	station_explosion.layer = 20
	station_explosion.mouse_opacity = 0
	station_explosion.screen_loc = "1,3"

	var/obj/screen/using

	using = new h_type( src )
	using.name = "act_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.a_intent == "hurt" ? "harm" : mymob.a_intent)
	using.screen_loc = ui_acti
	using.layer = 20
	adding += using
	action_intent = using

	using = new h_type( src )
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	adding += using
	move_intent = using

	using = new h_type(src) //Right hud bar
	using.dir = SOUTH
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.screen_loc = "EAST+1,SOUTH to EAST+1,NORTH"
	using.layer = 19
	adding += using

	using = new h_type(src) //Lower hud bar
	using.dir = EAST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.screen_loc = "WEST,SOUTH-1 to EAST,SOUTH-1"
	using.layer = 19
	adding += using

	using = new h_type(src) //Corner Button
	using.dir = NORTHWEST
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.screen_loc = "EAST+1,SOUTH-1"
	using.layer = 19
	adding += using

	using = new h_type( src )
	using.name = "arrowleft"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "s_arrow"
	using.dir = WEST
	using.screen_loc = ui_iarrowleft
	using.layer = 19
	adding += using

	using = new h_type( src )
	using.name = "arrowright"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "s_arrow"
	using.dir = EAST
	using.screen_loc = ui_iarrowright
	using.layer = 19
	adding += using


	using = new h_type( src )
	using.name = "resist"
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "act_resist"
	using.screen_loc = ui_resist
	using.layer = 19
	adding += using



	using = new h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "1,1 to 5,15"
	using.layer = 17
	using.mouse_opacity = 0
	vimpaired += using

	using = new h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "5,1 to 10,5"
	using.layer = 17
	using.mouse_opacity = 0
	vimpaired += using

	using = new h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "6,11 to 10,15"
	using.layer = 17
	using.mouse_opacity = 0
	vimpaired += using

	using = new h_type( src )
	using.name = null
	using.icon = 'icons/mob/screen1_alien.dmi'
	using.icon_state = "dither50"
	using.screen_loc = "11,1 to 15,15"
	using.layer = 17
	using.mouse_opacity = 0
	vimpaired += using

	mymob.oxygen = new /obj/screen( null )
	mymob.oxygen.icon = 'icons/mob/screen1_alien.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen

	mymob.toxin = new /obj/screen( null )
	mymob.toxin.icon = 'icons/mob/screen1_alien.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin


	mymob.fire = new /obj/screen( null )
	mymob.fire.icon = 'icons/mob/screen1_alien.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire


	mymob.healths = new /obj/screen( null )
	mymob.healths.icon = 'icons/mob/screen1_alien.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health

	mymob.pullin = new /obj/screen( null )
	mymob.pullin.icon = 'icons/mob/screen1_alien.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull

	mymob.blind = new /obj/screen( null )
	mymob.blind.icon = 'icons/mob/screen1_alien.dmi'
	mymob.blind.icon_state = "black"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1 to 15,15"
	mymob.blind.layer = 0
	mymob.blind.mouse_opacity = 0

	mymob.flash = new /obj/screen( null )
	mymob.flash.icon = 'icons/mob/screen1_alien.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17


	mymob.sleep = new /obj/screen( null )
	mymob.sleep.icon = 'icons/mob/screen1_alien.dmi'
	mymob.sleep.icon_state = "sleep0"
	mymob.sleep.name = "sleep"
	mymob.sleep.screen_loc = ui_sleep

	mymob.rest = new /obj/screen( null )
	mymob.rest.icon = 'icons/mob/screen1_alien.dmi'
	mymob.rest.icon_state = "rest0"
	mymob.rest.name = "rest"
	mymob.rest.screen_loc = ui_rest


	mymob.zone_sel = new /obj/screen/zone_sel( null )
	mymob.zone_sel.overlays = null
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.client.screen = null

	mymob.client.screen += list( mymob.zone_sel, mymob.oxygen, mymob.toxin, mymob.fire, mymob.healths, mymob.pullin, mymob.blind, mymob.flash, mymob.rest, mymob.sleep) //, mymob.mach )
	mymob.client.screen += adding + other



