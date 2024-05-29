process FETCH_EGGNOG_GROUP_LOCAL {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.12.3 conda-forge::ripgrep=14.1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/python_ripgrep:6f07fd6cbda0142b' :
        'container "community.wave.seqera.io/library/python_ripgrep:324b372792aae9ce' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    path db
    path eggnog_idmap
    path ensembl_idmap
    path refseq_idmap
    val offline_run

    output:
    tuple val(meta), path("*_eggnog_group.csv"), emit: eggnog_group
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    uniprotid=\$(zcat $eggnog_idmap | grep \$(cat $uniprot_id) | cut -f2 | cut -d',' -f1)
    zcat $db | grep \$uniprotid | cut -f 5 | tr ',' '\\n' | awk -F'.' '{ print \$2 }' > ${prefix}_eggnog_group_raw.txt || test -f ${prefix}_eggnog_group_raw.txt
    uniprotize_oma_local.py ${prefix}_eggnog_group_raw.txt $ensembl_idmap $refseq_idmap > ${prefix}_eggnog_group.txt
    touch ${prefix}_eggnog_group.txt
    csv_adorn.py ${prefix}_eggnog_group.txt EggNOG > ${prefix}_eggnog_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
        ripgrep: \$(rg --version | head -n1 | cut -d' ' -f2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_eggnog_group.txt
    touch ${prefix}_eggnog_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
        ripgrep: \$(rg --version | head -n1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
