process DUMP_PARAMS {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::coreutils=9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
    'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(exact)
    val use_structures
    val use_centroid
    val min_score
    val skip_downstream
    val skip_iqtree
    val skip_fastme

    output:
    tuple val(meta), path("params.yml"), emit: params
    path("versions.yml"), emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    cat <<- END_PARAMS > params.yml
    id: ${meta.id}
    exact_match: \$(cat $exact)
    use_structures: ${use_structures}
    use_centroid: ${use_centroid}
    min_score: ${min_score}
    skip_downstream: ${skip_downstream}
    skip_iqtree: ${skip_iqtree}
    skip_fastme: ${skip_fastme}
    END_PARAMS

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cat: \$(echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    """
    touch params.yml

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        cat: \$(echo \$(cat --version 2>&1) | sed 's/^.*coreutils) //; s/ .*\$//')
    END_VERSIONS
    """
}
