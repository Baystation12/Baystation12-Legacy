/mob/living/silicon/ai/say_understands(var/other)
	if (istype(other, /mob/living/carbon/human))
		return 1
	if (istype(other, /mob/living/silicon/robot))
		return 1
	return ..()

/mob/living/silicon/ai/say_quote(var/text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return "queries, \"[text]\"";
	else if (ending == "!")
		return "declares, \"[copytext(text, 1, length(text))].\"";

	return "states, \"[text]\"";
