process MAKE_SCORE_TABLE {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), path(merged_csv), path(id_map)

    output:
    tuple val(meta), path('*score_table.csv'), emit: score_table
    tuple val("${task.process}"), val('python'), eval("python3 --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python3 -c 'import Bio; print(Bio.__version__)' | sed 's/^//'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    def id_arg = id_map ? "cat ${id_map} > idmap" : "touch idmap"
    """
    $id_arg
    make_score_table.py --merged-csv $merged_csv --diamond-mapping idmap > ${prefix}_score_table.csv
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_score_table.csv
    """
}
