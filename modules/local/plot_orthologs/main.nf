process PLOT_ORTHOLOGS {
    tag "$meta.id"
    label 'process_short'

    conda     "conda-forge::r-tidyverse=2.0.0 conda-forge::r-reshape2=1.4.4 conda-forge::r-ggvenndiagram=1.5.2"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/24/241121c567b6ac13fb664276916cc15e5b21b773612e30debf1de3cafe64fd97/data' :
        'community.wave.seqera.io/library/r-ggvenndiagram_r-reshape2_r-tidyverse:b2486480b5e4dea4' }"

    input:
    tuple val(meta), path(score_table)

    output:
    tuple val(meta), path("*_supports_light.png"), path("*_supports_dark.png"), emit: supports
    tuple val(meta), path("*_venn_light.png"), path("*_venn_dark.png")        , emit: venn
    tuple val(meta), path("*_jaccard_light.png"), path("*_jaccard_dark.png")  , emit: jaccard
    tuple val("${task.process}"), val('r-base'), eval("Rscript -e 'cat(as.character(getRversion()))' | sed 's/^//'"), emit: versions_r_base, topic: versions
    tuple val("${task.process}"), val('tidyverse'), eval("Rscript -e 'cat(as.character(packageVersion(\"tidyverse\")))' | sed 's/^//'"), emit: versions_tidyverse, topic: versions
    tuple val("${task.process}"), val('reshape2'), eval("Rscript -e 'cat(as.character(packageVersion(\"reshape2\")))' | sed 's/^//'"), emit: versions_reshape2, topic: versions
    tuple val("${task.process}"), val('ggvenndiagram'), eval("Rscript -e 'cat(as.character(packageVersion(\"ggvenndiagram\")))' | sed 's/^//'"), emit: versions_ggvenndiagram, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    plot_orthologs.R $score_table $prefix
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_supports_dark.png
    touch ${prefix}_supports_light.png
    touch ${prefix}_venn_dark.png
    touch ${prefix}_venn_light.png
    touch ${prefix}_jaccard_dark.png
    touch ${prefix}_jaccard_light.png
    """
}
