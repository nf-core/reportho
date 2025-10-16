process SPLIT_ID_FORMAT {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.12.9 conda-forge::requests=2.32.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/1c/1c915e07bc896c1ee384b521d49f45e1244c18299f88ad0b02fa8d221f0a7c7e/data' :
        'community.wave.seqera.io/library/python_requests:222028ddf1c9e3c2' }"

    input:
    tuple val(meta), path(ids)

    output:
    tuple val(meta), path('*_ids.txt'), emit: ids_split
    path "versions.yml"               , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    cut -d ',' -f 1 $ids | tail -n +2 > tmp
    split_id_format.py tmp $prefix

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_uniprot_ids.txt

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
