process IDENTIFY_SEQ_ONLINE {
    tag "$meta.id"
    label 'process_short'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/0d/0d538250963cf019c7bacab286c9212ea63ef29f6d15fd47af3871f14a5e88a0/data' :
        'community.wave.seqera.io/library/biopython_python_pip_omadb:f2944a25695475ca' }"

    input:
    tuple val(meta), path(fasta)

    output:
    tuple val(meta), path("*_id.txt"), path("*_taxid.txt"), path("*_exact.txt"), emit: seqinfo
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("pip show biopython | sed -n 's/^Version: //p'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('omadb'), eval("pip show omadb | sed -n 's/^Version: //p'"), emit: versions_omadb, topic: versions
    tuple val("${task.process}"), val('oma_database'), eval("get_oma_version.py | sed -n 's/^OMA Database:[[:space:]]*//p'"), emit: versions_oma_database, topic: versions
    tuple val("${task.process}"), val('oma_api'), eval("get_oma_version.py | sed -n 's/^OMA API:[[:space:]]*//p'"), emit: versions_oma_api, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    fetch_oma_by_sequence.py --fasta $fasta --id-out id_raw.txt --taxid-out ${prefix}_taxid.txt --exact-out ${prefix}_exact.txt
    uniprotize_oma_online.py --oma-group-file id_raw.txt > ${prefix}_id.txt
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_id.txt
    touch ${prefix}_taxid.txt
    touch ${prefix}_exact.txt
    """
}
