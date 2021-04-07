/datum/magic/invoke
	var/list/possible_words = list()
	var/list/phrase_list = list()
	var/phrase
	var/uses // for magics with a limited number of uses!
	var/cooldown_time = 0 // for magic with cooldown! the time of the cooldown for the magic
	var/cooldown = 0 // the cooldown itself

/datum/magic/invoke/setup()
	var/done = FALSE
	if(!LAZYLEN(possible_words))
		return
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
				return

/datum/magic/invoke/misfire(mob/living/firer, amped)
	firer.fire_stacks += amped ? 5 : 2
	firer.IgniteMob()

/datum/magic/invoke/check_uses(mob/living/firer)
	if(uses)
		for(var/M in firer.used_magics)
			if(M == name && firer.used_magics[M] >= uses)
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
				if(firer.cdr_magics[M] < world.time)
					firer.cdr_magics["[name]"] = world.time + MI.cooldown_time
					return TRUE
				else if(firer.cdr_magics[M] > world.time)
					return TRUE
			else
				continue
		firer.cdr_magics["[name]"] = 0
		return FALSE
	return FALSE
