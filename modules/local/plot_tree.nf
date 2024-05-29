process PLOT_TREE {
    tag "$meta.id"
    label 'process_single'

    conda "bioconda::bioconductor-treeio=1.26.0 bioconda::bioconductor-ggtree=3.10.0 conda-forge::r-ggplot2=3.5.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        "oras://community.wave.seqera.io/library/bioconductor-ggtree_bioconductor-treeio_r-ggplot2:89a30ee47c501fe4" :
        "community.wave.seqera.io/library/bioconductor-ggtree_bioconductor-treeio_r-ggplot2:54fc04b8b0f7b6c7" }"

    input:
    tuple val(meta), path(tree)
    val method

    output:
    tuple val(meta), path("*_light.png"), path("*_dark.png") , emit: plot
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    plot_tree.R $tree $prefix $method

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
    END_VERSIONS
    """

    stub:
    prefix = task.ext.prefix ?: meta.id
    """
    touch ${prefix}_${method}_tree_dark.png
    touch ${prefix}_${method}_tree_light.png

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
    END_VERSIONS
    """
}
