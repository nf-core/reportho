include { DUMP_PARAMS } from "../../modules/local/dump_params"
include { MAKE_REPORT } from "../../modules/local/make_report"

workflow REPORT {

    take:
    use_centroid
    min_score
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
    ch_versions  = Channel.empty()
    ch_fasta     = ch_seqinfo.map { [it[0], []] }

    DUMP_PARAMS(
        ch_seqinfo.map { [it[0], it[3]] },
        params.use_centroid,
        params.min_score,
        params.skip_merge,
        params.min_identity,
        params.min_coverage
    )

    ch_versions = ch_versions.mix(DUMP_PARAMS.out.versions)

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

    ch_versions = ch_versions.mix(MAKE_REPORT.out.versions)

    emit:
    versions = ch_versions
}
