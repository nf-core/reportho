process FILTER_HITS {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' :
        'biocontainers/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' }"

    input:
    tuple val(meta), path(score_table), path(queryid)
    val use_centroid
    val min_score

    output:
    tuple val(meta), path('*_minscore_*.txt'), path("*_centroid.txt"), emit: scored_hits
    tuple val(meta), path('*_filtered_hits.txt')                     , emit: filtered_hits
    path "versions.yml"                                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix     = task.ext.prefix ?: meta.id
    targetfile = use_centroid ? "${prefix}_centroid.txt" : "${prefix}_minscore_${min_score}.txt"
    """
    score_hits.py $score_table $prefix $queryid
    touch $targetfile
    cat $targetfile > ${prefix}_filtered_hits.txt

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_minscore_000.txt
    touch ${prefix}_centroid.txt
    touch ${prefix}_filtered_hits.txt

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
    END_VERSIONS
    """
}
