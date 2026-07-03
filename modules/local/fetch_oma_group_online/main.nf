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
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c 'import Bio; print(Bio.__version__)' | sed 's/^//'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions
    tuple val("${task.process}"), val('oma_database'), eval("get_oma_version.py | sed -n 's/^[[:space:]]*OMA Database:[[:space:]]*//p'"), emit: versions_oma_database, topic: versions
    tuple val("${task.process}"), val('oma_api'), eval("get_oma_version.py | sed -n 's/^[[:space:]]*OMA API:[[:space:]]*//p'"), emit: versions_oma_api, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get uniprot ID
    uniprot_id=\$(cat ${uniprot_id})

    # fetch OMA group ID from API
    groupid=\$(fetch_oma_groupid.py --protein-id \$uniprot_id)

    # fetch OMA group from API
    fetch_oma_group.py --group-id \$groupid > oma_group_raw.txt

    # convert OMA group to Uniprot IDs
    uniprotize_oma_online.py --oma-group-file oma_group_raw.txt > ${prefix}_oma_group.txt

    # convert output to CSV
    csv_adorn.py --path ${prefix}_oma_group.txt --header OMA > ${prefix}_oma_group.csv
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_oma_group.csv
    """
}
