process DUMP_PARAMS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
    'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(exact)
    val uniprot_query
    val use_structures
    val use_centroid
    val min_score
    val skip_downstream
    val use_iqtree
    val use_fastme

    output:
    tuple val(meta), path("params.yml"), emit: params

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    cat <<- END_PARAMS > params.yml
    id: ${meta.id}
    uniprot_query: ${uniprot_query}
    exact_match: \$(cat $exact)
    use_structures: ${use_structures}
    use_centroid: ${use_centroid}
    min_score: ${min_score}
    skip_downstream: ${skip_downstream}
    use_iqtree: ${use_iqtree}
    use_fastme: ${use_fastme}
    END_PARAMS
    """

    stub:
    """
    touch params.yml
    """
}
