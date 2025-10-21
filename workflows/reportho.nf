/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_reportho_pipeline'

include { GET_ORTHOLOGS          } from '../subworkflows/local/get_orthologs'
include { GET_SEQUENCES          } from '../subworkflows/local/get_sequences'
include { MERGE_IDS              } from '../subworkflows/local/merge_ids'
include { SCORE_ORTHOLOGS        } from '../subworkflows/local/score_orthologs'
include { REPORT                 } from '../subworkflows/local/report'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow REPORTHO {

    take:
    ch_samplesheet_query // channel: samplesheet query
    ch_samplesheet_fasta // channel: samplesheet fasta

    main:

    ch_versions      = Channel.empty()
    ch_multiqc_files = Channel.empty()
    ch_fasta_query   = ch_samplesheet_query.map { [it[0], []] }.mix(ch_samplesheet_fasta.map { [it[0], file(it[1])] })

    ch_oma_groups    = params.oma_path ? Channel.value(file(params.oma_path)) : Channel.empty()
    ch_oma_uniprot   = params.oma_uniprot_path ? Channel.value(file(params.oma_uniprot_path)) : Channel.empty()
    ch_oma_ensembl   = params.oma_ensembl_path ? Channel.value(file(params.oma_ensembl_path)) : Channel.empty()
    ch_oma_refseq    = params.oma_refseq_path ? Channel.value(file(params.oma_refseq_path)) : Channel.empty()
    ch_panther       = params.panther_path ? Channel.value(file(params.panther_path)) : Channel.empty()
    ch_eggnog        = params.eggnog_path ? Channel.value(file(params.eggnog_path)) : Channel.empty()
    ch_eggnog_idmap  = params.eggnog_idmap_path ? Channel.value(file(params.eggnog_idmap_path)) : Channel.empty()

    ch_seqhits       = ch_samplesheet_query.map { [it[0], []] }
    ch_seqmisses     = ch_samplesheet_query.map { [it[0], []] }

    GET_ORTHOLOGS (
        ch_samplesheet_query,
        ch_samplesheet_fasta,
        ch_oma_groups,
        ch_oma_uniprot,
        ch_oma_ensembl,
        ch_oma_refseq,
        ch_panther,
        ch_eggnog,
        ch_eggnog_idmap
    )

    ch_versions = ch_versions.mix(GET_ORTHOLOGS.out.versions)

    ch_seqs = ch_samplesheet_query.map { [it[0], []] }

    if (!params.offline_run && (!params.skip_merge || !params.skip_downstream))
    {
        GET_SEQUENCES (
            GET_ORTHOLOGS.out.orthologs,
            ch_fasta_query
        )

        ch_seqs      = GET_SEQUENCES.out.fasta
        ch_seqhits   = GET_SEQUENCES.out.hits
        ch_seqmisses = GET_SEQUENCES.out.misses

        ch_versions = ch_versions.mix(GET_SEQUENCES.out.versions)
    }

    ch_id_map   = ch_fasta_query.map { [it[0], []] }
    ch_clusters = ch_fasta_query.map { [it[0], []] }

    if (!params.offline_run && !params.skip_merge)
    {
        MERGE_IDS (
            ch_seqs
        )

        ch_versions = ch_versions.mix(MERGE_IDS.out.versions)

        ch_id_map   = MERGE_IDS.out.id_map
        ch_clusters = MERGE_IDS.out.id_clusters
    }

    SCORE_ORTHOLOGS (
        GET_ORTHOLOGS.out.seqinfo,
        GET_ORTHOLOGS.out.orthologs,
        ch_id_map,
        ch_clusters,
        params.skip_merge,
        params.skip_orthoplots
    )

    ch_versions = ch_versions.mix(SCORE_ORTHOLOGS.out.versions)

    ch_samplesheet = ch_samplesheet_query.mix (ch_samplesheet_fasta)

    ch_multiqc_files = ch_multiqc_files.mix(SCORE_ORTHOLOGS.out.aggregated_stats.map {it[1]})
    ch_multiqc_files = ch_multiqc_files.mix(SCORE_ORTHOLOGS.out.aggregated_hits.map {it[1]})
    ch_multiqc_files = ch_multiqc_files.mix(SCORE_ORTHOLOGS.out.aggregated_merge.map {it[1]})

    if(workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() != 0) {
        log.warn(
            "The conda/mamba profile is used, so the report will not be generated. " +
            "Please use the 'skip_report' parameter to skip this warning."
        )
    }

    if(!params.skip_report && workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() == 0) {
        REPORT (
            params.use_centroid,
            params.min_score,
            GET_ORTHOLOGS.out.seqinfo,
            SCORE_ORTHOLOGS.out.score_table,
            SCORE_ORTHOLOGS.out.orthologs,
            SCORE_ORTHOLOGS.out.supports_plot.map { [it[0], it[2]]},
            SCORE_ORTHOLOGS.out.venn_plot.map { [it[0], it[2]]},
            SCORE_ORTHOLOGS.out.jaccard_plot.map { [it[0], it[2]]},
            SCORE_ORTHOLOGS.out.stats,
            ch_seqhits,
            ch_seqmisses,
            SCORE_ORTHOLOGS.out.merge,
            ch_clusters
        )

        ch_versions = ch_versions.mix(REPORT.out.versions)
    }

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name: 'nf_core_'  +  'reportho_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }


    //
    // MultiQC
    //
    ch_multiqc_report = Channel.empty()
    if (!params.skip_multiqc) {
        ch_multiqc_config        = Channel.fromPath(
            "$projectDir/assets/multiqc_config.yml", checkIfExists: true)

        ch_multiqc_custom_config = params.multiqc_config ?
            Channel.fromPath(params.multiqc_config, checkIfExists: true) :
            Channel.empty()

        ch_multiqc_logo          = params.multiqc_logo ?
            Channel.fromPath(params.multiqc_logo, checkIfExists: true) :
            Channel.empty()
        summary_params      = paramsSummaryMap(
            workflow, parameters_schema: "nextflow_schema.json")

        ch_workflow_summary = Channel.value(paramsSummaryMultiqc(summary_params))

        ch_multiqc_custom_methods_description = params.multiqc_methods_description ?
            file(params.multiqc_methods_description, checkIfExists: true) :
            file("$projectDir/assets/methods_description_template.yml", checkIfExists: true)

        ch_methods_description                = Channel.value(
            methodsDescriptionText(ch_multiqc_custom_methods_description))

        ch_multiqc_files = ch_multiqc_files.mix(
            ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))

        ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)

        ch_multiqc_files = ch_multiqc_files.mix(
            ch_methods_description.collectFile(
                name: 'methods_description_mqc.yaml',
                sort: true
            )
        )

        MULTIQC (
            ch_multiqc_files.collect(),
            ch_multiqc_config.toList(),
            ch_multiqc_custom_config.toList(),
            ch_multiqc_logo.toList(),
            [],
            []
        )
        ch_multiqc_report = MULTIQC.out.report.toList()
    }

    emit:
    multiqc_report = ch_multiqc_report // channel: /path/to/multiqc_report.html
    versions       = ch_collated_versions    // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
