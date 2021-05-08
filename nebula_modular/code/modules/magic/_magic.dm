/datum/magic
	var/name
	var/complexity = 1
	var/max_misfire = 1
	var/residual_cost = 5
	var/mana_cost = 10
	var/roundstart = FALSE

/datum/magic/proc/setup() // called by SSmagic

/datum/magic/proc/fire(mob/living/firer, amped = FALSE)

/datum/magic/proc/misfire(mob/living/firer, amped = FALSE)

/datum/magic/proc/use_mana(mob/living/firer, datum/magic/invoke/MI, amount)

/datum/magic/proc/check_uses(mob/living/firer, datum/magic/invoke/MI)

/datum/magic/proc/check_cooldown(mob/living/firer, datum/magic/invoke/MI)

/datum/magic/proc/counter(mob/living/firer, datum/magic/invoke/MI)

/datum/magic/proc/fire_process(mob/living/firer, datum/magic/invoke/MI)

/datum/magic/proc/misfire_process(mob/living/firer, datum/magic/invoke/MI)

/datum/magic/proc/should_reject(mob/living/firer)
	. = FALSE
	if(ishuman(firer))
		var/mob/living/carbon/human/H = firer
		if(H.dna && LAZYLEN(H.dna.mutations))
			for(var/datum/mutation/human/M in H.dna.mutations)
				if(M.quality == POSITIVE)
					return TRUE
	if(firer.mana <= 30)
		to_chat(firer, "<span class='warning'>You are almost out of mana!</span>")
		return TRUE
	if(SSmagic?.residual_energy >= 250)
		if(prob(50))
			to_chat(firer, "<span class='warning'>The magic residue is too high!</span>")
			return TRUE
