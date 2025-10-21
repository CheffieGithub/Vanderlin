/// Unit test to check if any outfit changes the stats or skills of a mob
/datum/unit_test/outfit_stats_change/Run()
	var/mob/living/carbon/human/man = allocate(/mob/living/carbon/human)
	for(var/datum/outfit/outfit in subtypesof(/datum/outfit))

		man.reset_stats()
		man.purge_all_skills()
		man.status_traits.Cut() // :)

		outfit.equip(man)

		if(length(man.skills?.known_skills))
			for(var/datum/skill/skill in man.skills?.known_skills)
				TEST_FAIL("[outfit.type] modifies [skill.type]")

		if(length(man.status_traits))
			TEST_FAIL("[outfit.type] modifies Traits")

		if(man.STASTR != 10)
			TEST_FAIL("[outfit.type] modifies STR")
		if(man.STAPER != 10)
			TEST_FAIL("[outfit.type] modifies PER")
		if(man.STAEND != 10)
			TEST_FAIL("[outfit.type] modifies END")
		if(man.STACON != 10)
			TEST_FAIL("[outfit.type] modifies CON")
		if(man.STAINT != 10)
			TEST_FAIL("[outfit.type] modifies INT")
		if(man.STASPD != 10)
			TEST_FAIL("[outfit.type] modifies SPD")
		if(man.STALUC != 10)
			TEST_FAIL("[outfit.type] modifies LUC")
