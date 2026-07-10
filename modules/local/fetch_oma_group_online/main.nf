process FETCH_OMA_GROUP_ONLINE {
    tag "$meta.id"
    label 'process_short'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/06/06c8422fa5063073c0c455709d27accb593303cb55e82a3437fad3171e103547/data' :
        'community.wave.seqera.io/library/pip_omadb:23b3dbf1b029e3cc' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)

    output:
    tuple val(meta), path("*_oma_group.csv"), emit: oma_group
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('omadb'), eval("pip show omadb | sed -n 's/^Version: //p'"), emit: versions_omadb, topic: versions
    tuple val("${task.process}"), val('oma_database'), eval("get_oma_version.py | sed -n 's/^OMA Database:[[:space:]]*//p'"), emit: versions_oma_database, topic: versions
    tuple val("${task.process}"), val('oma_api'), eval("get_oma_version.py | sed -n 's/^OMA API:[[:space:]]*//p'"), emit: versions_oma_api, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get uniprot ID
    uniprot_id=\$(cat ${uniprot_id})

    # fetch OMA group from API
    fetch_oma_group.py --protein-id \$uniprot_id > oma_group_raw.txt

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
