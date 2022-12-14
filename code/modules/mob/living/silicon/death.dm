/mob/living/silicon/gib()
	..("gibbed-r")
	gibs(loc, null, /obj/effect/spawner/gibs/robot)

/mob/living/silicon/dust()
	..("dust-r", /obj/effect/decal/remains/robot)

/mob/living/silicon/ash()
	..("dust-r")

/mob/living/silicon/death(gibbed,deathmessage)
	if(in_contents_of(/obj/machinery/recharge_station))//exit the recharge station
		var/obj/machinery/recharge_station/RC = loc
		RC.go_out()
	return ..(gibbed,deathmessage)