include { FETCH_SEQUENCES_ONLINE } from "../../modules/local/fetch_sequences_online"

workflow FETCH_SEQUENCES {
    take:
    ch_id_list
    ch_query

    main:
    ch_id_list
        .join(ch_query)
        .set { ch_input }

    FETCH_SEQUENCES_ONLINE (
        ch_input
    )

    emit:
    sequences = FETCH_SEQUENCES_ONLINE.out.fasta
    hits      = FETCH_SEQUENCES_ONLINE.out.hits
    misses    = FETCH_SEQUENCES_ONLINE.out.misses
    versions  = FETCH_SEQUENCES_ONLINE.out.versions
}
