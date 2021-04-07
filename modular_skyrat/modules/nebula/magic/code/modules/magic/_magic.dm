/datum/magic
	var/name
	var/complexity = 1
	var/max_misfire = 1
	var/residual_cost = 5
	var/roundstart = TRUE

/datum/magic/proc/setup() // called by SSmagic

/datum/magic/proc/fire(mob/living/firer, amped = FALSE)

/datum/magic/proc/misfire(mob/living/firer, amped = FALSE)

/datum/magic/proc/check_uses(mob/living/firer)

/datum/magic/proc/check_cooldown(mob/living/firer, datum/magic/invoke/MI)

/datum/magic/proc/should_reject(mob/living/firer)
	. = FALSE
	if(ishuman(firer))
		var/mob/living/carbon/human/H = firer
		if(H.dna && LAZYLEN(H.dna.mutations))
			for(var/datum/mutation/human/M in H.dna.mutations)
				if(M.quality == POSITIVE)
					return TRUE
	if(firer.residual_energy >= 15)
		return TRUE
