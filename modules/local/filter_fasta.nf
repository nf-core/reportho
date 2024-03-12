process FILTER_FASTA {
    tag "$meta.id"
    label "process_single"

    input:
    tuple val(meta), path(fasta), path(structures)

    output:
    tuple val(meta), path("*_filtered.fa"), emit: fasta

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    filter_fasta.py ${fasta} ${structures} ${prefix}_filtered.fa
    """
}
