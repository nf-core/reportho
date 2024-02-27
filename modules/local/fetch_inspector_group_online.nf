process FETCH_INSPECTOR_GROUP_ONLINE {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.11.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-ffdffc678ef7e057a54c6e2a990ebda211c39d9c:b162506bb828460d3d668b995cae3d4274ce8488-0' :
        'biocontainers/mulled-v2-ffdffc678ef7e057a54c6e2a990ebda211c39d9c:b162506bb828460d3d668b995cae3d4274ce8488-0' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid)
    val inspector_version

    output:
    tuple val(meta), path("inspector_group.txt") , emit: inspector_group
    path "versions.yml"                          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    uniprot_id=\$(cat $uniprot_id)
    fetch_inspector_group.py \$uniprot_id $inspector_version > inspector_group.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        OrthoInspector Database: $inspector_version
    END_VERSIONS
    """
}
