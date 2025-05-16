/mob/living/carbon/human/proc/introduce(name, job)
	var/message = "I am [name], I am \an [lowertext(job)]."
	if(job && !name)
		message = "My name is not important, I am \an [lowertext(job)]."
	else if(name && !job)
		message = "My name is [name]."
	else if(!job && !name)
		message = "Remember my voice, for it is all you shall know."
	if(!say(message, spans = list("notice")))
		return
	for(var/atom/movable/hearing_movable as anything in get_hearers_in_LOS(7, src))
		if(!ishuman(hearing_movable))
			return
		var/mob/living/carbon/human/H = hearing_movable
		if(!H.mind)
			return
		H.mind.know_person(mind, name, job)

/// We know person
/datum/mind/proc/know_person(datum/mind/person, name, job)
	if(!person)
		return
	if(person == src)
		return
	var/datum/mind/M = person
	if(!ishuman(M.current))
		return
	var/mob/living/carbon/human/H = M.current
	var/used_name = name
	var/used_job = job
	if(LAZYACCESS(known_people, H.real_name))
		var/current_name = LAZYACCESSASSOC(known_people, H.real_name, "NAME")
		if(current_name && used_name)
			if(current_name != used_name)
				to_chat(H, span_warning("[used_name] previously introduced [H.p_them()]self to me as [current_name]..."))
				H.playsound_local(H, 'sound/misc/notice.ogg', 70, FALSE)
				LAZYSETASSOC(known_people, H.real_name, "NAME", used_name)
		var/current_job = LAZYACCESSASSOC(known_people, H.real_name, "JOB")
		if(current_job && used_job)
			if(current_job != used_job)
				if(current_name)
					to_chat(H, span_warning("[current_name] previously told me [H.p_they()] work[H.p_s()] as \an [lowertext(current_job)]..."))
					to_chat(H, span_warning("But now [H.p_they()] say[H.p_s()] [H.p_theyre()] [H.p_are()] \an [lowertext(used_job)]!"))
					H.playsound_local(H, 'sound/misc/notice.ogg', 70, FALSE)
				LAZYSETASSOC(known_people, H.real_name, "JOB", used_job)
		return
	H.playsound_local(H, 'sound/misc/notice (2).ogg', 100, FALSE)
	LAZYINITLIST(known_people)
	// These can be faked or not given
	if(used_name)
		LAZYSETASSOC(known_people, H.real_name, "NAME", used_name)
	if(used_job)
		LAZYSETASSOC(known_people, H.real_name, "JOB", used_job)
	// You can tell these from the voice, they cannot be faked
	LAZYSETASSOC(known_people, H.real_name, "VOICE", H.voice_color)
	LAZYSETASSOC(known_people, H.real_name, "GENDER", H.gender)
	LAZYSETASSOC(known_people, H.real_name, "AGE", H.age)

/// Skip all the fancy crap and just add mind to our known people
/datum/mind/proc/know_person_forced(datum/mind/person)
	if(!person)
		return
	if(person == src)
		return
	var/datum/mind/M = person
	if(!ishuman(M.current))
		return
	var/mob/living/carbon/human/H = M.current
	if(LAZYACCESS(known_people, H.real_name))
		LAZYREMOVE(known_people, H.real_name)
	var/used_title
	if(H.job)
		var/datum/job/job = SSjob.GetJob(H.job)
		used_title = job.get_informed_title(H)
	if(!used_title)
		used_title = "Unknown"
	LAZYSETASSOC(known_people, H.real_name, "NAME", H.real_name)
	LAZYSETASSOC(known_people, H.real_name, "JOB", used_title)
	LAZYSETASSOC(known_people, H.real_name, "VOICE", H.voice_color)
	LAZYSETASSOC(known_people, H.real_name, "GENDER", H.gender)
	LAZYSETASSOC(known_people, H.real_name, "AGE", H.age)

/// Force us to know person
/datum/mind/proc/person_knows_me(datum/mind/person)
	know_person_forced(person)

/// Force us and person to know eachother
/datum/mind/proc/become_known_to_both(datum/mind/person)
	src.know_person_forced(person)
	person.know_person_forced(src)

/// Get what we know person as or null
/datum/mind/proc/known_as(datum/mind/person)
	if(!person)
		return
	var/mob/living/carbon/human/H = person.current
	if(!istype(H))
		return
	if(!LAZYLEN(known_people))
		return
	for(var/P as anything in known_people)
		if(H.real_name == P)
			var/known_name = LAZYACCESSASSOC(known_people, P, "NAME")
			if(!known_name || known_name == "Unknown")
				return
			return known_name

/// Return TRUE if we know this name
/datum/mind/proc/know_name(name, requires_true = FALSE)
	if(!name)
		return FALSE
	if(!LAZYLEN(known_people))
		return FALSE
	for(var/datum/mind/person as anything in known_people)
		var/known_name = LAZYACCESSASSOC(known_people, person, "NAME")
		if(!known_name)
			continue
		if(requires_true)
			var/mob/living/carbon/human/H = person.current
			if(!istype(H))
				continue
			var/known = lowertext(known_name)
			var/real = lowertext(H.real_name)
			if(name == known && known == real)
				return TRUE
		else
			if(LOWERSTRINGCOMP(known_name, name))
				return TRUE
	return FALSE

/// we are removed from X's known people
/datum/mind/proc/become_unknown_to(datum/mind/person)
	if(!QDELETED(person))
		return
	if(!LAZYLEN(person.known_people))
		return
	if(person == src)
		return
	var/mob/living/carbon/human/H = current
	if(!istype(H))
		return
	if(LAZYACCESS(known_people, H.real_name))
		LAZYREMOVE(known_people, H.real_name)

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
	for(var/P as anything in known_people)
		if(!LAZYLEN(known_people[P]))
			LAZYREMOVE(known_people, P)
			continue
		var/color = LAZYACCESSASSOC(known_people, P, "VOICE")
		if(!color)
			continue
		var/description
		var/name = LAZYACCESSASSOC(known_people, P, "NAME")
		if(!name)
			name = "Unknown"

		var/job = LAZYACCESSASSOC(known_people, P, "JOB")
		var/gender = LAZYACCESSASSOC(known_people, P, "GENDER")
		var/age = LAZYACCESSASSOC(known_people, P, "AGE")

		contents += "<B><font color=#[color];text-shadow:0 0 10px #8d5958, 0 0 20px #8d5958, 0 0 30px #8d5958, 0 0 40px #8d5958, 0 0 50px #e60073, 0 0 60px #8d5958, 0 0 70px #8d5958;>"
		contents += "[name]</font>[job ? ", [job]" : ""]</B>"
		if(description)
			contents += "<BR>[description]"
		contents += "<BR>[age], [capitalize(gender)]"
		contents += "<BR>"

	var/datum/browser/popup = new(user, "PEOPLEIKNOW", "", 260, 400)
	popup.set_content(contents)
	popup.open()
