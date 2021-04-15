GLOBAL_DATUM_INIT(blue_fire_track, /datum/blue_fire_tracker, new)

/datum/blue_fire_tracker
	var/list/all_words = list()

// Blue fire
/obj/effect/blue_fire
	name = "\the invoking magic"
	icon = 'modular_skyrat/modules/nebula/magic/icons/blue_fire.dmi'
	anchored = TRUE
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF
	invisibility = INVISIBILITY_OBSERVER
	light_color = "#3399ff"
	light_power = 1.2
	light_range = 1.4
	var/image_state = "blue_fire"
	var/image/img
	var/mob/living/who	//the mob that can see us
	var/generate_more = FALSE	//generate more when destroyed?
	var/datum/magic/invoke/MI	//the invoke magic assoc to this effect
	var/word = ""	//a word from the invoking magic phrase

/obj/effect/blue_fire/Initialize(mapload, mob/living/user, generate = FALSE, pick_magic = FALSE)
	. = ..()
	img = image(icon, src, image_state, OBJ_LAYER)
	if(user)
		AddMob(user)
	if(generate)
		generate_more = TRUE
	if(pick_magic)
		generate_name()
	set_light_range_power_color(light_range, light_power, light_color)

/obj/effect/blue_fire/Destroy()
	img = null
	if(generate_more && who)
		Generate(who)
	if(who)
		RemoveMob(who)
	return ..()

/obj/effect/blue_fire/proc/Generate(mob/caller)
	var/count = length(SSmagic.all_phrases_list)
	for(var/i = 1 to count)
		var/turf/chosen_location = get_safe_random_station_maint_turf()
		var/obj/effect/blue_fire/what_if_i_have_one = locate() in range(8, chosen_location)
		if(what_if_i_have_one && what_if_i_have_one != src && what_if_i_have_one.who == who)
			continue
		new /obj/effect/blue_fire(chosen_location, caller, FALSE, TRUE)
	GLOB.blue_fire_track.all_words.Cut()
	GLOB.blue_fire_track.all_words = SSmagic.all_phrases_list.Copy()

/obj/effect/blue_fire/attack_hand(mob/living/user, list/modifiers)
	if(generate_more)
		to_chat(user, "<span class='notice'>You touch the blue fire and it dissipates into the air making a flash.. Look for more blue fires in maintenance to gain knowledge about spells.</span>")
		var/mob/living/carbon/H = user
		playsound(src, 'sound/magic/teleport_app.ogg', 50, TRUE)
		H.flash_act(1, 1)
		do_sparks(1, TRUE, src)
		qdel(src)
		return

	if(!word)
		return
	to_chat(user, "<span class='notice'>You touch the blue fire and it dissipates into the air leaving a word in a sequence.. <b><font color='#57139b'>[word]</font></b></span>")
	playsound(src, pick('sound/magic/teleport_app.ogg', 'sound/magic/teleport_diss.ogg'), 50, TRUE)
	var/mob/living/carbon/H = user
	H.flash_act(1, 1)
	do_sparks(1, TRUE, src)
	qdel(src)

/obj/effect/blue_fire/proc/ReworkNetwork()
	if(who && who.client)
		who.client.images |= img

/obj/effect/blue_fire/proc/AddMob(mob/living/user)
	if(!user)
		return
	RegisterSignal(user,COMSIG_MOB_LOGIN,.proc/ReworkNetwork)
	who = user
	if(user.client)
		user.client.images |= img

/obj/effect/blue_fire/proc/RemoveMob(mob/living/user)
	if(!user)
		return
	UnregisterSignal(user,COMSIG_MOB_LOGIN)
	who = null
	if(user.client)
		user.client.images -= img

/obj/effect/blue_fire/proc/generate_name()
	for(var/datum/magic/invoke/M in SSmagic.loaded_magic)
		if(M.roundstart)
			continue
		for(var/w = 1 to M.phrase_list.len)
			if(M.phrase_list[w] in GLOB.blue_fire_track.all_words)
				GLOB.blue_fire_track.all_words -= M.phrase_list[w]
				MI = M
				if(M.phrase_list.len == 1 && w == M.phrase_list.len)
					word = "[MI.name] has only one word: [M.phrase_list[w]]. This spell is now complete!"
				else if(w == M.phrase_list.len)
					word = "the last word for \the [MI.name], [w]: [M.phrase_list[w]]"
				else
					word = "[w]: [M.phrase_list[w]]"
				name = MI.name
				return

/proc/get_safe_random_station_maint_turf()
	var/list/areas_to_pick_from = list()
	for(var/area/maintenance/M in world)
		areas_to_pick_from += M
	for (var/i in 1 to 5)
		var/list/L = get_area_turfs(pick(areas_to_pick_from))
		var/turf/target
		while (L.len && !target)
			var/I = rand(1, L.len)
			var/turf/T = L[I]
			if(!T.density)
				var/clear = TRUE
				for(var/obj/O in T)
					if(O.density)
						clear = FALSE
						break
				if(clear)
					target = T
			if (!target)
				L.Cut(I,I+1)
		if (target)
			return target
