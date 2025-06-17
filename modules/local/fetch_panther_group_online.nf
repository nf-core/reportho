process FETCH_PANTHER_GROUP_ONLINE {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)

    output:
    tuple val(meta), path("*_panther_group.csv"), emit: panther_group
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get Uniprot ID and TaxID
    uniprot_id=\$(cat $uniprot_id)
    taxid=\$(cat $taxid)

    # fetch PANTHER group from API
    fetch_panther_group.py \$uniprot_id \$taxid > ${prefix}_panther_group.txt || test -f ${prefix}_panther_group.txt

    # convert output to CSV
    csv_adorn.py ${prefix}_panther_group.txt PANTHER > ${prefix}_panther_group.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
        Panther Database: \$(cat panther_version.txt)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_panther_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
        Panther Database: \$(cat panther_version.txt)
    END_VERSIONS
    """
}
