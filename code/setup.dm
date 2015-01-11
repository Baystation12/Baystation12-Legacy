#define R_IDEAL_GAS_EQUATION	8.31 * 2 //kPa*L/(K*mol)
#define ONE_ATMOSPHERE		101.325	//kPa
#define IDEAL_GAS_ENTROPY_CONSTANT 	1164	//(mol^3 * s^3) / (kg^3 * L). Equal to (4*pi/(avrogadro's number * planck's constant)^2)^(3/2) / (avrogadro's number * 1000 Liters per m^3).

#define CELL_VOLUME 2500	//liters in a cell


#define O2STANDARD 0.21
#define N2STANDARD 0.79

//XGM gas flags
#define XGM_GAS_FUEL 1
#define XGM_GAS_OXIDIZER 2
#define XGM_GAS_CONTAMINANT 4

#define PLASMA_HALLUCINATION 1
#define OXYGEN_LOSS 2
#define PLASMA_DMG 3
#define RPREV_REQUIRE_HEADS_ALIVE 0
#define RPREV_REQUIRE_REVS_ALIVE 0
//radiation constants
#define STEFAN_BOLTZMANN_CONSTANT		5.6704e-8	//W/(m^2*K^4)
#define COSMIC_RADIATION_TEMPERATURE	3.15		//K
#define AVERAGE_SOLAR_RADIATION			200			//W/m^2. Kind of arbitrary. Really this should depend on the sun position much like solars.
#define RADIATOR_OPTIMUM_PRESSURE		110			//kPa at 20 C

#define MOLES_PLASMA_VISIBLE	0.5 //Moles in a standard cell after which plasma is visible

#define BREATH_VOLUME 0.5	//liters in a normal breath
/*
	Atmos Machinery
*/
#define MAX_SIPHON_FLOWRATE		2500	//L/s	This can be used to balance how fast a room is siphoned. Anything higher than CELL_VOLUME has no effect.
#define MAX_SCRUBBER_FLOWRATE	200		//L/s	Max flow rate when scrubbing from a turf.

//These balance how easy or hard it is to create huge pressure gradients with pumps and filters. Lower values means it takes longer to create large pressures differences.
//Has no effect on pumping gasses from high pressure to low, only from low to high. Must be between 0 and 1.
#define ATMOS_PUMP_EFFICIENCY	2.5
#define ATMOS_FILTER_EFFICIENCY	2.5

//will not bother pumping or filtering if the gas source as fewer than this amount of moles, to help with performance.
#define MINUMUM_MOLES_TO_PUMP	0.01
#define MINUMUM_MOLES_TO_FILTER	0.1

//The flow rate/effectiveness of various atmos devices is limited by their internal volume, so for many atmos devices these will control maximum flow rates in L/s
#define ATMOS_DEFAULT_VOLUME_PUMP	200	//L
#define ATMOS_DEFAULT_VOLUME_FILTER	200	//L
#define ATMOS_DEFAULT_VOLUME_MIXER	200	//L
#define ATMOS_DEFAULT_VOLUME_PIPE	70	//L

#define QUANTIZE(variable)		(round(variable,0.0001))
//Phoron fire properties
#define PHORON_MINIMUM_BURN_TEMPERATURE		100+T0C
#define PHORON_FLASHPOINT 					246+T0C
#define PHORON_UPPER_TEMPERATURE			1370+T0C
#define PHORON_MINIMUM_OXYGEN_NEEDED		2
#define PHORON_MINIMUM_OXYGEN_PHORON_RATIO	20
#define PHORON_OXYGEN_FULLBURN				10

#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.048
	//Minimum ratio of air that must move to/from a tile to suspend group processing

#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.048
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4
	//Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5
	//Minimum temperature difference before the gas temperatures are just set to be equal



#define FLOOR_HEAT_TRANSFER_COEFFICIENT 0.08
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.03
#define SPACE_HEAT_TRANSFER_COEFFICIENT 0.20 //a hack to partly simulate radiative heat
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.40
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.10 //a hack for now
	//Must be between 0 and 1. Values closer to 1 equalize temperature faster
	//Should not exceed 0.4 else strange heat flow occur


#define FIRE_SPREAD_RADIOSITY_SCALE		0.85
vs_control/var/FIRE_PLASMA_ENERGY_RELEASED = 3000000 //Amount of heat released per mole of burnt plasma into the tile
vs_control/var/FIRE_PLASMA_ENERGY_RELEASED_DESC = "Determines the temp increase from plasma fires."
vs_control/var/FIRE_CARBON_ENERGY_RELEASED =  750000 //Amount of heat released per mole of burnt plasma into the tile
vs_control/var/FIRE_CARBON_ENERGY_RELEASED_DESC = "Determines the temp increase from fuel fires."
vs_control/var/OXY_TO_PLASMA = 1
vs_control/var/OXY_TO_PLASMA_DESC = "Ratio of oxygen to plasma burned to produce CO2."
#define FIRE_GROWTH_RATE			50000 //For small fires

//Plasma fire properties

#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10

#define SPARK_TEMP 3500 //The temperature of welders, lighters, etc. for fire purposes.

#define T0C 273.15					// 0degC
#define T20C 293.15					// 20degC
#define TCMB 2.7					// -270.3degC
#define TSPC 253.15					// -20degC
#define TESPC 243.15				// -30degC
/var/const/MOLES_CELLSTANDARD = (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))	//moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC
/var/const/MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION = T20C+10
/var/const/MINIMUM_TEMPERATURE_START_SUPERCONDUCTION = T20C+200

/var/const/TANK_LEAK_PRESSURE = (30.*ONE_ATMOSPHERE)	// Tank starts leaking
/var/const/TANK_RUPTURE_PRESSURE = (40.*ONE_ATMOSPHERE) // Tank spills all contents into atmosphere

/var/const/TANK_FRAGMENT_PRESSURE = (50.*ONE_ATMOSPHERE) // Boom 3x3 base explosion
/var/const/TANK_FRAGMENT_SCALE = (10.*ONE_ATMOSPHERE) // +1 for each SCALE kPa aboe threshold

/var/const/MOLES_O2STANDARD = MOLES_CELLSTANDARD*O2STANDARD	// O2 standard value (21%)
/var/const/MOLES_N2STANDARD = MOLES_CELLSTANDARD*N2STANDARD	// N2 standard value (79%)
/var/const/BREATH_PERCENTAGE = BREATH_VOLUME/CELL_VOLUME
	//Amount of air to take a from a tile
/var/const/HUMAN_NEEDED_OXYGEN = MOLES_CELLSTANDARD*BREATH_PERCENTAGE*0.16
	//Amount of air needed before pass out/suffocation commences
								// was 2 atm
/var/const/MINIMUM_AIR_TO_SUSPEND = MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND
	//Minimum amount of air that has to move before a group processing can be suspended

/var/const/MINIMUM_MOLES_DELTA_TO_MOVE = MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND //Either this must be active
/var/const/MINIMUM_TEMPERATURE_TO_MOVE = T20C+100 		  //or this (or both, obviously)

/var/const/FIRE_MINIMUM_TEMPERATURE_TO_SPREAD = 150+T0C
/var/const/FIRE_MINIMUM_TEMPERATURE_TO_EXIST = 100+T0C

/var/const/PLASMA_MINIMUM_BURN_TEMPERATURE = 250+T0C
/var/const/PLASMA_UPPER_TEMPERATURE	= 1370+T0C

#define NORMPIPERATE 30					//pipe-insulation rate divisor
#define HEATPIPERATE 8					//heat-exch pipe insulation

#define FLOWFRAC 0.99				// fraction of gas transfered per process


//FLAGS BITMASK
#define ONBACK 1			// can be put in back slot
#define TABLEPASS 2			// can pass by a table or rack
#define HALFMASK 4			// mask only gets 1/2 of air supply from internals

#define HEADSPACE 4			// head wear protects against space

#define MASKINTERNALS 8		// mask allows internals
#define SUITSPACE 8			// suit protects against space

#define USEDELAY 16			// 1 second extra delay on use
#define NOSHIELD 32			// weapon not affected by shield
#define CONDUCT 64			// conducts electricity (metal etc.)
#define ONBELT 128			// can be put in belt slot
#define FPRINT 256			// takes a fingerprint
#define ON_BORDER 512		// item has priority to check when entering or leaving

#define GLASSESCOVERSEYES 1024
#define MASKCOVERSEYES 1024		// get rid of some of the other retardation in these flags
#define HEADCOVERSEYES 1024		// feel free to realloc these numbers for other purposes
#define MASKCOVERSMOUTH 2048		// on other items, these are just for mask/head
#define HEADCOVERSMOUTH 2048

#define PLASMAGUARD 4096

#define OPENCONTAINER	4096	// is an open container for chemistry purposes

#define ONESIZEFITSALL	8192	// can be worn by fatties (or children? ugh)

#define NOSPLASH 16384


// bitflags for clothing parts
#define HEAD			1
#define UPPER_TORSO		2
#define LOWER_TORSO		4
#define LEGS			8
#define FEET			16
#define ARMS			32
#define HANDS			64

// channel numbers for power

#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
#define TOTAL 4	//for total power used only

// bitflags for machine stat variable
#define BROKEN 1
#define NOPOWER 2
#define POWEROFF 4		// tbd
#define MAINT 8			// under maintaince

#define ENGINE_EJECT_Z 3

var/const
	GAS_O2 = 1 << 0
	GAS_N2 = 1 << 1
	GAS_PL = 1 << 2
	GAS_CO2 = 1 << 3
	GAS_N2O = 1 << 4

//Symbolic defines for getZLevel (copied from old code)
//These are not actual Z levels, but arguments to a function that returns a Z level.
#define Z_STATION	1
#define Z_SPACE		2

#define mSmallsize 32768
#define mShock 16384
#define mFingerprints 8192
#define mHallucination 4096
#define mBlend 2048
#define mMorph 1024
#define mRemotetalk 512
#define mRun 256
#define mRegen 128
#define mRemote 64
#define mNobreath 32

#define TABBED_PM	1

//For ze mini pods (take from old code).
/var/list/podspawns = list( )
/var/list/poddocks = list( )