include { MAKE_SCORE_TABLE             } from "../../modules/local/make_score_table"
include { FILTER_HITS                  } from "../../modules/local/filter_hits"
include { PLOT_ORTHOLOGS               } from "../../modules/local/plot_orthologs"
include { MAKE_HITS_TABLE              } from "../../modules/local/make_hits_table"
include { CSVTK_CONCAT as MERGE_HITS   } from "../../modules/nf-core/csvtk/concat/main"
include { MAKE_STATS                   } from "../../modules/local/make_stats"
include { STATS2CSV                    } from "../../modules/local/stats2csv"
include { CSVTK_CONCAT as MERGE_STATS  } from "../../modules/nf-core/csvtk/concat/main"

workflow SCORE_ORTHOLOGS {
    take:
    ch_query
    ch_orthologs
    ch_id_map

    main:
    // Scoring and filtering
    ch_versions = Channel.empty()

    MAKE_SCORE_TABLE (
        ch_orthologs.join(ch_id_map)
    )

    ch_versions = ch_versions.mix(MAKE_SCORE_TABLE.out.versions)

    ch_forfilter = MAKE_SCORE_TABLE.out.score_table
        .combine(ch_query, by: 0)
        .map { id, score, query, taxid, exact -> [id, score, query] }

    FILTER_HITS (
        ch_forfilter,
        params.use_centroid,
        params.min_score
    )

    ch_versions = ch_versions.mix(FILTER_HITS.out.versions)

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

        ch_versions = ch_versions.mix(PLOT_ORTHOLOGS.out.versions)
    }

    // Hits

    MAKE_HITS_TABLE(
        ch_orthologs
    )

    ch_versions = ch_versions.mix(MAKE_HITS_TABLE.out.versions)

    ch_hits = MAKE_HITS_TABLE.out.hits_table
        .collect { it[1] }
        .map { [[id: "all"], it] }

    MERGE_HITS(
        ch_hits,
        "csv",
        "csv"
    )

    ch_versions = ch_versions.mix(MERGE_HITS.out.versions)

    // Stats

    MAKE_STATS(
        MAKE_SCORE_TABLE.out.score_table
    )

    ch_versions = ch_versions.mix(MAKE_STATS.out.versions)

    STATS2CSV(
        MAKE_STATS.out.stats
    )

    ch_versions = ch_versions.mix(STATS2CSV.out.versions)

    ch_stats = STATS2CSV.out.csv
        .collect { it[1] }
        .map { [[id: "all"], it] }

    MERGE_STATS(
        ch_stats,
        "csv",
        "csv"
    )

    ch_versions = ch_versions.mix(MERGE_STATS.out.versions)

    ch_versions
        .collectFile(name: "score_orthologs_versions.yml", sort: true, newLine: true)
        .set { ch_merged_versions }

    emit:
    score_table      = MAKE_SCORE_TABLE.out.score_table
    orthologs        = FILTER_HITS.out.filtered_hits
    supports_plot    = ch_supportsplot
    venn_plot        = ch_vennplot
    jaccard_plot     = ch_jaccardplot
    stats            = MAKE_STATS.out.stats
    hits             = MAKE_HITS_TABLE.out.hits_table
    aggregated_stats = MERGE_STATS.out.csv
    aggregated_hits  = MERGE_HITS.out.csv
    versions         = ch_merged_versions
}
