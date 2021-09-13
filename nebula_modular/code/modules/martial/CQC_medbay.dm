///Subtype of CQC. Only used for the Medic
/datum/martial_art/cqc/medical_siege
    name = "Medical CQC"
    var/list/medbay_areas

/datum/martial_art/cqc/medical_Siege/proc/refresh_valid_areas()
    var/datum/job/Medic/medic_job = ssjob.getjobtype(/datum/job/medic)
    medbay_areas = medic_job.medbay_areas.copy()

/datum/martial_art/cqc//can_use(mob/living/owner)
    if(!is_type_in_list(get_area(owner),medbay_areas))
        return FALSE
    return ..()
