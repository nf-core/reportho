process PLOT_ORTHOLOGS {
    tag "$meta.id"
    label 'process_single'

    input:
    tuple val(meta), path(score_table)

    output:
    val meta, emit: meta
    path "supports.png", emit: supports
    path "venn.png", emit: venn
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    plot_orthologs.R $score_table .

    cat <<- END_VERSIONS > versions.yml
    "${task.process}"
        R: \$(R --version | head -n 1 | cut -d ' ' -f 3)
    END_VERSIONS
    """
}
