/var/const/OPEN = 1
/var/const/CLOSED = 2

/obj/machinery/door/firedoor/power_change()
	if( powered(ENVIRON) )
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

/obj/machinery/door/firedoor/process()
	if(src.operating)
		return
	if(src.nextstate)
		if(src.nextstate == OPEN && src.density)
			spawn()
				src.open()
		else if(src.nextstate == CLOSED && !src.density)
			spawn()
				src.close()
		src.nextstate = null

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C as obj, mob/user as mob)
	src.add_fingerprint(user)
	if ((istype(C, /obj/item/weapon/weldingtool) && !( src.operating ) && src.density))
		var/obj/item/weapon/weldingtool/W = C
		if(W.welding)
			if (W.get_fuel() > 2)
				W.use_fuel(2)
			if (!( src.blocked ))
				src.blocked = 1
			else
				src.blocked = 0
			update_icon()

			return
	if (!( istype(C, /obj/item/weapon/crowbar) || (ishuman(user) && user:zombie) ))
		return

	if (!src.blocked && !src.operating)
		if(src.density)
			spawn( 0 )
				src.operating = 1

				do_animate("opening")
				sleep(15)
				src.density = 0
				update_icon()

				src.ul_SetOpacity(0)
				update_nearby_tiles()
				src.operating = 0
				return
		else //close it up again
			spawn( 0 )
				src.operating = 1

				do_animate("closing")
				src.density = 1
				sleep(15)
				update_icon()

				src.ul_SetOpacity(1)
				update_nearby_tiles()
				src.operating = 0
				return
	return

/obj/machinery/door/firedoor/border_only
	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group)
			var/direction = get_dir(src,target)
			return (dir != direction)
		else if(density)
			if(!height)
				var/direction = get_dir(src,target)
				return (dir != direction)
			else
				return 0

		return 1

	update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/destination = get_step(source,dir)

		if(need_rebuild)
			if(istype(source)) //Rebuild/update nearby group geometry
				if(source.parent)
					air_master.groups_to_rebuild += source.parent
				else
					air_master.tiles_to_update += source
			if(istype(destination))
				if(destination.parent)
					air_master.groups_to_rebuild += destination.parent
				else
					air_master.tiles_to_update += destination

		else
			if(istype(source)) air_master.tiles_to_update += source
			if(istype(destination)) air_master.tiles_to_update += destination

		return 1