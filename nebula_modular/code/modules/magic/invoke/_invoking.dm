/datum/magic/invoke
	var/list/possible_words = list()
	var/list/phrase_list = list()
	var/phrase
	var/uses // for magics with a limited number of uses
	var/cooldown = 0 // for magic with cooldown
	var/list/counter_charm // the counter charm of the magic, if any
	var/whisper = TRUE // whisper when invoking or a silent invocation?
	var/in_order = FALSE // all words in possible words are put in order

/datum/magic/invoke/setup()
	if(!LAZYLEN(possible_words))
		return

	if(in_order || roundstart)
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
		if(in_order && !roundstart)
			SSmagic.all_phrases_list |= phrase_list
			GLOB.blue_fire_track.all_words |= phrase_list
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
	firer.fire_stacks += amped ? 4 : 2
	firer.IgniteMob()

/datum/magic/invoke/fire_process(mob/living/firer, datum/magic/invoke/MI)
	if(!MI.use_mana(firer, MI))
		return

	if(MI.check_uses(firer, MI))
		firer.handle_rejection(MI)
		firer.log_message("Misfired [MI.name] ([MI.type])", LOG_ATTACK)
		to_chat(firer, "<span class='danger'>[MI.name] misfired! You can no longer use this magic.</span>")
		SSmagic.process_residuo(MI.residual_cost)
		MI.misfire(firer, FALSE)
		return

	if(MI.check_cooldown(firer, MI))
		to_chat(firer, "<span class='danger'>[MI.name] isn't ready yet!</span>")
		return

	firer.handle_rejection(MI)
	firer.log_message("Invoked [MI.name] ([MI.type])", LOG_ATTACK)
	SSmagic.process_residuo(MI.residual_cost)
	if(!MI.fire(firer, FALSE))
		to_chat(firer, "<span class='notice'>You invoked [MI.name]!</span>")

/datum/magic/invoke/misfire_process(mob/living/firer, datum/magic/invoke/MI)
	firer.handle_rejection(MI)
	firer.log_message("Misfired [MI.name] ([MI.type])", LOG_ATTACK)
	to_chat(firer, "<span class='danger'>You failed to invoke [MI.name]!</span>")
	SSmagic.process_residuo(MI.residual_cost)
	MI.misfire(firer, FALSE)

/datum/magic/invoke/use_mana(mob/living/firer, datum/magic/invoke/MI, amount)
	if(!amount)
		amount = MI.mana_cost
	if(amount > firer.mana_max)
		to_chat(firer, "<span class='warning'>It looks like you don't have enough mana capacity for this magic.</span>")
		firer.log_message("Misfired [MI.name] ([MI.type])", LOG_ATTACK)
		MI.misfire(firer, TRUE)
		return FALSE
	if(amount > firer.mana)
		to_chat(firer, "<span class='warning'>You don't have enough mana!</span>")
		return FALSE
	firer.mana -= amount
	return TRUE

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
	if(MI.cooldown)
		for(var/M in firer.cdr_magics)
			if(M == name)
				if(firer.cdr_magics[M] > world.time)
					return TRUE
				else
					break
			else
				continue
		firer.cdr_magics["[name]"] = world.time + MI.cooldown
		return FALSE
	return FALSE
