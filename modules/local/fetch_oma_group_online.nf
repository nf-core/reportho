process FETCH_OMA_GROUP_ONLINE {
    input:
    tuple val(meta), path(uniprot_id), path(taxid)

    output:
    tuple val(meta), path("oma_group.txt")

    script:
    """
    uniprot_id=\$(cat ${uniprot_id})
    groupid=\$(fetch_oma_groupid.py \$uniprot_id)
    fetch_oma_group.py \$groupid > oma_group_raw.txt
    uniprotize_oma.py oma_group_raw.txt > oma_group.txt
    """
}
