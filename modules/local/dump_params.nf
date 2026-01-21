process DUMP_PARAMS {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::coreutils=9.5"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
    'nf-core/ubuntu:20.04' }"

    input:
    tuple val(meta), path(exact)
    val use_centroid
    val min_score
    val skip_merge
    val min_identity
    val min_coverage

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
    use_centroid: ${use_centroid}
    min_score: ${min_score}
    skip_merge: ${skip_merge}
    min_identity: ${min_identity}
    min_coverage: ${min_coverage}
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
