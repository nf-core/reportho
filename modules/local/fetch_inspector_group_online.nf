process FETCH_INSPECTOR_GROUP_ONLINE {
    input:
    tuple val(meta), path(uniprot_id), path(taxid)
    val inspector_version

    output:
    tuple val(meta), path("inspector_group.txt") , emit: inspector_group
    path "versions.yml"                          , emit: versions

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
