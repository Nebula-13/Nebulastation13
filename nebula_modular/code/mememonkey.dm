//had to improve monkey code in monkey_controller.dm lol - also it'll literally also be fixed in a TGstation PR like tomorrow, merge conflict galore!

/obj/structure/rinha_de_macaco
	name = "MONKEY RAGE BEACON"
	desc = "<span class='danger'>BLOOD IS FUEL. OTHER MONKEYS ARE FULL.</span>"
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "tdoppler"
	base_icon_state = "tdoppler"
	density = TRUE
	anchored = TRUE

	verb_say = "SAYS"
	verb_ask = "ASKS"
	verb_exclaim = "EXCLAIMS"
	verb_whisper = "WHISPERS"
	verb_sing = "SINGS"
	verb_yell = "YELLS"
	speech_span = "monkeyhive"

	var/list/contestants = list()
	var/list/possible_weapons = list(
		/obj/item/kitchen/knife = 10,
		/obj/item/spear = 10,
		/obj/item/kitchen/knife/combat = 10,
		/obj/item/storage/toolbox = 10,
		/obj/item/melee/chainofcommand/tailwhip/kitty = 10,
		/obj/item/hatchet = 10,
		/obj/item/circular_saw = 9,
		/obj/item/claymore = 8,
		/obj/item/melee/sabre = 8,
		/obj/item/melee/synthetic_arm_blade = 7,
		/obj/item/claymore/highlander = 2,
		/obj/item/his_grace = 1,
	) //sadly two-handed items are hardcoded to not be wielded by monkeys, so no doom chainsaw today

/obj/structure/rinha_de_macaco/attack_ghost(mob/user)
	. = ..()
	//no admin check, the admin check is this being spawned in by one in the first palce
	var/how_many_monkeys = input(user, "How many monkeys do you want to spawn? (leave blank for none)", "RIP AND TEAR UNTIL IT IS DONE") as null|num
	if(how_many_monkeys)
		for(var/i in 1 to how_many_monkeys) //FUCK IT, NO CAP ON MONKEY AMOUNT
			new /mob/living/carbon/human/species/monkey(get_turf(src))
	var/guns = FALSE
	if(alert(user, "Give weapons to the monkeys? (They cannot be stolen by players)", "RIP AND TEAR UNTIL IT IS DONE", "YES", "NO") == "YES")
		guns = TRUE
	if(alert(user, "Do you want to start the bloodshed?", "RIP AND TEAR UNTIL IT IS DONE", "YES", "NOT YET") != "YES")
		return
	bloodshed(guns)

/obj/structure/rinha_de_macaco/proc/bloodshed(arm_monkeys = TRUE)
	var/list/found = viewers(5, src)
	for(var/mob/living/carbon/human/species/monkey/monke in found)
		if(ismonkey(monke) && istype(monke.ai_controller, /datum/ai_controller/monkey))
			contestants |= monke

			var/datum/ai_controller/monkey/ai = monke.ai_controller
			ai.bloodshed(found.Copy())
			arm_monkey(monke, arm_monkeys)

	if(length(contestants))
		add_atom_colour(rgb(211, 40, 40), TEMPORARY_COLOUR_PRIORITY)
		START_PROCESSING(SSobj, src)

/obj/structure/rinha_de_macaco/proc/end_bloodshed()
	STOP_PROCESSING(SSobj, src)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, rgb(211, 40, 40))
	contestants = list()

//copied and changed from mayhem status effect lol
/obj/structure/rinha_de_macaco/proc/arm_monkey(mob/living/carbon/human/target, give_weapon = FALSE)
	if(give_weapon)
		var/obj/item/weapon = pickweight(possible_weapons)
		weapon = new weapon
		target.drop_all_held_items()
		target.put_in_hands(weapon, del_on_fail = TRUE, forced = TRUE)
		ADD_TRAIT(weapon, TRAIT_NODROP, "rinha de macaco")
		weapon.item_flags = DROPDEL

	to_chat(target, "<span class='reallybig redtext'>BLOOD IS FUEL. OTHER MONKEYS ARE FULL. RIP AND TEAR, UNTIL IT IS DONE.</span>")
	SEND_SOUND(target, sound('sound/hallucinations/veryfar_noise.ogg'))
	target.log_message("entered a blood frenzy due to a monkey rage beacon", LOG_ATTACK)
	var/datum/client_colour/colour = target.add_client_colour(/datum/client_colour/bloodlust)
	QDEL_IN(colour, 1.1 SECONDS)

/datum/ai_controller/monkey/proc/bloodshed(list/mortal_enemies)
	mortal_enemies -= src

	blackboard[BB_MONKEY_AGRESSIVE] = TRUE
	var/list/enemies = blackboard[BB_MONKEY_ENEMIES]
	for(var/mob/living/carbon/human/H in mortal_enemies)
		enemies[H] = 100 // FIGHT TO THE DEATH!


/obj/structure/rinha_de_macaco/process(delta_time)
	for(var/mob/living/L in contestants)
		if(L.stat)
			say(uppertext("[L] HAS BEEN DEFEATED IN COMBAT! [L.p_their()] BLOOD REINVIGORATES THEIR ENEMIES!"))
			for(var/mob/living/target in viewers(2, get_turf(L)))
				target.heal_overall_damage(50)
			L.gib(TRUE, TRUE, TRUE)
			contestants.Remove(L)
	switch(length(contestants))
		if(1) //a winner is you!
			var/mob/living/winner = contestants[1]
			say(uppertext("[winner] HAS WON THE BLOODSHED!"))
			congratulate_winner(winner)
			end_bloodshed()
		if(0) //everyone left died in between last process and this one
			say("EVERYONE IS DEAD, NO ONE WINS THIS BLOODSHED!")
			end_bloodshed()


/obj/structure/rinha_de_macaco/proc/congratulate_winner(mob/living/carbon/human/winner)
	if(prob(25))
		winner.gorillize()
	winner.maxHealth *= 1.5
	winner.revive(full_heal = TRUE, admin_revive = TRUE)
	winner.melee_damage_lower *= 2
	winner.melee_damage_upper *= 2
	winner.transform *= 1.5
	winner.add_atom_colour(rgb(211, 40, 40), ADMIN_COLOUR_PRIORITY)

