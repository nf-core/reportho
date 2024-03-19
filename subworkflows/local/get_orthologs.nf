include { IDENTIFY_SEQ_ONLINE          } from "../../modules/local/identify_seq_online"
include { WRITE_SEQINFO                } from "../../modules/local/write_seqinfo"
include { FETCH_OMA_GROUP_ONLINE       } from "../../modules/local/fetch_oma_group_online"
include { FETCH_PANTHER_GROUP_ONLINE   } from "../../modules/local/fetch_panther_group_online"
include { FETCH_INSPECTOR_GROUP_ONLINE } from "../../modules/local/fetch_inspector_group_online"
include { MAKE_SCORE_TABLE             } from "../../modules/local/make_score_table"
include { FILTER_HITS                  } from "../../modules/local/filter_hits"
include { PLOT_ORTHOLOGS               } from "../../modules/local/plot_orthologs"

workflow GET_ORTHOLOGS {
    take:
    ch_samplesheet

    main:

    ch_versions = Channel.empty()

    if (!params.uniprot_query) {
        ch_samplesheet
            .map { it -> [it[0], file(it[1])] }
            .set { ch_inputfile }


        IDENTIFY_SEQ_ONLINE (
            ch_inputfile
        )

        IDENTIFY_SEQ_ONLINE.out.seqinfo
            .set { ch_query }

        ch_versions
            .mix(IDENTIFY_SEQ_ONLINE.out.versions)
            .set { ch_versions }
    } else {
        WRITE_SEQINFO (
            ch_samplesheet
        )

        WRITE_SEQINFO.out.seqinfo
            .set { ch_query }

        ch_versions
            .mix(WRITE_SEQINFO.out.versions)
            .set { ch_versions }
    }

    FETCH_OMA_GROUP_ONLINE (
        ch_query
    )

    ch_versions
        .mix(FETCH_OMA_GROUP_ONLINE.out.versions)
        .set { ch_versions }

    FETCH_PANTHER_GROUP_ONLINE (
        ch_query
    )

    ch_versions
        .mix(FETCH_PANTHER_GROUP_ONLINE.out.versions)
        .set { ch_versions }

    FETCH_INSPECTOR_GROUP_ONLINE (
        ch_query,
        params.inspector_version
    )

    ch_versions
        .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.versions)
        .set { ch_versions }

    MAKE_SCORE_TABLE (
        FETCH_OMA_GROUP_ONLINE.out.oma_group.map { it[0] },
        FETCH_OMA_GROUP_ONLINE.out.oma_group.map { it[1] },
        FETCH_PANTHER_GROUP_ONLINE.out.panther_group.map { it[1] },
        FETCH_INSPECTOR_GROUP_ONLINE.out.inspector_group.map { it[1] }
    )

    ch_versions
        .mix(MAKE_SCORE_TABLE.out.versions)
        .set { ch_versions }

    FILTER_HITS (
        MAKE_SCORE_TABLE.out.score_table,
        params.merge_strategy
    )

    ch_versions
        .mix(FILTER_HITS.out.versions)
        .set { ch_versions }

    PLOT_ORTHOLOGS (
        MAKE_SCORE_TABLE.out.score_table
    )

    ch_versions
        .mix(PLOT_ORTHOLOGS.out.versions)
        .set { ch_versions }

    ch_versions
        .collectFile(name: "get_orthologs_versions.yml", sort: true, newLine: true)
        .set { ch_merged_versions }

    emit:
    orthologs     = FILTER_HITS.out.filtered_hits
    supports_plot = PLOT_ORTHOLOGS.out.supports
    venn_plot     = PLOT_ORTHOLOGS.out.venn
    versions      = ch_merged_versions

}
