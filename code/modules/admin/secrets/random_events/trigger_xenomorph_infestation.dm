/datum/admin_secret_item/random_event/trigger_xenomorph_infestation
	name = "Trigger a Skathari Incursion"

/datum/admin_secret_item/random_event/trigger_xenomorph_infestation/execute(var/mob/user)
	. = ..()
	if(.)
		return xenomorphs.attempt_random_spawn()
