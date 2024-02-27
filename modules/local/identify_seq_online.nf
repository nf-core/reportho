process IDENTIFY_SEQ_ONLINE {
    tag "$meta.id"
    label "process_single"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("id.txt"), path("taxid.txt")

    script:
    """
    fetch_oma_by_sequence.py $fasta id_raw.txt taxid.txt
    uniprotize_oma.py id_raw.txt > id.txt
    """
}
