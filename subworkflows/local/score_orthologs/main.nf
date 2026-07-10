include { MAKE_SCORE_TABLE             } from "../../../modules/local/make_score_table/main.nf"
include { FILTER_HITS                  } from "../../../modules/local/filter_hits/main.nf"
include { PLOT_ORTHOLOGS               } from "../../../modules/local/plot_orthologs/main.nf"
include { MAKE_HITS_TABLE              } from "../../../modules/local/make_hits_table/main.nf"
include { CSVTK_CONCAT as MERGE_HITS   } from "../../../modules/nf-core/csvtk/concat/main.nf"
include { MAKE_MERGE_TABLE             } from "../../../modules/local/make_merge_table/main.nf"
include { CSVTK_CONCAT as MERGE_MERGE  } from "../../../modules/nf-core/csvtk/concat/main.nf"
include { MAKE_STATS                   } from "../../../modules/local/make_stats/main.nf"
include { STATS2CSV                    } from "../../../modules/local/stats2csv/main.nf"
include { CSVTK_CONCAT as MERGE_STATS  } from "../../../modules/nf-core/csvtk/concat/main.nf"

workflow SCORE_ORTHOLOGS {
    take:
    ch_query
    ch_orthologs
    ch_id_map
    ch_clusters
    skip_merge
    skip_plots

    main:
    // Scoring and filtering
    MAKE_SCORE_TABLE (
        ch_orthologs.join(ch_id_map)
    )

    ch_forfilter = MAKE_SCORE_TABLE.out.score_table
        .combine(ch_query, by: 0)
        .map { id, score, query, _taxid, _exact -> [id, score, query] }

    FILTER_HITS (
        ch_forfilter,
        params.use_centroid,
        params.min_score
    )

    // Plotting

    ch_supportsplot = ch_query.map { meta, _query_id, _taxid, _exact -> [meta, []]}
    ch_vennplot     = ch_query.map { meta, _query_id, _taxid, _exact -> [meta, []]}
    ch_jaccardplot  = ch_query.map { meta, _query_id, _taxid, _exact -> [meta, []]}

    if(!skip_plots) {
        PLOT_ORTHOLOGS (
            MAKE_SCORE_TABLE.out.score_table
        )

        ch_supportsplot = PLOT_ORTHOLOGS.out.supports
        ch_vennplot     = PLOT_ORTHOLOGS.out.venn
        ch_jaccardplot  = PLOT_ORTHOLOGS.out.jaccard
    }

    // Hits

    MAKE_HITS_TABLE(
        ch_orthologs
    )

    ch_hits = MAKE_HITS_TABLE.out.hits_table
        .collect { row -> row[1] }
        .map { row -> [[id: "all"], row] }

    MERGE_HITS(
        ch_hits,
        "csv",
        "csv"
    )

    ch_merge_table      = channel.empty()
    ch_aggregated_merge = channel.empty()

    if(!skip_merge) {
        MAKE_MERGE_TABLE (
            ch_clusters
        )

        ch_merge_table = MAKE_MERGE_TABLE.out.merge_table

        ch_merge = MAKE_MERGE_TABLE.out.merge_table
            .collect { row -> row[1] }
            .map { row -> [[id: "all"], row] }

        MERGE_MERGE(
            ch_merge,
            "csv",
            "csv"
        )

        ch_aggregated_merge = MERGE_MERGE.out.csv
    }

    // Stats

    MAKE_STATS(
        MAKE_SCORE_TABLE.out.score_table
    )

    STATS2CSV(
        MAKE_STATS.out.stats
    )

    ch_stats = STATS2CSV.out.csv
        .collect { row -> row[1] }
        .map { row -> [[id: "all"], row] }

    MERGE_STATS(
        ch_stats,
        "csv",
        "csv"
    )

    emit:
    score_table      = MAKE_SCORE_TABLE.out.score_table
    orthologs        = FILTER_HITS.out.filtered_hits
    supports_plot    = ch_supportsplot
    venn_plot        = ch_vennplot
    jaccard_plot     = ch_jaccardplot
    stats            = MAKE_STATS.out.stats
    hits             = MAKE_HITS_TABLE.out.hits_table
    merge            = ch_merge_table
    aggregated_stats = MERGE_STATS.out.csv
    aggregated_hits  = MERGE_HITS.out.csv
    aggregated_merge = ch_aggregated_merge
}
