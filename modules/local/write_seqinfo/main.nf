process WRITE_SEQINFO {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), val(uniprot_id)
    val offline_run

    output:
    tuple val(meta), path("*_id.txt"), path("*_taxid.txt"), path("*_exact.txt") , emit: seqinfo
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c 'import Bio; print(Bio.__version__)' | sed 's/^//'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    tax_command = offline_run ? "echo 'UNKNOWN'" : "fetch_oma_taxid_by_id.py --uniprot-id $uniprot_id"
    """
    echo "${uniprot_id}" > ${prefix}_id.txt
    echo "true" > ${prefix}_exact.txt
    $tax_command > ${prefix}_taxid.txt
    """

    stub:
    prefix = task.ext.prefix ?: meta.id
    """
    touch ${prefix}_id.txt
    touch ${prefix}_exact.txt
    touch ${prefix}_taxid.txt
    """
}
