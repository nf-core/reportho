process FETCH_PANTHER_GROUP_ONLINE {
    input:
    tuple val(meta), path(uniprot_id), path(taxid)

    output:
    tuple val(meta), path("panther_group.txt") , emit:panther_group
    path "versions.yml"                        , emit: versions

    script:
    """
    uniprot_id=\$(cat $uniprot_id)
    taxid=\$(cat $taxid)
    fetch_panther_group.py \$uniprot_id \$taxid > panther_group.txt 2> panther_version.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Panther Database: \$(cat panther_version.txt)
    END_VERSIONS
    """
}
