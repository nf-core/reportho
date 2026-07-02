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
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c \"import Bio; print(Bio.__version__)\" | sed 's/^//'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions
    tuple val("${task.process}"), val('panther_database'), eval("cat panther_version.txt | sed 's/^//'"), emit: versions_panther_database, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get Uniprot ID and TaxID
    uniprot_id=\$(cat $uniprot_id)
    taxid=\$(cat $taxid)

    # fetch PANTHER group from API
    fetch_panther_group.py --input-id \$uniprot_id --organism \$taxid > ${prefix}_panther_group.txt || test -f ${prefix}_panther_group.txt

    # convert output to CSV
    csv_adorn.py --path ${prefix}_panther_group.txt --header PANTHER > ${prefix}_panther_group.csv
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_panther_group.csv
    """
}
