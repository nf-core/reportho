include { DUMP_PARAMS    } from "../../modules/local/dump_params"
include { MAKE_REPORT    } from "../../modules/local/make_report"
include { CONVERT_FASTA } from "../../modules/local/convert_fasta"

workflow REPORT {
    take:
    ch_seqinfo
    ch_scoretable
    ch_filtered
    ch_supportsplot
    ch_vennplot
    ch_jaccardplot
    ch_seqhits
    ch_seqmisses
    ch_strhits
    ch_strmisses
    ch_alignment
    ch_iqtree
    ch_fastme

    main:
    DUMP_PARAMS(
        ch_seqinfo.map { [it[0], it[3]] }
    )

    CONVERT_FASTA(ch_alignment)

    ch_forreport = ch_seqinfo
        .join(ch_scoretable, by:0)
        .join(ch_filtered, by:0)
        .join(ch_supportsplot, by:0)
        .join(ch_vennplot, by:0)
        .join(ch_jaccardplot, by:0)
        .join(ch_seqhits, by:0)
        .join(ch_seqmisses, by:0)
        .join(ch_strhits, by:0)
        .join(ch_strmisses, by:0)
        .join(CONVERT_FASTA.out.fasta, by:0)
        .join(ch_iqtree, by:0)
        .join(ch_fastme, by:0)
        .join(DUMP_PARAMS.out.params, by:0)

    MAKE_REPORT(
        ch_forreport
    )
}
