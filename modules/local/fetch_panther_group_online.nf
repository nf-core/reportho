process FETCH_PANTHER_GROUP_ONLINE {
    input:
    tuple val(meta), path(uniprot_id), path(taxid)

    output:
    tuple val(meta), path("panther_group.txt")

    script:
    """
    uniprot_id=\$(cat uniprot_id)
    taxid=\$(cat taxid)
    fetch_panther_group.py \$uniprot_id \$taxid > panther_group.txt
    """
}
