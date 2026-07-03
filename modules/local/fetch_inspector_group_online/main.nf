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
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c 'import Bio; print(Bio.__version__)' | sed 's/^//'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions
    tuple val("${task.process}"), val('orthoinspector_database'), eval("""echo "$inspector_version" | sed 's/^//'"""), emit: versions_orthoinspector_database, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get the Uniprot ID
    uniprot_id=\$(cat $uniprot_id)

    # get the OrthoInspector group from the API
    fetch_inspector_group.py --uniprot-id \$uniprot_id --db-id $inspector_version > ${prefix}_inspector_group.txt

    # convert output to CSV
    csv_adorn.py --path ${prefix}_inspector_group.txt --header OrthoInspector > ${prefix}_inspector_group.csv
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_inspector_group.csv
    """
}
