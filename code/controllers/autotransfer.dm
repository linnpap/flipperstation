var/global/datum/controller/transfer_controller/transfer_controller

/datum/controller/transfer_controller
	var/timerbuffer = 0 //buffer for time check
	var/currenttick = 0
/datum/controller/transfer_controller/New()
	timerbuffer = config.vote_autotransfer_initial
	START_PROCESSING(SSprocessing, src)

/datum/controller/transfer_controller/Destroy()
	STOP_PROCESSING(SSprocessing, src)

/datum/controller/transfer_controller/process()
	currenttick = currenttick + 1
	if (round_duration_in_ds >= timerbuffer - 1 MINUTE)
		SSvote.autotransfer()
		timerbuffer = timerbuffer + config.vote_autotransfer_interval
