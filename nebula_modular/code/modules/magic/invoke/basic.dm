// Summon Sparks
/datum/magic/invoke/sparks
	name = "Summon Sparks"
	complexity = 3
	mana_cost = 15
	residual_cost = 6
	cooldown = 6 MINUTES
	possible_words = list("spark", "scintilla", "accendo", "kindle", "incito", "ignesco")

/datum/magic/invoke/sparks/fire(mob/living/firer, amped)
	do_sparks(amped ? 6 : 3, TRUE, firer)
	firer.reagents.add_reagent(/datum/reagent/consumable/nuka_cola, 5)
	firer.reagents.add_reagent(/datum/reagent/medicine/synaptizine, 10)

// Magic Locator
/datum/magic/invoke/locator
	name = "Magic Locator"
	complexity = 1
	cooldown = 2 MINUTES
	roundstart = TRUE
	possible_words = list("locate")

/datum/magic/invoke/locator/fire(mob/living/firer)
	for(var/obj/effect/blue_fire/bf in world)
		if(bf.who == firer)
			to_chat(firer, "<span class='notice'>You feel something coming from \the <b><font color='#57139b'>[get_area_name(bf, TRUE)]..</font></b></span>")
			return
		continue
	to_chat(firer, "<span class='danger'>There is no more knowledge to acquire.</span>")
	return TRUE

// Apparate
/datum/magic/invoke/apparate
	name = "Apparate"
	complexity = 1
	mana_cost = 50
	residual_cost = 15
	cooldown = 10 MINUTES
	roundstart = TRUE
	possible_words = list("apparatus")

/datum/magic/invoke/apparate/fire(mob/living/firer)
	do_teleport(firer, get_turf(firer), 15, asoundin = 'sound/magic/enter_blood.ogg', asoundout = 'sound/magic/exit_blood.ogg', channel = TELEPORT_CHANNEL_MAGIC, no_effects = TRUE)

// Healing
/datum/magic/invoke/healing
	name = "Healing"
	complexity = 1
	mana_cost = 23
	residual_cost = 7
	cooldown = 1 MINUTES
	possible_words = list("healing", "heal", "sana", "sanitatem")

/datum/magic/invoke/healing/fire(mob/living/firer)
	var/mob/living/target
	var/mob/living/pull = firer.pulling
	if(pull && isliving(pull))
		target = pull
	else
		target = firer

	if(target != firer && target.stat == DEAD)
		to_chat(firer, "<span class='warning'>You haven't yet learned how to revive the dead!</span>")
		return TRUE
	if(!target.getBruteLoss() && !target.getFireLoss() && !target.getOxyLoss() && !target.getToxLoss())
		to_chat(firer, "<span class='warning'>[target == firer ? "You are" : "[target] is"] already in a good condition!</span>")
		return TRUE
	firer.visible_message("<span class='notice'>[firer] begins to magically heal [target == firer ? "himself" : target].</span>", "<span class='notice'>You begin to magically heal [target == firer ? "yourself" : target].</span>")

	var/mana = 2
	var/heal = 2
	var/down = 2
	var/delay = 3 SECONDS
	while(TRUE)
		if(!use_mana(firer, src, mana))
			to_chat(firer, "<span class='warning'>You're out of mana!</span>")
			break
		if(target != firer && target.stat == DEAD)
			to_chat(firer, "<span class='warning'>You can't heal the dead!</span>")
			break
		if(!target.getBruteLoss() && !target.getFireLoss() && !target.getOxyLoss() && !target.getToxLoss())
			to_chat(firer, "<span class='notice'>[target == firer ? "You are" : "[target] is"] in a good condition now!</span>")
			break
		if(!do_after(firer, delay, target = target))
			to_chat(firer, "<span class='warning'>You stop healing [target == firer ? "yourself" : target].</span>")
			break
		target.adjustOxyLoss(-heal, FALSE)
		target.adjustToxLoss(-heal, FALSE)
		target.heal_overall_damage(heal, heal)
		new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")
		firer.adjustStaminaLoss(down)
		if(firer.getStaminaLoss() >= 50)
			firer.SetAllImmobility(down)
			firer.AdjustSleeping(down)
		mana *= 1.6
		heal *= 1.6
		down *= 1.6
		delay -= 0.2 SECONDS

	firer.visible_message("<span class='notice'>[firer] stops magically healing [target == firer ? "himself" : target].</span>", "<span class='notice'>You stop magically healing [target == firer ? "yourself" : target].</span>")

// Lumos - and their variants
/datum/magic/invoke/lumos
	name = "Lumos" // that reference
	complexity = 1
	roundstart = TRUE
	cooldown = 10 MINUTES
	possible_words = list("lumos")
	counter_charm = list("nox")
	var/obj/effect/dummy/luminescent_glow/glow
	var/timerid

/datum/magic/invoke/lumos/fire(mob/living/firer)
	glow = new(firer)
	glow.set_light_range_power_color(3, 2, "#767ef0")
	timerid = QDEL_IN(glow, 5 MINUTES)

/datum/magic/invoke/lumos/counter(mob/living/firer)
	glow = locate() in firer
	if(glow)
		deltimer(timerid)
		qdel(glow)
	else
		to_chat(firer, "<span class='danger'>You need to invoke Lumos in order to use this.</span>")

// Lumox Maxima
/datum/magic/invoke/lumos/maxima
	name = "Lumos Maxima"
	complexity = 2
	mana_cost = 20
	residual_cost = 8
	cooldown = 0
	possible_words = list("lumos", "maxima")

/datum/magic/invoke/lumos/maxima/fire(mob/living/firer)
	glow = locate() in firer
	if(glow)
		glow.set_light_range_power_color(5, 3, "#767ef0")
	else
		to_chat(firer, "<span class='danger'>You need to invoke Lumos in order to use this.</span>")
		return TRUE

// Lumos Solem
/datum/magic/invoke/lumos/solem
	name = "Lumos Solem"
	complexity = 2
	mana_cost = 30
	residual_cost = 10
	cooldown = 8 MINUTES
	roundstart = FALSE
	in_order = TRUE
	possible_words = list("lumos", "solem")
	counter_charm = null

/datum/magic/invoke/lumos/solem/fire(mob/living/firer)
	for(var/mob/living/carbon/C in viewers(firer.loc))
		C.flash_act(6, 1, visual = TRUE)
		if(!C == firer)
			C.visible_message("<span class='danger'>[firer] flashed [C] with magic!</span>", \
							"<span class='userdanger'>[firer] flashed you with magic!</span>", null, COMBAT_MESSAGE_RANGE)
	playsound(firer, 'sound/magic/charge.ogg', 50, TRUE)
