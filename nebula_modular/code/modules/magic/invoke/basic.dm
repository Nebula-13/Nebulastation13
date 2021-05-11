// Summon Sparks
/datum/magic/invoke/sparks
	name = "Summon Sparks"
	desc = "Gives the user speed and stun resistance for a short period of time."
	complexity = 3
	mana_cost = 15
	residual_cost = 6
	cooldown = 6 MINUTES
	possible_words = list("spark", "scintilla", "accendo", "kindle", "incito", "ignesco")

/datum/magic/invoke/sparks/fire(mob/living/firer, amped)
	do_sparks(amped ? 6 : 3, TRUE, firer)
	firer.add_movespeed_modifier(/datum/movespeed_modifier/reagent/nuka_cola)
	if(iscarbon(firer))
		var/mob/living/carbon/F = firer
		F.Jitter(20 * REAGENTS_EFFECT_MULTIPLIER)
		F.set_drugginess(30 * REAGENTS_EFFECT_MULTIPLIER)
		F.dizziness += 1.5 * REAGENTS_EFFECT_MULTIPLIER
		F.drowsyness = 0
		F.AdjustSleeping(-40 * REAGENTS_EFFECT_MULTIPLIER)
		F.adjust_bodytemperature(-5 * REAGENTS_EFFECT_MULTIPLIER * TEMPERATURE_DAMAGE_COEFFICIENT, F.get_body_temp_normal())
		F.AdjustStun(-20 * REAGENTS_EFFECT_MULTIPLIER)
		F.AdjustKnockdown(-20 * REAGENTS_EFFECT_MULTIPLIER)
		F.AdjustUnconscious(-20 * REAGENTS_EFFECT_MULTIPLIER)
		F.AdjustImmobilized(-20 * REAGENTS_EFFECT_MULTIPLIER)
		F.AdjustParalyzed(-20 * REAGENTS_EFFECT_MULTIPLIER)
		F.adjustStaminaLoss(-30 * REAGENTS_EFFECT_MULTIPLIER)
	addtimer(CALLBACK(firer, /mob/.proc/remove_movespeed_modifier, /datum/movespeed_modifier/reagent/nuka_cola), 15 SECONDS)

// Magic Locator
/datum/magic/invoke/locator
	name = "Magic Locator"
	desc = "Reveals the location of a random spell's word."
	complexity = 1
	cooldown = 2 MINUTES
	possible_words = list("locate", "invenio")

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
	desc = "Teleports the user to some random location."
	complexity = 1
	mana_cost = 50
	residual_cost = 20
	cooldown = 10 MINUTES
	roundstart = TRUE
	possible_words = list("apparatus")

/datum/magic/invoke/apparate/fire(mob/living/firer)
	do_teleport(firer, get_turf(firer), 15, asoundin = 'sound/magic/enter_blood.ogg', asoundout = 'sound/magic/exit_blood.ogg', channel = TELEPORT_CHANNEL_MAGIC, no_effects = TRUE)

// Lumos - and their variants
/datum/magic/invoke/lumos
	name = "Lumos"
	desc = "Conjures light around the user, useful if you don't have another light source. Consumes mana continuously. Saying \"nox\" ends the effect."
	complexity = 1
	roundstart = TRUE
	cooldown = 1 SECONDS
	possible_words = list("lumos")
	counter_charm = list("nox")
	var/glow = /obj/effect/dummy/luminescent_glow

/datum/magic/invoke/lumos/fire(mob/living/firer)
	if(locate(glow) in firer)
		to_chat(firer, "<span class='warning'>You are already using Lumos!</span>")
		return TRUE
	new glow(firer)
	var/obj/effect/dummy/luminescent_glow/lumo = locate(glow) in firer
	lumo.set_light_range_power_color(3.1, 2, "#969ceb")
	to_chat(firer, "<span class='notice'>You invoked Lumos!</span>")
	while(TRUE)
		lumo = locate(glow) in firer
		if(!lumo)
			break
		if(do_after(firer, 1 SECONDS, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED), progress = FALSE))
			if(!use_mana(firer, src, 1.2))
				qdel(lumo)
				break
	return TRUE

/datum/magic/invoke/lumos/counter(mob/living/firer)
	var/obj/effect/dummy/luminescent_glow/lumo = locate(glow) in firer
	if(lumo)
		qdel(lumo)
	else
		to_chat(firer, "<span class='danger'>You need to invoke Lumos in order to use this.</span>")

// Lumox Maxima
/datum/magic/invoke/lumos/maxima
	name = "Lumos Maxima"
	desc = "Increases the light of Lumos."
	complexity = 2
	mana_cost = 20
	residual_cost = 8
	cooldown = 0
	possible_words = list("lumos", "maxima")

/datum/magic/invoke/lumos/maxima/fire(mob/living/firer)
	var/obj/effect/dummy/luminescent_glow/lumo = locate(glow) in firer
	if(lumo)
		lumo.set_light_range_power_color(5, 3, "#969ceb")
	else
		to_chat(firer, "<span class='danger'>You need to invoke Lumos in order to use this.</span>")
		return TRUE

// Lumos Solem
/datum/magic/invoke/lumos/solem
	name = "Lumos Solem"
	desc = "Conjures a beam of light that blinds and confuses enemies around you."
	complexity = 2
	mana_cost = 30
	residual_cost = 10
	cooldown = 8 MINUTES
	roundstart = FALSE
	in_order = TRUE
	possible_words = list("lumos", "solem")
	counter_charm = null

/datum/magic/invoke/lumos/solem/fire(mob/living/firer)
	for(var/mob/living/L in viewers(firer.loc))
		if(L == firer)
			continue
		if(iscarbon(L))
			var/mob/living/carbon/C = L
			log_combat(firer, C, "flashed", src)
			C.flash_act(6, 1, TRUE, TRUE)
			C.add_confusion(7)
			C.visible_message("<span class='danger'>[firer] blinds [C] with magic!</span>", \
							"<span class='userdanger'>[firer] blinded you with magic!</span>", null, COMBAT_MESSAGE_RANGE)
		if(issilicon(L))
			var/mob/living/silicon/robot/B = L
			log_combat(firer, B, "flashed", src)
			B.flash_act(6, 1, TRUE, TRUE)
			B.Paralyze(rand(10, 25))
			B.add_confusion(7)
			B.visible_message("<span class='warning'>[firer] overloads [B]'s sensors with magic!</span>", \
								"<span class='danger'>You overload [B]'s sensors with magic!</span>")
	playsound(firer, 'sound/magic/charge.ogg', 50, TRUE)

// Stealth
/datum/magic/invoke/stealth
	name = "Stealth"
	desc = "Using a magic trick, you create a clone and remain invisible for a short time. Useful to escape and outwit your enemies."
	complexity = 1
	mana_cost = 25
	residual_cost = 15
	cooldown = 10 MINUTES
	whisper = FALSE
	possible_words = list("evadere", "evanescet")

/datum/magic/invoke/stealth/fire(mob/living/firer)
	var/mob/living/simple_animal/hostile/illusion/escape/decoy = new(firer.loc)
	decoy.Copy_Parent(firer, 50)
	decoy.GiveTarget(firer)
	decoy.Goto(firer, decoy.move_to_delay, 12)
	firer.alpha = 0
	playsound(firer.loc, 'sound/magic/smoke.ogg', 50)
	addtimer(CALLBACK(src, .proc/end_stealth, firer), 6 SECONDS)

/datum/magic/invoke/stealth/proc/end_stealth(mob/living/firer)
	animate(firer, alpha = initial(firer.alpha), time = 2 SECONDS)
	firer.visible_message("<span class='notice'>[firer] appears out of nowhere!</span>")
