process FETCH_OMA_GROUP_LOCAL {
    tag "$meta.id"
    label "process_short"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    path db
    path uniprot_idmap
    path ensembl_idmap
    path refseq_idmap

    output:
    tuple val(meta), path("*_oma_group.csv") , emit: oma_group
    path "versions.yml"                      , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    omaid=\$(uniprot2oma_local.py $uniprot_idmap $uniprot_id)
    omagroup=\$(zcat $db | grep \$omaid | head -1 | cut -f3-)
    oma2uniprot_local.py $uniprot_idmap \$omagroup > ${prefix}_oma_group_raw.txt
    uniprotize_oma_local.py ${prefix}_oma_group_raw.txt $ensembl_idmap $refseq_idmap > ${prefix}_oma_group.txt
    csv_adorn.py ${prefix}_oma_group.txt OMA > ${prefix}_oma_group.csv

    cat <<- END_VERSIONS > versions.yml
    ${task.process}:
        Python: \$(python --version | cut -f2)
    END_VERSIONS
    """

}
