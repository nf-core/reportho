#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/reportho
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/nf-core/reportho
    Website: https://nf-co.re/reportho
    Slack  : https://nfcore.slack.com/channels/reportho
----------------------------------------------------------------------------------------
*/

nextflow.enable.moduleBinaries = true

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { REPORTHO  } from './workflows/reportho'
include { PIPELINE_INITIALISATION } from './subworkflows/local/utils_nfcore_reportho_pipeline/main'
include { PIPELINE_COMPLETION     } from './subworkflows/local/utils_nfcore_reportho_pipeline/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    NAMED WORKFLOWS FOR PIPELINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Run main analysis pipeline depending on type of input
//
workflow NFCORE_REPORTHO {

    take:
    samplesheet_query   // channel: samplesheet read in from --input with query
    samplesheet_fasta   // channel: samplesheet read in from --input with fasta
    offline_run
    use_all
    use_centroid
    skip_oma
    local_databases
    oma_path
    oma_uniprot_path
    oma_ensembl_path
    oma_refseq_path
    skip_panther
    panther_path
    skip_orthoinspector
    orthoinspector_version
    skip_eggnog
    eggnog_path
    eggnog_idmap_path
    min_score
    skip_merge
    skip_downstream
    skip_orthoplots
    skip_samplesheets
    skip_report
    min_identity
    min_coverage
    multiqc_config
    multiqc_logo
    multiqc_methods_description
    outdir

    main:

    //
    // WORKFLOW: Run pipeline
    //
    REPORTHO (
        samplesheet_query,
        samplesheet_fasta,
        offline_run,
        use_all,
        use_centroid,
        skip_oma,
        local_databases,
        oma_path,
        oma_uniprot_path,
        oma_ensembl_path,
        oma_refseq_path,
        skip_panther,
        panther_path,
        skip_orthoinspector,
        orthoinspector_version,
        skip_eggnog,
        eggnog_path,
        eggnog_idmap_path,
        min_score,
        skip_merge,
        skip_downstream,
        skip_orthoplots,
        skip_samplesheets,
        skip_report,
        min_identity,
        min_coverage,
        multiqc_config,
        multiqc_logo,
        multiqc_methods_description,
        outdir,
    )

    emit:
    REPORTHO.out
}
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {

    main:
    effective_local_databases = params.local_databases
    effective_skip_downstream = params.containsKey('skip_downstream') ? params['skip_downstream'] : false

    if (params.offline_run) {
        if (!effective_local_databases) {
            effective_local_databases = true
            log.warn("Offline mode enabled, setting 'local_databases' to 'true'")
        }
        if (!effective_skip_downstream) {
            effective_skip_downstream = true
            log.warn("Offline mode enabled, setting 'skip_downstream' to 'true'")
        }
        if (params.use_all) {
            log.warn("Offline run set with 'use_all', only local databases will be used")
        }
    } else if (params.use_all && effective_local_databases) {
        log.warn("Local databases set with 'use_all', only local databases will be used")
    }

    if (!params.skip_samplesheets && (params.offline_run || (params.skip_merge && effective_skip_downstream))) {
        log.error("Samplesheet generation for nf-core/multiplesequencealign requires fetched sequences. Set '--skip_samplesheets' to true or disable offline/no-fetch settings.")
    }

    //
    // SUBWORKFLOW: Run initialisation tasks
    //
    PIPELINE_INITIALISATION (
        params.version,
        params.validate_params,
        params.monochrome_logs,
        args,
        params.outdir,
        params.input,
        params.help,
        params.help_full,
        params.show_hidden
    )

    //
    // WORKFLOW: Run main workflow
    //
    NFCORE_REPORTHO (
        PIPELINE_INITIALISATION.out.samplesheet_query,
        PIPELINE_INITIALISATION.out.samplesheet_fasta,
        params.offline_run,
        params.use_all,
        params.use_centroid,
        params.skip_oma,
        effective_local_databases,
        params.oma_path,
        params.oma_uniprot_path,
        params.oma_ensembl_path,
        params.oma_refseq_path,
        params.skip_panther,
        params.panther_path,
        params.skip_orthoinspector,
        params.orthoinspector_version,
        params.skip_eggnog,
        params.eggnog_path,
        params.eggnog_idmap_path,
        params.min_score,
        params.skip_merge,
        effective_skip_downstream,
        params.skip_orthoplots,
        params.skip_samplesheets,
        params.skip_report,
        params.min_identity,
        params.min_coverage,
        params.multiqc_config,
        params.multiqc_logo,
        params.multiqc_methods_description,
        params.outdir
    )
    //
    // SUBWORKFLOW: Run completion tasks
    //
    PIPELINE_COMPLETION (
        params.email,
        params.email_on_fail,
        params.plaintext_email,
        params.max_multiqc_email_size,
        params.outdir,
        params.monochrome_logs,
        NFCORE_REPORTHO.out
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
