include { DUMP_PARAMS } from "../../../modules/local/dump_params/main.nf"
include { MAKE_REPORT } from "../../../modules/local/make_report/main.nf"

workflow REPORT {

    take:
    use_centroid
    min_score
    skip_merge
    min_identity
    min_coverage
    ch_seqinfo
    ch_scoretable
    ch_filtered
    ch_supportsplot
    ch_vennplot
    ch_jaccardplot
    ch_orthostats
    ch_seqhits
    ch_seqmisses
    ch_mergestats
    ch_clusters

    main:
    DUMP_PARAMS(
        ch_seqinfo.map { meta, _query_id, _taxid, exact -> [meta, exact] },
        use_centroid,
        min_score,
        skip_merge,
        min_identity,
        min_coverage
    )

    ch_forreport = ch_seqinfo
        .join(ch_scoretable, by:0)
        .join(ch_filtered, by:0)
        .join(ch_supportsplot, by:0)
        .join(ch_vennplot, by:0)
        .join(ch_jaccardplot, by:0)
        .join(ch_orthostats, by:0)
        .join(ch_seqhits, by:0)
        .join(ch_seqmisses, by:0)
        .join(ch_mergestats, by:0)
        .join(ch_clusters, by:0)
        .join(DUMP_PARAMS.out.params, by:0)

    MAKE_REPORT(
        ch_forreport
    )
}
