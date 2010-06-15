/obj/decal/ash
	name = "Ashes"
	desc = "Ashes to ashes, dust to dust."
	icon = 'objects.dmi'
	icon_state = "ash"
	anchored = 1

/obj/decal/point
	name = "point"
	icon = 'screen1.dmi'
	icon_state = "arrow"
	layer = 16.0
	anchored = 1

/obj/decal/cleanable
	var/list/random_icon_states = list()

/obj/decal/cleanable/blood
	name = "blood"
	desc = "It's red."
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/datum/disease/virus = null
	blood_DNA = null
	blood_type = null

/obj/decal/cleanable/blood/splatter
	random_icon_states = list("gibbl1", "gibbl2", "gibbl3", "gibbl4", "gibbl5")

/obj/decal/cleanable/blood/tracks
	icon_state = "tracks"
	random_icon_states = null

/obj/decal/cleanable/blood/gibs
	name = "gibs"
	desc = "Grisly..."
	density = 0
	anchored = 0
	layer = 2
	icon = 'blood.dmi'
	icon_state = "gibbl5"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6")

/obj/decal/cleanable/blood/gibs/body
	random_icon_states = list("gibhead", "gibtorso")

/obj/decal/cleanable/blood/gibs/limb
	random_icon_states = list("gibleg", "gibarm")

/obj/decal/cleanable/blood/gibs/core
	random_icon_states = list("gibmid1", "gibmid2", "gibmid3")

/obj/decal/cleanable/robot_debris
	name = "robot debris"
	desc = "Useless heap of junk."
	density = 0
	anchored = 0
	layer = 2
	icon = 'robots.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6", "gib7")

/obj/decal/cleanable/robot_debris/limb
	random_icon_states = list("gibarm", "gibleg")

/obj/decal/cleanable/oil
	name = "motor oil"
	desc = "It's black."
	density = 0
	anchored = 1
	layer = 2
	icon = 'oil.dmi'
	icon_state = "floor1"
	var/datum/disease/virus = null
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")

/obj/decal/cleanable/oil/streak
	random_icon_states = list("streak1", "streak2", "streak3", "streak4", "streak5")

/obj/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'objects.dmi'
	icon_state = "shards"

/obj/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	density = 0
	anchored = 1
	layer = 2
	icon = 'old_or_unused.dmi'
	icon_state = "dirt"

/obj/decal/cleanable/greenglow
	name = "green glow"
	desc = "Eerie."
	density = 0
	anchored = 1
	layer = 2
	icon = 'effects.dmi'
	icon_state = "greenglow"

/obj/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'old_or_unused.dmi'
	icon_state = "cobweb1"

/obj/decal/cleanable/molten_item
	name = "gooey grey mass"
	desc = "huh."
	density = 0
	anchored = 1
	layer = 3
	icon = 'chemical.dmi'
	icon_state = "molten"

/obj/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Someone should remove that."
	density = 0
	anchored = 1
	layer = 3
	icon = 'old_or_unused.dmi'
	icon_state = "cobweb2"
