include { IDENTIFY_SEQ_ONLINE          } from "../../modules/local/identify_seq_online"
include { WRITE_SEQINFO                } from "../../modules/local/write_seqinfo"

include { FETCH_OMA_GROUP_ONLINE       } from "../../modules/local/fetch_oma_group_online"
include { FETCH_PANTHER_GROUP_ONLINE   } from "../../modules/local/fetch_panther_group_online"
include { FETCH_INSPECTOR_GROUP_ONLINE } from "../../modules/local/fetch_inspector_group_online"

include { FETCH_OMA_GROUP_LOCAL        } from "../../modules/local/fetch_oma_group_local"
include { FETCH_PANTHER_GROUP_LOCAL    } from "../../modules/local/fetch_panther_group_local"
include { FETCH_EGGNOG_GROUP_LOCAL     } from "../../modules/local/fetch_eggnog_group_local"

include { CSVTK_JOIN as MERGE_CSV      } from "../../modules/nf-core/csvtk/join/main"
include { MAKE_SCORE_TABLE             } from "../../modules/local/make_score_table"
include { FILTER_HITS                  } from "../../modules/local/filter_hits"
include { PLOT_ORTHOLOGS               } from "../../modules/local/plot_orthologs"
include { MAKE_STATS                   } from "../../modules/local/make_stats"
include { STATS2CSV                    } from "../../modules/local/stats2csv"
include { CSVTK_CONCAT as MERGE_STATS  } from "../../modules/nf-core/csvtk/concat/main"

workflow GET_ORTHOLOGS {
    take:
    ch_samplesheet

    main:

    ch_versions    = Channel.empty()
    ch_queryid     = params.uniprot_query ? ch_samplesheet.map { it[1] } : ch_samplesheet.map { it[0].id }
    ch_orthogroups = Channel.empty()

    // Preprocessing - find the ID and taxid of the query sequences

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

    // Ortholog fetching

    if(params.use_all) {
        // OMA
        if (params.local_databases) {
            FETCH_OMA_GROUP_LOCAL (
                ch_query,
                params.oma_path,
                params.oma_uniprot_path,
                params.oma_ensembl_path,
                params.oma_refseq_path
            )

            ch_orthogroups
                .mix(FETCH_OMA_GROUP_LOCAL.out.oma_group)
                .set { ch_orthogroups }

            ch_versions
                .mix(FETCH_OMA_GROUP_LOCAL.out.versions)
                .set { ch_versions }
        } else {
            FETCH_OMA_GROUP_ONLINE (
                ch_query
            )

            ch_orthogroups
                .mix(FETCH_OMA_GROUP_ONLINE.out.oma_group)
                .set { ch_orthogroups }

            ch_versions
                .mix(FETCH_OMA_GROUP_ONLINE.out.versions)
                .set { ch_versions }
        }
        // Panther
        if (params.local_databases) {
            FETCH_PANTHER_GROUP_LOCAL (
                ch_query,
                params.panther_path
            )

            ch_orthogroups
                .mix(FETCH_PANTHER_GROUP_LOCAL.out.panther_group)
                .set { ch_orthogroups }

            ch_versions
                .mix(FETCH_PANTHER_GROUP_LOCAL.out.versions)
                .set { ch_versions }
        } else {
            FETCH_PANTHER_GROUP_ONLINE (
                ch_query
            )

            ch_orthogroups
                .mix(FETCH_PANTHER_GROUP_ONLINE.out.panther_group)
                .set { ch_orthogroups }

            ch_versions
                .mix(FETCH_PANTHER_GROUP_ONLINE.out.versions)
                .set { ch_versions }
        }
        // OrthoInspector
        FETCH_INSPECTOR_GROUP_ONLINE (
            ch_query,
            params.inspector_version
        )

        ch_orthogroups
            .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.inspector_group)
            .set { ch_orthogroups }

        ch_versions
            .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.versions)
            .set { ch_versions }

        FETCH_EGGNOG_GROUP_LOCAL (
            ch_query,
            params.eggnog_path,
            params.eggnog_idmap_path
        )

        ch_orthogroups
            .mix(FETCH_EGGNOG_GROUP_LOCAL.out.eggnog_group)
            .set { ch_orthogroups }

        ch_versions
            .mix(FETCH_EGGNOG_GROUP_LOCAL.out.versions)
            .set { ch_versions }

    } else { // online/local separation is used
        // local only
        if (params.local_databases) {
            if (!params.skip_oma) {
                FETCH_OMA_GROUP_LOCAL (
                    ch_query,
                    params.oma_path,
                    params.oma_uniprot_path,
                    params.oma_ensembl_path,
                    params.oma_refseq_path
                )

                ch_orthogroups
                    .mix(FETCH_OMA_GROUP_LOCAL.out.oma_group)
                    .set { ch_orthogroups }

                ch_versions
                    .mix(FETCH_OMA_GROUP_LOCAL.out.versions)
                    .set { ch_versions }
            }

            if (!params.skip_panther) {
                FETCH_PANTHER_GROUP_LOCAL (
                    ch_query,
                    params.panther_path
                )

                ch_orthogroups
                    .mix(FETCH_PANTHER_GROUP_LOCAL.out.panther_group)
                    .set { ch_orthogroups }

                ch_versions
                    .mix(FETCH_PANTHER_GROUP_LOCAL.out.versions)
                    .set { ch_versions }
            }

            if(!params.skip_eggnog) {
                FETCH_EGGNOG_GROUP_LOCAL (
                    ch_query,
                    params.eggnog_path,
                    params.eggnog_idmap_path
                )

                ch_orthogroups
                    .mix(FETCH_EGGNOG_GROUP_LOCAL.out.eggnog_group)
                    .set { ch_orthogroups }

                ch_versions
                    .mix(FETCH_EGGNOG_GROUP_LOCAL.out.versions)
                    .set { ch_versions }

            }
        }
        else { // online only
            if (!params.skip_oma) {
                FETCH_OMA_GROUP_ONLINE (
                    ch_query
                )

                ch_orthogroups
                    .mix(FETCH_OMA_GROUP_ONLINE.out.oma_group)
                    .set { ch_orthogroups }

                ch_versions
                    .mix(FETCH_OMA_GROUP_ONLINE.out.versions)
                    .set { ch_versions }

            }
            if (!params.skip_panther) {
                FETCH_PANTHER_GROUP_ONLINE (
                    ch_query
                )

                ch_orthogroups
                    .mix(FETCH_PANTHER_GROUP_ONLINE.out.panther_group)
                    .set { ch_orthogroups }

                ch_versions
                    .mix(FETCH_PANTHER_GROUP_ONLINE.out.versions)
                    .set { ch_versions }
            }
            if (!params.skip_inspector) {
                FETCH_INSPECTOR_GROUP_ONLINE (
                    ch_query,
                    params.inspector_version
                )

                ch_orthogroups
                    .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.inspector_group)
                    .set { ch_orthogroups }

                ch_versions
                    .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.versions)
                    .set { ch_versions }
            }
        }
    }

    // Result merging

    MERGE_CSV (
        ch_orthogroups.groupTuple()
    )

    ch_versions
        .mix(MERGE_CSV.out.versions)
        .set { ch_versions }

    // Scoring and filtering

    MAKE_SCORE_TABLE (
        MERGE_CSV.out.csv
    )

    ch_versions
        .mix(MAKE_SCORE_TABLE.out.versions)
        .set { ch_versions }

    ch_forfilter = MAKE_SCORE_TABLE.out.score_table
        .combine(ch_query, by: 0)
        .map { id, score, query, taxid, exact -> [id, score, query] }

    FILTER_HITS (
        ch_forfilter,
        params.use_centroid,
        params.min_score
    )

    ch_versions
        .mix(FILTER_HITS.out.versions)
        .set { ch_versions }

    // Plotting

    ch_supportsplot = ch_query.map { [it[0], []]}
    ch_vennplot     = ch_query.map { [it[0], []]}
    ch_jaccardplot  = ch_query.map { [it[0], []]}

    if(!params.skip_orthoplots) {
        PLOT_ORTHOLOGS (
            MAKE_SCORE_TABLE.out.score_table
        )

        ch_supportsplot = PLOT_ORTHOLOGS.out.supports
        ch_vennplot     = PLOT_ORTHOLOGS.out.venn
        ch_jaccardplot  = PLOT_ORTHOLOGS.out.jaccard

        ch_versions
            .mix(PLOT_ORTHOLOGS.out.versions)
            .set { ch_versions }
    }

    // Stats

    MAKE_STATS(
        MAKE_SCORE_TABLE.out.score_table
    )

    ch_versions
        .mix(MAKE_STATS.out.versions)
        .set { ch_versions }

    STATS2CSV(
        MAKE_STATS.out.stats
    )

    ch_versions
        .mix(STATS2CSV.out.versions)
        .set { ch_versions }

    ch_stats = STATS2CSV.out.csv
        .collect { it[1] }
        .map { [[id: "all"], it] }

    MERGE_STATS(
        ch_stats,
        "csv",
        "csv"
    )

    ch_versions
        .mix(MERGE_STATS.out.versions)
        .set { ch_versions }

    ch_versions
        .collectFile(name: "get_orthologs_versions.yml", sort: true, newLine: true)
        .set { ch_merged_versions }

    emit:
    seqinfo          = ch_query
    id               = ch_query.map { it[1] }
    taxid            = ch_query.map { it[2] }
    exact            = ch_query.map { it[3] }
    orthogroups      = ch_orthogroups
    score_table      = MAKE_SCORE_TABLE.out.score_table
    orthologs        = FILTER_HITS.out.filtered_hits
    supports_plot    = ch_supportsplot
    venn_plot        = ch_vennplot
    jaccard_plot     = ch_jaccardplot
    stats            = MAKE_STATS.out.stats
    aggregated_stats = MERGE_STATS.out.csv
    versions         = ch_merged_versions

}
