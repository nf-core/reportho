process WRITE_SEQINFO {
    input:
    tuple val(meta), val(uniprot_id), val(taxid)

    output:
    tuple val(meta), path("id.txt"), path("taxid.txt")

    script:
    """
    echo "${uniprot_id}" > id.txt
    echo "${taxid}" > taxid.txt
    """
}
