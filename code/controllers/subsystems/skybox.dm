
//Exists to handle a few global variables that change enough to justify this. Technically a parallax, but it exhibits a skybox effect.
SUBSYSTEM_DEF(skybox)
	name = "Space skybox"
	init_order = INIT_ORDER_SKYBOX
	flags = SS_NO_FIRE
	var/static/list/skybox_cache = list()

	var/static/list/dust_cache = list()
	var/static/list/speedspace_cache = list()
	var/static/list/mapedge_cache = list()
	var/static/list/phase_shift_by_x = list()
	var/static/list/phase_shift_by_y = list()

/datum/controller/subsystem/skybox/OnNew()
	//Static
	for (var/i in 0 to 25)
		var/image/im = image('icons/turf/space_dust.dmi', "[i]")
		im.plane = DUST_PLANE
		im.alpha = 128 //80
		im.blend_mode = BLEND_ADD
		dust_cache["[i]"] = im
	//Moving
	for (var/i in 0 to 14)
		// NORTH/SOUTH
		var/image/im = image('icons/turf/space_dust_transit.dmi', "speedspace_ns_[i]")
		im.plane = DUST_PLANE
		im.blend_mode = BLEND_ADD
		speedspace_cache["NS_[i]"] = im
		// EAST/WEST
		im = image('icons/turf/space_dust_transit.dmi', "speedspace_ew_[i]")
		im.plane = DUST_PLANE
		im.blend_mode = BLEND_ADD
		speedspace_cache["EW_[i]"] = im
	//Over-the-edge images
	for (var/dir in alldirs)
		var/image/I = image('icons/turf/space.dmi', "white")
		var/matrix/M = matrix()
		var/horizontal = (dir & (WEST|EAST))
		var/vertical = (dir & (NORTH|SOUTH))
		M.Scale(horizontal ? 8 : 1, vertical ? 8 : 1)
		I.transform = M
		I.appearance_flags = KEEP_APART | TILE_BOUND
		I.plane = SPACE_PLANE
		I.layer = 0

		if(dir & NORTH)
			I.pixel_y = 112
		else if(dir & SOUTH)
			I.pixel_y = -112

		if(dir & EAST)
			I.pixel_x = 112
		else if(dir & WEST)
			I.pixel_x = -112

		mapedge_cache["[dir]"] = I

	//Shuffle some lists
	phase_shift_by_x = get_cross_shift_list(15)
	phase_shift_by_y = get_cross_shift_list(15)


/datum/controller/subsystem/skybox/proc/get_skybox(z)
	if(!skybox_cache["[z]"])
		skybox_cache["[z]"] = generate_skybox(z)
	return skybox_cache["[z]"]

/datum/controller/subsystem/skybox/proc/generate_skybox(z)
	var/datum/skybox_settings/settings = global.using_map.get_skybox_datum(z)

	var/image/res = image(settings.icon)
	res.appearance_flags = KEEP_TOGETHER

	var/image/base = image(settings.icon, settings.icon_state)
	base.color = settings.color

	if(settings.use_stars)
		var/image/stars = image(settings.icon, settings.star_state)
		stars.appearance_flags = RESET_COLOR
		base.add_overlay(stars)

	res.add_overlay(base)

	if(global.using_map.use_overmap && settings.use_overmap_details)
		var/obj/effect/overmap/visitable/O = get_overmap_sector(z)
		if(istype(O))
			var/image/overmap = image(settings.icon)
			overmap.add_overlay(O.generate_skybox())
			var/list/add = list()
			for(var/obj/effect/overmap/visitable/other in O.loc)
				if(other != O)
					add += other.get_skybox_representation()
			overmap.add_overlay(add)
			overmap.appearance_flags = RESET_COLOR
			res.add_overlay(overmap)

	// Allow events to apply custom overlays to skybox! (Awesome!)
	var/list/add = list()
	for(var/datum/event/E in SSevents.active_events)
		if(E.has_skybox_image && E.isRunning && (z in E.affecting_z))
			add += E.get_skybox_image()
	res.add_overlay(add)

	return res

/datum/controller/subsystem/skybox/proc/rebuild_skyboxes(var/list/zlevels)
	for(var/z in zlevels)
		skybox_cache["[z]"] = generate_skybox(z)

	for(var/client/C in GLOB.clients)
		var/their_z = get_z(C.mob)
		if(!their_z) //Nullspace
			continue
		if(their_z in zlevels)
			C.update_skybox(1)

// Settings datum that maps can override to play with their skyboxes
/datum/skybox_settings
	var/icon = 'icons/skybox/skybox.dmi' //Path to our background. Lets us use anything we damn well please. Skyboxes need to be 736x736
	var/icon_state = "dyable"
	var/color
	var/random_color = FALSE

	var/use_stars = TRUE
	var/star_icon = 'icons/skybox/skybox.dmi'
	var/star_state = "stars"

	var/use_overmap_details = TRUE //Do we try to draw overmap visitables in our sector on the map?

/datum/skybox_settings/New()
	..()
	if(random_color)
		color = rgb(rand(0,255), rand(0,255), rand(0,255))
