include { DUMP_PARAMS } from "../../modules/local/dump_params"
include { MAKE_REPORT } from "../../modules/local/make_report"

workflow REPORT {
    take:
    ch_seqinfo
    ch_scoretable
    ch_filtered
    ch_supportsplot
    ch_vennplot
    ch_jaccardplot

    main:
    DUMP_PARAMS(
        ch_seqinfo.map { it[0] }
    )

    ch_forreport = ch_seqinfo
        .join(ch_scoretable, by:0)
        .join(ch_filtered, by:0)
        .join(ch_supportsplot, by:0)
        .join(ch_vennplot, by:0)
        .join(ch_jaccardplot, by:0)
        .join(DUMP_PARAMS.out.params, by:0)

    MAKE_REPORT(
        ch_forreport
    )
}
