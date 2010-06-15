// Disposal pipe construction

/obj/disposalconstruct

	name = "disposal pipe segment"
	desc = "A huge pipe segment used for constructing disposal systems."
	icon = 'disposal.dmi'
	icon_state = "conpipe-s"
	anchored = 0
	density = 1
	pressure_resistance = 5*ONE_ATMOSPHERE
	m_amt = 1850
	level = 2
	var/ptype = 0
	// 0=straight, 1=bent, 2=junction-j1, 3=junction-j2, 4=junction-y, 5=trunk

	var/dpdir = 0	// directions as disposalpipe
	var/base_state = "pipe-s"

	// update iconstate and dpdir due to dir and type
	proc/update()
		var/flip = turn(dir, 180)
		var/left = turn(dir, 90)
		var/right = turn(dir, -90)

		switch(ptype)
			if(0)
				base_state = "pipe-s"
				dpdir = dir | flip
			if(1)
				base_state = "pipe-c"
				dpdir = dir | right
			if(2)
				base_state = "pipe-j1"
				dpdir = dir | right | flip
			if(3)
				base_state = "pipe-j2"
				dpdir = dir | left | flip
			if(4)
				base_state = "pipe-y"
				dpdir = dir | left | right
			if(5)
				base_state = "pipe-t"
				dpdir = dir


		icon_state = "con[base_state]"

		if(invisibility)				// if invisible, fade icon
			icon -= rgb(0,0,0,128)

	// hide called by levelupdate if turf intact status changes
	// change visibility status and force update of icon
	hide(var/intact)
		invisibility = (intact && level==1) ? 101: 0	// hide if floor is intact
		update()


	// flip and rotate verbs
	verb/rotate()
		set src in view(1)

		if(usr.stat)
			return
		if(anchored)
			usr << "You must unfasten the pipe before rotating it."
		dir = turn(dir, -90)
		update()

	verb/flip()
		set src in view(1)
		if(usr.stat)
			return

		if(anchored)
			usr << "You must unfasten the pipe before flipping it."

		dir = turn(dir, 180)
		if(ptype == 2)
			ptype = 3
		else if(ptype == 3)
			ptype = 2
		update()

	// returns the type path of disposalpipe corresponding to this item dtype
	proc/dpipetype()
		switch(ptype)
			if(0,1)
				return /obj/disposalpipe/segment
			if(2,3,4)
				return /obj/disposalpipe/junction
			if(5)
				return /obj/disposalpipe/trunk
		return



	// attackby item
	// wrench: (un)anchor
	// weldingtool: convert to real pipe

	attackby(var/obj/item/I, var/mob/user)
		var/turf/T = src.loc
		if(T.intact)
			user << "You can only attach the pipe if the floor plating is removed."
			return

		var/obj/disposalpipe/CP = locate() in T
		if(CP)
			update()
			var/pdir = CP.dpdir
			if(istype(CP, /obj/disposalpipe/broken))
				pdir = CP.dir
			if(pdir & dpdir)
				user << "There is already a pipe at that location."
				return

		if(istype(I, /obj/item/weapon/wrench))
			if(anchored)
				anchored = 0
				level = 2
				density = 1
				user << "You detach the pipe from the underfloor."
			else
				anchored = 1
				level = 1
				density = 0
				user << "You attach the pipe to the underfloor."
			playsound(src.loc, 'Ratchet.ogg', 100, 1)

		else if(istype(I, /obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/W = I
			if(W.welding)
				if(W.get_fuel() > 2)
					W.use_fuel(2)
					playsound(src.loc, 'Welder2.ogg', 100, 1)

					// check if anything changed over 2 seconds
					var/turf/uloc = user.loc
					var/atom/wloc = W.loc
					user << "Welding the pipe in place."
					sleep(20)
					if(user.loc == uloc && wloc == W.loc)

						update()
						var/pipetype = dpipetype()
						var/obj/disposalpipe/P = new pipetype(src.loc)
						P.base_icon_state = base_state
						P.dir = dir
						P.dpdir = dpdir
						P.updateicon()

						del(src)
					else
						user << "You must stay still while welding."
						return



				else
					user << "You need more welding fuel to complete this task."
					return
