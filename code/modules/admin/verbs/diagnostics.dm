/client/proc
	general_report()
		set category = "Diagnostics"

		if(!master_controller)
			usr << alert("Master_controller not found.")

		var/mobs = 0
		for(var/mob/M in world)
			mobs++

		var/output = {"<B>GENERAL SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Machines:</B> [machines.len]<BR>
<B># of Pipe Networks:</B> [pipe_networks.len]<BR>
<B># of Processing Items:</B> [processing_items.len]<BR>
<B># of Power Nets:</B> [powernets.len]<BR>
<B># of Mobs:</B> [mobs]<BR>
"}

		usr << browse(output,"window=generalreport")

	/*air_report()
		set category = "Diagnostics"

		if(!master_controller || !air_master)
			alert(usr,"Master_controller or air_master not found.","Air Report")
			return 0

		var/active_groups = 0
		var/inactive_groups = 0
		var/active_tiles = 0
		for(var/datum/air_group/group in air_master.air_groups)
			if(group.group_processing)
				active_groups++
			else
				inactive_groups++
				active_tiles += group.members.len

		var/hotspots = 0
		for(var/obj/hotspot/hotspot in world)
			hotspots++

		var/output = {"<B>AIR SYSTEMS REPORT</B><HR>
<B>General Processing Data</B><BR>
<B># of Groups:</B> [air_master.air_groups.len]<BR>
---- <I>Active:</I> [active_groups]<BR>
---- <I>Inactive:</I> [inactive_groups]<BR>
-------- <I>Tiles:</I> [active_tiles]<BR>
<B># of Active Singletons:</B> [air_master.active_singletons.len]<BR>
<BR>
<B>Special Processing Data</B><BR>
<B>Hotspot Processing:</B> [hotspots]<BR>
<B>High Temperature Processing:</B> [air_master.active_super_conductivity.len]<BR>
<B>High Pressure Processing:</B> [air_master.high_pressure_delta.len] (not yet implemented)<BR>
<BR>
<B>Geometry Processing Data</B><BR>
<B>Group Rebuild:</B> [air_master.groups_to_rebuild.len]<BR>
<B>Tile Update:</B> [air_master.tiles_to_update.len]<BR>
"}

		usr << browse(output,"window=airreport")

	air_status(turf/target as turf)
		set category = "Diagnostics"

		if(!isturf(target))
			return

		var/datum/gas_mixture/GM = target.return_air()
		var/burning = 0
		if(istype(target, /turf/simulated))
			var/turf/simulated/T = target
			if(T.active_hotspot)
				burning = 1

		usr << "\blue @[target.x],[target.y] ([GM.group_multiplier]): O:[GM.oxygen] T:[GM.toxins] N:[GM.nitrogen] C:[GM.carbon_dioxide] w [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(burning)?("\red BURNING"):(null)]"
		for(var/datum/gas/trace_gas in GM.trace_gases)
			usr << "[trace_gas.type]: [trace_gas.moles]"*/

	fix_next_move()
		set category = "Diagnostics"
		set name = "Press this if everybody freezes up"
		var/largest_move_time = 0
		var/largest_click_time = 0
		var/mob/largest_move_mob = null
		var/mob/largest_click_mob = null
		for(var/mob/M in world)
			if(!M.client)
				continue
			if(M.next_move >= largest_move_time)
				largest_move_mob = M
				if(M.next_move > world.time)
					largest_move_time = M.next_move - world.time
				else
					largest_move_time = 1
			if(M.lastDblClick >= largest_click_time)
				largest_click_mob = M
				if(M.lastDblClick > world.time)
					largest_click_time = M.lastDblClick - world.time
				else
					largest_click_time = 0
			log_admin("DEBUG: [key_name(M)]  next_move = [M.next_move]  lastDblClick = [M.lastDblClick]  world.time = [world.time]")
			M.next_move = 1
			M.lastDblClick = 0
		message_admins("[key_name_admin(largest_move_mob)] had the largest move delay with [largest_move_time] frames / [largest_move_time/10] seconds!", 1)
		message_admins("[key_name_admin(largest_click_mob)] had the largest click delay with [largest_click_time] frames / [largest_click_time/10] seconds!", 1)
		message_admins("world.time = [world.time]", 1)
		return