/datum/persistent/paper/sticky
	name = "stickynotes"
	paper_type = /obj/item/paper/sticky
	requires_noticeboard = FALSE

/datum/persistent/paper/sticky/CreateEntryInstance(var/turf/creating, var/list/token)
	var/atom/paper = ..()
	if(paper)
		paper.pixel_x = token["offset_x"]
		paper.pixel_y = token["offset_y"]
		paper.color =   token["color"]
	return paper

/datum/persistent/paper/sticky/CompileEntry(var/atom/entry, var/write_file)
	. = ..()
	var/obj/item/paper/sticky/paper = entry
	LAZYADDASSOC(., "offset_x", paper.pixel_x)
	LAZYADDASSOC(., "offset_y", paper.pixel_y)
	LAZYADDASSOC(., "color", paper.color)