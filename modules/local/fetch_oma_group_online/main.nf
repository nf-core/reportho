process FETCH_OMA_GROUP_ONLINE {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)

    output:
    tuple val(meta), path("*_oma_group.csv"), emit: oma_group
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get uniprot ID
    uniprot_id=\$(cat ${uniprot_id})

    # fetch OMA group ID from API
    groupid=\$(fetch_oma_groupid.py \$uniprot_id)

    # fetch OMA group from API
    fetch_oma_group.py \$groupid > oma_group_raw.txt

    # convert OMA group to Uniprot IDs
    uniprotize_oma_online.py oma_group_raw.txt > ${prefix}_oma_group.txt

    # convert output to CSV
    csv_adorn.py ${prefix}_oma_group.txt OMA > ${prefix}_oma_group.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    \$(get_oma_version.py)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_oma_group.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    \$(get_oma_version.py)
    END_VERSIONS
    """
}
