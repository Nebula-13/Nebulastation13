/mob/living/proc/try_say_magic(msg)
	. = FALSE
	if(!msg)
		return
	if(!SSmagic || !SSmagic.initialized)
		return
	var/trimmed = trim(lowertext(msg))
	var/list/split_pre = splittext(trimmed, " ")
	for(var/datum/magic/invoke/MI in SSmagic.loaded_magic)
		if(MI.counter_charm && (trimmed in MI.counter_charm))
			MI.counter(src)
			whisper(msg)
			return TRUE
		if(split_pre.len < MI.complexity)
			continue
		var/list/split = list()
		var/ok = TRUE
		for(var/i = 1 to MI.complexity)
			if(!(split_pre[i] in MI.possible_words))
				ok = FALSE
				break
			split += split_pre[i]
		if(!ok)
			continue

		var/diff = length(difflist(MI.phrase_list, split))
		if(!diff && trimmed == MI.phrase)
			if(MI.whisper)
				whisper(msg)
			MI.fire_process(src, MI)
			return TRUE

		else if(diff <= MI.max_misfire || (!diff && trimmed != MI.phrase))
			if(MI.whisper)
				whisper(msg)
			MI.misfire_process(src, MI)
			return TRUE

/datum/mind
	var/magic_affinity = FALSE

/mob/living
	var/mana_max = 0
	var/mana = 0
	var/obj/marked_item
	var/obj/bluespace_fissure
	var/list/used_magics = list()
	var/list/cdr_magics = list()

/mob/living/carbon/Initialize()
	. = ..()
	mana_max = rand(MANA_MIN, MANA_MAX)
	mana = mana_max

/mob/living/Destroy()
	. = ..()
	QDEL_LIST(used_magics)
	QDEL_LIST(cdr_magics)
	QDEL_NULL(marked_item)
	QDEL_NULL(bluespace_fissure)

/mob/living/proc/process_residual_energy()
	var/static/list/beneficial_clothes = typecacheof(list(
		/obj/item/clothing/suit/wizrobe,
		/obj/item/clothing/head/wizard
	))

	. = 5
	if(mind && (mind.assigned_role == "Scientist" || mind.assigned_role == "Research Director"))
		. -= 0.5
	var/obj/item/clothing/helmet = get_item_by_slot(ITEM_SLOT_HEAD)
	if(is_type_in_typecache(helmet, beneficial_clothes))
		. += 0.45
	else
		if(helmet && istype(helmet))
			if(helmet.clothing_flags & THICKMATERIAL)
				. -= 0.5
	var/obj/item/clothing/armor = get_item_by_slot(ITEM_SLOT_OCLOTHING)
	if(is_type_in_typecache(armor, beneficial_clothes))
		. += 0.75
	else
		if(armor && istype(armor))
			if(armor.clothing_flags & THICKMATERIAL)
				if(armor.body_parts_covered & CHEST)
					. -= 0.5
				if(armor.body_parts_covered & GROIN)
					. -= 0.5
				if(armor.body_parts_covered & LEGS)
					. -= 0.5
				if(armor.body_parts_covered & ARMS)
					. -= 0.5

/mob/living/proc/handle_rejection(datum/magic/MI)
	if(MI.should_reject(src))
		log_message("Experienced rejection from [MI.name] ([MI.type])", LOG_ATTACK)
		visible_message("<span class='danger'>[src]'s blood vessels burst!</span>", "<span class='userdanger'>Your blood vessels burst!</span>")
		adjustToxLoss(2 * SSmagic.magical_factor)
		return TRUE
	return FALSE

/mob/living/carbon/Life(delta_time, times_fired)
	. = ..()
	if(.)
		if(mana_max && mana < mana_max)
			var/flat = MANA_REGEN
			if(IsSleeping())
				flat += MANA_REGEN_EXTRA
			mana += round(flat + (mana/MANA_REGEN_COEFF) * MANA_REGEN_MULTIPLIER)
			if(mana > mana_max)
				mana = mana_max

		if(mind?.magic_affinity && hud_used?.mana && mana != mana_max)
			if(mana >= mana_max-10)
				hud_used.mana.icon_state = "10"
			else if(mana >= mana_max*0.9)
				hud_used.mana.icon_state = "9"
			else if(mana >= mana_max*0.8)
				hud_used.mana.icon_state = "8"
			else if(mana >= mana_max*0.7)
				hud_used.mana.icon_state = "7"
			else if(mana >= mana_max*0.6)
				hud_used.mana.icon_state = "6"
			else if(mana >= mana_max*0.5)
				hud_used.mana.icon_state = "5"
			else if(mana >= mana_max*0.4)
				hud_used.mana.icon_state = "4"
			else if(mana >= mana_max*0.3)
				hud_used.mana.icon_state = "3"
			else if(mana >= mana_max*0.2)
				hud_used.mana.icon_state = "2"
			else if(mana >= mana_max*0.1)
				hud_used.mana.icon_state = "1"
			else
				hud_used.mana.icon_state = "0"
		else
			if(hud_used?.mana.icon_state == "nothing")
				return
			else
				hud_used?.mana.icon_state = "nothing"

/mob/living/carbon/handle_rejection(datum/magic/MI) //
	. = ..()
	if(.)
		if(prob(60))
			vomit(FALSE, TRUE, FALSE, rand(1, 3))

/mob/living/carbon/human/handle_rejection(datum/magic/MI)
	. = ..()
	if(.)
		bleed(5 * SSmagic.magical_factor * 0.6)
		//physiology.bleed_mod = max(physiology.bleed_mod + (0.5 * SSmagic.magical_factor), 0.5 * SSmagic.magical_factor)

/mob/living/say(message, bubble_type, list/spans, sanitize, datum/language/language, ignore_spam, forced)
	if(findtext(message, "pq"))
		message = replacetext(message, "pq", "porque")
	if(findtext(message, "vc"))
		message = replacetext(message, "vc", "você")
	. = ..()
