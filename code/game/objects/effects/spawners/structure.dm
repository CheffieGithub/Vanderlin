/*
Because mapping is already tedious enough this spawner let you spawn generic
"sets" of objects rather than having to make the same object stack again and
again.
*/

/obj/effect/spawner/structure
	name = "map structure spawner"
	var/list/spawn_list

/obj/effect/spawner/structure/Initialize()
	. = ..()
	if(LAZYLEN(spawn_list))
		for(var/I in spawn_list)
			new I(get_turf(src))
	return INITIALIZE_HINT_QDEL
