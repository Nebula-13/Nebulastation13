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
