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
    tuple val("${task.process}"), val('python'), eval("python3 --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    cut -d ',' -f 1 $ids | tail -n +2 > tmp
    split_id_format.py --id-list tmp --prefix $prefix
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_uniprot_ids.txt
    """
}
