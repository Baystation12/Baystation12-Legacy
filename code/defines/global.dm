var/global
	obj/datacore/data_core = null
	obj/overlay/plmaster = null
	obj/overlay/slmaster = null

	//obj/hud/main_hud1 = null

	list/machines = list()
	list/processing_items = list()
	list/processing_others = list() // The few exceptions that don't fit in the other lists
	list/processing_turfs = list()
		//items that ask to be called every cycle

	defer_cables_rebuild = 0		// true if all unified networks will be rebuilt on post-event

var

	//////////////

	BLINDBLOCK = 0
	DEAFBLOCK = 0
	HULKBLOCK = 0
	TELEBLOCK = 0
	FIREBLOCK = 0
	XRAYBLOCK = 0
	CLUMSYBLOCK = 0
	FAKEBLOCK = 0
	BLOCKADD = 0
	DIFFMUT = 0
	HEADACHEBLOCK = 0
	COUGHBLOCK = 0
	TWITCHBLOCK = 0
	NERVOUSBLOCK = 0
	NOBREATHBLOCK = 0
	REMOTEVIEWBLOCK = 0
	REGENERATEBLOCK = 0
	INCREASERUNBLOCK = 0
	REMOTETALKBLOCK = 0
	MORPHBLOCK = 0
	BLENDBLOCK = 0
	HALLUCINATIONBLOCK = 0
	NOPRINTSBLOCK = 0
	SHOCKIMMUNITYBLOCK = 0
	SMALLSIZEBLOCK = 0


	skipupdate = 0
	///////////////
	eventchance = 1 //% per 2 mins
	EventsOn = 1
	event = 0
	hadevent = 0
	blobevent = 0
	///////////////

	diary = null
	current_date = time2text(world.realtime, "YYYYMMDD")
	station_name = null
	game_version = "Baystation"

	datum/air_tunnel/air_tunnel1/SS13_airtunnel = null
	master_mode = "traitor"

	datum/engine_eject/engine_eject_control = null
	host = null
	aliens_allowed = 0
	ooc_allowed = 1
	traitor_scaling = 1
	dna_ident = 1
	abandon_allowed = 1
	enter_allowed = 1
	shuttle_frozen = 0
	shuttle_left = 0
	delay_start = 0



	datum/PodControl/LaunchControl = new /datum/PodControl()

	captainMax = 1
	engineerMax = 5
	barmanMax = 2
	scientistMax = 3
	chemistMax = 1
	geneticistMax = 2
	securityMax = 7
	hopMax = 1
	hosMax = 1
	directorMax = 1
	chiefMax = 1
	atmosMax = 4
	detectiveMax = 1
	CounselorMax = 1
	janitorMax = 2
	doctorMax = 4
	clownMax = 0
	chefMax = 1
	roboticsMax = 3
	cargoMax = 3
	hydroponicsMax = 1

	list/bombers = list(  )
	list/admin_log = list (  )
	list/lastsignalers = list(	)	//keeps last 100 signals here in format: "[src] used \ref[src] @ location [src.loc]: [freq]/[code]"
	list/admins = list(  )
	list/reg_dna = list(  )
//	list/traitobj = list(  )


	CELLRATE = 0.002  // multiplier for watts per tick <> cell storage (eg: .002 means if there is a load of 1000 watts, 20 units will be taken from a cell per second)
	CHARGELEVEL = 0.001 // Cap for how fast cells charge, as a percentage-per-tick (.001 means cellcharge is capped to 1% per second)

	shuttle_z = 2	//default
	airtunnel_start = 68 // default
	airtunnel_stop = 68 // default
	airtunnel_bottom = 72 // default
	list/monkeystart = list()
	list/wizardstart = list()
	list/newplayer_start = list()
	list/latejoin = list()
	list/derelictstart = list()
	list/prisonwarp = list()	//prisoners go to these
	list/mazewarp = list()
	list/tdome1 = list()
	list/tdome2 = list()
	list/prisonsecuritywarp = list()	//prison security goes to these
	list/prisonwarped = list()	//list of players already warped
	list/blobstart = list()
	list/blobs = list()
//	list/traitors = list()	//traitor list
	list/cardinal = list( NORTH, SOUTH, EAST, WEST )
	list/cardinal8 = list( NORTH, NORTHEAST, NORTHWEST, SOUTH, SOUTHEAST, SOUTHWEST, EAST, WEST )
	list/cardinal3d = list( NORTH, SOUTH, EAST, WEST, UP, DOWN )

	datum/station_state/start_state = null
	datum/configuration/config = null
	datum/vote/vote = null
	datum/sun/sun = null

	list/list/AllNetworks = list( )

	Debug = 0	// global debug switch
	Debug2 = 0

	datum/debug/debugobj

	datum/moduletypes/mods = new()

	wavesecret = 0

	shuttlecoming = 0

	join_motd = null
	auth_motd = null
	rules = null
	no_auth_motd = null
	forceblob = 0

	// **********************************
	//	Networking Support
	// **********************************

	//Network address generation info
	list/usedtypes = list()
	list/usedids = list()
	list/usednetids = list()

	//True if computernet rebuild will be called manually after an event
	defer_computernet_rebuild = 0

	//Computernets in the world.
	list/datum/computernet/computernets = null

	//All the passwords needed for specific network devices
	list/accesspasswords = list()

	//Routing table used for networking
	//datum/rtable/routingtable = new /datum/rtable()

	//airlockWireColorToIndex takes a number representing the wire color, e.g. the orange wire is always 1, the dark red wire is always 2, etc. It returns the index for whatever that wire does.
	//airlockIndexToWireColor does the opposite thing - it takes the index for what the wire does, for example AIRLOCK_WIRE_IDSCAN is 1, AIRLOCK_WIRE_POWER1 is 2, etc. It returns the wire color number.
	//airlockWireColorToFlag takes the wire color number and returns the flag for it (1, 2, 4, 8, 16, etc)
	list/airlockWireColorToFlag = RandomAirlockWires()
	list/airlockIndexToFlag
	list/airlockIndexToWireColor
	list/airlockWireColorToIndex
	list/APCWireColorToFlag = RandomAPCWires()
	list/APCIndexToFlag
	list/APCIndexToWireColor
	list/APCWireColorToIndex

	const/SPEED_OF_LIGHT = 3e8 //not exact but hey!
	const/SPEED_OF_LIGHT_SQ = 9e+16
	const/FIRE_DAMAGE_MODIFIER = 0.0215 //Higher values result in more external fire damage to the skin (default 0.0215)
	const/AIR_DAMAGE_MODIFIER = 2.025 //More means less damage from hot air scalding lungs, less = more damage. (default 2.025)
	const/INFINITY = 1e31 //closer then enough

	//Don't set this very much higher then 1024 unless you like inviting people in to dos your server with message spam
	const/MAX_MESSAGE_LEN = 1024
	const/MAX_PAPER_MESSAGE_LEN = 3072

	const/shuttle_time_in_station = 1800 // 3 minutes in the station
	const/shuttle_time_to_arrive = 6000 // 10 minutes to arrive

	//3D dir flags - already defined wtf?
	//const/UP = 16
	//const/DOWN = 32