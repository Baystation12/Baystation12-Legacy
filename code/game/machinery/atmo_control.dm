obj/machinery/air_sensor
	icon = 'stationobjs.dmi'
	icon_state = "gsensor1"
	name = "Gas Sensor"

	anchored = 1

	var/id_tag
	var/frequency = 1439

	var/on = 1
	var/output = 3
	//Flags:
	// 1 for pressure
	// 2 for temperature
	// 4 for oxygen concentration
	// 8 for toxins concentration
	// 16 for n2 concentration

	var/datum/radio_frequency/radio_connection

	proc/update_icon()
		icon_state = "gsensor[on]"

	process()
		if(on)
			var/datum/signal/signal = new
			signal.transmission_method = 1 //radio signal
			signal.data["tag"] = id_tag
			signal.data["timestamp"] = air_master.current_cycle

			var/datum/gas_mixture/air_sample = return_air()

			if(output&1)
				signal.data["pressure"] = num2text(round(air_sample.return_pressure(),0.1),)
			if(output&2)
				signal.data["temperature"] = round(air_sample.temperature,0.1)

			if(output&28)
				var/total_moles = air_sample.total_moles()
				if(output&4)
					signal.data["oxygen"] = round(100*air_sample.oxygen/total_moles)
				if(output&8)
					signal.data["toxins"] = round(100*air_sample.toxins/total_moles)
				if(output&16)
					signal.data["n2"] = round(100*air_sample.nitrogen/total_moles)

			radio_connection.post_signal(src, signal)


	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

	initialize()
		set_frequency(frequency)

	New()
		..()

		if(radio_controller)
			set_frequency(frequency)

obj/machinery/computer/general_air_control
	icon = 'computer.dmi'
	icon_state = "computer_generic"

	name = "Computer"

	var/frequency = 1439
	var/list/sensors = list()

	var/list/sensor_information = list()
	var/datum/radio_frequency/radio_connection

	attack_hand(mob/user)
		user << browse(return_text(),"window=computer")
		user.machine = src
		onclose(user, "computer")

	process()
		..()

		src.updateDialog()

	attackby(I as obj, user as mob)
		if(istype(I, /obj/item/weapon/screwdriver))
			playsound(src.loc, 'Screwdriver.ogg', 50, 1)
			if(do_after(user, 20))
				if (src.stat & BROKEN)
					user << "\blue The broken glass falls out."
					var/obj/computerframe/A = new /obj/computerframe( src.loc )
					new /obj/item/weapon/shard( src.loc )
					var/obj/item/weapon/circuitboard/air_management/M = new /obj/item/weapon/circuitboard/air_management( A )
					for (var/obj/C in src)
						C.loc = src.loc
					M.frequency = src.frequency
					A.circuit = M
					A.state = 3
					A.icon_state = "3"
					A.anchored = 1
					del(src)
				else
					user << "\blue You disconnect the monitor."
					var/obj/computerframe/A = new /obj/computerframe( src.loc )
					var/obj/item/weapon/circuitboard/air_management/M = new /obj/item/weapon/circuitboard/air_management( A )
					for (var/obj/C in src)
						C.loc = src.loc
					M.frequency = src.frequency
					A.circuit = M
					A.state = 4
					A.icon_state = "4"
					A.anchored = 1
					del(src)
		else
			src.attack_hand(user)
		return

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/id_tag = signal.data["tag"]
		if(!id_tag || !sensors.Find(id_tag)) return

		sensor_information[id_tag] = signal.data

	proc/return_text()
		var/sensor_data
		if(sensors.len)
			for(var/id_tag in sensors)
				var/long_name = sensors[id_tag]
				var/list/data = sensor_information[id_tag]
				var/sensor_part = "<B>[long_name]</B>: "

				if(data)
					if(data["pressure"])
						sensor_part += "[data["pressure"]] kPa"
						if(data["temperature"])
							sensor_part += ", [data["temperature"]] K"
						sensor_part += "<BR>"
					else if(data["temperature"])
						sensor_part += "[data["temperature"]] K<BR>"

					if(data["oxygen"]||data["toxins"])
						sensor_part += "<B>[long_name] Composition</B>: "
						if(data["oxygen"])
							sensor_part += "[data["oxygen"]] %O2"
							if(data["toxins"])
								sensor_part += ", [data["toxins"]] %TX"
							sensor_part += "<BR>"
						else if(data["toxins"])
							sensor_part += "[data["toxins"]] %TX<BR>"

				else
					sensor_part = "<FONT color='red'>[long_name] can not be found!</FONT><BR>"

				sensor_data += sensor_part

		else
			sensor_data = "No sensors connected."

		var/output = {"<B>[name]</B><HR>
<B>Sensor Data: <BR></B>
[sensor_data]<HR>"}

		return output

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[frequency]")
			frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[frequency]")

	initialize()
		set_frequency(frequency)

	large_tank_control
		icon = 'computer.dmi'
		icon_state = "tank"

		var/input_tag
		var/output_tag

		var/list/input_info
		var/list/output_info

		var/pressure_setting = ONE_ATMOSPHERE * 45

		return_text()
			var/output = ..()

			output += "<B>Tank Control System</B><BR>"
			if(input_info)
				var/power = (input_info["power"] == "on")
				var/volume_rate = input_info["volume_rate"]
				output += {"<B>Input</B>: [power?("Injecting"):("On Hold")] <A href='?src=\ref[src];in_refresh_status=1'>Refresh</A><BR>
Rate: [volume_rate] L/sec<BR>"}
				output += "Command: <A href='?src=\ref[src];in_toggle_injector=1'>Toggle Power</A><BR>"

			else
				output += "<FONT color='red'>ERROR: Can not find input port</FONT> <A href='?src=\ref[src];in_refresh_status=1'>Search</A><BR>"

			output += "<BR>"

			if(output_info)
				var/power = (output_info["power"] == "on")
				var/output_pressure = output_info["internal"]
				output += {"<B>Output</B>: [power?("Open"):("On Hold")] <A href='?src=\ref[src];out_refresh_status=1'>Refresh</A><BR>
Max Output Pressure: [output_pressure] kPa<BR>"}
				output += "Command: <A href='?src=\ref[src];out_toggle_power=1'>Toggle Power</A> <A href='?src=\ref[src];out_set_pressure=1'>Set Pressure</A><BR>"

			else
				output += "<FONT color='red'>ERROR: Can not find output port</FONT> <A href='?src=\ref[src];out_refresh_status=1'>Search</A><BR>"

			output += "Max Output Pressure Set: <A href='?src=\ref[src];adj_pressure=-100'>-</A> <A href='?src=\ref[src];adj_pressure=-1'>-</A> [pressure_setting] kPa <A href='?src=\ref[src];adj_pressure=1'>+</A> <A href='?src=\ref[src];adj_pressure=100'>+</A><BR>"

			return output

		receive_signal(datum/signal/signal)
			if(!signal || signal.encryption) return

			var/id_tag = signal.data["tag"]

			if(input_tag == id_tag)
				input_info = signal.data
			else if(output_tag == id_tag)
				output_info = signal.data
			else
				..(signal)

		Topic(href, href_list)
			if(..())
				return

			if(href_list["in_refresh_status"])
				input_info = null
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = input_tag
				signal.data["status"] = 1

				radio_connection.post_signal(src, signal)

			if(href_list["in_toggle_injector"])
				input_info = null
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = input_tag
				signal.data["command"] = "power_toggle"

				radio_connection.post_signal(src, signal)

			if(href_list["out_refresh_status"])
				output_info = null
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = output_tag
				signal.data["status"] = 1

				radio_connection.post_signal(src, signal)

			if(href_list["out_toggle_power"])
				output_info = null
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = output_tag
				signal.data["command"] = "power_toggle"

				radio_connection.post_signal(src, signal)

			if(href_list["out_set_pressure"])
				output_info = null
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = output_tag
				signal.data["command"] = "set_internal_pressure"
				signal.data["parameter"] = "[pressure_setting]"

				radio_connection.post_signal(src, signal)

			if(href_list["adj_pressure"])
				var/change = text2num(href_list["adj_pressure"])
				pressure_setting = min(max(0, pressure_setting + change), 50*ONE_ATMOSPHERE)

			spawn(7)
				attack_hand(usr)

	fuel_injection
		icon = 'computer.dmi'
		icon_state = "atmos"

		var/device_tag
		var/list/device_info

		var/automation = 0

		var/cutoff_temperature = 2000
		var/on_temperature = 1200

		attackby(I as obj, user as mob)
			if(istype(I, /obj/item/weapon/screwdriver))
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				if(do_after(user, 20))
					if (src.stat & BROKEN)
						user << "\blue The broken glass falls out."
						var/obj/computerframe/A = new /obj/computerframe( src.loc )
						new /obj/item/weapon/shard( src.loc )
						var/obj/item/weapon/circuitboard/injector_control/M = new /obj/item/weapon/circuitboard/injector_control( A )
						for (var/obj/C in src)
							C.loc = src.loc
						M.frequency = src.frequency
						A.circuit = M
						A.state = 3
						A.icon_state = "3"
						A.anchored = 1
						del(src)
					else
						user << "\blue You disconnect the monitor."
						var/obj/computerframe/A = new /obj/computerframe( src.loc )
						var/obj/item/weapon/circuitboard/injector_control/M = new /obj/item/weapon/circuitboard/injector_control( A )
						for (var/obj/C in src)
							C.loc = src.loc
						M.frequency = src.frequency
						A.circuit = M
						A.state = 4
						A.icon_state = "4"
						A.anchored = 1
						del(src)
			else
				src.attack_hand(user)
			return

		process()
			if(automation)
				if(!radio_connection)
					return 0

				var/injecting = 0
				for(var/id_tag in sensor_information)
					var/list/data = sensor_information[id_tag]
					if(data["temperature"])
						if(data["temperature"] >= cutoff_temperature)
							injecting = 0
							break
						if(data["temperature"] <= on_temperature)
							injecting = 1

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = device_tag

				if(injecting)
					signal.data["command"] = "power_on"
				else
					signal.data["command"] = "power_off"

				radio_connection.post_signal(src, signal)

			..()

		return_text()
			var/output = ..()

			output += "<B>Fuel Injection System</B><BR>"
			if(device_info)
				var/power = device_info["power"]
				var/volume_rate = device_info["volume_rate"]
				output += {"Status: [power?("Injecting"):("On Hold")] <A href='?src=\ref[src];refresh_status=1'>Refresh</A><BR>
Rate: [volume_rate] L/sec<BR>"}

				if(automation)
					output += "Automated Fuel Injection: <A href='?src=\ref[src];toggle_automation=1'>Engaged</A><BR>"
					output += "Injector Controls Locked Out<BR>"
				else
					output += "Automated Fuel Injection: <A href='?src=\ref[src];toggle_automation=1'>Disengaged</A><BR>"
					output += "Injector: <A href='?src=\ref[src];toggle_injector=1'>Toggle Power</A> <A href='?src=\ref[src];injection=1'>Inject (1 Cycle)</A><BR>"

			else
				output += "<FONT color='red'>ERROR: Can not find device</FONT> <A href='?src=\ref[src];refresh_status=1'>Search</A><BR>"

			return output

		receive_signal(datum/signal/signal)
			if(!signal || signal.encryption) return

			var/id_tag = signal.data["tag"]

			if(device_tag == id_tag)
				device_info = signal.data
			else
				..(signal)

		Topic(href, href_list)
			if(..())
				return

			if(href_list["refresh_status"])
				device_info = null
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = device_tag
				signal.data["status"] = 1

				radio_connection.post_signal(src, signal)

			if(href_list["toggle_automation"])
				automation = !automation

			if(href_list["toggle_injector"])
				device_info = null
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = device_tag
				signal.data["command"] = "power_toggle"

				radio_connection.post_signal(src, signal)

			if(href_list["injection"])
				if(!radio_connection)
					return 0

				var/datum/signal/signal = new
				signal.transmission_method = 1 //radio signal
				signal.source = src

				signal.data["tag"] = device_tag
				signal.data["command"] = "inject"

				radio_connection.post_signal(src, signal)

/obj/machinery/computer/general_alert
	var/datum/radio_frequency/radio_connection

	initialize()
		set_frequency(receive_frequency)

	receive_signal(datum/signal/signal)
		if(!signal || signal.encryption) return

		var/zone = signal.data["zone"]
		var/severity = signal.data["alert"]
		var/info
		switch (signal.data["subtype"])
			if (1)
				info = "Air Pressure Warning"
			if (2)
				info = "Oxygen Level Warning"
			if (3)
				info = "Temperature Warning"
			if (4)
				info = "Carbon Dioxide Warning"
			if (5)
				info = "Plasma Leak"

		if(!zone || !severity) return

		zone = "[zone] - [info]"

		if(severity=="severe")
			priority_alarms -= zone
			priority_alarms += zone
		else
			minor_alarms -= zone
			minor_alarms += zone

	proc
		set_frequency(new_frequency)
			radio_controller.remove_object(src, "[receive_frequency]")
			receive_frequency = new_frequency
			radio_connection = radio_controller.add_object(src, "[receive_frequency]")


	attack_hand(mob/user)
		user << browse(return_text(),"window=computer")
		user.machine = src
		onclose(user, "computer")

	process()
		if(priority_alarms.len)
			icon_state = "alert:2"

		else if(minor_alarms.len)
			icon_state = "alert:1"

		else
			icon_state = "alert:0"

		..()

		src.updateDialog()

	proc/return_text()
		var/priority_text
		var/minor_text

		if(priority_alarms.len)
			for(var/zone in priority_alarms)
				priority_text += "<FONT color='red'><B>[zone]</B></FONT>  <A href='?src=\ref[src];priority_clear=[ckey(zone)]'>X</A><BR>"
		else
			priority_text = "No priority alerts detected.<BR>"

		if(minor_alarms.len)
			for(var/zone in minor_alarms)
				minor_text += "<B>[zone]</B>  <A href='?src=\ref[src];minor_clear=[ckey(zone)]'>X</A><BR>"
		else
			minor_text = "No minor alerts detected.<BR>"

		var/output = {"<B>[name]</B><HR>
<B>Priority Alerts:</B><BR>
[priority_text]
<BR>
<HR>
<B>Minor Alerts:</B><BR>
[minor_text]
<BR>"}

		return output

	Topic(href, href_list)
		if(..())
			return

		if(href_list["priority_clear"])
			var/removing_zone = href_list["priority_clear"]
			for(var/zone in priority_alarms)
				if(ckey(zone) == removing_zone)
					priority_alarms -= zone

		if(href_list["minor_clear"])
			var/removing_zone = href_list["minor_clear"]
			for(var/zone in minor_alarms)
				if(ckey(zone) == removing_zone)
					minor_alarms -= zone