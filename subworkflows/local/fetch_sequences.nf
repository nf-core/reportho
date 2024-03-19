include { FETCH_SEQUENCES_ONLINE } from "../../modules/local/fetch_sequences_online"

workflow FETCH_SEQUENCES {
    take:
    ch_idlist

    main:
    FETCH_SEQUENCES_ONLINE (
        ch_idlist
    )

    emit:
    sequences = FETCH_SEQUENCES_ONLINE.out.fasta
    hits      = FETCH_SEQUENCES_ONLINE.out.hits
    misses    = FETCH_SEQUENCES_ONLINE.out.misses
    versions  = FETCH_SEQUENCES_ONLINE.out.versions
}
