process WRITE_SEQINFO {
    input:
    tuple val(meta), val(uniprot_id)

    output:
    tuple val(meta), path("id.txt"), path("taxid.txt")

    script:
    """
    echo "${uniprot_id}" > id.txt
    fetch_oma_taxid_by_id.py $uniprot_id > taxid.txt
    """
}
