/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
include { MULTIQC                } from '../modules/nf-core/multiqc/main'
include { paramsSummaryMap       } from 'plugin/nf-schema'
include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline/main'
include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline/main'
include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_reportho_pipeline/main'

include { GET_ORTHOLOGS          } from '../subworkflows/local/get_orthologs/main'
include { GET_SEQUENCES          } from '../subworkflows/local/get_sequences/main'
include { MERGE_IDS              } from '../subworkflows/local/merge_ids/main'
include { SCORE_ORTHOLOGS        } from '../subworkflows/local/score_orthologs/main'
include { GENERATE_MSA_SAMPLESHEET } from '../subworkflows/local/generate_msa_samplesheet/main'
include { REPORT                 } from '../subworkflows/local/report/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow REPORTHO {

    take:
    ch_samplesheet_query // channel: samplesheet query
    ch_samplesheet_fasta // channel: samplesheet fasta
    use_centroid
    min_score
    skip_merge
    min_identity
    min_coverage
    multiqc_config
    multiqc_logo
    multiqc_methods_description
    outdir

    main:
    ch_multiqc_files = channel.empty()
    ch_fasta_query   = ch_samplesheet_query.map { meta, _query -> [meta, []] }.mix(ch_samplesheet_fasta.map { meta, fasta -> [meta, file(fasta)] })

    ch_oma_groups    = params.oma_path ? channel.value(file(params.oma_path)) : channel.empty()
    ch_oma_uniprot   = params.oma_uniprot_path ? channel.value(file(params.oma_uniprot_path)) : channel.empty()
    ch_oma_ensembl   = params.oma_ensembl_path ? channel.value(file(params.oma_ensembl_path)) : channel.empty()
    ch_oma_refseq    = params.oma_refseq_path ? channel.value(file(params.oma_refseq_path)) : channel.empty()
    ch_panther       = params.panther_path ? channel.value(file(params.panther_path)) : channel.empty()
    ch_eggnog        = params.eggnog_path ? channel.value(file(params.eggnog_path)) : channel.empty()
    ch_eggnog_idmap  = params.eggnog_idmap_path ? channel.value(file(params.eggnog_idmap_path)) : channel.empty()

    ch_seqhits       = ch_samplesheet_query.map { meta, _query -> [meta, []] }
    ch_seqmisses     = ch_samplesheet_query.map { meta, _query -> [meta, []] }

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

    ch_seqs = ch_samplesheet_query.map { meta, _query -> [meta, []] }

    if (!params.offline_run && (!params.skip_merge || !params.skip_downstream))
    {
        GET_SEQUENCES (
            GET_ORTHOLOGS.out.orthologs,
            ch_fasta_query
        )

        ch_seqs      = GET_SEQUENCES.out.fasta
        ch_seqhits   = GET_SEQUENCES.out.hits
        ch_seqmisses = GET_SEQUENCES.out.misses
    }

    ch_id_map   = ch_fasta_query.map { meta, _fasta -> [meta, []] }
    ch_clusters = ch_fasta_query.map { meta, _fasta -> [meta, []] }

    if (!params.offline_run && !params.skip_merge)
    {
        MERGE_IDS (
            ch_seqs
        )

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
    ch_multiqc_files = ch_multiqc_files.mix(SCORE_ORTHOLOGS.out.aggregated_stats.map { _meta, stats_csv -> stats_csv })
    ch_multiqc_files = ch_multiqc_files.mix(SCORE_ORTHOLOGS.out.aggregated_hits.map { _meta, hits_csv -> hits_csv })
    ch_multiqc_files = ch_multiqc_files.mix(SCORE_ORTHOLOGS.out.aggregated_merge.map { _meta, merge_csv -> merge_csv })

    if(!params.skip_samplesheets) {
        GENERATE_MSA_SAMPLESHEET(
            ch_seqs,
            SCORE_ORTHOLOGS.out.orthologs,
            outdir
        )
    }

    if(workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() != 0) {
        log.warn(
            "The conda/mamba profile is used, so the report will not be generated. " +
            "Please use the 'skip_report' parameter to skip this warning."
        )
    }

    if(!params.skip_report && workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() == 0) {
        REPORT (
            use_centroid,
            min_score,
            skip_merge,
            min_identity,
            min_coverage,
            GET_ORTHOLOGS.out.seqinfo,
            SCORE_ORTHOLOGS.out.score_table,
            SCORE_ORTHOLOGS.out.orthologs,
            SCORE_ORTHOLOGS.out.supports_plot.map { meta, _plot_table, supports_plot -> [meta, supports_plot]},
            SCORE_ORTHOLOGS.out.venn_plot.map { meta, _plot_table, venn_plot -> [meta, venn_plot]},
            SCORE_ORTHOLOGS.out.jaccard_plot.map { meta, _plot_table, jaccard_plot -> [meta, jaccard_plot]},
            SCORE_ORTHOLOGS.out.stats,
            ch_seqhits,
            ch_seqmisses,
            SCORE_ORTHOLOGS.out.merge,
            ch_clusters
        )
    }

    //
    // Collate and save software versions
    //
    def topic_versions = channel.topic("versions")
        .distinct()
        .branch { entry ->
            versions_file: entry instanceof Path
            versions_tuple: true
        }

    def topic_versions_string = topic_versions.versions_tuple
        .map { process, tool, version ->
            [ process[process.lastIndexOf(':')+1..-1], "  ${tool}: ${version}" ]
        }
        .groupTuple(by:0)
        .map { process, tool_versions ->
            tool_versions.unique().sort()
            "${process}:\n${tool_versions.join('\n')}"
        }

    def ch_collated_versions = softwareVersionsToYAML(topic_versions.versions_file)
        .mix(topic_versions_string)
        .collectFile(
            storeDir: "${outdir}/pipeline_info",
            name: 'nf_core_'  +  'reportho_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        )

    //
    // MultiQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)

    def ch_summary_params = paramsSummaryMap(workflow, parameters_schema: "nextflow_schema.json")

    def ch_workflow_summary = channel.value(paramsSummaryMultiqc(ch_summary_params))

    ch_multiqc_files = ch_multiqc_files.mix(ch_workflow_summary.collectFile(name: 'workflow_summary_mqc.yaml'))

    def ch_multiqc_custom_methods_description = multiqc_methods_description
        ? file(multiqc_methods_description, checkIfExists: true)
        : file("${projectDir}/assets/methods_description_template.yml", checkIfExists: true)

    def ch_methods_description = channel.value(methodsDescriptionText(ch_multiqc_custom_methods_description))

    ch_multiqc_files = ch_multiqc_files.mix(ch_methods_description.collectFile(name: 'methods_description_mqc.yaml', sort: true))

    MULTIQC(
        ch_multiqc_files.flatten().collect().map { files ->
            [
                [id: 'reportho'],
                files,
                multiqc_config
                    ? file(multiqc_config, checkIfExists: true)
                    : file("${projectDir}/assets/multiqc_config.yml", checkIfExists: true),
                multiqc_logo ? file(multiqc_logo, checkIfExists: true) : [],
                [],
                [],
            ]
        }
    )
    emit:
    MULTIQC.out.report.map { _meta, report -> [report] }.toList() // channel: /path/to/multiqc_report.html
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
