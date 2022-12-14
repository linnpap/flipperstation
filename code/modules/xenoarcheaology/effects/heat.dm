/datum/artifact_effect/common/heat
	name = "heat"
	effect_color = "#ff6600"
	var/target_temp

/datum/artifact_effect/common/heat/New()
	..()
	effect = pick(EFFECT_TOUCH, EFFECT_AURA)
	effect_type = pick(EFFECT_ORGANIC, EFFECT_BLUESPACE, EFFECT_SYNTH)
	target_temp = rand(300, 600)


/datum/artifact_effect/common/heat/DoEffectTouch(mob/living/user)
	var/atom/holder = get_master_holder()
	if (holder)
		to_chat(user, "<font color='red'> You feel a wave of heat travel up your spine!</font>")
		var/datum/gas_mixture/env = holder.loc.return_air()
		if (env)
			env.temperature += rand(5,50)


/datum/artifact_effect/common/heat/DoEffectAura()
	var/atom/holder = get_master_holder()
	if (holder)
		var/datum/gas_mixture/env = holder.loc.return_air()
		if (env && env.temperature < target_temp)
			env.temperature += pick(0, 0, 1)
