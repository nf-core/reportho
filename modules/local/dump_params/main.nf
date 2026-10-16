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
    tuple val("${task.process}"), val('coreutils'), eval("cat --version | sed '1!d; s/.* //'"), emit: versions_coreutils, topic: versions

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
    """

    stub:
    """
    touch params.yml
    """
}
