/datum/species/unathi
	mob_size = MOB_MEDIUM //To allow normal mob swapping
	spawn_flags = SPECIES_CAN_JOIN //Species_can_join is the only spawn flag all the races get, so that none of them will be whitelist only if whitelist is enabled.
	limb_blend = ICON_MULTIPLY
	icobase = 'modular_flipper/icons/mob/human_races/r_lizard.dmi'
	deform = 'modular_flipper/icons/mob/human_races/r_def_lizard.dmi'
	min_age = 18
	inherent_verbs = list(/mob/living/carbon/human/proc/tie_hair)
	genders = list(MALE, FEMALE, PLURAL, NEUTER)
	descriptors = list()
	male_scream_sound = 'modular_flipper/sound/effects/mob_effects/lizard_scream.ogg'
	female_scream_sound	= 'modular_flipper/sound/effects/mob_effects/lizard_scream.ogg'

/datum/species/tajaran
	icobase = 'modular_flipper/icons/mob/human_races/r_tajaran.dmi'
	deform = 'modular_flipper/icons/mob/human_races/r_def_tajaran.dmi'
	limb_blend = ICON_MULTIPLY
	min_age = 18
	inherent_verbs = list(/mob/living/carbon/human/proc/tie_hair)
	allergens = null
	heat_discomfort_level = 295 //Prevents heat discomfort spam at 20c
	genders = list(MALE, FEMALE, PLURAL, NEUTER)

/datum/species/skrell
	icobase = 'modular_flipper/icons/mob/human_races/r_skrell.dmi'
	deform = 'modular_flipper/icons/mob/human_races/r_def_skrell.dmi'
	limb_blend = ICON_MULTIPLY
	min_age = 18
	inherent_verbs = list(/mob/living/carbon/human/proc/tie_hair)
	reagent_tag = null
	allergens = null
	assisted_langs = list(LANGUAGE_EAL, LANGUAGE_ROOTLOCAL, LANGUAGE_ROOTGLOBAL, LANGUAGE_VOX)
	genders = list(MALE, FEMALE, PLURAL, NEUTER)

/datum/species/human
	min_age = 18
	genders = list(MALE, FEMALE, PLURAL, NEUTER)

/datum/species/human/vatgrown
	spawn_flags = SPECIES_IS_RESTRICTED

/datum/species/zaddat
	spawn_flags = SPECIES_IS_RESTRICTED

/datum/species/diona
	spawn_flags = SPECIES_IS_RESTRICTED
