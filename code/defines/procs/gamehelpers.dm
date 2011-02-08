/proc/dopage(src,target)
	var/href_list
	var/href
	href_list = params2list("src=\ref[src]&[target]=1")
	href = "src=\ref[src];[target]=1"
	src:temphtml = null
	src:Topic(href, href_list)
	return null

/proc/get_area(O)
	var/location = O
	var/i
	for(i=1, i<=20, i++)
		if(!isarea(location))
			location = location:loc
		else
			return location
	return 0

// Get an area by its name
/proc/get_area_name(N)

	for(var/area/A in world)
		if(A.name == N)
			return A
	return 0

// Get a random (from L) non-dense turf around an atom
/proc/get_random_turf(var/atom/A, var/list/L)
	while(L.len > 0)
		var/dir = pick(L)
		L -= dir
		var/turf/T = get_step(A,dir)
		var/possible = 1

		if(T.density == 0)
			for(var/obj/I in T)
				if(I.density == 1)
					possible = 0
					break

			if(possible)
				return T

	return

/proc/in_range(source, user)
	if(get_dist(source, user) <= 1)
		return 1
	else
		if (istype(user, /mob/living/carbon))
			if (user:mutations & 1)
				var/X = source:x
				var/Y = source:y
				var/Z = source:z
				spawn(0)
					//I really shouldnt put this here but i dont have a better idea
					var/obj/overlay/O = new /obj/overlay ( locate(X,Y,Z) )
					O.name = "sparkles"
					O.anchored = 1
					O.density = 0
					O.layer = FLY_LAYER
					O.dir = pick(cardinal)
					O.icon = 'effects.dmi'
					O.icon_state = "nothing"
					flick("empdisable",O)
					spawn(5)
						del(O)


				return 1

	return 0 //not in range and not telekinetic

/proc/circlerange(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in range(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs

/proc/circleview(center=usr,radius=3)

	var/turf/centerturf = get_turf(center)
	var/list/turfs = new/list()
	var/rsq = radius * (radius+0.5)

	for(var/atom/T in view(radius, centerturf))
		var/dx = T.x - centerturf.x
		var/dy = T.y - centerturf.y
		if(dx*dx + dy*dy <= rsq)
			turfs += T

	//turfs += centerturf
	return turfs
