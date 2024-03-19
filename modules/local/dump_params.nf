process DUMP_PARAMS {
    tag "$meta.id"
    label "process_single"

    input:
    val meta

    output:
    tuple val(meta), path("params.yml"), emit: params

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    echo <<- END_PARAMS > params.yml
    uniprot_query: ${params.uniprot_query}
    use_structures: ${params.use_structures}
    merge_strategy: ${params.merge_strategy}
    END_PARAMS
    """
}
