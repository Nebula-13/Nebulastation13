/area/Entered(atom/movable/M)
	. = ..()
	var/obj/machinery/light_switch/L = locate() in src
	if(L && is_station_level(L.z))
		if(L.area.lightswitch)
			return
		L.area.lightswitch = TRUE
		L.area.update_appearance()

		for(var/obj/machinery/light_switch/S in area)
			S.update_appearance()

		L.area.power_change()

/area/Exited(atom/movable/M)
	. = ..()
	if(ismob(AM))
		var/mob/M = AM
		if(M.mind)
			var/stillPopulated = FALSE
			var/list/currentLivingMobs = GetAllContents(/mob/living)
			for(var/mob/living/L in currentLivingMobs)
				if(L.mind)
					stillPopulated = TRUE
					break
			if(!stillPopulated)
				var/obj/machinery/light_switch/L = locate() in src
				if(L && is_station_level(L.z))
					if(!L.area.lightswitch)
						return
					L.area.lightswitch = FALSE
					L.area.update_appearance()

					for(var/obj/machinery/light_switch/S in area)
						S.update_appearance()

					L.area.power_change()
