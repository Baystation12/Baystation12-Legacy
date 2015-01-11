/obj/machinery/portable_atmospherics/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "pscrubber:0"
	density = 1

	var/on = 0
	var/volume_rate = 1800

	volume = 2000

/obj/machinery/portable_atmospherics/scrubber/update_icon()
	src.overlays = 0

	if(on)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	return

/obj/machinery/portable_atmospherics/scrubber/process()
	..()
	if(on)
		//Take a gas sample
		var/datum/gas_mixture/input
		var/datum/gas_mixture/output
		if(holding)
			input = holding.air_contents
			output = loc.return_air()
		else
			input = loc.return_air()
			output = holding.air_contents
		var/transfer_moles = min(1, volume_rate/input.volume)*input.total_moles
		//Filter it
		var/list/filter = new
		filter += "phoron"
		filter += "carbon_dioxide"

		scrub_gas(src, filter, input, output, transfer_moles)
	//src.updateDialog()
	src.update_icon()
	return

/obj/machinery/portable_atmospherics/scrubber/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/scrubber/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_paw(var/mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/portable_atmospherics/scrubber/attack_hand(var/mob/user as mob)

	user.machine = src
	var/holding_text

	if(holding)
		holding_text = {"<BR><B>Tank Pressure</B>: [holding.air_contents.return_pressure()] KPa<BR>
<A href='?src=\ref[src];remove_tank=1'>Remove Tank</A><BR>
"}
	var/output_text = {"<TT><B>[name]</B><BR>
Pressure: [air_contents.return_pressure()] KPa<BR>
Port Status: [(connected_port)?("Connected"):("Disconnected")]
[holding_text]
<BR>
Power Switch: <A href='?src=\ref[src];power=1'>[on?("On"):("Off")]</A><BR>
Target Pressure: <A href='?src=\ref[src];volume_adj=-10'>-</A> <A href='?src=\ref[src];volume_adj=-1'>-</A> [volume_rate] <A href='?src=\ref[src];volume_adj=1'>+</A> <A href='?src=\ref[src];pressure_adj=10'>+</A><BR>
<HR>
<A href='?src=\ref[user];mach_close=scrubber'>Close</A><BR>
"}

	user << browse(output_text, "window=scrubber;size=600x300")
	onclose(user, "scrubber")
	return

/obj/machinery/portable_atmospherics/scrubber/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return

	if (((get_dist(src, usr) <= 1) && istype(src.loc, /turf)))
		usr.machine = src

		if(href_list["power"])
			on = !on

		if (href_list["remove_tank"])
			if(holding)
				holding.loc = loc
				holding = null

		if (href_list["volume_adj"])
			var/diff = text2num(href_list["volume_adj"])
			volume_rate = min(10*ONE_ATMOSPHERE, max(0, volume_rate+diff))

		src.updateUsrDialog()
		src.add_fingerprint(usr)
		update_icon()
	else
		usr << browse(null, "window=scrubber")
		return
	return