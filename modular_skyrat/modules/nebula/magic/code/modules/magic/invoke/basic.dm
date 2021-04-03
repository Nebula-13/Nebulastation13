/datum/magic/invoke/sparks
	name = "Summon Sparks"
	complexity = 3
	possible_words = list("spark", "scintilla", "accendo", "kindle", "incito", "ignesco")

/datum/magic/invoke/sparks/fire(mob/living/firer, amped)
	do_sparks(amped ? 6 : 3, TRUE, firer)

/datum/magic/invoke/locator
	name = "Magic Locator"
	complexity = 4
	residual_cost = 10
	uses = 1
	possible_words = list("cogitare", "ostende", "inveniet", "quaerere", "vestium", "dimensionem", "spectrum")

/datum/magic/invoke/locator/fire(mob/living/firer, amped)
	if(check_uses(firer))
		firer.handle_rejection(src)
		firer.log_message("Misfired [name] ([type])", LOG_ATTACK)
		to_chat(firer, "<span class='danger'>[name] misfired! You can no longer use this magic.</span>")
		firer.residual_energy += residual_cost * SSmagic.magical_factor
		misfire(firer, FALSE)
		return

	var/obj/structure/closet/locker = SSbluespace_locker.external_locker
	if(locker)
		var/obj/effect/temp_visual/eye_locator/o = new (get_turf(locker))
		o.set_light(6, 5)
		animate(o, alpha = 255, time = 3 SECONDS)
		firer.reset_perspective(o)
		firer.Immobilize(45)
		do_sparks(3, TRUE, o)
		addtimer(CALLBACK(firer, /mob/living/.proc/reset_perspective), 5 SECONDS)

/obj/effect/temp_visual/eye_locator
	name = "eye locator"
	icon = 'modular_skyrat/modules/nebula/magic/icons/eye.dmi'
	icon_state = "eye"
	duration = 51 // deciseconds
	randomdir = FALSE
	alpha = 0
	anchored = TRUE
