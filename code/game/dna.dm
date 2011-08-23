/////////////////////////// DNA DATUM

#define STRUCDNASIZE 25

/datum/dna
	var/unique_enzymes = null
	var/struc_enzymes = null
	var/uni_identity = null

/datum/dna/proc/check_integrity()
	//Lazy.
//	if(length(uni_identity) != 39) uni_identity = "00600200A00E0110148FC01300B0095BD7FD3F4"
//	if(length(struc_enzymes)!= STRUCDNASIZE*3) struc_enzymes = "2013E85C944C19A4B00185144725785DC6406A4508186248487555169453220780579106750610"
	return
/datum/dna/proc/ready_dna(mob/living/carbon/human/character)

	var/temp
	var/hair
	var/beard

	// determine DNA fragment from hairstyle
	// :wtc:

	var/list/styles = list("bald", "hair_a", "hair_b", "hair_c", "hair_d", "hair_e", "hair_f", "hair_bedhead", "hair_dreads", "hair_ponytail" )
	var/hrange = round(4095 / styles.len)

	var/style = styles.Find(character.hair_icon_state)
	if(style)
		hair = style * hrange + hrange - rand(1,hrange-1)
	else
		hair = 0

	switch(character.face_icon_state)
		if("bald") beard = rand(1,350)
		if("facial_elvis") beard = rand(351,650)
		if("facial_vandyke") beard = rand(651,950)
		if("facial_neckbeard") beard = rand(951,1250)
		if("facial_chaplin") beard = rand(1251,1550)
		if("facial_watson") beard = rand(1551,1850)
		if("facial_abe") beard = rand(1851,2150)
		if("facial_chin") beard = rand(2151,2450)
		if("facial_hip") beard = rand(2451,2750)
		if("facial_gt") beard = rand(2751,3050)
		if("facial_hogan") beard = rand(3051,3350)
		if("facial_selleck") beard = rand(3351,3650)
		if("facial_fullbeard") beard = rand(3651,3950)
		if("facial_longbeard") beard = rand(3951,4095)

	temp = add_zero2(num2hex((character.r_hair),1), 3)
	temp += add_zero2(num2hex((character.b_hair),1), 3)
	temp += add_zero2(num2hex((character.g_hair),1), 3)
	temp += add_zero2(num2hex((character.r_facial),1), 3)
	temp += add_zero2(num2hex((character.b_facial),1), 3)
	temp += add_zero2(num2hex((character.g_facial),1), 3)
	temp += add_zero2(num2hex(((character.s_tone + 220) * 16),1), 3)
	temp += add_zero2(num2hex((character.r_eyes),1), 3)
	temp += add_zero2(num2hex((character.g_eyes),1), 3)
	temp += add_zero2(num2hex((character.b_eyes),1), 3)

	var/gender

	if (character.gender == MALE)
		gender = add_zero2(num2hex((rand(1,(2050+BLOCKADD))),1), 3)
	else
		gender = add_zero2(num2hex((rand((2051+BLOCKADD),4094)),1), 3)

	temp += gender
	temp += add_zero2(num2hex((beard),1), 3)
	temp += add_zero2(num2hex((hair),1), 3)

	uni_identity = temp

	var/mutstring = "2013E85C944C19A4B00185144725785DC6406A4508186248487555169453220780579106750610"

	struc_enzymes = mutstring

	unique_enzymes = md5(character.real_name)
	reg_dna[unique_enzymes] = character.real_name

/////////////////////////// DNA DATUM

/////////////////////////// DNA HELPER-PROCS
/proc/getleftblocks(input,blocknumber,blocksize)
	var/string
	string = copytext(input,1,((blocksize*blocknumber)-(blocksize-1)))
	if (blocknumber > 1)
		return string
	else
		return null

/proc/getrightblocks(input,blocknumber,blocksize)
	var/string
	string = copytext(input,blocksize*blocknumber+1,length(input)+1)
	if (blocknumber < (length(input)/blocksize))
		return string
	else
		return null

/proc/getblock(input,blocknumber,blocksize)
	var/result
	result = copytext(input ,(blocksize*blocknumber)-(blocksize-1),(blocksize*blocknumber)+1)
	return result

/proc/setblock(istring, blocknumber, replacement, blocksize)
	var/result
	result = getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)
	return result

/proc/add_zero2(t, u)
	var/temp1
	while (length(t) < u)
		t = "0[t]"
	temp1 = t
	if (length(t) > u)
		temp1 = copytext(t,2,u+1)
	return temp1

/proc/miniscramble(input,rs,rd)
	var/output
	output = null
	if (input == "C" || input == "D" || input == "E" || input == "F")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"6",prob((rs*10));"7",prob((rs*5)+(rd));"0",prob((rs*5)+(rd));"1",prob((rs*10)-(rd));"2",prob((rs*10)-(rd));"3")
	if (input == "8" || input == "9" || input == "A" || input == "B")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "4" || input == "5" || input == "6" || input == "7")
		output = pick(prob((rs*10));"4",prob((rs*10));"5",prob((rs*10));"A",prob((rs*10));"B",prob((rs*5)+(rd));"C",prob((rs*5)+(rd));"D",prob((rs*5)+(rd));"2",prob((rs*5)+(rd));"3")
	if (input == "0" || input == "1" || input == "2" || input == "3")
		output = pick(prob((rs*10));"8",prob((rs*10));"9",prob((rs*10));"A",prob((rs*10));"B",prob((rs*10)-(rd));"C",prob((rs*10)-(rd));"D",prob((rs*5)+(rd));"E",prob((rs*5)+(rd));"F")
	if (!output) output = "5"
	return output

/proc/isblockon(hnumber, bnumber)
	var/temp2
	temp2 = hex2num(hnumber)
	if (bnumber == HULKBLOCK || bnumber == TELEBLOCK)
		if (temp2 >= 3500 + BLOCKADD)
			return 1
		else
			return 0
	if (bnumber == XRAYBLOCK || bnumber == FIREBLOCK)
		if (temp2 >= 3050 + BLOCKADD)
			return 1
		else
			return 0
	if (temp2 >= 2050 + BLOCKADD)
		return 1
	else
		return 0

/proc/randmutb(mob/M as mob)
	var/num
	var/newdna
	num = pick(1,3,FAKEBLOCK,5,CLUMSYBLOCK,7,9,BLINDBLOCK,DEAFBLOCK)
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/randmutg(mob/M as mob)
	var/num
	var/newdna
	num = pick(HULKBLOCK,XRAYBLOCK,FIREBLOCK,TELEBLOCK)
	newdna = setblock(M.dna.struc_enzymes,num,toggledblock(getblock(M.dna.struc_enzymes,num,3)),3)
	M.dna.struc_enzymes = newdna
	return

/proc/randmuti(mob/M as mob)
	var/num
	var/newdna
	num = pick(1,2,3,4,5,6,7,8,9,10,11,12,13)
	newdna = setblock(M.dna.uni_identity,num,add_zero2(num2hex(rand(1,4095),1),3),3)
	M.dna.uni_identity = newdna
	return

/proc/toggledblock(hnumber) //unused
	var/temp3
	var/chtemp
	temp3 = hex2num(hnumber)
	if (temp3 < 2050)
		chtemp = rand(2050,4095)
		return add_zero2(num2hex(chtemp,1),3)
	else
		chtemp = rand(1,2049)
		return add_zero2(num2hex(chtemp,1),3)
/////////////////////////// DNA HELPER-PROCS

/////////////////////////// DNA MISC-PROCS
/proc/updateappearance(mob/M as mob,structure)
	if(istype(M, /mob/living/carbon/human))
		M.dna.check_integrity()
		var/mob/living/carbon/human/H = M
		H.r_hair = hex2num(getblock(structure,1,3))
		H.b_hair = hex2num(getblock(structure,2,3))
		H.g_hair = hex2num(getblock(structure,3,3))
		H.r_facial = hex2num(getblock(structure,4,3))
		H.b_facial = hex2num(getblock(structure,5,3))
		H.g_facial = hex2num(getblock(structure,6,3))
		H.s_tone = round(((hex2num(getblock(structure,7,3)) / 16) - 220))
		H.r_eyes = hex2num(getblock(structure,8,3))
		H.g_eyes = hex2num(getblock(structure,9,3))
		H.b_eyes = hex2num(getblock(structure,10,3))

		if (isblockon(getblock(structure, 11,3),11))
			H.gender = FEMALE
		else
			H.gender = MALE
		///
		var/beardnum = hex2num(getblock(structure,12,3))
		if (beardnum >= 1 && beardnum <= 350)
			H.face_icon_state = "bald"
			H.f_style = "bald"
		else if (beardnum >= 351 && beardnum <= 650)
			H.face_icon_state = "facial_elvis"
			H.f_style = "facial_elvis"
		else if (beardnum >= 651 && beardnum <= 950)
			H.face_icon_state = "facial_vandyke"
			H.f_style = "facial_vandyke"
		else if (beardnum >= 951 && beardnum <= 1250)
			H.face_icon_state = "facial_neckbeard"
			H.f_style = "facial_neckbeard"
		else if (beardnum >= 1251 && beardnum <= 1550)
			H.face_icon_state = "facial_chaplin"
			H.f_style = "facial_chaplin"
		else if (beardnum >= 1551 && beardnum <= 1850)
			H.face_icon_state = "facial_watson"
			H.f_style = "facial_watson"
		else if (beardnum >= 1851 && beardnum <= 2150)
			H.face_icon_state = "facial_abe"
			H.f_style = "facial_abe"
		else if (beardnum >= 2151 && beardnum <= 2450)
			H.face_icon_state = "facial_chin"
			H.f_style = "facial_chin"
		else if (beardnum >= 2451 && beardnum <= 2750)
			H.face_icon_state = "facial_hip"
			H.f_style = "facial_hip"
		else if (beardnum >= 2751 && beardnum <= 3050)
			H.face_icon_state = "facial_gt"
			H.f_style = "facial_gt"
		else if (beardnum >= 3051 && beardnum <= 3350)
			H.face_icon_state = "facial_hogan"
			H.f_style = "facial_hogan"
		else if (beardnum >= 3351 && beardnum <= 3650)
			H.face_icon_state = "facial_selleck"
			H.f_style = "facial_selleck"
		else if (beardnum >= 3651 && beardnum <= 3950)
			H.face_icon_state = "facial_fullbeard"
			H.f_style = "facial_fullbeard"
		else if (beardnum >= 3951 && beardnum <= 4095)
			H.face_icon_state = "facial_longbeard"
			H.f_style = "facial_longbeard"


		var/hairnum = hex2num(getblock(structure,13,3))


		var/list/styles = list("bald", "hair_a", "hair_b", "hair_c", "hair_d", "hair_e", "hair_f", "hair_bedhead", "hair_dreads", "hair_ponytail" )
		var/hrange = round(4095 / styles.len)

		var/style = round(hairnum / hrange)

		if (style > styles.len)
			style = styles.len
		if (style < 1)
			style = 1

		H.hair_icon_state = styles[style]
		H.h_style = H.hair_icon_state


		H.update_face()
		H.update_body()

		return 1
	else
		return 0

/proc/ismuton(var/block,var/mob/M)
	return isblockon(getblock(M.dna.struc_enzymes, block,3),block)

/proc/domutcheck(mob/M as mob, connected, inj)
	if (!M) return
	//telekinesis = 1
	//firemut = 2
	//xray = 4
	//hulk = 8
	//clumsy = 16
	//nobreath = 32
	//remoteviewing = 64
	//regenerate = 128
	//Increaserun = 256
	//remotetalk = 512
	//morphskincolour = 1024
	//blend = 2048
	//hallucinationimmunity = 4096
	//fingerprints = 8192
	//shockimmunity = 16384
	//smallsize = 32768


	M.dna.check_integrity()

	M.disabilities = 0
	M.sdisabilities = 0
	M.mutations = 0

	M.see_in_dark = 2
	M.see_invisible = 0


	if(ismuton(NOBREATHBLOCK,M))
		if(prob(15))
			M << "\blue You stop breathing"
			M.mutations |= mNobreath
	if(ismuton(REMOTEVIEWBLOCK,M))
		if(prob(15))
			M << "\blue Your mind expands"
			M.mutations |= mRemote
	if(ismuton(REGENERATEBLOCK,M))
		if(prob(15))
			M << "\blue You feel strange"
			M.mutations |= mRegen
	if(ismuton(INCREASERUNBLOCK,M))
		if(prob(15))
			M << "\blue You feel quick"
			M.mutations |= mRun
	if(ismuton(REMOTETALKBLOCK,M))
		if(prob(15))
			M << "\blue You expand your mind outwards"
			M.mutations |= mRemotetalk
	if(ismuton(MORPHBLOCK,M))
		if(prob(15))
			M.mutations |= mMorph
			M << "\blue Your skin feels strange"
	if(ismuton(BLENDBLOCK,M))
		if(prob(15))
			M.mutations |= mBlend
			M << "\blue You feel alone"
	if(ismuton(HALLUCINATIONBLOCK,M))
		if(prob(15))
			M.mutations |= mHallucination
			M << "\blue Your mind says 'Hello'"
	if(ismuton(NOPRINTSBLOCK,M))
		if(prob(15))
			M.mutations |= mFingerprints
			M << "\blue Your fingers feel numb"
	if(ismuton(SHOCKIMMUNITYBLOCK,M))
		if(prob(15))
			M.mutations |= mShock
			M << "\blue You feel strange"
	if(ismuton(SMALLSIZEBLOCK,M))
		if(prob(15))
			M << "\blue Your skin feels rubbery"
			M.mutations |= mSmallsize



	if (isblockon(getblock(M.dna.struc_enzymes, HULKBLOCK,3),HULKBLOCK))
		if(inj || prob(15))
			M << "\blue Your muscles hurt."
			M.mutations |= 8
	if (isblockon(getblock(M.dna.struc_enzymes, HEADACHEBLOCK,3),HEADACHEBLOCK))
		M.disabilities |= 2
		M << "\red You get a headache."
	if (isblockon(getblock(M.dna.struc_enzymes, FAKEBLOCK,3),FAKEBLOCK))
		M << "\red You feel strange."
		if (prob(95))
			if(prob(50))
				randmutb(M)
			else
				randmuti(M)
		else
			randmutg(M)
	if (isblockon(getblock(M.dna.struc_enzymes, COUGHBLOCK,3),COUGHBLOCK))
		M.disabilities |= 4
		M << "\red You start coughing."
	if (isblockon(getblock(M.dna.struc_enzymes, CLUMSYBLOCK,3),CLUMSYBLOCK))
		M << "\red You feel lightheaded."
		M.mutations |= 16
	if (isblockon(getblock(M.dna.struc_enzymes, TWITCHBLOCK,3),TWITCHBLOCK))
		M.disabilities |= 8
		M << "\red You twitch."
	if (isblockon(getblock(M.dna.struc_enzymes, XRAYBLOCK,3),XRAYBLOCK))
		if(inj || prob(30))
			M << "\blue The walls suddenly disappear."
			M.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			M.see_in_dark = 8
			M.see_invisible = 2
			M.mutations |= 4
	if (isblockon(getblock(M.dna.struc_enzymes, NERVOUSBLOCK,3),NERVOUSBLOCK))
		M.disabilities |= 16
		M << "\red You feel nervous."
	if (isblockon(getblock(M.dna.struc_enzymes, FIREBLOCK,3),FIREBLOCK))
		if(inj || prob(30))
			M << "\blue Your body feels warm."
			M.mutations |= 2
	if (isblockon(getblock(M.dna.struc_enzymes, BLINDBLOCK,3),BLINDBLOCK))
		M.sdisabilities |= 1
		M << "\red You can't seem to see anything."
	if (isblockon(getblock(M.dna.struc_enzymes, TELEBLOCK,3),TELEBLOCK))
		if(inj || prob(15))
			M << "\blue You feel smarter."
			M.mutations |= 1
	if (isblockon(getblock(M.dna.struc_enzymes, DEAFBLOCK,3),DEAFBLOCK))
		M.sdisabilities |= 4
		M.ear_deaf = 1
		M << "\red Its kinda quiet..."

//////////////////////////////////////////////////////////// Monkey Block
	if (isblockon(getblock(M.dna.struc_enzymes, 14,3),14) && istype(M, /mob/living/carbon/human))
	// human > monkey
		var/list/implants = list() //Try to preserve implants.
		for(var/obj/item/weapon/implant/W in M)
			if (istype(W, /obj/item/weapon/implant))
				implants += W
		for(var/obj/item/weapon/W in M)
			M.u_equip(W)
			if (M.client)
				M.client.screen -= W
			if (W)
				W.loc = M.loc
				W.dropped(M)
				W.layer = initial(W.layer)
		for(var/obj/item/clothing/C)
			C.dropped(M)
			if (M.client)
				M.client.screen -= C
		if(!connected)
			M.update_clothing()
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new /atom/movable/overlay( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'mob.dmi'
			animation.master = src
			flick("h2monkey", animation)
			sleep(48 )
			del(animation)

		var/mob/living/carbon/monkey/O = new /mob/living/carbon/monkey(src)
		O.dna = M.dna
		M.dna = null

		for(var/obj/T in M)
			del(T)
		for(var/R in M.organs)
			del(M.organs["[R]"])

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null
		O.name = "monkey ([copytext(md5(M.real_name), 2, 6)])"
		O.toxloss += (M.toxloss + 20)
		O.bruteloss += (M.bruteloss + 40)
		O.oxyloss += M.oxyloss
		O.fireloss += M.fireloss
		O.stat = M.stat
		O.a_intent = "hurt"
		for (var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O
			continue
		del(M)
		return

	if (!isblockon(getblock(M.dna.struc_enzymes, 14,3),14) && !istype(M, /mob/living/carbon/human))
	// monkey > human
		var/list/implants = list()
		for (var/obj/item/weapon/implant/I in M) //Still preserving implants
			implants += I

		if(!connected)
			for(var/obj/item/weapon/W in M)
				M.u_equip(W)
				if (M.client)
					M.client.screen -= W
				if (W)
					W.loc = M.loc
					W.dropped(M)
					W.layer = initial(W.layer)
			M.update_clothing()
			M.monkeyizing = 1
			M.canmove = 0
			M.icon = null
			M.invisibility = 101
			var/atom/movable/overlay/animation = new /atom/movable/overlay( M.loc )
			animation.icon_state = "blank"
			animation.icon = 'mob.dmi'
			animation.master = src
			flick("monkey2h", animation)
			sleep(48 )
			del(animation)

		var/mob/living/carbon/human/O = new /mob/living/carbon/human( src )
		if (isblockon(getblock(M.dna.uni_identity, 11,3),11))
			O.gender = FEMALE
		else
			O.gender = MALE
		O.dna = M.dna
		M.dna = null

		for(var/obj/T in M)
			del(T)

		O.loc = M.loc

		if(M.mind)
			M.mind.transfer_to(O)

		if (connected) //inside dna thing
			var/obj/machinery/dna_scannernew/C = connected
			O.loc = C
			C.occupant = O
			connected = null

		var/i
		while (!i)
			var/randomname
			if (O.gender == MALE)
				randomname = capitalize(pick(first_names_male) + " " + capitalize(pick(last_names)))
			else
				randomname = capitalize(pick(first_names_female) + " " + capitalize(pick(last_names)))
			if (findname(randomname))
				continue
			else
				O.real_name = randomname
				i++
		updateappearance(O,O.dna.uni_identity)
	//	O.toxloss += M.toxloss
	//	O.bruteloss += M.bruteloss
	//	O.oxyloss += M.oxyloss
	//	O.fireloss += M.fireloss
	//	O.stat = M.stat
		for (var/obj/item/weapon/implant/I in implants)
			I.loc = O
			I.implanted = O
			continue

		O.update_clothing()
		O.toxloss += (M.toxloss + 20)
		O.bruteloss += (M.bruteloss + 40)
		O.oxyloss += M.oxyloss
		del(M)
		return
//////////////////////////////////////////////////////////// Monkey Block
	if (M) M.update_clothing()
	return null
/////////////////////////// DNA MISC-PROCS


/////////////////////////// DNA MACHINES
/*/obj/machinery/dna_scannernew/allow_drop()
	return 0*/

/obj/machinery/dna_scannernew/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.go_out()
	return

/obj/machinery/dna_scannernew/verb/eject()
	set src in oview(1)

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/verb/move_inside()
	set src in oview(1)

	if (usr.stat != 0)
		return
	if (src.occupant)
		usr << "\blue <B>The scanner is already occupied!</B>"
		return
	if (usr.abiotic())
		usr << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	usr.pulling = null
	usr.client.perspective = EYE_PERSPECTIVE
	usr.client.eye = src
	usr.loc = src
	src.occupant = usr
	src.icon_state = "scanner_1"
	for(var/obj/O in src)
		//O = null
		del(O)
		//Foreach goto(124)
	src.add_fingerprint(usr)
	return

/obj/machinery/dna_scannernew/attackby(obj/item/weapon/grab/G as obj, user as mob)
	if ((!( istype(G, /obj/item/weapon/grab) ) || !( ismob(G.affecting) )))
		return
	if (src.occupant)
		user << "\blue <B>The scanner is already occupied!</B>"
		return
	if (G.affecting.abiotic())
		user << "\blue <B>Subject cannot have abiotic items on.</B>"
		return
	var/mob/M = G.affecting
	if (M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = src
	M.loc = src
	src.occupant = M
	src.icon_state = "scanner_1"
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(154)
	src.add_fingerprint(user)
	//G = null
	del(G)
	return

/obj/machinery/dna_scannernew/proc/go_out()
	if ((!( src.occupant ) || src.locked))
		return
	for(var/obj/O in src)
		O.loc = src.loc
		//Foreach goto(30)
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	src.icon_state = "scanner_0"
	return

/obj/machinery/dna_scannernew/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
				//Foreach goto(35)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(108)
				//SN src = null
				del(src)
				return
		if(3.0)
			if (prob(25))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
					//Foreach goto(181)
				//SN src = null
				del(src)
				return
		else
	return


/obj/machinery/dna_scannernew/blob_act()
	if(prob(50))
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.loc
		del(src)

/obj/machinery/scan_consolenew/ex_act(severity)

	switch(severity)
		if(1.0)
			//SN src = null
			del(src)
			return
		if(2.0)
			if (prob(50))
				//SN src = null
				del(src)
				return
		else
	return

/obj/machinery/scan_consolenew/blob_act()

	if(prob(50))
		del(src)

/obj/machinery/scan_consolenew/power_change()
	if(stat & BROKEN)
		icon_state = "broken"
	else if(powered())
		icon_state = initial(icon_state)
		stat &= ~NOPOWER
	else
		spawn(rand(0, 15))
			src.icon_state = "c_unpowered"
			stat |= NOPOWER

/obj/machinery/scan_consolenew/New()
	..()
	spawn( 5 )
		src.connected = locate(/obj/machinery/dna_scannernew, get_step(src, WEST))
		return
	return

/obj/machinery/scan_consolenew/attackby(obj/item/W as obj, mob/user as mob)
	if ((istype(W, /obj/item/weapon/disk/data/genetics)) && (!src.diskette))
		user.drop_item()
		W.loc = src
		src.diskette = W
		user << "You insert [W]."
		src.updateUsrDialog()

/obj/machinery/scan_consolenew/process() //not really used right now
	if(stat & (NOPOWER|BROKEN))
		return
	use_power(250) // power stuff
	if (!( src.status )) //remove this
		return
	return

/obj/machinery/scan_consolenew/attack_paw(user as mob)
	return src.attack_hand(user)

/obj/machinery/scan_consolenew/attack_ai(user as mob)
	return src.attack_hand(user)

/obj/machinery/scan_consolenew/attack_hand(user as mob)
	if(..())
		return
	var/dat
	if (src.delete && src.temphtml) //Window in buffer but its just simple message, so nothing
		src.delete = src.delete

	else if (!src.delete && src.temphtml) //Window in buffer - its a menu, dont add clear message
		dat = "[src.temphtml]<BR><BR><A href='?src=\ref[src];clear=1'>Main Menu</A>"
	else
		if (src.connected) //Is something connected?
			var/mob/occupant = src.connected.occupant
			dat = "<font color='blue'><B>Occupant Statistics:</B></FONT><BR>" //Blah obvious
			if (occupant) //is there REALLY someone in there?
				if (!istype(occupant,/mob/living/carbon/human))
					sleep(1)
				var/t1
				switch(occupant.stat) // obvious, see what their status is
					if(0)
						t1 = "Conscious"
					if(1)
						t1 = "Unconscious"
					else
						t1 = "*dead*"
				dat += text("[]\tHealth %: [] ([])</FONT><BR>", (occupant.health > 50 ? "<font color='blue'>" : "<font color='red'>"), occupant.health, t1)
				dat += text("<font color='green'>Radiation Level: []%</FONT><BR><BR>", occupant.radiation)
				dat += text("Unique Enzymes : <font color='blue'>[]</FONT><BR>", uppertext(occupant.dna.unique_enzymes))
				dat += text("Unique Identifier: <font color='blue'>[]</FONT><BR>", occupant.dna.uni_identity)
				dat += text("Structural Enzymes: <font color='blue'>[]</FONT><BR><BR>", occupant.dna.struc_enzymes)
				dat += text("<A href='?src=\ref[];unimenu=1'>Modify Unique Identifier</A><BR>", src)
				dat += text("<A href='?src=\ref[];strucmenu=1'>Modify Structural Enzymes</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];genpulse=1'>Pulse Radiation</A><BR>", src)
				dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];rejuv=1'>Inject Rejuvenators</A><BR><BR>", src)
			else
				dat += "The scanner is empty.<BR><BR>"
				dat += text("<A href='?src=\ref[];buffermenu=1'>View/Edit/Transfer Buffer</A><BR><BR>", src)
				dat += text("<A href='?src=\ref[];radset=1'>Radiation Emitter Settings</A><BR><BR>", src)
			if (!( src.connected.locked ))
				dat += text("<A href='?src=\ref[];locked=1'>Lock (Unlocked)</A><BR>", src)
			else
				dat += text("<A href='?src=\ref[];locked=1'>Unlock (Locked)</A><BR>", src)
				//Other stuff goes here
			if (!isnull(src.diskette))
				dat += text("<A href='?src=\ref[];eject_disk=1'>Eject Disk</A><BR>", src)
			dat += text("<BR><BR><A href='?src=\ref[];mach_close=scannernew'>Close</A>", user)
		else
			dat = "<font color='red'> Error: No DNA Modifier connected. </FONT>"
	user << browse(dat, "window=scannernew;size=1000x625")
	onclose(user, "scannernew")
	return

/obj/machinery/scan_consolenew/Topic(href, href_list)
	if(..())
		return
	if ((usr.contents.Find(src) || in_range(src, usr) && istype(src.loc, /turf)) || (istype(usr, /mob/living/silicon)))
		usr.machine = src
		if (href_list["locked"])
			if ((src.connected && src.connected.occupant))
				src.connected.locked = !( src.connected.locked )
		////////////////////////////////////////////////////////
		if (href_list["genpulse"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=1000x625")
				return
			src.delete = 1
			src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
			usr << browse(temphtml, "window=scannernew;size=1000x650")
			onclose(usr, "scannernew")
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			if (prob(95))
				if(prob(75))
					randmutb(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			else
				if(prob(95))
					randmutg(src.connected.occupant)
				else
					randmuti(src.connected.occupant)
			src.connected.occupant.radiation += ((src.radstrength*3)+src.radduration*3)
			temphtml = null
			delete = 0
		if (href_list["radset"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=1000x625")
				return
			src.temphtml = text("Radiation Duration: <B><font color='green'>[]</B></FONT><BR>", src.radduration)
			src.temphtml += text("Radiation Intensity: <font color='green'><B>[]</B></FONT><BR><BR>", src.radstrength)
			src.temphtml += text("<A href='?src=\ref[];radleminus=1'>--</A> Duration <A href='?src=\ref[];radleplus=1'>++</A><BR>", src, src)
			src.temphtml += text("<A href='?src=\ref[];radinminus=1'>--</A> Intesity <A href='?src=\ref[];radinplus=1'>++</A><BR>", src, src)
			src.delete = 0
		if (href_list["radleplus"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=1000x625")
				return
			if (src.radduration < 20)
				src.radduration++
				src.radduration++
			dopage(src,"radset")
		if (href_list["radleminus"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=1000x625")
				return
			if (src.radduration > 2)
				src.radduration--
				src.radduration--
			dopage(src,"radset")
		if (href_list["radinplus"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=1000x625")
				return
			if (src.radstrength < 10)
				src.radstrength++
			dopage(src,"radset")
		if (href_list["radinminus"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=550x625")
				return
			if (src.radstrength > 1)
				src.radstrength--
			dopage(src,"radset")
		////////////////////////////////////////////////////////
		if (href_list["unimenu"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=550x625")
				return
			//src.temphtml = text("Unique Identifier: <font color='blue'>[]</FONT><BR><BR>", src.connected.occupant.dna.uni_identity)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			src.temphtml = text("Unique Identifier: <font color='blue'>[getleftblocks(src.connected.occupant.dna.uni_identity,uniblock,3)][src.subblock == 1 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1)][src.subblock == 2 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1)][src.subblock == 3 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)][getrightblocks(src.connected.occupant.dna.uni_identity,uniblock,3)]</FONT><BR><BR>")
			src.temphtml += text("Selected Block: <font color='blue'><B>[]</B></FONT><BR>", src.uniblock)
			src.temphtml += text("<A href='?src=\ref[];unimenuminus=1'><-</A> Block <A href='?src=\ref[];unimenuplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", src.subblock)
			src.temphtml += text("<A href='?src=\ref[];unimenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];unimenusubplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += "<B>Modify Block:</B><BR>"
			src.temphtml += text("<A href='?src=\ref[];unipulse=1'>Radiation</A><BR>", src)
			src.delete = 0
		if (href_list["unimenuplus"])
			if (src.uniblock < 13)
				src.uniblock++
			dopage(src,"unimenu")
		if (href_list["unimenuminus"])
			if (src.uniblock > 1)
				src.uniblock--
			dopage(src,"unimenu")
		if (href_list["unimenusubplus"])
			if (src.subblock < 3)
				src.subblock++
			dopage(src,"unimenu")
		if (href_list["unimenusubminus"])
			if (src.subblock > 1)
				src.subblock--
			dopage(src,"unimenu")
		if (href_list["unipulse"])
			var/block
			var/newblock
			var/tstructure2
			block = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),src.subblock,1)
			src.delete = 1
			src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			///
			if (prob((80 + (src.radduration / 2))))
				block = miniscramble(block, src.radstrength, src.radduration)
				newblock = null
				if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)
				if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),3,1)
				if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.uni_identity,src.uniblock,3),2,1) + block
				tstructure2 = setblock(src.connected.occupant.dna.uni_identity, src.uniblock, newblock,3)
				src.connected.occupant.dna.uni_identity = tstructure2
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
				src.connected.occupant.radiation += (src.radstrength+src.radduration)
			else
				if	(prob(20+src.radstrength))
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
				src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
			dopage(src,"unimenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["rejuv"])
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			var/mob/living/carbon/human/H = src.connected.occupant
			if (H.reagents.get_reagent_amount("inaprovaline") < 60)
				H.reagents.add_reagent("inaprovaline", 30)
			usr << text("Occupant now has [] units of inaprovaline in \his bloodstream.", H.reagents.get_reagent_amount("inaprovaline"))
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["strucmenu"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=550x625")
				return
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			src.temphtml = text("Structural Enzymes: <font color='blue'>[getleftblocks(src.connected.occupant.dna.struc_enzymes,strucblock,3)][src.subblock == 1 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1)][src.subblock == 2 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1)][src.subblock == 3 ? "<U><B>"+getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)+"</U></B>" : getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)][getrightblocks(src.connected.occupant.dna.struc_enzymes,strucblock,3)]</FONT><BR><BR>")
			//src.temphtml = text("Structural Enzymes: <font color='blue'>[]</FONT><BR><BR>", src.connected.occupant.dna.struc_enzymes)
			src.temphtml += text("Selected Block: <font color='blue'><B>[src.strucblock]</B></FONT><BR>")
			src.temphtml += text("<A href='?src=\ref[];strucmenuminus=1'><-</A> <A href='?src=\ref[src];setblock=1'>Block</A> <A href='?src=\ref[];strucmenuplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += text("Selected Sub-Block: <font color='blue'><B>[]</B></FONT><BR>", src.subblock)
			src.temphtml += text("<A href='?src=\ref[];strucmenusubminus=1'><-</A> Sub-Block <A href='?src=\ref[];strucmenusubplus=1'>-></A><BR><BR>", src, src)
			src.temphtml += "<B>Modify Block:</B><BR>"
			src.temphtml += text("<A href='?src=\ref[];strucpulse=1'>Radiation</A><BR>", src)
			src.delete = 0
		if (href_list["setblock"])
			var/i = text2num(input("Which block do you want to select ?"))
			if(i>0 && i<STRUCDNASIZE)
				src.strucblock = i

		if (href_list["strucmenuplus"])
			if (src.strucblock < STRUCDNASIZE)
				src.strucblock++
			dopage(src,"strucmenu")
		if (href_list["strucmenuminus"])
			if (src.strucblock > 1)
				src.strucblock--
			dopage(src,"strucmenu")
		if (href_list["strucmenusubplus"])
			if (src.subblock < 3)
				src.subblock++
			dopage(src,"strucmenu")
		if (href_list["strucmenusubminus"])
			if (src.subblock > 1)
				src.subblock--
			dopage(src,"strucmenu")
		if (href_list["strucpulse"])
			var/block
			var/newblock
			var/tstructure2
			var/oldblock
			block = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),src.subblock,1)
			src.delete = 1
			src.temphtml = text("Working ... Please wait ([] Seconds)", src.radduration)
			usr << browse(temphtml, "window=scannernew;size=550x650")
			onclose(usr, "scannernew")
			sleep(10*src.radduration)
			if (!src.connected.occupant)
				temphtml = null
				delete = 0
				return null
			///
			if (prob((80 + (src.radduration / 2))))
				if ((src.strucblock != 2 || src.strucblock != 12 || src.strucblock != 8 || src.strucblock || 10) && prob (20))
					oldblock = src.strucblock
					block = miniscramble(block, src.radstrength, src.radduration)
					newblock = null
					if (src.strucblock > 1 && src.strucblock < 5)
						src.strucblock++
					else if (src.strucblock > 5 && src.strucblock < STRUCDNASIZE)
						src.strucblock--
					if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + block
					tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.strucblock, newblock,3)
					src.connected.occupant.dna.struc_enzymes = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radstrength+src.radduration)
					src.strucblock = oldblock
				else
					//
					block = miniscramble(block, src.radstrength, src.radduration)
					newblock = null
					if (src.subblock == 1) newblock = block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 2) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + block + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),3,1)
					if (src.subblock == 3) newblock = getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),1,1) + getblock(getblock(src.connected.occupant.dna.struc_enzymes,src.strucblock,3),2,1) + block
					tstructure2 = setblock(src.connected.occupant.dna.struc_enzymes, src.strucblock, newblock,3)
					src.connected.occupant.dna.struc_enzymes = tstructure2
					domutcheck(src.connected.occupant,src.connected)
					src.connected.occupant.radiation += (src.radstrength+src.radduration)
			else
				if	(prob(80-src.radduration))
					randmutb(src.connected.occupant)
					domutcheck(src.connected.occupant,src.connected)
				else
					randmuti(src.connected.occupant)
					updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
				src.connected.occupant.radiation += ((src.radstrength*2)+src.radduration)
			///
			dopage(src,"strucmenu")
			src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["buffermenu"])
			if(src.connected.occupant == usr)
				usr << browse(null, "window=scannernew;size=550x625")
				return
			src.temphtml = "<B>Buffer 1:</B><BR>"
			if (!(src.buffer1))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer1)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer1owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer1label)
			if (src.connected.occupant) src.temphtml += text("Save : <A href='?src=\ref[];b1addui=1'>UI</A> - <A href='?src=\ref[];b1adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b1addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer1) src.temphtml += text("Transfer to: <A href='?src=\ref[];b1transfer=1'>Occupant</A> - <A href='?src=\ref[];b1injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1iso=1'>Isolate Block</A><BR>", src)
			if (src.diskette) src.temphtml += "Disk: <A href='?src=\ref[src];save_disk=1'>Save To</a> | <A href='?src=\ref[src];load_disk=1'>Load From</a><br>"
			if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1label=1'>Edit Label</A><BR>", src)
			if (src.buffer1) src.temphtml += text("<A href='?src=\ref[];b1clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer1) src.temphtml += "<BR>"
			src.temphtml += "<B>Buffer 2:</B><BR>"
			if (!(src.buffer2))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer2)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer2owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer2label)
			if (src.connected.occupant) src.temphtml += text("Save : <A href='?src=\ref[];b2addui=1'>UI</A> - <A href='?src=\ref[];b2adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b2addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer2) src.temphtml += text("Transfer to: <A href='?src=\ref[];b2transfer=1'>Occupant</A> - <A href='?src=\ref[];b2injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2iso=1'>Isolate Block</A><BR>", src)
			if (src.diskette) src.temphtml += "Disk: <A href='?src=\ref[src];save_disk=2'>Save To</a> | <A href='?src=\ref[src];load_disk=2'>Load From</a><br>"
			if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2label=1'>Edit Label</A><BR>", src)
			if (src.buffer2) src.temphtml += text("<A href='?src=\ref[];b2clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer2) src.temphtml += "<BR>"
			src.temphtml += "<B>Buffer 3:</B><BR>"
			if (!(src.buffer3))
				src.temphtml += "Buffer Empty<BR>"
			else
				src.temphtml += text("Data: <font color='blue'>[]</FONT><BR>", src.buffer3)
				src.temphtml += text("By: <font color='blue'>[]</FONT><BR>", src.buffer3owner)
				src.temphtml += text("Label: <font color='blue'>[]</FONT><BR>", src.buffer3label)
			if (src.connected.occupant) src.temphtml += text("Save : <A href='?src=\ref[];b3addui=1'>UI</A> - <A href='?src=\ref[];b3adduiue=1'>UI+UE</A> - <A href='?src=\ref[];b3addse=1'>SE</A><BR>", src, src, src)
			if (src.buffer3) src.temphtml += text("Transfer to: <A href='?src=\ref[];b3transfer=1'>Occupant</A> - <A href='?src=\ref[];b3injector=1'>Injector</A><BR>", src, src)
			//if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3iso=1'>Isolate Block</A><BR>", src)
			if (src.diskette) src.temphtml += "Disk: <A href='?src=\ref[src];save_disk=3'>Save To</a> | <A href='?src=\ref[src];load_disk=3'>Load From</a><br>"
			if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3label=1'>Edit Label</A><BR>", src)
			if (src.buffer3) src.temphtml += text("<A href='?src=\ref[];b3clear=1'>Clear Buffer</A><BR><BR>", src)
			if (!src.buffer3) src.temphtml += "<BR>"
		if (href_list["b1addui"])
			src.buffer1iue = 0
			src.buffer1 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Unique Identifier"
			src.buffer1type = "ui"
			dopage(src,"buffermenu")
		if (href_list["b1adduiue"])
			src.buffer1 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Unique Identifier & Unique Enzymes"
			src.buffer1type = "ui"
			src.buffer1iue = 1
			dopage(src,"buffermenu")
		if (href_list["b2adduiue"])
			src.buffer2 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer2owner = src.connected.occupant.name
			else
				src.buffer2owner = src.connected.occupant.real_name
			src.buffer2label = "Unique Identifier & Unique Enzymes"
			src.buffer2type = "ui"
			src.buffer2iue = 1
			dopage(src,"buffermenu")
		if (href_list["b3adduiue"])
			src.buffer3 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Unique Identifier & Unique Enzymes"
			src.buffer3type = "ui"
			src.buffer3iue = 1
			dopage(src,"buffermenu")
		if (href_list["b2addui"])
			if(src.connected.occupant)
				src.buffer2iue = 0
				src.buffer2 = src.connected.occupant.dna.uni_identity
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer2owner = src.connected.occupant.name
				else
					src.buffer2owner = src.connected.occupant.real_name
				src.buffer2label = "Unique Identifier"
				src.buffer2type = "ui"
			dopage(src,"buffermenu")
		if (href_list["b3addui"])
			src.buffer3iue = 0
			src.buffer3 = src.connected.occupant.dna.uni_identity
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Unique Identifier"
			src.buffer3type = "ui"
			dopage(src,"buffermenu")
		if (href_list["b1addse"])
			src.buffer1iue = 0
			src.buffer1 = src.connected.occupant.dna.struc_enzymes
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer1owner = src.connected.occupant.name
			else
				src.buffer1owner = src.connected.occupant.real_name
			src.buffer1label = "Structural Enzymes"
			src.buffer1type = "se"
			dopage(src,"buffermenu")
		if (href_list["b2addse"])
			if(src.connected.occupant)
				src.buffer2iue = 0
				src.buffer2 = src.connected.occupant.dna.struc_enzymes
				if (!istype(src.connected.occupant,/mob/living/carbon/human))
					src.buffer2owner = src.connected.occupant.name
				else
					src.buffer2owner = src.connected.occupant.real_name
				src.buffer2label = "Structural Enzymes"
				src.buffer2type = "se"
			dopage(src,"buffermenu")
		if (href_list["b3addse"])
			src.buffer3iue = 0
			src.buffer3 = src.connected.occupant.dna.struc_enzymes
			if (!istype(src.connected.occupant,/mob/living/carbon/human))
				src.buffer3owner = src.connected.occupant.name
			else
				src.buffer3owner = src.connected.occupant.real_name
			src.buffer3label = "Structural Enzymes"
			src.buffer3type = "se"
			dopage(src,"buffermenu")
		if (href_list["b1clear"])
			src.buffer1 = null
			src.buffer1owner = null
			src.buffer1label = null
			src.buffer1iue = null
			dopage(src,"buffermenu")
		if (href_list["b2clear"])
			src.buffer2 = null
			src.buffer2owner = null
			src.buffer2label = null
			src.buffer2iue = null
			dopage(src,"buffermenu")
		if (href_list["b3clear"])
			src.buffer3 = null
			src.buffer3owner = null
			src.buffer3label = null
			src.buffer3iue = null
			dopage(src,"buffermenu")
		if (href_list["b1label"])
			src.buffer1label = input("New Label:","Edit Label","Infos here")
			dopage(src,"buffermenu")
		if (href_list["b2label"])
			src.buffer2label = input("New Label:","Edit Label","Infos here")
			dopage(src,"buffermenu")
		if (href_list["b3label"])
			src.buffer3label = input("New Label:","Edit Label","Infos here")
			dopage(src,"buffermenu")
		if (href_list["b1transfer"])
			if (!src.connected.occupant)
				return
			if (src.buffer1type == "ui")
				if (src.buffer1iue)
					src.connected.occupant.real_name = src.buffer1owner
					src.connected.occupant.name = src.buffer1owner
				src.connected.occupant.dna.uni_identity = src.buffer1
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			else if (src.buffer1type == "se")
				src.connected.occupant.dna.struc_enzymes = src.buffer1
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b2transfer"])
			if (!src.connected.occupant)
				return
			if (src.buffer2type == "ui")
				if (src.buffer2iue)
					src.connected.occupant.real_name = src.buffer2owner
					src.connected.occupant.name = src.buffer2owner
				src.connected.occupant.dna.uni_identity = src.buffer2
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			else if (src.buffer2type == "se")
				src.connected.occupant.dna.struc_enzymes = src.buffer2
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b3transfer"])
			if (!src.connected.occupant)
				return
			if (src.buffer3type == "ui")
				if (src.buffer3iue)
					src.connected.occupant.real_name = src.buffer3owner
					src.connected.occupant.name = src.buffer3owner
				src.connected.occupant.dna.uni_identity = src.buffer3
				updateappearance(src.connected.occupant,src.connected.occupant.dna.uni_identity)
			else if (src.buffer3type == "se")
				src.connected.occupant.dna.struc_enzymes = src.buffer3
				domutcheck(src.connected.occupant,src.connected)
			src.temphtml = "Transfered."
			src.connected.occupant.radiation += rand(20,50)
			src.delete = 0
		if (href_list["b1injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer1
				I.dnatype = src.buffer1type
				I.loc = src.loc
				I.name += " ([src.buffer1label])"
				if (src.buffer1iue) I.ue = src.buffer1owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				spawn(1200)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		if (href_list["b2injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer2
				I.dnatype = src.buffer2type
				I.loc = src.loc
				I.name += " ([src.buffer2label])"
				if (src.buffer2iue) I.ue = src.buffer2owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				spawn(1200)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		if (href_list["b3injector"])
			if (src.injectorready)
				var/obj/item/weapon/dnainjector/I = new /obj/item/weapon/dnainjector
				I.dna = src.buffer3
				I.dnatype = src.buffer3type
				I.loc = src.loc
				I.name += " ([src.buffer3label])"
				if (src.buffer3iue) I.ue = src.buffer3owner //lazy haw haw
				src.temphtml = "Injector created."
				src.delete = 0
				src.injectorready = 0
				spawn(1200)
					src.injectorready = 1
			else
				src.temphtml = "Replicator not ready yet."
				src.delete = 0
		////////////////////////////////////////////////////////
		if (href_list["load_disk"])
			var/buffernum = text2num(href_list["load_disk"])
			if ((buffernum > 3) || (buffernum < 1))
				return
			if ((isnull(src.diskette)) || (!src.diskette.data) || (src.diskette.data == ""))
				return
			switch(buffernum)
				if(1)
					src.buffer1 = src.diskette.data
					src.buffer1type = src.diskette.data_type
					src.buffer1iue = src.diskette.ue
					src.buffer1owner = src.diskette.owner
				if(2)
					src.buffer2 = src.diskette.data
					src.buffer2type = src.diskette.data_type
					src.buffer2iue = src.diskette.ue
					src.buffer2owner = src.diskette.owner
				if(3)
					src.buffer3 = src.diskette.data
					src.buffer3type = src.diskette.data_type
					src.buffer3iue = src.diskette.ue
					src.buffer3owner = src.diskette.owner
			src.temphtml = "Data loaded."

		if (href_list["save_disk"])
			var/buffernum = text2num(href_list["save_disk"])
			if ((buffernum > 3) || (buffernum < 1))
				return
			if ((isnull(src.diskette)) || (src.diskette.read_only))
				return
			var/saved = 1
			switch(buffernum)
				if(1)
					if(!buffer1)
						saved = 0
					else
						src.diskette.data = buffer1
						src.diskette.data_type = src.buffer1type
						src.diskette.ue = src.buffer1iue
						src.diskette.owner = src.buffer1owner
						src.diskette.name = "data disk - '[src.buffer1owner]'"
				if(2)
					if(!buffer2)
						saved = 0
					else
						src.diskette.data = buffer2
						src.diskette.data_type = src.buffer2type
						src.diskette.ue = src.buffer2iue
						src.diskette.owner = src.buffer2owner
						src.diskette.name = "data disk - '[src.buffer2owner]'"
				if(3)
					if(!buffer3)
						saved = 0
					else
						src.diskette.data = buffer3
						src.diskette.data_type = src.buffer3type
						src.diskette.ue = src.buffer3iue
						src.diskette.owner = src.buffer3owner
						src.diskette.name = "data disk - '[src.buffer3owner]'"
			if(!saved)
				src.temphtml = "\red ERROR:Data equals null"
			else
				src.temphtml = "Data saved."
		if (href_list["eject_disk"])
			if (!src.diskette)
				return
			src.diskette.loc = get_turf(src)
			src.diskette = null
		////////////////////////////////////////////////////////
		if (href_list["clear"])
			src.temphtml = null
			src.delete = 0
		if (href_list["update"]) //ignore
			src.temphtml = src.temphtml
		src.add_fingerprint(usr)
		src.updateUsrDialog()
	return
/////////////////////////// DNA MACHINES