process DUMP_PARAMS {
    tag "$meta.id"
    label "process_single"

    input:
    val meta

    output:
    tuple val(meta), path("*_params.yml"), emit: params

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    echo <<- END_PARAMS > params.yml
    uniprot_query: ${params.uniprot_query}
    use_structures: ${params.use_structures}
    merge_strategy: ${params.merge_strategy}
    END_PARAMS
    """
}
