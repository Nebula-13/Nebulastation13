/datum/emote/living/sex
	key = "sex"
	key_third_person = "sexes"
	cooldown = 30 SECONDS

/datum/emote/living/sex/run_emote(mob/living/user, params, type_override, intentional)
	. = ..()
	if(!.)
		return


	var/obj/item/sexer = new /obj/item/modosexo(user)
	var/mob/living/carbon/human/H = user
	var/obj/item/held = user.get_active_held_item()
	var/obj/item/unheld = user.get_inactive_held_item()
	if(user.put_in_hands(sexer) && H.dna.species.mutant_bodyparts["penis"] && H.is_bottomless())
		if(held || unheld)
			if(!((held.name=="sex" && held.item_flags == DROPDEL | ABSTRACT | HAND_ITEM) || (unheld.name=="sex" && unheld.item_flags == DROPDEL | ABSTRACT | HAND_ITEM)))
				to_chat(user, "<span class='notice'>You pull your willy out.</span>")
			else
				qdel(sexer)
		else
			to_chat(user, "<span class='notice'>You pull your willy out.</span>")
	else
		qdel(sexer)
		to_chat(user, "<span class='warning'>You're incapable of sexing.</span>")


/obj/item/modosexo
	name = "penis"
	desc = "Default knob joke number 35."
	icon_state = "dildo"
	inhand_icon_state = "dildo"
	icon = 'modular_skyrat/modules/modular_items/lewd_items/icons/obj/lewd_items/lewd_items.dmi'
	//lefthand_file = 'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_inhands/lewd_inhand_left.dmi'
	//righthand_file = 'modular_skyrat/modules/modular_items/lewd_items/icons/mob/lewd_inhands/lewd_inhand_right.dmi'
	//shouldn't show inhand
	var/current_color = "human"
	var/color_changed = FALSE
	var/static/list/dildo_designs
	w_class = WEIGHT_CLASS_TINY
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM



//Essentially dildocode but the fucker also gets arousal.
//No way I am putting effort on this, sorry coomers!
/obj/item/modosexo/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	. = ..()
	if(!istype(M, /mob/living/carbon/human))
		return
	if(M == user) //No.
		return
	var/message = ""
	var/obj/item/organ/genital/vagina = M.getorganslot(ORGAN_SLOT_VAGINA)
	if(M.client?.prefs.sextoys_pref == "Yes")
		switch(user.zone_selected)
			if(BODY_ZONE_PRECISE_GROIN)
				if(vagina)
					if(M.is_bottomless() || vagina.visibility_preference == GENITAL_ALWAYS_SHOW)
						message = (user == M) ? pick("rubs [M.p_their()] vagina with [src]","gently jams [M.p_their()] pussy with [src]","fucks [M.p_their()] vagina with a [src]") : pick("uses [src] to fuck [M]'s vagina","jams [M]'s pussy with [src]")
						M.adjustArousal(6)
						M.adjustPleasure(8)
						user.adjustArousal(4)
						user.adjustPleasure(6)
						if(prob(40) && (M.stat != DEAD))
							M.emote(pick("twitch_s","moan"))
						user.visible_message(span_purple("[user] [message]!"))
						playsound(loc, pick('modular_skyrat/modules/modular_items/lewd_items/sounds/bang1.ogg',
											'modular_skyrat/modules/modular_items/lewd_items/sounds/bang2.ogg',
											'modular_skyrat/modules/modular_items/lewd_items/sounds/bang3.ogg',
											'modular_skyrat/modules/modular_items/lewd_items/sounds/bang4.ogg',
											'modular_skyrat/modules/modular_items/lewd_items/sounds/bang5.ogg',
											'modular_skyrat/modules/modular_items/lewd_items/sounds/bang6.ogg'), 60, TRUE)
					else
						to_chat(user, span_danger("[M]'s groin is covered!"))
						return
				else
					to_chat(user, span_danger("[M] don't have suitable genitalia for that!"))
					return

			if(BODY_ZONE_HEAD, BODY_ZONE_PRECISE_MOUTH, BODY_ZONE_PRECISE_EYES) //Mouth only. Sorry, perverts. No eye/ear penetration for you today.
				if(!M.is_mouth_covered())
					message = (user == M) ? pick("licks [src] erotically","sucks on [src], slowly inserting it into [M.p_their()] throat") : pick("fucks [M]'s mouth with [src]", "inserts [src] into [M]'s throat, choking [M.p_them()]", "forces [M] to suck [src]", "inserts [src] into [M]'s throat")
					M.adjustArousal(4)
					M.adjustPleasure(1)
					user.adjustArousal(6)
					user.adjustArousal(8)
					M.adjustOxyLoss(1.5)
					if(prob(70) && (M.stat != DEAD))
						M.emote(pick("gasp","moan"))
					user.visible_message(span_purple("[user] [message]!"))
					playsound(loc, pick('modular_skyrat/modules/modular_items/lewd_items/sounds/bang1.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang2.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang3.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang4.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang5.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang6.ogg'), 40, TRUE)

				else
					to_chat(user, span_danger("Looks like [M]'s mouth is covered!"))
					return

			else
				if(M.is_bottomless())
					message = (user == M) ? pick("puts [src] into [M.p_their()] anus","slowly inserts [src] into [M.p_their()] ass") : pick("fucks [M]'s ass with [src]", "uses [src] to fuck [M]'s anus", "jams [M]'s ass with [src]", "roughly fucks [M]'s ass with [src], making [M.p_their()] eyes roll back")
					M.adjustArousal(5)
					M.adjustPleasure(5)
					user.adjustArousal(4)
					user.adjustPleasure(6)
					if(prob(60) && (M.stat != DEAD))
						M.emote(pick("twitch_s","moan","shiver"))
					user.visible_message(span_purple("[user] [message]!"))
					playsound(loc, pick('modular_skyrat/modules/modular_items/lewd_items/sounds/bang1.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang2.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang3.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang4.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang5.ogg',
										'modular_skyrat/modules/modular_items/lewd_items/sounds/bang6.ogg'), 100, TRUE)

				else
					to_chat(user, span_danger("[M]'s anus is covered!"))
					return
	else
		to_chat(user, span_danger("[M] doesn't want you to do that."))
		return