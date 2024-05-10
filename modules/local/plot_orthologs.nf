process PLOT_ORTHOLOGS {
    tag "$meta.id"
    label 'process_single'

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://itrujnara/plot-orthologs:1.0.1' :
        'itrujnara/plot-orthologs:1.0.1' }"

    input:
    tuple val(meta), path(score_table)

    output:
    tuple val(meta), path("*_supports.png") , emit: supports
    tuple val(meta), path("*_venn.png")     , emit: venn
    tuple val(meta), path("*_jaccard.png")  , emit: jaccard
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    plot_orthologs.R $score_table $prefix

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_supports.png
    touch ${prefix}_venn.png
    touch ${prefix}_jaccard.png

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
    END_VERSIONS
    """
}
