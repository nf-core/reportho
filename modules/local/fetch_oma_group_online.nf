process FETCH_OMA_GROUP_ONLINE {
    input:
    tuple val(meta), path(uniprot_id), path(taxid)

    output:
    tuple val(meta), path("oma_group.txt") , emit: oma_group
    path "versions.yml"                    , emit: versions

    script:
    """
    uniprot_id=\$(cat ${uniprot_id})
    groupid=\$(fetch_oma_groupid.py \$uniprot_id)
    fetch_oma_group.py \$groupid > oma_group_raw.txt
    uniprotize_oma.py oma_group_raw.txt > oma_group.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python3 --version | cut -d ' ' -f 2)
    \$(get_oma_version.py)
    END_VERSIONS
    """
}
