process FETCH_EGGNOG_GROUP_LOCAL {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.12.3 conda-forge::ripgrep=14.1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/python_ripgrep:6f07fd6cbda0142b' :
        'community.wave.seqera.io/library/python_ripgrep:324b372792aae9ce' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    path db
    path eggnog_idmap
    path ensembl_idmap
    path refseq_idmap

    output:
    tuple val(meta), path("*_eggnog_group.csv"), emit: eggnog_group
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('ripgrep'), eval("rg --version | sed '1!d; s/ripgrep //; s/ .*//'"), emit: versions_ripgrep, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # get the EggNOG ID from the ID map
    zcat $eggnog_idmap | grep \$(cat $uniprot_id) | cut -f2 | cut -d',' -f1 > eggnog_id.txt || touch eggnog_id.txt

    # get the OMA IDs from the database
    zcat $db | grep \$(cat eggnog_id.txt) | cut -f 5 | tr ',' '\\n' | awk -F'.' '{ print \$2 }' > ${prefix}_eggnog_group_raw.txt || touch ${prefix}_eggnog_group_raw.txt

    # convert IDs to Uniprot
    uniprotize_oma_local.py --ids-path ${prefix}_eggnog_group_raw.txt --ensembl-idmap $ensembl_idmap --refseq-idmap $refseq_idmap > ${prefix}_eggnog_group.txt

    # create the other file
    touch ${prefix}_eggnog_group.txt

    # convert output to CSV
    csv_adorn.py --path ${prefix}_eggnog_group.txt --header EggNOG > ${prefix}_eggnog_group.csv
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_eggnog_group.txt
    touch ${prefix}_eggnog_group.csv
    """
}
