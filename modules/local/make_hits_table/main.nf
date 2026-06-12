process MAKE_HITS_TABLE {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), path(merged_csv)

    output:
    tuple val(meta), path('*hits_table.csv'), emit: hits_table
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    make_hits_table.py $merged_csv ${meta.id} > ${prefix}_hits_table.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_hits_table.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
