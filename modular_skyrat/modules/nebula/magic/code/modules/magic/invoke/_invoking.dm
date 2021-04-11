/datum/magic/invoke
	var/list/possible_words = list()
	var/list/phrase_list = list()
	var/phrase
	var/uses // for magics with a limited number of uses!
	var/cooldown_time = 0 // for magic with cooldown! the time of the cooldown for the magic
	var/cooldown = 0 // the cooldown itself
	var/list/counter_charm // the counter charm of the magic, if any

/datum/magic/invoke/setup()
	if(!LAZYLEN(possible_words))
		return

	if(roundstart)
		var/list/words = possible_words.Copy()
		var/new_phrase = ""
		var/new_phrase_list = list()
		for(var/i = 1 to complexity)
			var/word = "[words[i]]"
			new_phrase = "[new_phrase][word] "
			new_phrase_list += word
		new_phrase = trim_right(new_phrase)
		phrase = new_phrase
		phrase_list = new_phrase_list
		log_game("Magic [name] has phrase \"[phrase]\"")
		return

	var/done = FALSE
	while(!done)
		var/list/words = possible_words.Copy()
		var/new_phrase = ""
		var/new_phrase_list = list()
		for(var/i = 1 to complexity)
			var/word = pick_n_take(words)
			new_phrase = "[new_phrase][word] "
			new_phrase_list += word
		new_phrase = trim_right(new_phrase)
		if(length(new_phrase))
			var/cont = TRUE
			for(var/datum/magic/invoke/IM in SSmagic.loaded_magic)
				if(IM.phrase == new_phrase)
					cont = FALSE
					break
			if(cont)
				phrase = new_phrase
				phrase_list = new_phrase_list
				log_game("Magic [name] has phrase \"[phrase]\"")
				SSmagic.all_phrases_list |= phrase_list
				GLOB.blue_fire_track.all_words |= phrase_list
				return

/datum/magic/invoke/misfire(mob/living/firer, amped)
	firer.fire_stacks += amped ? 5 : 2
	firer.IgniteMob()

/datum/magic/invoke/fire_process(mob/living/firer, datum/magic/invoke/MI)
	if(MI.check_uses(firer, MI))
		firer.handle_rejection(MI)
		firer.log_message("Misfired [name] ([type])", LOG_ATTACK)
		to_chat(firer, "<span class='danger'>[name] misfired! You can no longer use this magic.</span>")
		firer.residual_energy += residual_cost * SSmagic.magical_factor
		MI.misfire(firer, FALSE)
		return

	if(MI.check_cooldown(firer, MI))
		to_chat(firer, "<span class='danger'>[MI.name] isn't ready yet!</span>")
		return

	firer.handle_rejection(MI)
	firer.log_message("Invoked [MI.name] ([MI.type])", LOG_ATTACK)
	to_chat(firer, "<span class='notice'>You successfully invoked [MI.name]!</span>")
	firer.residual_energy += MI.residual_cost * SSmagic.magical_factor
	MI.fire(firer, FALSE)

/datum/magic/invoke/misfire_process(mob/living/firer, datum/magic/invoke/MI)
	firer.handle_rejection(MI)
	firer.log_message("Misfired [MI.name] ([MI.type])", LOG_ATTACK)
	to_chat(firer, "<span class='danger'>You failed to invoke [MI.name]!</span>")
	firer.residual_energy += MI.residual_cost * SSmagic.magical_factor
	MI.misfire(firer, FALSE)

/datum/magic/invoke/check_uses(mob/living/firer, datum/magic/invoke/MI)
	if(MI.uses)
		for(var/M in firer.used_magics)
			if(M == name && firer.used_magics[M] >= MI.uses)
				firer.used_magics["[name]"] += 1
				return TRUE
			else
				continue
		firer.used_magics["[name]"] += 1
		return FALSE
	return FALSE

/datum/magic/invoke/check_cooldown(mob/living/firer, datum/magic/invoke/MI)
	if(MI.cooldown_time)
		for(var/M in firer.cdr_magics)
			if(M == name)
				if(firer.cdr_magics[M] > world.time)
					return TRUE
				else
					break
			else
				continue
		firer.cdr_magics["[name]"] = world.time + MI.cooldown_time
		return FALSE
	return FALSE
