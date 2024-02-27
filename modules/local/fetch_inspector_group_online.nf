process FETCH_INSPECTOR_GROUP_ONLINE {
    input:
    tuple val(meta), path(uniprot_id), path(taxid)

    output:
    tuple val(meta), path("inspector_group.txt")

    script:
    """
    uniprot_id=\$(cat $uniprot_id)
    fetch_inspector_group.py $uniprot_id > inspector_group.txt
    """
}
