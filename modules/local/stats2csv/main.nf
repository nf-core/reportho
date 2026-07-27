process STATS2CSV {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::pyyaml=5.4.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/0d/0d2b6ac1ed316a98eca861b5fbb6d52e11fd960e331a4f356e1dff8e7b544e2a/data' :
        'community.wave.seqera.io/library/python_pyyaml:1d8dd531b5ad400c' }"

    input:
    tuple val(meta), path(stats)

    output:
    tuple val(meta), path("*_stats.csv"), emit: csv
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'" ), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('pyyaml'), eval("pip show pyyaml | sed -n 's/^Version: //p'"), emit: versions_pyyaml, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    yml2csv.py --sample-id ${meta.id} --yaml $stats --output-file ${prefix}_stats.csv
    """

    stub:
    prefix = task.ext.prefix ?: meta.id
    """
    touch ${prefix}_stats.csv
    """
}
