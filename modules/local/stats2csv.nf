process STATS2CSV {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.11.0 conda-forge::pyyaml=5.4.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-deac90960ddeb4d14fb31faf92c0652d613b3327:10b46d090d02e9e22e206db80d14e994267520c3-0' :
        'biocontainers/mulled-v2-deac90960ddeb4d14fb31faf92c0652d613b3327:10b46d090d02e9e22e206db80d14e994267520c3-0' }"

    input:
    tuple val(meta), path(stats)

    output:
    tuple val(meta), path("*_stats.csv"), emit: csv
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    yml2csv.py ${meta.id} $stats ${prefix}_stats.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        PyYAML: \$(pip show pyyaml | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
