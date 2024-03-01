process PLOT_ORTHOLOGS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://itrujnara/plot_orthologs:1.0.0' :
        'itrujnara/plot_orthologs:1.0.0' }"

    input:
    tuple val(meta), path(score_table)

    output:
    val meta, emit: meta
    path "supports.png", emit: supports
    path "venn.png", emit: venn
    path "jaccard.png", emit: jaccard
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
