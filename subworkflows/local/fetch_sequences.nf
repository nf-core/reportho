include { FETCH_SEQUENCES_ONLINE } from "../../modules/local/fetch_sequences_online"

workflow FETCH_SEQUENCES {
    take:
    ch_idlist
    ch_query_fasta

    main:

    ch_input = params.uniprot_query ? ch_idlist.map { it -> [it[0], it[1], []]} : ch_idlist.join(ch_query_fasta)
    FETCH_SEQUENCES_ONLINE (
        ch_input
    )

    emit:
    sequences = FETCH_SEQUENCES_ONLINE.out.fasta
    hits      = FETCH_SEQUENCES_ONLINE.out.hits
    misses    = FETCH_SEQUENCES_ONLINE.out.misses
    versions  = FETCH_SEQUENCES_ONLINE.out.versions
}
