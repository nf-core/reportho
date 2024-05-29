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
include { MAKE_HITS_TABLE              } from "../../modules/local/make_hits_table"
include { CSVTK_CONCAT as MERGE_HITS   } from "../../modules/nf-core/csvtk/concat/main"
include { MAKE_STATS                   } from "../../modules/local/make_stats"
include { STATS2CSV                    } from "../../modules/local/stats2csv"
include { CSVTK_CONCAT as MERGE_STATS  } from "../../modules/nf-core/csvtk/concat/main"

workflow GET_ORTHOLOGS {
    take:
    ch_samplesheet_query
    ch_samplesheet_fasta

    main:
    ch_versions     = Channel.empty()
    ch_orthogroups  = Channel.empty()

    ch_oma_groups   = params.oma_path ? Channel.value(file(params.oma_path)) : Channel.empty()
    ch_oma_uniprot  = params.oma_uniprot_path ? Channel.value(file(params.oma_uniprot_path)) : Channel.empty()
    ch_oma_ensembl  = params.oma_ensembl_path ? Channel.value(file(params.oma_ensembl_path)) : Channel.empty()
    ch_oma_refseq   = params.oma_refseq_path ? Channel.value(file(params.oma_refseq_path)) : Channel.empty()
    ch_panther      = params.panther_path ? Channel.value(file(params.panther_path)) : Channel.empty()
    ch_eggnog       = params.eggnog_path ? Channel.value(file(params.eggnog_path)) : Channel.empty()
    ch_eggnog_idmap = params.eggnog_idmap_path ? Channel.value(file(params.eggnog_idmap_path)) : Channel.empty()

    ch_samplesheet_fasta.map {
        if (params.offline_run) {
            error "Tried to use FASTA input in an offline run. Aborting pipeline for user safety."
        }
        return it
    }.set { ch_samplesheet_fasta }

    // Preprocessing - find the ID and taxid of the query sequences

    ch_samplesheet_fasta
        .map { it -> [it[0], file(it[1])] }
        .set { ch_fasta }

    IDENTIFY_SEQ_ONLINE (
        ch_fasta
    )

    ch_query = IDENTIFY_SEQ_ONLINE.out.seqinfo
    ch_versions = ch_versions.mix(IDENTIFY_SEQ_ONLINE.out.versions)

    WRITE_SEQINFO (
        ch_samplesheet_query,
        params.offline_run
    )

    ch_query = IDENTIFY_SEQ_ONLINE.out.seqinfo.mix(WRITE_SEQINFO.out.seqinfo)
    ch_versions = ch_versions.mix(WRITE_SEQINFO.out.versions)

    // Ortholog fetching

    // OMA

    if (params.use_all || !params.skip_oma) {
        if (params.local_databases) {
            FETCH_OMA_GROUP_LOCAL (
                ch_query,
                ch_oma_groups,
                ch_oma_uniprot,
                ch_oma_ensembl,
                ch_oma_refseq
            )

            ch_orthogroups
                .mix(FETCH_OMA_GROUP_LOCAL.out.oma_group)
                .set { ch_orthogroups }

            ch_versions = ch_versions.mix(FETCH_OMA_GROUP_LOCAL.out.versions)
        }
        else {
            FETCH_OMA_GROUP_ONLINE (
                ch_query
            )

            ch_orthogroups
                .mix(FETCH_OMA_GROUP_ONLINE.out.oma_group)
                .set { ch_orthogroups }

            ch_versions = ch_versions.mix(FETCH_OMA_GROUP_ONLINE.out.versions)
        }
    }

    // PANTHER

    if (params.use_all || !params.skip_panther) {
        if (params.local_databases) {
            FETCH_PANTHER_GROUP_LOCAL (
                ch_query,
                ch_panther
            )

            ch_orthogroups
                .mix(FETCH_PANTHER_GROUP_LOCAL.out.panther_group)
                .set { ch_orthogroups }

            ch_versions = ch_versions.mix(FETCH_PANTHER_GROUP_LOCAL.out.versions)
        } else {
            FETCH_PANTHER_GROUP_ONLINE (
                ch_query
            )

            ch_orthogroups
                .mix(FETCH_PANTHER_GROUP_ONLINE.out.panther_group)
                .set { ch_orthogroups }

            ch_versions = ch_versions.mix(FETCH_PANTHER_GROUP_ONLINE.out.versions)
        }
    }

    // OrthoInspector

    if ((params.use_all || !params.skip_orthoinspector) && !params.local_databases) {
        FETCH_INSPECTOR_GROUP_ONLINE (
            ch_query,
            params.orthoinspector_version
        )

        ch_orthogroups
            .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.inspector_group)
            .set { ch_orthogroups }

        ch_versions = ch_versions.mix(FETCH_INSPECTOR_GROUP_ONLINE.out.versions)
    }

    // EggNOG

    if (params.use_all || (!params.skip_eggnog && params.local_databases)) {
        FETCH_EGGNOG_GROUP_LOCAL (
            ch_query,
            ch_eggnog,
            ch_eggnog_idmap,
            ch_oma_ensembl,
            ch_oma_refseq,
            params.offline_run
        )

        ch_orthogroups
            .mix(FETCH_EGGNOG_GROUP_LOCAL.out.eggnog_group)
            .set { ch_orthogroups }

        ch_versions = ch_versions.mix(FETCH_EGGNOG_GROUP_LOCAL.out.versions)
    }

    // Result merging

    MERGE_CSV (
        ch_orthogroups.groupTuple()
    )

    ch_versions = ch_versions.mix(MERGE_CSV.out.versions)

    // Scoring and filtering

    MAKE_SCORE_TABLE (
        MERGE_CSV.out.csv
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
        MERGE_CSV.out.csv
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
    hits             = MAKE_HITS_TABLE.out.hits_table
    aggregated_stats = MERGE_STATS.out.csv
    aggregated_hits  = MERGE_HITS.out.csv
    versions         = ch_merged_versions

}
