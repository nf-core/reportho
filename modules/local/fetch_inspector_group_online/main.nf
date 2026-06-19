process FETCH_INSPECTOR_GROUP_ONLINE {
    tag "$meta.id"
    label 'process_low'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    val inspector_version

    output:
    tuple val(meta), path("*_inspector_group.csv"), emit: inspector_group
    path "versions.yml"                           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get the Uniprot ID
    uniprot_id=\$(cat $uniprot_id)

    # get the OrthoInspector group from the API
    fetch_inspector_group.py \$uniprot_id $inspector_version > ${prefix}_inspector_group.txt

    # convert output to CSV
    csv_adorn.py ${prefix}_inspector_group.txt OrthoInspector > ${prefix}_inspector_group.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
        OrthoInspector Database: $inspector_version
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_inspector_group.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
        OrthoInspector Database: $inspector_version
    END_VERSIONS
    """
}
