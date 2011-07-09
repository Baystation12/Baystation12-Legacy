/proc/togglebuildmode(mob/M as mob in world)
	if(M.client)
		if(M.client.buildmode)
			M.client.buildmode = 0
			M.client.show_popup_menus = 1
			for(var/obj/buildholder/H)
				if(H.cl == M.client)
					del(H)
		else
			M.client.buildmode = 1
			M.client.show_popup_menus = 0

			var/obj/buildholder/H = new/obj/buildholder()
			var/obj/builddir/A = new/obj/builddir(H)
			A.master = H
			var/obj/buildhelp/B = new/obj/buildhelp(H)
			B.master = H
			var/obj/buildmode/C = new/obj/buildmode(H)
			C.master = H
			var/obj/buildquit/D = new/obj/buildquit(H)
			D.master = H

			H.builddir = A
			H.buildhelp = B
			H.buildmode = C
			H.buildquit = D
			M.client.screen += A
			M.client.screen += B
			M.client.screen += C
			M.client.screen += D
			H.cl = M.client

/obj/builddir
	density = 1
	anchored = 1
	layer = 20
	dir = NORTH
	icon = 'buildmode.dmi'
	icon_state = "build"
	screen_loc = "NORTH,WEST"
	var/obj/buildholder/master = null
/obj/buildhelp
	density = 1
	anchored = 1
	layer = 20
	dir = NORTH
	icon = 'buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"
	var/obj/buildholder/master = null
/obj/buildmode
	density = 1
	anchored = 1
	layer = 20
	dir = NORTH
	icon = 'buildmode.dmi'
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST+2"
	var/obj/buildholder/master = null
	var/varholder = "name"
	var/valueholder = "dongs"
	var/objholder = "/obj/closet"
/obj/buildquit
	density = 1
	anchored = 1
	layer = 20
	dir = NORTH
	icon = 'buildmode.dmi'
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"
	var/obj/buildholder/master = null

/obj/buildquit/Click()
	togglebuildmode(master.cl.mob)

/obj/buildholder
	density = 0
	anchored = 1
	var/client/cl = null
	var/obj/builddir/builddir = null
	var/obj/buildhelp/buildhelp = null
	var/obj/buildmode/buildmode = null
	var/obj/buildquit/buildquit = null
	var/list/argL = null
	var/procname = null

/obj/builddir/Click()
	switch(dir)
		if(NORTH)
			dir = EAST
		if(EAST)
			dir = SOUTH
		if(SOUTH)
			dir = WEST
		if(WEST)
			dir = NORTHWEST
		if(NORTHWEST)
			dir = NORTH

/obj/buildhelp/Click()
	switch(master.cl.buildmode)
		if(1)
			usr << "\blue ***********************************************************"
			usr << "\blue Left Mouse Button        = Construct / Upgrade"
			usr << "\blue Right Mouse Button       = Deconstruct / Delete / Downgrade"
			usr << "\blue Left Mouse Button + ctrl = R-Window"
			usr << "\blue Left Mouse Button + alt  = Airlock"
			usr << ""
			usr << "\blue Use the button in the upper left corner to"
			usr << "\blue change the direction of built objects."
			usr << "\blue ***********************************************************"
		if(2)
			usr << "\blue ***********************************************************"
			usr << "\blue Right Mouse Button on buildmode button = Set object type"
			usr << "\blue Left Mouse Button on turf/obj          = Place objects"
			usr << "\blue Right Mouse Button                     = Delete objects"
			usr << ""
			usr << "\blue Use the button in the upper left corner to"
			usr << "\blue change the direction of built objects."
			usr << "\blue ***********************************************************"
		if(3)
			usr << "\blue ***********************************************************"
			usr << "\blue Right Mouse Button on buildmode button = Select var(type) & value"
			usr << "\blue Left Mouse Button on turf/obj/mob      = Set var(type) & value"
			usr << "\blue Right Mouse Button on turf/obj/mob     = Reset var's value"
			usr << "\blue ***********************************************************"

/obj/buildmode/Click(location, control, params)
	var/list/pa = params2list(params)

	if(pa.Find("left"))
		switch(master.cl.buildmode)
			if(1)
				master.cl.buildmode = 2
				src.icon_state = "buildmode2"
			if(2)
				master.cl.buildmode = 3
				src.icon_state = "buildmode3"
			if(3)
				if(master.cl.holder && master.cl.holder.rank in list("Host", "Coder"))
					master.cl.buildmode = 4
					src.icon_state = "procgun"
				else
					master.cl.buildmode = 1
					src.icon_state = "buildmode1"
			if(4)
				master.cl.buildmode = 1
				src.icon_state = "buildmode1"

	else if(pa.Find("right"))
		switch(master.cl.buildmode)
			if(1)
				return
			if(2)
				objholder = input(usr,"Enter typepath:" ,"Typepath","/obj/closet")
				var/list/removed_paths = list("/obj/bhole")
				if(objholder in removed_paths)
					alert("That path is not allowed.")
					objholder = "/obj/closet"
				else if (dd_hasprefix(objholder, "/mob") && !(usr.client.holder.rank in list("Host", "Coder", "Super Administrator")))
					objholder = "/obj/closet"
			if(3)
				var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "cuffed", "ka", "last_eaten", "urine")

				master.buildmode.varholder = input(usr,"Enter variable name:" ,"Name", "name")
				if(master.buildmode.varholder in locked && !(usr.client.holder.rank in list("Host", "Coder")))
					return
				var/thetype = input(usr,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
				if(!thetype) return
				switch(thetype)
					if("text")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", "value") as text
					if("number")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", 123) as num
					if("mob-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as mob in world
					if("obj-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as obj in world
					if("turf-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as turf in world

			if(4)
				master.procname = input(usr, "Enter full proc path:", "ProcPath")
				var/argNum = input("Number of arguments:","Number",null) as num
				master.argL = new/list()
				var/class
				var/i
				for(i=0; i<argNum; i++)
					class = input("Type of Argument #[i]","Variable Type", "text") in list("text","num","type","reference","icon","file","cancel")
					switch(class)
						if("cancel")
							return

						if("text")
							master.argL.Add( input("Enter new text:","Text",null) as text )

						if("num")
							master.argL.Add( input("Enter new number:","Num",null) as num )

						if("type")
							master.argL.Add( input("Enter type:","Type",null) in typesof(/obj,/mob,/area,/turf) )

						if("reference")
							master.argL.Add( input("Select reference:","Reference",null) as mob|obj|turf|area in world )

						if("icon")
							master.argL.Add( input("Pick icon:","Icon",null) as icon )

						if("file")
							master.argL.Add( input("Pick file:","File",null) as file )


/proc/build_click(var/mob/user, buildmode, location, control, params, var/obj/object)

	var/obj/buildholder/holder = null

	for(var/obj/buildholder/H)
		if(H.cl == user.client)
			holder = H
			break

	if(!holder) return
	var/list/pa = params2list(params)


	switch(buildmode)

		if(1)
			if(istype(object,/turf) && pa.Find("left") && !pa.Find("alt") && !pa.Find("ctrl") )
				if(istype(object,/turf/space))
					var/turf/T = object
					T.ReplaceWithFloor()
					return
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ReplaceWithWall()
					return
				else if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ReplaceWithRWall()
					return

			else if(pa.Find("right"))
				if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ReplaceWithFloor()
					return
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ReplaceWithOpen()
					return
				else if(istype(object,/turf/simulated/wall/r_wall))
					var/turf/T = object
					T.ReplaceWithWall()
					return
				else if(istype(object,/obj))
					del(object)
					return

			else if(istype(object,/turf) && pa.Find("alt") && pa.Find("left"))
				new/obj/machinery/door/airlock(get_turf(object))

			else if(istype(object,/turf) && pa.Find("ctrl") && pa.Find("left"))
				switch(holder.builddir.dir)
					if(NORTH)
						new/obj/window/reinforced/north(get_turf(object))
					if(EAST)
						new/obj/window/reinforced/east(get_turf(object))
					if(SOUTH)
						new/obj/window/reinforced/south(get_turf(object))
					if(WEST)
						new/obj/window/reinforced/west(get_turf(object))
					if(NORTHWEST)
						new/obj/window/reinforced/northwest(get_turf(object))
		if(2)
			if(pa.Find("left"))
				var/obj/A = new holder.buildmode.objholder (get_turf(object))
				A.dir = holder.builddir.dir
				blink(A)
			else if(pa.Find("right"))
				if(isobj(object)) del(object)

		if(3)
			if(pa.Find("left")) //I cant believe this shit actually compiles.
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
//					message_admins("[key_name_admin(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]", 1)
					object.vars[holder.buildmode.varholder] = holder.buildmode.valueholder
					blink(object)
				else
					usr << "\red [initial(object.name)] does not have a var called '[holder.buildmode.varholder]'"
			if(pa.Find("right"))
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
//					message_admins("[key_name_admin(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]", 1)
					object.vars[holder.buildmode.varholder] = initial(object.vars[holder.buildmode.varholder])
					blink(object)
				else
					usr << "\red [initial(object.name)] does not have a var called '[holder.buildmode.varholder]'"
		if(4)
			blink(object)
			var/returnval = call(object, holder.procname)(arglist(holder.argL))
			usr << "\blue Proc \"[holder.procname]\" returned: [returnval ? returnval : "null"]"


/proc/blink(atom/A)
	A.icon += rgb(0,75,75)
	spawn(10) A.icon = initial(A.icon)
