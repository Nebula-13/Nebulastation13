// Bluespace locker locator
/datum/magic/invoke/bslocator
	name = "Bluespace Locator"
	complexity = 4
	residual_cost = 7
	uses = 1
	possible_words = list("cogitare", "ostende", "inveniet", "quaerere", "vestium", "dimensionem", "spectrum")

/datum/magic/invoke/bslocator/fire(mob/living/firer)

	var/obj/structure/closet/locker = SSbluespace_locker.external_locker
	if(locker)
		var/obj/effect/temp_visual/eye_locator/o = new (get_turf(locker), firer)
		o.current_image = image('nebula_modular/icons/eye.dmi', o, "eye", ABOVE_MOB_LAYER)
		o.current_image.alpha = 0
		firer.client.images |= o.current_image
		o.set_light(5, 4)
		firer.reset_perspective(o)
		firer.Immobilize(45)
		animate(o.current_image, alpha = 255, time = 3 SECONDS)
		do_sparks(3, TRUE, o)
		addtimer(CALLBACK(firer, /mob/living/.proc/reset_perspective), 5 SECONDS)

/obj/effect/temp_visual/eye_locator
	duration = 51 // deciseconds
	randomdir = FALSE
	invisibility = INVISIBILITY_MAXIMUM
	var/mob/living/carbon/user
	var/image/current_image

/obj/effect/temp_visual/eye_locator/Initialize(mapload, mob/living/carbon/T)
	. = ..()
	user = T

/obj/effect/temp_visual/eye_locator/Destroy()
	if(user.client)
		user.client.images.Remove(current_image)
	. = ..()

// Expelliarmus
/datum/magic/invoke/expelliarmus
	name = "Expelliarmus"
	complexity = 1
	cooldown = 15 MINUTES
	whisper = FALSE
	possible_words = list("expelliarmus")
	residual_cost = 10

/datum/magic/invoke/expelliarmus/fire(mob/living/firer)
	var/obj/effect/proc_holder/spell/aimed/expelliarmus/e = new(firer)
	e.add_ranged_ability(firer, forced = TRUE)

/obj/effect/proc_holder/spell/aimed/expelliarmus
	name = "Expelliarmus"
	desc = "Disarm your enimies!"
	school = "evocation"
	clothes_req = FALSE
	invocation = "EXPELLIARMUS!!"
	invocation_type = "shout"
	range = 10
	sound = 'sound/magic/repulse.ogg'
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	has_action = FALSE
	active_msg = "You prepare to cast expelliarmus!"
	deactive_msg = "You extinguish your magic... for now."
	current_amount = 1
	charge_type = "charges"

/obj/effect/proc_holder/spell/aimed/expelliarmus/fire_projectile(mob/living/user, atom/target)
	current_amount--
	if(iscarbon(target))
		var/mob/living/carbon/H = target
		var/list/hand_items = list(H.get_active_held_item(), H.get_inactive_held_item())
		H.Paralyze(6)
		for(var/obj/item in hand_items)
			if(!item)
				continue
			item.throw_at(user, rand(4, 6), rand(3, 4))
		H.visible_message("<span class='danger'>[user] disarmed [target]!</span>", \
							"<span class='userdanger'>[user] disarmed you!</span>", null, COMBAT_MESSAGE_RANGE)
	return TRUE

/obj/effect/proc_holder/spell/aimed/expelliarmus/cast_check(skipcharge, mob/user = usr)
	if(user.stat && !stat_allowed)
		to_chat(user, "<span class='notice'>Not when you're incapacitated.</span>")
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if((invocation_type == "whisper" || invocation_type == "shout") && !H.can_speak_vocal())
			to_chat(user, "<span class='notice'>You can't get the words out!</span>")
			return FALSE
	return TRUE

// Expectro Patronum
/datum/magic/invoke/patronum
	name = "Expectro Patronum"
	complexity = 2
	residual_cost = 8
	cooldown = 10 MINUTES
	in_order = TRUE
	whisper = FALSE
	possible_words = list("expectro", "patronum")

/datum/magic/invoke/patronum/fire(mob/living/firer)
	var/obj/effect/proc_holder/spell/aimed/patronum/p = new(firer)
	p.add_ranged_ability(firer, forced = TRUE)

/obj/effect/proc_holder/spell/aimed/patronum
	name = "Expectro Patronum"
	desc = "This magic is generally used to repel spirits."
	school = "evocation"
	clothes_req = FALSE
	invocation = "EXPECTRO PATRONUM!!"
	invocation_type = "shout"
	range = 20
	sound = 'sound/magic/disable_tech.ogg'
	ranged_mousepointer = 'icons/effects/mouse_pointers/cult_target.dmi'
	projectile_type = /obj/projectile/magic/aoe/patronum
	has_action = FALSE
	active_msg = "You prepare to cast expectro patronum!"
	deactive_msg = "You extinguish your magic... for now."
	current_amount = 1
	charge_type = "charges"

/obj/effect/proc_holder/spell/aimed/patronum/process(delta_time)
	return

/obj/effect/proc_holder/spell/aimed/patronum/cast_check(skipcharge, mob/user = usr)
	if(user.stat && !stat_allowed)
		to_chat(user, "<span class='notice'>Not when you're incapacitated.</span>")
		return FALSE
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if((invocation_type == "whisper" || invocation_type == "shout") && !H.can_speak_vocal())
			to_chat(user, "<span class='notice'>You can't get the words out!</span>")
			return FALSE
	return TRUE

/obj/projectile/magic/aoe/patronum
	name = "bolt of patronum"
	icon = 'nebula_modular/icons/patronum.dmi'
	icon_state = "patronum"
	damage = 6
	damage_type = BURN
	nodamage = FALSE

/obj/projectile/magic/aoe/patronum/on_hit(target)
	. = ..()
	if(isrevenant(target))
		var/mob/living/simple_animal/revenant/M = target
		M.visible_message("<span class='warning'>[M] violently flinches!</span>", \
						"<span class='revendanger'>As \the [src] passes through you, you feel your essence draining away!</span>")
		M.adjustBruteLoss(45)
		M.inhibited = TRUE
		M.update_action_buttons_icon()
		addtimer(CALLBACK(M, /mob/living/simple_animal/revenant.proc/reset_inhibit), 30)

	if(isshade(target))
		var/mob/living/simple_animal/shade/M
		M.visible_message("<span class='warning'>[M] violently flinches!</span>", \
						"<span class='userdanger'>[src] passes through you, damaging from the inside out!</span>")
		M.adjustBruteLoss(45)

	for(var/mob/living/carbon/H in viewers(get_turf(loc)))
		H.flash_act(1, 1)
		if(!H == firer)
			H.soundbang_act(1, 2, 0, 5)
	visible_message("<span class='warning'>[src] disappears in the air in contact with [target]!</span>")

// Accio
/datum/magic/invoke/accio
	name = "Accio"
	complexity = 1
	residual_cost = 7
	cooldown = 2 MINUTES
	possible_words = list("accio")
	var/allow_change = FALSE

/datum/magic/invoke/accio/fire(mob/living/firer)
	var/list/hand_items = list(firer.get_active_held_item(),firer.get_inactive_held_item())
	var/message
	if(!firer.marked_item) //linking item to the spell
		message = "<span class='notice'>"
		for(var/obj/item/item in hand_items)
			if(item.item_flags & ABSTRACT)
				continue
			if(SEND_SIGNAL(item, COMSIG_ITEM_MARK_RETRIEVAL) & COMPONENT_BLOCK_MARK_RETRIEVAL)
				continue
			if(HAS_TRAIT(item, TRAIT_NODROP))
				message += "Though it feels redundant, "
			firer.marked_item = item
			message += "You mark [item] for recall.</span>"

		if(!firer.marked_item)
			if(hand_items)
				message = "<span class='caution'>You aren't holding anything that can be marked for recall.</span>"
			else
				message = "<span class='notice'>You must hold the desired item in your hands to mark it for recall.</span>"

	else if(firer.marked_item && (firer.marked_item in hand_items) && allow_change) //unlinking item to the spell
		message = "<span class='notice'>You remove the mark on [firer.marked_item] to use elsewhere.</span>"
		firer.marked_item = null

	else if(firer.marked_item && QDELETED(firer.marked_item)) //the item was destroyed at some point
		message = "<span class='warning'>You sense your marked item has been destroyed!</span>"
		firer.marked_item = null

	else	//Getting previously marked item
		var/obj/item_to_retrieve = firer.marked_item
		var/infinite_recursion = 0 //I don't want to know how someone could put something inside itself but these are wizards so let's be safe

		if(!item_to_retrieve.loc)
			if(isorgan(item_to_retrieve)) // Organs are usually stored in nullspace
				var/obj/item/organ/organ = item_to_retrieve
				if(organ.owner)
					// If this code ever runs I will be happy
					log_combat(firer, organ.owner, "magically removed [organ.name] from", addition="INTENT: [uppertext(firer.combat_mode)]")
					organ.Remove(organ.owner)

		else
			while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
				if(isitem(item_to_retrieve.loc))
					var/obj/item/I = item_to_retrieve.loc
					if(I.item_flags & ABSTRACT) //Being able to summon abstract things because your item happened to get placed there is a no-no
						break
				if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
					var/mob/M = item_to_retrieve.loc

					if(issilicon(M)) //Items in silicons warp the whole silicon
						M.loc.visible_message("<span class='warning'>[M] suddenly disappears!</span>")
						M.forceMove(firer.loc)
						M.loc.visible_message("<span class='caution'>[M] suddenly appears!</span>")
						item_to_retrieve = null
						break
					M.dropItemToGround(item_to_retrieve)

					if(iscarbon(M)) //Edge case housekeeping
						var/mob/living/carbon/C = M
						for(var/X in C.bodyparts)
							var/obj/item/bodypart/part = X
							if(item_to_retrieve in part.embedded_objects)
								part.embedded_objects -= item_to_retrieve
								to_chat(C, "<span class='warning'>The [item_to_retrieve] that was embedded in your [firer] has mysteriously vanished. How fortunate!</span>")
								if(!C.has_embedded_objects())
									C.clear_alert("embeddedobject")
									SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "embedded")
								break
				else
					if(istype(item_to_retrieve.loc, /obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
						var/obj/machinery/portable_atmospherics/P = item_to_retrieve.loc
						P.disconnect()
						P.update_icon()

					item_to_retrieve = item_to_retrieve.loc

				infinite_recursion += 1

		if(!item_to_retrieve)
			return

		if(item_to_retrieve.loc)
			item_to_retrieve.loc.visible_message("<span class='warning'>The [item_to_retrieve.name] suddenly disappears!</span>")
		if(!firer.put_in_hands(item_to_retrieve))
			item_to_retrieve.forceMove(firer.drop_location())
			item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears!</span>")
			playsound(get_turf(firer), 'sound/magic/summonitems_generic.ogg', 50, 1)
		else
			item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears in [firer]'s hand!</span>")
			playsound(get_turf(firer), 'sound/magic/summonitems_generic.ogg', 50, 1)


	if(message)
		to_chat(firer, message)
