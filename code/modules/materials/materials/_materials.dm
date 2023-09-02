/*
	MATERIAL DATUMS
	This data is used by various parts of the game for basic physical properties and behaviors
	of the metals/materials used for constructing many objects. Each var is commented and should be pretty
	self-explanatory but the various object types may have their own documentation. ~Z

	PATHS THAT USE DATUMS
		turf/simulated/wall
		obj/item/material
		obj/structure/barricade
		obj/item/stack/material
		obj/structure/table

	VALID ICONS
		WALLS
			stone
			metal
			solid
			resin
			ONLY WALLS
				cult
				hull
				curvy
				jaggy
				brick
				REINFORCEMENT
					reinf_over
					reinf_mesh
					reinf_cult
					reinf_metal
		DOORS
			stone
			metal
			resin
			wood
*/

// Assoc list containing all material datums indexed by name.
var/global/list/name_to_material

//Returns the material the object is made of, if applicable.
//Will we ever need to return more than one value here? Or should we just return the "dominant" material.
/obj/proc/get_material()
	return null

//mostly for convenience
/obj/proc/get_material_name()
	var/datum/material/material = get_material()
	if(material)
		return material.name

// Builds the datum list above.
/proc/populate_material_list(force_remake=0)
	if(name_to_material && !force_remake) return // Already set up!
	name_to_material = list()
	for(var/type in subtypesof(/datum/material))
		var/datum/material/new_mineral = new type
		if(!new_mineral.name)
			continue
		name_to_material[lowertext(new_mineral.name)] = new_mineral
	return 1

// Safety proc to make sure the material list exists before trying to grab from it.
/proc/get_material_by_name(name)
	name = lowertext(name)
	if(!name_to_material)
		populate_material_list()
	return name_to_material[name]

/proc/material_display_name(name)
	var/datum/material/material = get_material_by_name(name)
	if(material)
		return material.display_name
	return null

// Material definition and procs follow.
/datum/material
	var/name	                          // Unique name for use in indexing the list.
	var/display_name                      // Prettier name for display.
	var/use_name
	var/flags = 0                         // Various status modifiers.
	var/sheet_singular_name = "sheet"
	var/sheet_plural_name = "sheets"
	var/is_fusion_fuel

	// Shards/tables/structures
	var/shard_type = SHARD_SHRAPNEL       // Path of debris object.
	var/shard_icon                        // Related to above.
	var/shard_can_repair = 1              // Can shards be turned into sheets with a welder?
	var/list/recipes                      // Holder for all recipes usable with a sheet of this material.
	var/destruction_desc = "breaks apart" // Fancy string for barricades/tables/objects exploding.

	// Icons
	var/icon_colour                                      // Colour applied to products of this material.
	var/icon_base = "metal"                              // Wall and table base icon tag. See header.
	var/door_icon_base = "metal"                         // Door base icon tag. See header.
	var/icon_reinf = "reinf_metal"                       // Overlay used
	var/list/stack_origin_tech = list(TECH_MATERIAL = 1) // Research level for stacks.
	var/pass_stack_colors = FALSE                        // Will stacks made from this material pass their colors onto objects?

	// Attributes
	var/cut_delay = 0            // Delay in ticks when cutting through this wall.
	var/radioactivity            // Radiation var. Used in wall and object processing to irradiate surroundings.
	var/ignition_point           // K, point at which the material catches on fire.
	var/melting_point = 1800     // K, walls will take damage if they're next to a fire hotter than this
	var/integrity = 150          // General-use HP value for products.
	var/protectiveness = 10      // How well this material works as armor.  Higher numbers are better, diminishing returns applies.
	var/opacity = 1              // Is the material transparent? 0.5< makes transparent walls/doors.
	var/reflectivity = 0         // How reflective to light is the material?  Currently used for laser reflection and defense.
	var/explosion_resistance = 5 // Only used by walls currently.
	var/negation = 0             // Objects that respect this will randomly absorb impacts with this var as the percent chance.
	var/spatial_instability = 0  // Objects that have trouble staying in the same physical space by sheer laws of nature have this. Percent for respecting items to cause teleportation.
	var/conductive = 1           // Objects without this var add ATOM_IS_INSULATED to flags on spawn.
	var/conductivity = null      // How conductive the material is. Iron acts as the baseline, at 10.
	var/list/composite_material  // If set, object matter var will be a list containing these values.
	var/luminescence
	var/radiation_resistance = 0 // Radiation resistance, which is added on top of a material's weight for blocking radiation. Needed to make lead special without superrobust weapons.
	var/supply_conversion_value  // Supply points per sheet that this material sells for.

	var/perunit = SHEET_MATERIAL_AMOUNT //How much stacks of translate from sheet to amount

	// Placeholder vars for the time being, todo properly integrate windows/light tiles/rods.
	var/created_window
	var/created_fulltile_window
	var/rod_product
	var/wire_product
	var/list/window_options = list()

	// Damage values.
	var/hardness = 60            // Prob of wall destruction by hulk, used for edge damage in weapons.  Also used for bullet protection in armor.
	var/weight = 20              // Determines blunt damage/throwforce for weapons.

	// Noise when someone is faceplanted onto a table made of this material.
	var/tableslam_noise = 'sound/weapons/tablehit1.ogg'
	// Noise made when a simple door made of this material opens or closes.
	var/dooropen_noise = 'sound/effects/stonedoor_openclose.ogg'
	// Path to resulting stacktype. Todo remove need for this.
	var/stack_type
	// Wallrot crumble message.
	var/rotting_touch_message = "crumbles under your touch"

// Placeholders for light tiles and rglass.
/datum/material/proc/build_rod_product(var/mob/user, var/obj/item/stack/used_stack, var/obj/item/stack/target_stack)
	if(!rod_product)
		to_chat(user, "<span class='warning'>You cannot make anything out of \the [target_stack]</span>")
		return
	if(used_stack.get_amount() < 1 || target_stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need one rod and one sheet of [display_name] to make anything useful.</span>")
		return
	used_stack.use(1)
	target_stack.use(1)
	var/obj/item/stack/S = new rod_product(get_turf(user))
	S.add_fingerprint(user)
	S.add_to_stacks(user)

/datum/material/proc/build_wired_product(var/mob/living/user, var/obj/item/stack/used_stack, var/obj/item/stack/target_stack)
	if(!wire_product)
		to_chat(user, "<span class='warning'>You cannot make anything out of \the [target_stack]</span>")
		return
	if(used_stack.get_amount() < 5 || target_stack.get_amount() < 1)
		to_chat(user, "<span class='warning'>You need five wires and one sheet of [display_name] to make anything useful.</span>")
		return

	used_stack.use(5)
	target_stack.use(1)
	to_chat(user, "<span class='notice'>You attach wire to the [name].</span>")
	var/obj/item/product = new wire_product(get_turf(user))
	user.put_in_hands(product)

// Make sure we have a display name and shard icon even if they aren't explicitly set.
/datum/material/New()
	..()
	if(!display_name)
		display_name = name
	if(!use_name)
		use_name = display_name
	if(!shard_icon)
		shard_icon = shard_type

// This is a placeholder for proper integration of windows/windoors into the system.
/datum/material/proc/build_windows(var/mob/living/user, var/obj/item/stack/used_stack)
	return 0

// Weapons handle applying a divisor for this value locally.
/datum/material/proc/get_blunt_damage()
	return weight //todo

// Return the matter comprising this material.
/datum/material/proc/get_matter()
	var/list/temp_matter = list()
	if(islist(composite_material))
		for(var/material_string in composite_material)
			temp_matter[material_string] = composite_material[material_string]
	else
		temp_matter[name] = SHEET_MATERIAL_AMOUNT
	return temp_matter

// As above.
/datum/material/proc/get_edge_damage()
	return hardness //todo

// Snowflakey, only checked for alien doors at the moment.
/datum/material/proc/can_open_material_door(var/mob/living/user)
	return 1

// Currently used for weapons and objects made of uranium to irradiate things.
/datum/material/proc/products_need_process()
	return (radioactivity>0) //todo

// Used by walls when qdel()ing to avoid neighbor merging.
/datum/material/placeholder
	name = "placeholder"

// Places a girder object when a wall is dismantled, also applies reinforced material.
/datum/material/proc/place_dismantled_girder(var/turf/target, var/datum/material/reinf_material, var/datum/material/girder_material)
	var/obj/structure/girder/G = new(target)
	if(reinf_material)
		G.reinf_material = reinf_material
		G.reinforce_girder()
	if(girder_material)
		if(istype(girder_material, /datum/material))
			girder_material = girder_material.name
		G.set_material(girder_material)


// General wall debris product placement.
// Not particularly necessary aside from snowflakey cult girders.
/datum/material/proc/place_dismantled_product(var/turf/target)
	place_sheet(target)

/datum/material/proc/get_place_stack_type()
	return stack_type

// Debris product. Used ALL THE TIME.
/datum/material/proc/place_sheet(var/turf/target, var/amount)
	var/place_stack_type = get_place_stack_type()
	if(place_stack_type)
		return new place_stack_type(target, amount)

// As above.
/datum/material/proc/place_shard(var/turf/target)
	if(shard_type)
		return new /obj/item/material/shard(target, src.name)

// Used by walls and weapons to determine if they break or not.
/datum/material/proc/is_brittle()
	return !!(flags & MATERIAL_BRITTLE)

/datum/material/proc/combustion_effect(var/turf/T, var/temperature)
	return

// Used by walls to do on-touch things, after checking for crumbling and open-ability.
/datum/material/proc/wall_touch_special(var/turf/simulated/wall/W, var/mob/living/L)
	return

/datum/material/proc/get_recipes()
	if(!recipes)
		generate_recipes()
	return recipes

/datum/material/proc/generate_recipes()
	// If is_brittle() returns true, these are only good for a single strike.
	recipes = list(
		new /datum/stack_recipe("[display_name] baseball bat", /obj/item/material/twohanded/baseballbat, 10, time = 20, one_per_turf = 0, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
		new /datum/stack_recipe("[display_name] ashtray", /obj/item/material/ashtray, 2, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
		new /datum/stack_recipe("[display_name] spoon", /obj/item/material/kitchen/utensil/spoon/plastic, 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
		new /datum/stack_recipe("[display_name] armor plate", /obj/item/material/armor_plating, 1, time = 20, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
		new /datum/stack_recipe("[display_name] armor plate insert", /obj/item/material/armor_plating/insert, 2, time = 40, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
		new /datum/stack_recipe("[display_name] grave marker", /obj/item/material/gravemarker, 5, time = 50, supplied_material = "[name]", pass_stack_color = TRUE),
		new /datum/stack_recipe("[display_name] ring", /obj/item/clothing/gloves/ring/material, 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
		new /datum/stack_recipe("[display_name] bracelet", /obj/item/clothing/accessory/bracelet/material, 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE)
	)

	if(integrity>=50)
		recipes += list(
			new /datum/stack_recipe("[display_name] door", /obj/structure/simple_door, 10, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] barricade", /obj/structure/barricade, 5, time = 50, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] stool", /obj/item/stool, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] chair", /obj/structure/bed/chair, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] bed", /obj/structure/bed, 2, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] double bed", /obj/structure/bed/double, 4, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] wall girders", /obj/structure/girder, 2, time = 50, one_per_turf = 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE)
		)

	if(hardness>50)
		recipes += list(
			new /datum/stack_recipe("[display_name] fork", /obj/item/material/kitchen/utensil/fork/plastic, 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] knife", /obj/item/material/knife/plastic, 1, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] blade", /obj/item/material/butterflyblade, 6, time = 20, one_per_turf = 0, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE),
			new /datum/stack_recipe("[display_name] defense wire", /obj/item/material/barbedwire, 10, time = 1 MINUTE, one_per_turf = 0, on_floor = 1, supplied_material = "[name]", pass_stack_color = TRUE)
		)

/datum/material/proc/get_wall_texture()
	return
