// =
// = The Unified (-Type-Tree) Cable Network System
// = Written by Sukasa with assistance from Googolplexed
// =
// = Cleans up the type tree and reduces future code maintenance
// = Also makes it easy to add new cable & network types
// =

// Unified Cable Network System - Base Network Controller Class

/datum/UnifiedNetworkController
	var/datum/UnifiedNetwork/Network = null

	New(var/datum/UnifiedNetwork/NewNetwork)
		..()
		Network = NewNetwork

	proc

		AttachNode(var/obj/Node)
			return

		DetachNode(var/obj/Node)
			return

		AddCable(var/obj/cabling/Cable)
			return

		RemoveCable(var/obj/cabling/Cable)
			return

		StartSplit(var/datum/UnifiedNetwork/NewNetwork)
			return

		FinishSplit(var/datum/UnifiedNetwork/NewNetwork)
			return

		CableCut(var/obj/cabling/Cable, var/mob/User)
			return

		CableBuilt(var/obj/cabling/Cable, var/mob/User)
			return

		Initialize()
			return

		Finalize()
			return

		BeginMerge(var/datum/UnifiedNetwork/TargetNetwork, var/IsSlave)
			return

		FinishMerge()
			return

		DeviceUsed(var/obj/item/device/Device, var/obj/cabling/Cable, var/mob/User)
			return

		CableTouched(var/obj/cabling/Cable, var/mob/User)
			return

		Process()
			return