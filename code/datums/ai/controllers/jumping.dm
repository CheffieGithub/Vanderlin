/datum/ai_controller/jumping_jacks
	ai_movement = /datum/ai_movement/astar
	can_jump = TRUE

	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/basic()
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
	)

	idle_behavior = /datum/idle_behavior/idle_random_walk

/mob/living/carbon/human/species/skeleton/npc/jumping_jacks
	ai_controller = /datum/ai_controller/jumping_jacks
