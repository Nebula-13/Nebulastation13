SUBSYSTEM_DEF(magic)
	name = "Magic"
	wait = 5 MINUTES
	init_order = INIT_ORDER_XKEYSCORE
	flags = SS_TICKER
	var/magical_factor
	var/residual_energy = 0
	var/stage_atual = 0
	var/join_magic_prob = 40
	var/list/loaded_magic = list()
	var/list/all_phrases_list = list()
	var/list/invokers = list()
	var/let_residual_decay = FALSE
	var/wave_effects = FALSE

/datum/controller/subsystem/magic/Initialize()
	. = ..()
	magical_factor = rand(MAGIC_RANDOMIZATION_MIN, MAGIC_RANDOMIZATION_MAX) * 0.5
	for(var/m in subtypesof(/datum/magic))
		var/datum/magic/M = m
		if(initial(M.name))
			log_game("Loaded magic [initial(M.name)]!")
			var/datum/magic/magick = new m
			magick.setup()
			loaded_magic += magick

/datum/controller/subsystem/magic/fire()

	for(var/mob/living/carbon/C in GLOB.mob_living_list)
		if(C.stat != DEAD && C.mind && C.mind.magic_affinity && !(C in invokers))
			invokers |= C

	process_residuo()

	if(let_residual_decay)
		residual_decay()

/datum/controller/subsystem/magic/proc/process_stage(stage)
	if(stage_atual == stage)
		return
	stage_atual = stage
	var/message = pick("You feel a shiver down your spine.. the magical residue is increasing!", "A chill runs down your spine as the magical residue increses..")
	switch(stage)
		if(RESIDUAL_STAGE_1)
			for(var/mob/living/carbon/H in invokers)
				if(prob(40))
					H.adjustOrganLoss(ORGAN_SLOT_BRAIN, rand(6, 12) * magical_factor)
				H.AddComponent(/datum/component/omen, silent=TRUE)
				message = "You feel a shiver down your spine as the magical residue increases.."

		if(RESIDUAL_STAGE_2)
			for(var/mob/living/carbon/H in invokers)
				if(prob(60))
					H.vomit(15, TRUE, FALSE)
					new /mob/living/simple_animal/hostile/cockroach/leech(get_turf(H))
				else
					if(prob(40))
						H.vomit(20, FALSE, FALSE)

		if(RESIDUAL_STAGE_3)
			for(var/mob/living/carbon/H in invokers)
				if(prob(30))
					var/n = 1
					for(var/V in H.held_items)
						var/obj/item/I = V
						if(istype(I) && H.dropItemToGround(I))
							H.put_in_hands(new /obj/item/putrid_hand())
							var/obj/item/bodypart/B = H.hand_bodyparts[n]
							B.receive_damage(100)
							addtimer(CALLBACK(B, /obj/item/bodypart./proc/dismember), 2 MINUTES)
							to_chat(H, "<span class='warning'>Your arm has been corrupted due to the high level of magical residue! Be careful, your arm will fall soon.</span>")
							break
						n++
				else
					if(prob(40))
						var/obj/item/organ/tongue/tongue
						for(var/org in H.internal_organs)
							if(istype(org, /obj/item/organ/tongue))
								tongue = org
								break
						if(!tongue)
							to_chat(H, "<span class='warning'>Your body burns!</span>")
							H.adjustFireLoss(rand(5, 10))
							return
						to_chat(H, "<span class='warning'>You feel your tongue being devoured inside.</span>")
						H.vomit(25, TRUE, FALSE)
						new /obj/structure/spider/spiderling/hunter(get_turf(H))
						tongue.Remove(H)
						tongue.forceMove(get_turf(H))
						tongue.name = "rotting tongue"
						tongue.icon_state = "tonguezombie"
						H.dna.add_mutation(/datum/mutation/human/mute, MUT_EXTRA, 5 MINUTES)

		if(RESIDUAL_STAGE_4)
			let_residual_decay = TRUE
			wait = 2 MINUTES
			if(prob(50))
				var/list/center_finder = list()
				for(var/es in GLOB.generic_event_spawns)
					var/obj/effect/landmark/event_spawn/temp = es
					if(is_station_level(temp.z))
						center_finder += temp
				if(!center_finder.len)
					CRASH("No landmarks on the station map, aborting")
				var/turf/location = get_turf(pick(center_finder))
				new /obj/effect/membrane(location)
				priority_announce("WARNING - Due to the high amount of residual energy concentrated in this sector, a fissure in the membrane was opened in \the [get_area_name(location, TRUE)]!", "Alert", 'sound/misc/notice1.ogg')
			for(var/mob/living/carbon/H in invokers)
				H.vomit(20, TRUE, FALSE)
				H.Jitter(20)
				H.apply_status_effect(STATUS_EFFECT_CONVULSING)
				message = "You feel like something terrible has happened.."

	for(var/mob/living/carbon/H in invokers)
		to_chat(H, "<span class='warning'><b><font color='#57139b'>[message]</font></b></span>")

/datum/controller/subsystem/magic/proc/residual_decay()
	if(residual_energy > 0)
		var/residual_decay = round(length(invokers) * magical_factor)
		if(residual_decay)
			residual_energy -= residual_decay

	if(residual_energy <= 0)
		residual_energy = 0
		stage_atual = 0
		let_residual_decay = FALSE
		wait = 5 MINUTES

/datum/controller/subsystem/magic/proc/process_residuo(amount)
	if(amount)
		residual_energy += amount

	switch(residual_energy)
		if(250 to 400)
			process_stage(RESIDUAL_STAGE_1)
		if(400 to 650)
			process_stage(RESIDUAL_STAGE_2)
		if(650 to 850)
			process_stage(RESIDUAL_STAGE_3)
		if(850 to INFINITY)
			process_stage(RESIDUAL_STAGE_4)

/datum/controller/subsystem/magic/proc/set_memory(mob/living/user)
	if(user.mind && SSmagic && SSmagic.initialized)
		var/turf/chosen_location = get_safe_random_station_turf()
		new /obj/effect/blue_fire(chosen_location, user, TRUE)
		var/phrase_text = "You have been blessed with the power to invoke magic! But you feel a strange aurea coming from \the [get_area_name(chosen_location, TRUE)].."
		return	phrase_text

// Itens / effects / mobs related
/obj/effect/membrane
	name = "membrane"
	desc = "You should run now."
	icon = 'icons/effects/effects.dmi'
	icon_state = "rift"
	density = TRUE
	anchored = TRUE
	var/list/to_spawn = list(/mob/living/simple_animal/hostile/zombie/membrane, /mob/living/simple_animal/hostile/faithless,
							/mob/living/simple_animal/hostile/poison/giant_spider, /mob/living/simple_animal/hostile/poison/giant_spider/hunter,
							/mob/living/simple_animal/hostile/blob/blobbernaut, /mob/living/simple_animal/hostile/netherworld)
	var/list/spawner_turfs = list()
	var/spawn_amount = 5
	var/cooldown = 1 MINUTES
	var/timer = 0

/obj/effect/membrane/Initialize(mapload)
	. = ..()
	for(var/range_turf in RANGE_TURFS(6, src))
		if(!isopenturf(range_turf) || isspaceturf(range_turf))
			continue
		spawner_turfs += range_turf
	for(var/i in 1 to spawn_amount)
		if(!length(spawner_turfs))
			break
		var/turf/spawner_turf = pick(spawner_turfs)
		var/picked_mob = pick(to_spawn)
		new picked_mob(spawner_turf)

	START_PROCESSING(SSobj, src)

/obj/effect/membrane/Destroy()
	STOP_PROCESSING(SSobj, src)
	SSmagic?.residual_energy = 0
	SSmagic?.stage_atual = 0
	priority_announce("The membrane has been stabilized, your sector is now safe again! Kill the remaining monsters and go back to work.", "Alert", 'sound/misc/notice2.ogg')
	return ..()

/obj/effect/membrane/process()
	if(timer > world.time)
		return
	var/count = 0
	for(var/mob/living/simple_animal/hostile/m in range(12, src))
		count++
	if(count < spawn_amount)
		var/picked_mob = pick(to_spawn)
		new picked_mob(get_turf(pick(spawner_turfs)))
	timer = world.time + cooldown

/obj/effect/membrane/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/nullrod) || istype(I, /obj/item/storage/book/bible))
		user.visible_message("<span class='danger'>[user] seals \the [src] with \the [I].</span>")
		qdel(src)
		return
	else
		return ..()

/mob/living/simple_animal/hostile/zombie/membrane
	melee_damage_lower = 16
	melee_damage_upper = 16

/mob/living/simple_animal/hostile/zombie/membrane/setup_visuals()
	return

/obj/effect/membrane/singularity_act()
	return

/obj/effect/membrane/singularity_pull()
	return

/mob/living/simple_animal/hostile/cockroach/leech
	name = "Leech"
	icon = 'nebula_modular/icons/leech.dmi'
	icon_state = "leech"
	icon_dead = "leech-dead"
	health = 15
	maxHealth = 15
	turns_per_move = 1
	see_in_dark = 10
	move_to_delay = 1
	melee_damage_lower = 7
	melee_damage_upper = 7
	obj_damage = 20
	robust_searching = 1
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	faction = list("hostile")

/mob/living/simple_animal/hostile/cockroach/leech/make_squashable()
	return

/obj/item/putrid_hand
	name = "putrid hand"
	desc = "A cursed hand."
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'nebula_modular/icons/putrid.dmi'
	icon_state = "putrid"
	inhand_icon_state = "putrid"
	lefthand_file = 'nebula_modular/icons/putrid_left.dmi'
	righthand_file = 'nebula_modular/icons/putrid_right.dmi'
	force = 0

/obj/item/putrid_hand/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	QDEL_IN(src, 2 MINUTES)

/obj/item/putrid_hand/attack(mob/living/M, mob/living/user, params)
	to_chat(user, "<span class='warning'>You can't use this arm!</span>")
	return

/obj/item/putrid_hand/attack_obj(obj/O, mob/living/user, params)
	to_chat(user, "<span class='warning'>You can't use this arm!</span>")
	return

/obj/item/putrid_hand/attack_secondary(mob/living/victim, mob/living/user, params)
	to_chat(user, "<span class='warning'>You can't use this arm!</span>")
	return

/obj/item/putrid_hand/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	to_chat(user, "<span class='warning'>You can't use this arm!</span>")
	return

