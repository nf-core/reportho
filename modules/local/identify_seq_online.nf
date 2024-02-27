process IDENTIFY_SEQ_ONLINE {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.11.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-ffdffc678ef7e057a54c6e2a990ebda211c39d9c:b162506bb828460d3d668b995cae3d4274ce8488-0' :
        'biocontainers/mulled-v2-ffdffc678ef7e057a54c6e2a990ebda211c39d9c:b162506bb828460d3d668b995cae3d4274ce8488-0' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("id.txt"), path("taxid.txt"), emit: seqinfo
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    fetch_oma_by_sequence.py $fasta id_raw.txt taxid.txt
    uniprotize_oma.py id_raw.txt > id.txt

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
