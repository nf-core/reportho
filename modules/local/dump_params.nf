process DUMP_PARAMS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
    'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(exact)

    output:
    tuple val(meta), path("params.yml"), emit: params

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    cat <<- END_PARAMS > params.yml
    id: ${meta.id}
    uniprot_query: ${params.uniprot_query}
    exact_match: \$(cat $exact)
    use_structures: ${params.use_structures}
    use_centroid: ${params.use_centroid}
    min_score: ${params.min_score}
    skip_downstream: ${params.skip_downstream}
    use_iqtree: ${params.use_iqtree}
    use_fastme: ${params.use_fastme}
    END_PARAMS
    """
}
