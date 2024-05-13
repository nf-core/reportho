/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC                 } from '../modules/nf-core/fastqc/main'
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-validation'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_reportho_pipeline'

include { GET_ORTHOLOGS          } from '../subworkflows/local/get_orthologs'
include { FETCH_SEQUENCES        } from '../subworkflows/local/fetch_sequences'
include { FETCH_STRUCTURES       } from '../subworkflows/local/fetch_structures'
include { ALIGN                  } from '../subworkflows/local/align'
include { MAKE_TREES             } from '../subworkflows/local/make_trees'
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

    GET_ORTHOLOGS (
        ch_samplesheet_query,
        ch_samplesheet_fasta
    )

    ch_versions    = ch_versions.mix(GET_ORTHOLOGS.out.versions)
    ch_samplesheet = ch_samplesheet_query.mix (ch_samplesheet_fasta)

    ch_multiqc_files = ch_multiqc_files.mix(GET_ORTHOLOGS.out.aggregated_stats.map {it[1]})
    ch_multiqc_files = ch_multiqc_files.mix(GET_ORTHOLOGS.out.aggregated_hits.map {it[1]})

    ch_seqhits   = ch_samplesheet.map { [it[0], []] }
    ch_seqmisses = ch_samplesheet.map { [it[0], []] }
    ch_strhits   = ch_samplesheet.map { [it[0], []] }
    ch_strmisses = ch_samplesheet.map { [it[0], []] }
    ch_alignment = ch_samplesheet.map { [it[0], []] }
    ch_iqtree    = ch_samplesheet.map { [it[0], []] }
    ch_fastme    = ch_samplesheet.map { [it[0], []] }

    if (!params.skip_downstream) {
        FETCH_SEQUENCES (
            GET_ORTHOLOGS.out.orthologs,
            ch_fasta_query
        )

        ch_seqhits = FETCH_SEQUENCES.out.hits

        ch_seqmisses = FETCH_SEQUENCES.out.misses

        ch_versions = ch_versions.mix(FETCH_SEQUENCES.out.versions)

        if (params.use_structures) {
            FETCH_STRUCTURES (
                GET_ORTHOLOGS.out.orthologs
            )

            ch_strhits = FETCH_STRUCTURES.out.hits

            ch_strmisses = FETCH_STRUCTURES.out.misses

            ch_versions = ch_versions.mix(FETCH_STRUCTURES.out.versions)
        }

        ch_structures = params.use_structures ? FETCH_STRUCTURES.out.structures : Channel.empty()

        ALIGN (
            FETCH_SEQUENCES.out.sequences,
            ch_structures
        )

        ch_alignment = ALIGN.out.alignment

        ch_versions = ch_versions.mix(ALIGN.out.versions)

        MAKE_TREES (
            ALIGN.out.alignment
        )

        ch_iqtree = MAKE_TREES.out.mlplot
        ch_fastme = MAKE_TREES.out.meplot

        ch_versions = ch_versions.mix(MAKE_TREES.out.versions)
    }

    if(!params.skip_report) {
        REPORT (
            params.use_structures,
            params.use_centroid,
            params.min_score,
            params.skip_downstream,
            params.skip_iqtree,
            params.skip_fastme,
            GET_ORTHOLOGS.out.seqinfo,
            GET_ORTHOLOGS.out.score_table,
            GET_ORTHOLOGS.out.orthologs,
            GET_ORTHOLOGS.out.supports_plot,
            GET_ORTHOLOGS.out.venn_plot,
            GET_ORTHOLOGS.out.jaccard_plot,
            GET_ORTHOLOGS.out.stats,
            ch_seqhits,
            ch_seqmisses,
            ch_strhits,
            ch_strmisses,
            ch_alignment,
            ch_iqtree,
            ch_fastme
        )

        ch_versions = ch_versions.mix(REPORT.out.versions)
    }

    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(storeDir: "${params.outdir}/pipeline_info", name: 'nf_core_pipeline_software_mqc_versions.yml', sort: true, newLine: true)
        .set { ch_collated_versions }

    //
    // MultiQC
    //
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
        ch_multiqc_logo.toList()
    )

    emit:
    multiqc_report = MULTIQC.out.report.toList()
    versions = ch_collated_versions // channel: [ path(versions.yml) ]
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
