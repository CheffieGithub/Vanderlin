/mob/living/carbon/human/proc/introduce(name, job, pronouns)
	var/message = "I am [name], I am \an [lowertext(job)]."
	if(job && !name)
		message = "My name is not important, I am \an [lowertext(job)]."
	else if(name && !job)
		message = "My name is [name]."
	else if(!job && !name)
		message = "Remember my voice, for it is all you shall know."

	if(pronouns)
		switch(pronouns)
			if(HE_HIM)
				message += " Refer to me as a man."
			if(SHE_HER)
				message += " Refer to me as a woman."
			if(THEY_THEM)
				message += " Refer to me as a collective."

	say(message, spans = list("notice"))

	for(var/atom/movable/hearing_movable as anything in get_hearers_in_view(7, src) - src)
		if(!ishuman(hearing_movable))
			return
		var/mob/living/carbon/human/H = hearing_movable
		H.mind?.know_person(mind, name, job, pronouns)

/// We know person
/datum/mind/proc/know_person(datum/mind/person, name, job, pronouns)
	if(QDELETED(person))
		return

	if(person == src)
		return

	if(!ishuman(person.current))
		return
	var/mob/living/carbon/human/H = person.current

	var/used_name = name
	var/used_job = job
	var/datum/relationship/existing = LAZYACCESS(known_people, H.mobid)
	if(!existing)
		H.playsound_local(H, 'sound/misc/notice (2).ogg', 100, FALSE)
		var/voice_type // If gender and voice type are the same ignore voice type
		if(!(H.voice_type in VOICE_MAP_DEFAULT[H.gender]))
			voice_type = H.voice_type
		var/datum/relationship/relation = new(person, used_name, used_job, H.gender, H.age, H.voice_color, voice_type, pronouns)
		LAZYSET(known_people, H.mobid, relation)
		return

	if(existing.known_before)
		return

	var/current_name = existing.name
	if(current_name && used_name)
		if(current_name != used_name)
			to_chat(H, span_warning("[used_name] previously introduced [H.p_them()]self to me as [current_name]..."))
			H.playsound_local(H, 'sound/misc/notice.ogg', 70, FALSE)
			existing.name = used_name

	var/current_job = existing.job
	if(current_job && used_job)
		if(current_job != used_job)
			if(current_name)
				to_chat(H, span_warning("[current_name] previously told me [H.p_they()] work[H.p_s()] as \an [lowertext(current_job)]..."))
				to_chat(H, span_warning("But now [H.p_they()] say[H.p_s()] [H.p_theyre()] [H.p_are()] \an [lowertext(used_job)]!"))
				H.playsound_local(H, 'sound/misc/notice.ogg', 70, FALSE)
				existing.job = used_job

/// Skip all the fancy crap and just add mind to our known people
/datum/mind/proc/know_person_forced(datum/mind/person)
	if(QDELETED(person))
		return

	if(person == src)
		return

	if(!ishuman(person.current))
		return
	var/mob/living/carbon/human/H = person.current

	var/datum/relationship/previous = LAZYACCESS(known_people, H.mobid)
	if(previous)
		QDEL_NULL(previous)

	var/used_title
	if(H.job)
		var/datum/job/job = SSjob.GetJob(H.job)
		used_title = job.get_informed_title(H)
	if(!used_title)
		used_title = "Unknown"

	var/pronouns // If gender and pronouns are the same ignore pronouns
	if(PRONOUN_MAP_DEFAULT[H.gender] != H.pronouns)
		pronouns = H.pronouns

	var/voice_type // If gender and voice type are the same ignore voice type
	if(!(H.voice_type in VOICE_MAP_DEFAULT[H.gender]))
		voice_type = H.voice_type

	var/datum/relationship/relation = new(person, H.real_name, used_title, H.gender, H.age, H.voice_color, voice_type, pronouns, TRUE)
	LAZYSET(known_people, H.mobid, relation)

/// Force us to know person
/datum/mind/proc/person_knows_me(datum/mind/person)
	know_person_forced(person)

/// Force us and person to know eachother
/datum/mind/proc/become_known_to_both(datum/mind/person)
	src.know_person_forced(person)
	person.know_person_forced(src)

/// Get relationship with a human or null
/datum/mind/proc/get_relationship(mob/living/carbon/human/person)
	if(QDELETED(person))
		return

	if(!istype(person))
		return

	if(!LAZYLEN(known_people))
		return

	for(var/mobid as anything in known_people)
		if(mobid == person.mobid)
			return known_people[mobid]

/// Get what we know this human as or null
/datum/mind/proc/known_as(mob/living/carbon/human/person)
	var/datum/relationship/relation = get_relationship(person)
	if(relation)
		var/known_name = relation.name
		if(!known_name || known_name == "Unknown")
			return
		return known_name

/// Return TRUE if we know this name
/datum/mind/proc/know_name(name, requires_true = FALSE)
	if(!name)
		return FALSE
	if(!LAZYLEN(known_people))
		return FALSE
	for(var/person as anything in known_people)
		var/datum/relationship/relation = known_people[person]
		var/known_name = relation.name
		if(!known_name)
			continue
		if(requires_true)
			var/known = lowertext(relation.name)
			var/real = lowertext(relation.subject_real_name)
			if(name == known && known == real)
				return TRUE
		else
			if(LOWERSTRINGCOMP(known_name, name))
				return TRUE
	return FALSE

/// we are removed from X's known people
/datum/mind/proc/become_unknown_to(datum/mind/person)
	if(QDELETED(person))
		return
	if(!LAZYLEN(person.known_people))
		return
	if(person == src)
		return
	var/mob/living/carbon/human/H = current
	if(!istype(H))
		return
	var/datum/relationship/previous = LAZYACCESS(known_people, H.mobid)
	if(previous)
		LAZYREMOVE(person.known_people, H.mobid)
		QDEL_NULL(previous)

/// removes all known people from your known_people list
/datum/mind/proc/unknow_all_people()
	LAZYCLEARLIST(known_people)

/// Remove us from everyone's known list and clear ours
/datum/mind/proc/reset_known()
	unknow_all_people()
	for(var/datum/mind/M as anything in SSticker.minds)
		become_unknown_to(M)

/// show known people to us
/datum/mind/proc/display_known_people(mob/user)
	if(!user)
		return
	if(!LAZYLEN(known_people))
		return
	var/contents = "<center>People that I know:</center><BR>"
	for(var/person as anything in known_people)
		var/datum/relationship/relation = known_people[person]

		var/list/descriptors
		var/name = relation.name
		if(!name)
			name = "Unknown"

		var/voice_type = relation.voice_type
		if(voice_type)
			descriptors += "They have a [voice_type] voice."

		var/job = relation.job
		var/pronouns = relation.pronouns
		contents += "<B><font color=#[relation.voice_color];text-shadow:0 0 10px #8d5958, 0 0 20px #8d5958, 0 0 30px #8d5958, 0 0 40px #8d5958, 0 0 50px #e60073, 0 0 60px #8d5958, 0 0 70px #8d5958;>"
		contents += "[name]</font>[relation.job ? ", [job]" : ", Unknown Occupation"]</B>"
		contents += "<BR>[relation.age], [pronouns ? pronouns : capitalize(relation.gender)]"
		if(length(descriptors))
			contents += "<BR>[jointext(descriptors, "\n")]"
		contents += "<BR>"

	var/datum/browser/popup = new(user, "PEOPLEIKNOW", "", 260, 400)
	popup.set_content(contents)
	popup.open()

/// This mainly exists to do away with the messy associative list and is purely data with no interfacing at the minute.
/datum/relationship
	/// Weakref to the mind of the subject
	var/datum/weakref/subject
	/// Real name at time of addition, always known by the datum. not the mind.
	var/subject_real_name
	/// Known name of the subject
	var/name
	/// Known occupation of the subject
	var/job
	/// Known gender/body type of the subject, always known
	var/gender
	/// Known age of the subject, always known
	var/age
	/// Voice color of the subject, always known
	var/voice_color
	// Requires a seperation from the default male/female voice type and pronoun setting
	/// Voice type of the subject
	var/voice_type
	/// Pronouns of the subject
	var/pronouns
	/// If IC we have known this person from before the current week, prevents changing of values from subsequent introductions
	var/known_before

/datum/relationship/New(datum/mind/subject, name, job, gender, age, voice_color, voice_type, pronouns, known_before = FALSE)
	src.subject = WEAKREF(subject)
	src.subject_real_name = subject.current.real_name
	src.name = name
	src.job = job
	src.gender = gender
	src.age = age
	src.voice_color = voice_color
	src.voice_type = voice_type
	src.pronouns = pronouns
	src.known_before = known_before

/datum/relationship/Destroy(force, ...)
	subject = null
	return ..()
