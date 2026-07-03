process FILTER_HITS {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), path(score_table), path(queryid)
    val use_centroid
    val min_score

    output:
    tuple val(meta), path('*_minscore_*.txt'), path("*_centroid.txt"), emit: scored_hits
    tuple val(meta), path('*_filtered_hits.txt')                     , emit: filtered_hits
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c 'import Bio; print(Bio.__version__)' | sed 's/^//'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    targetfile = use_centroid ? "${prefix}_centroid.txt" : "${prefix}_minscore_${min_score}.txt"
    """
    score_hits.py --input-file $score_table --prefix $prefix --query-file $queryid
    touch $targetfile
    touch ${prefix}_centroid.txt
    cat $targetfile > ${prefix}_filtered_hits.txt
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_minscore_000.txt
    touch ${prefix}_centroid.txt
    touch ${prefix}_filtered_hits.txt
    """
}
