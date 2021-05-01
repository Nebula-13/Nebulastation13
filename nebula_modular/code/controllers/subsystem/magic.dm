SUBSYSTEM_DEF(magic)
	name = "Magic"
	init_order = INIT_ORDER_XKEYSCORE
	flags = SS_NO_FIRE
	var/magical_factor
	var/join_magic_prob = 40
	var/list/loaded_magic = list()
	var/list/all_phrases_list = list()
	var/wave_effects = FALSE

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
		var/turf/chosen_location = get_safe_random_station_turf()
		new /obj/effect/blue_fire(chosen_location, user, TRUE)
		var/phrase_text = "You have been blessed with the power to invoke magic! But you feel a strange aurea coming from \the [get_area_name(chosen_location, TRUE)].."
		return	phrase_text
