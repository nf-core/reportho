process PLOT_TREE {
    tag "${tree.baseName}"
    label "process_single"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://itrujnara/plot-tree:1.0.0' :
        'itrujnara/plot-tree:1.0.0' }"

    input:
    path tree

    output:
    path "*.png", emit: plot
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: tree.baseName
    """
    plot_tree.R $tree $prefix

    cat <<- END_VERSIONS > versions.yml
    ${task.process}:
        R: \$(R --version | head -n 1 | cut -d ' ' -f 3)
    END_VERSIONS
    """
}
