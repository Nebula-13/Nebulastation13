/area/Entered(atom/movable/M)
	. = ..()
	if(isliving(M))
		var/mob/living/AM = M
		if(AM.mind)
			var/obj/machinery/light_switch/L = locate() in src
			if(L && is_station_level(L.z))
				if(L.area.lightswitch)
					return
				L.area.lightswitch = TRUE
				L.area.update_appearance()

				for(var/obj/machinery/light_switch/S in L.area)
					S.update_appearance()

				L.area.power_change()
				playsound(L, 'modular_skyrat/modules/aesthetics/lightswitch/sound/lightswitch.ogg', 100, 1)

/area/Exited(atom/movable/M)
	. = ..()
	if(isliving(M))
		var/mob/living/AM = M
		if(AM.mind)
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

					for(var/obj/machinery/light_switch/S in L.area)
						S.update_appearance()

					L.area.power_change()
					playsound(L, 'modular_skyrat/modules/aesthetics/lightswitch/sound/lightswitch.ogg', 100, 1)
