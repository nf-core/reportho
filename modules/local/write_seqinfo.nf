process WRITE_SEQINFO {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.11.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-ffdffc678ef7e057a54c6e2a990ebda211c39d9c:b162506bb828460d3d668b995cae3d4274ce8488-0' :
        'biocontainers/mulled-v2-ffdffc678ef7e057a54c6e2a990ebda211c39d9c:b162506bb828460d3d668b995cae3d4274ce8488-0' }"

    input:
    tuple val(meta), val(uniprot_id)

    output:
    tuple val(meta), path("id.txt"), path("taxid.txt"), emit: seqinfo
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    echo "${uniprot_id}" > id.txt
    fetch_oma_taxid_by_id.py $uniprot_id > taxid.txt

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python3 --version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
