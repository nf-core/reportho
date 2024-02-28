process FETCH_OMA_GROUP_ONLINE {
    tag "$meta.id"
    label 'process_single'

    // conda "conda-forge::python=3.11.0 conda-forge::biopython=1.80 conda-forge::requests=2.31.0"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/mulled-v2-27978155697a3671f3ef9aead4b5c823a02cc0b7:548df772fe13c0232a7eab1bc1deb98b495a05ab-0' :
    //     'biocontainers/mulled-v2-27978155697a3671f3ef9aead4b5c823a02cc0b7:548df772fe13c0232a7eab1bc1deb98b495a05ab-0' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid)

    output:
    tuple val(meta), path("oma_group.txt") , emit: oma_group
    path "versions.yml"                    , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    uniprot_id=\$(cat ${uniprot_id})
    groupid=\$(fetch_oma_groupid.py \$uniprot_id)
    fetch_oma_group.py \$groupid > oma_group_raw.txt
    uniprotize_oma.py oma_group_raw.txt > oma_group.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    \$(get_oma_version.py)
    END_VERSIONS
    """
}
