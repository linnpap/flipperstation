/datum/lore/mission
	var/prefix = ""
	var/mission_strings = list()
	var/mission_type = ""

/datum/lore/mission/New(a,b,c)
	prefix = a
	mission_strings = b
	mission_type = c

/datum/lore/mission/prebuilt
/datum/lore/mission/prebuilt/New(a)
	prefix = a

//Default mission types for ease of populating organizations
//Most orgs that do medical missions are going to run comperable kinds of medical mission
/datum/lore/mission/prebuilt/medical
	mission_strings = list("medical", "medical resupply", "hospital", "pathogen containment")
	mission_type = ATC_MED

/datum/lore/mission/prebuilt/transport
	mission_strings = list("transport", "passenger transport", "general transport", "courier", "just-in-time delivery")
	mission_type = ATC_TRANS

/datum/lore/mission/prebuilt/freight
	mission_strings = list("freight", "hauling", "bulk transport", "materials delivery")
	mission_type = ATC_FREIGHT

/datum/lore/mission/prebuilt/defense
	mission_strings = list("defense", "asset protection", "patrol")
	mission_type = ATC_DEF

/datum/lore/mission/prebuilt/industrial
	mission_strings = list("industrial", "construction", "repair", "maintence", "factory resupply")
	mission_type = ATC_INDU

/datum/lore/mission/prebuilt/scientific
	mission_strings = list("scientific", "research", "data collection", "survey")
	mission_type = ATC_SCI

/datum/lore/mission/prebuilt/diplomatic
	mission_strings = list("diplomatic") //theres not a lot of words for 'diplomatic'
	mission_type = ATC_DIPLO

/datum/lore/mission/prebuilt/luxury
	mission_strings = list("luxury cruise", "pleasure cruise", "VIP transport", "sight-seeing", "vacation")
	mission_type = ATC_LUX

/datum/lore/mission/prebuilt/transport/default
	prefix = "ITV"