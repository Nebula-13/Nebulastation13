GLOBAL_VAR_INIT(magicStorageTurf, null)

// Pocket Dimension
/datum/magic/invoke/dimension
	name = "Pocket Dimension"
	complexity = 5
	residual_cost = 12
	whisper = FALSE
	cooldown = 2 MINUTES
	possible_words = list("sinum", "excitandus", "patefacio", "sursum", "abditum", "ianua", "ostium", "revelare")
	counter_charm = list("revenite")

	var/datum/map_template/pocket_dimension/hotelRoomTemp
	var/datum/map_template/pocket_dimension/empty/hotelRoomTempEmpty
	var/datum/turf_reservation/ReservationStorage
	var/list/activeRooms = list()
	var/list/storedRooms = list()
	var/storageTurf

/datum/magic/invoke/dimension/setup()
	. = ..()
	//Load templates
	hotelRoomTemp = new()
	hotelRoomTempEmpty = new()

	if(!storageTurf)
		if(!GLOB.magicStorageTurf)
			var/datum/map_template/pocket_dimension_storage/storageTemp = new()
			var/datum/turf_reservation/storageReservation = SSmapping.RequestBlockReservation(3, 3)
			storageTemp.load(locate(storageReservation.bottom_left_coords[1], storageReservation.bottom_left_coords[2], storageReservation.bottom_left_coords[3]))
			GLOB.magicStorageTurf = locate(storageReservation.bottom_left_coords[1]+1, storageReservation.bottom_left_coords[2]+1, storageReservation.bottom_left_coords[3])
			ReservationStorage = storageReservation
		else
			storageTurf = GLOB.magicStorageTurf

/datum/magic/invoke/dimension/fire(mob/living/firer, amped)
	if(istype(get_area(firer), /area/pocket_dimension))
		to_chat(firer, "<span class='danger'>You can't use it while inside the pocket dimension!</span>")
		return TRUE
	if(do_after(firer, 4 SECONDS, firer))
		firer.whisper(pick("aperi ianuam", "sinum dimensionem", "ostende te"))
		firer.visible_message("<span class='warning'>[firer] starts distorting the space around it!</span>")
		var/list/manifestations = list()
		manifest_dimension(ReservationStorage, firer, manifestations)
		if(do_after(firer, 7 SECONDS, firer))
			firer.whisper(pick("in utre aquas maris", "ostium revelare", "ipsum revelare"))
			de_manifest(manifestations)
			promptAndCheckIn(firer)
			return FALSE
		de_manifest(manifestations)
	to_chat(firer, "<span class='danger'>You need to focus!</span>")
	return TRUE

/datum/magic/invoke/dimension/counter(mob/living/firer)
	if(!istype(get_area(firer), /area/pocket_dimension))
		to_chat(firer, "<span class='danger'>You're not in the pocket dimension!</span>")
		return
	promptExit(firer)

/datum/magic/invoke/dimension/proc/promptAndCheckIn(mob/living/user)
	var/chosenRoomNumber = user?.mind
	if(!chosenRoomNumber)
		return

	if(user.bluespace_fissure)
		QDEL_NULL(user.bluespace_fissure)
	var/obj/effect/bluespace_fissure/fissure = new(get_turf(user))
	user.bluespace_fissure = fissure

	if(tryActiveRoom(chosenRoomNumber, user))
		return
	if(tryStoredRoom(chosenRoomNumber, user))
		return
	sendToNewRoom(chosenRoomNumber, user)

/datum/magic/invoke/dimension/proc/promptExit(mob/living/user)
	if(!user.bluespace_fissure)
		to_chat(user, "<span class='warning'>The portal seems to be malfunctioning and refuses to open!</span>")
		return
	playsound(user, 'sound/magic/teleport_diss.ogg', 50, FALSE)
	var/atom/movable/pull = user.pulling
	if(pull && ((isobj(pull) && !pull.anchored) || (isliving(pull) && user.grab_state == GRAB_AGGRESSIVE)))
		pull.alpha = 0
		animate(pull, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
		pull.forceMove(get_turf(user.bluespace_fissure))
		if(isliving(pull))
			var/mob/living/LL = pull
			to_chat(LL, "<span class='danger'>All of existence fades out for a moment...</span>")
			LL.Paralyze(5 SECONDS)
	user.alpha = 0
	animate(user, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
	user.forceMove(get_turf(user.bluespace_fissure))
	if(pull)
		user.start_pulling(pull)

	QDEL_NULL(user.bluespace_fissure)

/datum/magic/invoke/dimension/proc/tryActiveRoom(roomNumber, mob/living/user)
	if(activeRooms["[roomNumber]"])
		var/datum/turf_reservation/roomReservation = activeRooms["[roomNumber]"]
		update_pocket_mirror(roomReservation, user)
		playsound(user, 'sound/magic/teleport_app.ogg', 50, FALSE)
		var/atom/movable/pull = user.pulling
		if(pull && ((isobj(pull) && !pull.anchored) || (isliving(pull) && user.grab_state == GRAB_AGGRESSIVE)))
			pull.alpha = 0
			animate(pull, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
			pull.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
			if(isliving(pull))
				var/mob/living/LL = pull
				to_chat(LL, "<span class='danger'>All of existence fades out for a moment...</span>")
				LL.Paralyze(5 SECONDS)
		user.alpha = 0
		animate(user, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
		user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
		if(pull)
			user.start_pulling(pull)
		return TRUE
	else
		return FALSE

/datum/magic/invoke/dimension/proc/tryStoredRoom(roomNumber, mob/living/user)
	if(storedRooms["[roomNumber]"])
		var/datum/turf_reservation/roomReservation = SSmapping.RequestBlockReservation(hotelRoomTemp.width, hotelRoomTemp.height)
		hotelRoomTempEmpty.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
		var/turfNumber = 1
		for(var/i=0, i<hotelRoomTemp.width, i++)
			for(var/j=0, j<hotelRoomTemp.height, j++)
				for(var/atom/movable/A in storedRooms["[roomNumber]"][turfNumber])
					if(istype(A.loc, /obj/item/abstractpocketstorage))//Don't want to recall something thats been moved
						A.forceMove(locate(roomReservation.bottom_left_coords[1] + i, roomReservation.bottom_left_coords[2] + j, roomReservation.bottom_left_coords[3]))
				turfNumber++
		for(var/obj/item/abstractpocketstorage/S in storageTurf)
			if(S.roomNumber == roomNumber)
				qdel(S)
		storedRooms -= "[roomNumber]"
		activeRooms["[roomNumber]"] = roomReservation
		linkTurfs(roomReservation, roomNumber, user)
		update_pocket_mirror(roomReservation, user)
		playsound(user, 'sound/magic/teleport_app.ogg', 50, FALSE)
		var/atom/movable/pull = user.pulling
		if(pull && ((isobj(pull) && !pull.anchored) || (isliving(pull) && user.grab_state == GRAB_AGGRESSIVE)))
			pull.alpha = 0
			animate(pull, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
			pull.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
			if(isliving(pull))
				var/mob/living/LL = pull
				to_chat(LL, "<span class='danger'>All of existence fades out for a moment...</span>")
				LL.Paralyze(5 SECONDS)
		user.alpha = 0
		animate(user, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
		user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
		if(pull)
			user.start_pulling(pull)
		return TRUE
	else
		return FALSE

/datum/magic/invoke/dimension/proc/sendToNewRoom(roomNumber, mob/living/user)
	var/datum/turf_reservation/roomReservation = SSmapping.RequestBlockReservation(hotelRoomTemp.width, hotelRoomTemp.height)
	hotelRoomTemp.load(locate(roomReservation.bottom_left_coords[1], roomReservation.bottom_left_coords[2], roomReservation.bottom_left_coords[3]))
	activeRooms["[roomNumber]"] = roomReservation
	linkTurfs(roomReservation, roomNumber, user)
	update_pocket_mirror(roomReservation, user)
	playsound(user, 'sound/magic/teleport_app.ogg', 50, FALSE)
	var/atom/movable/pull = user.pulling
	if(pull && ((isobj(pull) && !pull.anchored) || (isliving(pull) && user.grab_state == GRAB_AGGRESSIVE)))
		pull.alpha = 0
		animate(pull, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
		pull.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
		if(isliving(pull))
			var/mob/living/LL = pull
			to_chat(LL, "<span class='danger'>All of existence fades out for a moment...</span>")
			LL.Paralyze(5 SECONDS)
	user.alpha = 0
	animate(user, alpha = 255, time = 2 SECONDS, easing = LINEAR_EASING)
	user.forceMove(locate(roomReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, roomReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, roomReservation.bottom_left_coords[3]))
	if(pull)
		user.start_pulling(pull)

/datum/magic/invoke/dimension/proc/linkTurfs(datum/turf_reservation/currentReservation, currentRoomnumber, mob/living/user)
	var/area/pocket_dimension/currentArea = get_area(locate(currentReservation.bottom_left_coords[1], currentReservation.bottom_left_coords[2], currentReservation.bottom_left_coords[3]))
	currentArea.name = "Pocket Dimension Room [currentRoomnumber]"
	currentArea.parentSphere = src
	currentArea.storageTurf = storageTurf
	currentArea.roomnumber = currentRoomnumber
	currentArea.reservation = currentReservation
	currentArea.global_turf_object = get_turf(user.bluespace_fissure)

/datum/magic/invoke/dimension/proc/ejectRooms()
	if(activeRooms.len)
		for(var/x in activeRooms)
			var/datum/turf_reservation/room = activeRooms[x]
			for(var/i=0, i<hotelRoomTemp.width, i++)
				for(var/j=0, j<hotelRoomTemp.height, j++)
					for(var/atom/movable/A in locate(room.bottom_left_coords[1] + i, room.bottom_left_coords[2] + j, room.bottom_left_coords[3]))
						if(ismob(A))
							var/mob/M = A
							if(M.mind)
								to_chat(M, "<span class='warning'>As the portal fissure breaks apart, you're suddenly ejected into the depths of space!")
						var/max = world.maxx-TRANSITIONEDGE
						var/min = 1+TRANSITIONEDGE
						var/list/possible_transtitons = list()
						for(var/AZ in SSmapping.z_list)
							var/datum/space_level/D = AZ
							if (D.linkage == CROSSLINKED)
								possible_transtitons += D.z_value
						var/_z = pick(possible_transtitons)
						var/_x = rand(min,max)
						var/_y = rand(min,max)
						var/turf/T = locate(_x, _y, _z)
						A.forceMove(T)
			qdel(room)

	if(storedRooms.len)
		for(var/x in storedRooms)
			var/list/atomList = storedRooms[x]
			for(var/atom/movable/A in atomList)
				var/max = world.maxx-TRANSITIONEDGE
				var/min = 1+TRANSITIONEDGE
				var/list/possible_transtitons = list()
				for(var/AZ in SSmapping.z_list)
					var/datum/space_level/D = AZ
					if (D.linkage == CROSSLINKED)
						possible_transtitons += D.z_value
				var/_z = pick(possible_transtitons)
				var/_x = rand(min,max)
				var/_y = rand(min,max)
				var/turf/T = locate(_x, _y, _z)
				A.forceMove(T)

/datum/magic/invoke/dimension/proc/update_pocket_mirror(datum/turf_reservation/currentReservation, mob/living/user)
	var/list/turflist = list()
	for(var/turf/t in range(3, user.bluespace_fissure.loc))
		turflist += t
	var/n = 1
	for(var/turf/open/indestructible/pocketspace/BSturf in range(3, locate(currentReservation.bottom_left_coords[1] + hotelRoomTemp.landingZoneRelativeX, currentReservation.bottom_left_coords[2] + hotelRoomTemp.landingZoneRelativeY, currentReservation.bottom_left_coords[3])))
		BSturf.vis_contents.Cut()
		BSturf.vis_contents += turflist[n]
		n++

//Manifest dimension stuff
/datum/magic/invoke/dimension/proc/manifest_dimension(datum/turf_reservation/roomReservation, mob/living/user, list/manifestations)
	var/corrected_max = clamp(user.x - 1, 1, world.maxx)
	var/corrected_may = clamp(user.y - 1, 1, world.maxy)
	for(var/mx = 0 to 3)
		for(var/my = 0 to 3)
			var/turf/us = locate(corrected_max + mx, corrected_may + my, user.z)
			var/turf/them = locate(roomReservation.bottom_left_coords[1] + mx, roomReservation.bottom_left_coords[2] + my, roomReservation.bottom_left_coords[3])
			if(us && them)
				var/obj/effect/manifestation/M = new(us)
				M.vis_contents += them
				manifestations += M

/datum/magic/invoke/dimension/proc/de_manifest(list/manifestations)
	for(var/obj/effect/manifestation/M in manifestations)
		manifestations -= M
		animate(M, alpha = 0, time = 2 SECONDS, easing = LINEAR_EASING)
		QDEL_IN(M, 3 SECONDS)

//Template Stuff
/datum/map_template/pocket_dimension
	name = "Pocket Dimension Room"
	mappath = '_maps/templates/pocket_dimension.dmm'
	var/landingZoneRelativeX = 4
	var/landingZoneRelativeY = 4

/datum/map_template/pocket_dimension/empty
	name = "Empty Pocket Dimension Room"
	mappath = '_maps/templates/pocket_dimensionempty.dmm'

/datum/map_template/pocket_dimension_storage
	name = "Pocket Dimension Storage"
	mappath = '_maps/templates/pocket_dimensionstorage.dmm'

//Effects
/obj/effect/bluespace_fissure
	name = "bluespace fissure"
	icon_state = "bluestream_fade"
	desc = "Seems like an interdimensional portal was opened here.."
	anchored = TRUE
	layer = ABOVE_MOB_LAYER

/obj/effect/manifestation
	layer = ABOVE_LIGHTING_PLANE
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	alpha = 0
	mouse_opacity = FALSE
	var/next_animate = 0

/obj/effect/manifestation/Initialize()
	. = ..()
	var/X,Y,i,rsq
	for(i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	START_PROCESSING(SSobj, src)
	animate(src, alpha = 127, time = 3 SECONDS, easing = LINEAR_EASING)

/obj/effect/manifestation/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/effect/manifestation/process()
	if(next_animate > world.time)
		return
	var/i,f
	for(i=1, i<=7, ++i)
		f = filters[i]
		var/next = rand()*20+10
		animate(f, offset=f:offset, time=0, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=next)
		next_animate = world.time + next

//Turfs and Areas
/area/pocket_dimension
	name = "Pocket Dimension Room"
	icon_state = "hilbertshotel"
	requires_power = FALSE
	has_gravity = TRUE
	area_flags = NOTELEPORT | HIDDEN_AREA
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	ambientsounds = list('sound/ambience/servicebell.ogg')
	var/roomnumber = 0
	var/datum/magic/invoke/dimension/parentSphere
	var/datum/turf_reservation/reservation
	var/turf/storageTurf

/area/pocket_dimension/Exited(atom/movable/AM)
	. = ..()
	if(ismob(AM))
		var/mob/M = AM
		if(M.mind)
			var/stillPopulated = FALSE
			var/list/currentLivingMobs = GetAllContents(/mob/living) //Got to catch anyone hiding in anything
			for(var/mob/living/L in currentLivingMobs) //Check to see if theres any sentient mobs left.
				if(L.mind)
					stillPopulated = TRUE
					break
			if(!stillPopulated)
				storeRoom()

/area/pocket_dimension/proc/storeRoom()
	var/roomSize = (reservation.top_right_coords[1]-reservation.bottom_left_coords[1]+1)*(reservation.top_right_coords[2]-reservation.bottom_left_coords[2]+1)
	var/storage[roomSize]
	var/turfNumber = 1
	var/obj/item/abstractpocketstorage/storageObj = new(storageTurf)
	storageObj.roomNumber = roomnumber
	storageObj.parentSphere = parentSphere
	storageObj.name = "Room [roomnumber] Storage"
	for(var/i=0, i<parentSphere.hotelRoomTemp.width, i++)
		for(var/j=0, j<parentSphere.hotelRoomTemp.height, j++)
			var/list/turfContents = list()
			for(var/atom/movable/A in locate(reservation.bottom_left_coords[1] + i, reservation.bottom_left_coords[2] + j, reservation.bottom_left_coords[3]))
				if(ismob(A) && !isliving(A))
					continue //Don't want to store ghosts
				turfContents += A
				A.forceMove(storageObj)
			storage[turfNumber] = turfContents
			turfNumber++
	parentSphere.storedRooms["[roomnumber]"] = storage
	parentSphere.activeRooms -= "[roomnumber]"
	qdel(reservation)

/area/pocket_dimension_storage
	name = "Pocket Dimension Storage Room"
	icon_state = "hilbertshotel"
	requires_power = FALSE
	has_gravity = TRUE
	area_flags = HIDDEN_AREA | NOTELEPORT | UNIQUE_AREA

/turf/open/indestructible/pocketspace
	name = "interdimensional distortion"
	icon = 'icons/turf/space.dmi'
	icon_state = "0"
	appearance_flags = KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE
	//var/next_animate = 0

/turf/open/indestructible/pocketspace/Initialize()
	. = ..()
	animate(src, alpha = 127, time = 3 SECONDS, easing = LINEAR_EASING)
	if(SSmagic.wave_effects)
		WaveEffect()

#define WAVE_COUNT 7

/turf/open/indestructible/pocketspace/proc/WaveEffect()
	var/start = filters.len
	var/X,Y,i,rsq,f
	for(i=1, i<=7, ++i)
		do
			X = 60*rand() - 30
			Y = 60*rand() - 30
			rsq = X*X + Y*Y
		while(rsq<100 || rsq>900)
		filters += filter(type="wave", x=X, y=Y, size=rand()*2.5+0.5, offset=rand())
	for(i=1, i<=7, ++i)
		f = filters[start+i]
		animate(f, offset=f:offset, time=0, loop=-1, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=rand()*20+10)

#undef WAVE_COUNT

/*/turf/open/indestructible/pocketspace/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/turf/open/indestructible/pocketspace/process()
	if(next_animate > world.time)
		return
	var/i,f
	for(i=1, i<=7, ++i)
		f = filters[i]
		var/next = rand()*20+10
		animate(f, offset=f:offset, time=0, loop=3, flags=ANIMATION_PARALLEL)
		animate(offset=f:offset-1, time=next)
		next_animate = world.time + next*/

/obj/item/abstractpocketstorage
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = ABSTRACT
	var/roomNumber
	var/datum/magic/invoke/dimension/parentSphere

/obj/item/abstractpocketstorage/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(ismob(AM))
		var/mob/M = AM
		M.notransform = TRUE

/obj/item/abstractpocketstorage/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if(ismob(AM))
		var/mob/M = AM
		M.notransform = FALSE
