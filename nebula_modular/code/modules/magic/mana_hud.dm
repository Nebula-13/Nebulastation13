/datum/hud
	var/atom/movable/screen/mana

/datum/hud/Destroy()
	mana = null
	return ..()

/datum/hud/human/New(mob/living/carbon/human/owner)
	. = ..()
	mana = new /atom/movable/screen/mana()
	mana.hud = src
	infodisplay += mana

/atom/movable/screen/mana
	name = "mana"
	icon = 'nebula_modular/icons/manabar.dmi'
	icon_state = "nothing"
	screen_loc = ui_mana

/atom/movable/screen/mana/Click()
	if(!iscarbon(usr))
		return
	var/mob/living/carbon/C = usr
	to_chat(C, "<span class='notice'><b>Mana: [C.mana]/[C.mana_max]</b></span>")
