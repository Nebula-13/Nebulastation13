/client/verb/checkinvokingmagics()
	set name = "Check Invoking Magic"
	set desc = "Invoking magic wiki"
	set category = "OOC"
	var/datum/magic_menu/tgui  = new(usr)
	tgui.ui_interact(usr)

/datum/magic_menu
	var/client/holder

/datum/magic_menu/New(user)
	if (istype(user, /client))
		var/client/user_client = user
		holder = user_client
	else
		var/mob/user_mob = user
		holder = user_mob.client

/datum/magic_menu/ui_close()
	qdel(src)

/datum/magic_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/magic_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Invoking", "Invoking Magic")
		ui.open()

/datum/magic_menu/ui_data(mob/user)
	var/list/data = list()
	var/list/magic =  list()

	for(var/datum/magic/invoke/M in SSmagic.loaded_magic)
		magic = list()
		magic["name"] = M.name
		magic["desc"] = M.desc
		magic["complexity"] = M.complexity
		magic["mana"] = M.mana_cost
		magic["roundstart"] = M.roundstart
		magic["uses"] = M.uses
		magic["cooldown"] = M.cooldown ? time2text(M.cooldown, "mm:ss") : 0
		data["magics"] += list(magic)

	if(!length(data["magics"]))
		data["magics"] = null

	return data

/client/proc/add_magic_affinity()
	set category = "Admin.Fun"
	set name = "Add Magic Affinity"
	set desc = "Adds magic affinity to a player"

	if(!SSmagic && !SSmagic.initialized)
		to_chat(usr, "<span class='warning'>The magic subsystem has not been initialized yet!</span>")
		return

	var/list/players = list()

	for(var/mob/living/P in GLOB.mob_living_list)
		if(P.mind && P.client && !P.mind.magic_affinity)
			players |= P

	var/mob/living/selection = input("Select a player to add magic affinity", "Magic affinity", null, null) as null|anything in players

	if(!selection || !(selection in players))
		return

	selection.mind.store_memory(SSmagic.set_memory(selection))
	selection.mind.magic_affinity = TRUE
	SSmagic.invokers += selection

	log_admin("[key_name(usr)] added magic affinity to [selection]")
	message_admins("[key_name_admin(usr)] added magic affinity to [selection]")
