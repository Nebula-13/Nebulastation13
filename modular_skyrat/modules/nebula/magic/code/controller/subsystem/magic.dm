SUBSYSTEM_DEF(magic)
	name = "Magic"
	init_order = INIT_ORDER_XKEYSCORE
	flags = SS_NO_FIRE
	var/magical_factor
	var/list/loaded_magic = list()

/datum/controller/subsystem/magic/Initialize()
	. = ..()
	magical_factor = rand(MAGIC_RANDOMIZATION_MIN, MAGIC_RANDOMIZATION_MAX) * 0.5
	for(var/m in subtypesof(/datum/magic))
		var/datum/magic/M = m
		if(initial(M.name))
			log_game("Loaded magic [initial(M.name)]!")
			var/datum/magic/magick = new m
			magick.setup()
			loaded_magic += magick

/datum/controller/subsystem/magic/proc/set_memory(mob/living/user)
	if(user.mind && SSmagic && SSmagic.initialized)
		var/list/words = list()
		for(var/datum/magic/invoke/IM in SSmagic.loaded_magic)
			words += pick(IM.phrase_list)
		var/picked_word = pick(words)
		var/phrase_text = "You remember a word.. [picked_word].."
		return	phrase_text
