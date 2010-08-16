/mob
	density = 1
	layer = 4.0
	animate_movement = 2
	var/datum/mind/mind

	var/uses_hud = 0
	var/obj/screen/flash = null
	var/obj/screen/blind = null
	var/obj/screen/hands = null
	var/obj/screen/mach = null
	var/obj/screen/sleep = null
	var/obj/screen/rest = null
	var/obj/screen/pullin = null
	var/obj/screen/internals = null
	var/obj/screen/oxygen = null
	var/obj/screen/i_select = null
	var/obj/screen/m_select = null
	var/obj/screen/toxin = null
	var/obj/screen/fire = null
	var/obj/screen/bodytemp = null
	var/obj/screen/healths = null
	var/obj/screen/throw_icon = null
	var/obj/screen/panel_icon = null
	var/obj/screen/cell_icon = null
	var/obj/screen/exttemp = null
	var/obj/screen/store = null
	var/obj/screen/module_icon = null

	var/list/obj/hallucinations = list()
	var/halloss = 0
	var/hallucination = 0

	var/alien_egg_flag = 0

	var/last_special = 0

	var/obj/screen/zone_sel/zone_sel = null

	var/emote_allowed = 1
	var/computer_id = null
	var/lastattacker = null
	var/lastattacked = null
	var/already_placed = 0.0
	var/obj/machinery/machine = null
	var/other_mobs = null
	var/memory = ""
	var/poll_answer = 0.0
	var/sdisabilities = 0
	var/disabilities = 0
	var/atom/movable/pulling = null
	var/stat = 0.0
	var/next_move = null
	var/prev_move = null
	var/monkeyizing = null
	var/other = 0.0
	var/hand = null
	var/eye_blind = null
	var/eye_blurry = null
	var/ear_deaf = null
	var/ear_damage = null
	var/stuttering = null
	var/intoxicated = null
	var/real_name = null
	var/blinded = null
	var/rejuv = null
	var/druggy = 0
	var/confused = 0
	var/staggering = 0
	var/antitoxs = null
	var/plasma = null
	var/sleeping = 0.0
	var/resting = 0.0
	var/lying = 0.0
	var/canmove = 1.0
	var/eye_stat = null
	var/oxyloss = 0.0
	var/toxloss = 0.0
	var/fireloss = 0.0
	var/timeofdeath = 0.0
	var/bruteloss = 0.0
	var/cpr_time = 1.0
	var/health = 100
	var/bodytemperature = 310.055	//98.7 F
	var/drowsyness = 0.0
	var/dizziness = 0
	var/is_dizzy = 0
	var/is_jittery = 0
	var/jitteriness = 0
	var/charges = 0.0
	var/urine = 0.0
	var/poo = 0.0
	var/nutrition = 0.0
	var/paralysis = 0.0
	var/stunned = 0.0
	var/weakened = 0.0
	var/losebreath = 0.0
	var/muted = null
	var/intent = null
	var/shakecamera = 0
	var/a_intent = "help"
	var/m_int = null
	var/m_intent = "run"
	var/lastDblClick = 0
	var/lastKnownIP = null
	var/obj/stool/buckled = null
	var/obj/item/weapon/handcuffs/handcuffed = null
	var/obj/item/l_hand = null
	var/obj/item/r_hand = null
	var/obj/item/weapon/back = null
	var/obj/item/weapon/tank/internal = null
	var/obj/item/weapon/storage/s_active = null
	var/obj/item/clothing/mask/wear_mask = null
	var/r_epil = 0
	var/r_ch_cou = 0
	var/r_Tourette = 0

	var/obj/hud/hud_used = null

	var/list/organs = list(  )
	var/list/grabbed_by = list(  )
	var/list/requests = list(  )

	var/list/mapobjs = list()

	var/in_throw_mode = 0

	var/coughedtime = null

	var/inertia_dir = 0
	var/footstep = 1

	var/music_lastplayed = "null"

	var/job = null

	var/nodamage = 0
	var/logged_in = 0

	var/underwear = 1
	var/be_syndicate = 0
	var/be_random_name = 0
	var/const/blindness = 1
	var/const/deafness = 2
	var/const/muteness = 4
	var/brainloss = 0


	var/datum/dna/dna = null
	var/radiation = 0.0

	var/mutations = 0
	//telekinesis = 1
	//firemut = 2
	//xray = 4
	//hulk = 8
	//clumsy = 16
	//obese = 32
	//husk = 64

	var/voice_name = "unidentifiable voice"
	var/voice_message = null

//Monkey/infected mode
	var/list/resistances = list()
	var/datum/disease/virus = null

	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

//Changeling mode stuff
	var/changeling_level = 0
	var/list/absorbed_dna = list()
	var/changeling_fakedeath = 0