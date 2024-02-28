include { FETCH_AFDB_STRUCTURES } from "../../modules/local/fetch_afdb_structures"

workflow FETCH_STRUCTURES {
    take:
    ch_idlist

    main:

    FETCH_AFDB_STRUCTURES(
        ch_idlist
    )

    emit:
    pdb      = FETCH_AFDB_STRUCTURES.out.pdb
    misses   = FETCH_AFDB_STRUCTURES.out.misses
    versions = FETCH_AFDB_STRUCTURES.out.versions
}
