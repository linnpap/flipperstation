// Inherits from /book/ so it can fit on bookshelves.
/obj/item/book/codex
	name = "Generic Codex: Electric Bugaloo"
	desc = "If you can read this, something is broken!"
	icon_state = "codex"
	item_state = "book4"
	unique = TRUE
	var/datum/codex_tree/tree = null
	var/root_type = /datum/lore/codex/category/main_vir_lore	//Runtimes on codex_tree.dm, line 18 with a null here

/obj/item/book/codex/Initialize()
	tree = new(src, root_type)
	. = ..()

/obj/item/book/codex/attack_self(mob/user)
	if(!tree)
		tree = new(src, root_type)
	icon_state = "[initial(icon_state)]-open"
	tree.display(user)

/obj/item/book/codex/lore/vir
	name = "The Traveler's Guide to Human Space: Vir Edition"
	desc = "Contains useful information about the world around you.  It seems to have been written for travelers to Vir, human or not.   It also \
	has the words 'Don't Panic' in small, friendly letters on the cover."
	icon_state = "codex"
	root_type = /datum/lore/codex/category/main_vir_lore
	libcategory = "Reference"

/obj/item/book/codex/lore/robutt
	name = "A Buyer's Guide to Artificial Bodies"
	desc = "Recommended reading for the newly cyborgified, new positronics, and the upwardly-mobile FBP."
	icon_state = "codex_robutt"
	item_state = "book6"
	root_type = /datum/lore/codex/category/main_robutts
	libcategory = "Reference"

/obj/item/book/codex/lore/news
	name = "Daedalus Pocket Newscaster"
	desc = "A regularly-updating compendium of articles on current events. Essential for new arrivals in the Vir system and anyone interested in politics."
	icon_state = "newscodex"
	item_state = "book1"
	w_class = ITEMSIZE_SMALL
	root_type = /datum/lore/codex/category/main_news
	libcategory = "Reference"
	drop_sound = 'sound/items/drop/device.ogg'
// Combines SOP/Regs/Law
/obj/item/book/codex/corp_regs
	name = "NanoTrasen Regulatory Compendium"
	desc = "Contains large amounts of information on Standard Operating Procedure, Corporate Regulations, and important regional laws.  The best friend of \
	Internal Affairs."
	icon_state = "corp_regs"
	item_state = "book10"
	root_type = /datum/lore/codex/category/main_corp_regs
	throwforce = 5 // Throw the book at 'em.
	libcategory = "Reference"
