process FILTER_FASTA {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.10.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/python:3.10' :
        'biocontainers/python:3.10' }"

    input:
    tuple val(meta), path(fasta), path(structures)

    output:
    tuple val(meta), path("*_filtered.fa"), emit: fasta
    path "versions.yml"                   , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    filter_fasta.py ${fasta} ${structures} ${prefix}_filtered.fa

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
