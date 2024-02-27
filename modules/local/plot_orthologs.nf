process PLOT_ORTHOLOGS {
    input:
    tuple val(meta), path(score_table)

    output:
    val meta, emit: meta
    path "supports.png", emit: supports
    path "venn.png", emit: venn
    path "versions.yml", emit: versions

    script:
    """
    plot_orthologs.R $score_table .

    cat <<- END_VERSIONS > versions.yml
    "${task.process}"
        R: \$(R --version | head -n 1 | cut -d ' ' -f 3)
    END_VERSIONS
    """
}
