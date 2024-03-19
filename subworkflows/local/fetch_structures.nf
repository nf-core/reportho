include { FETCH_AFDB_STRUCTURES } from "../../modules/local/fetch_afdb_structures"

workflow FETCH_STRUCTURES {
    take:
    ch_idlist

    main:

    FETCH_AFDB_STRUCTURES(
        ch_idlist
    )

    emit:
    structures  = FETCH_AFDB_STRUCTURES.out.pdb
    hits        = FETCH_AFDB_STRUCTURES.out.hits
    misses      = FETCH_AFDB_STRUCTURES.out.misses
    af_versions = FETCH_AFDB_STRUCTURES.out.af_versions
    versions    = FETCH_AFDB_STRUCTURES.out.versions
}
