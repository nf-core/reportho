process FETCH_EGGNOG_GROUP_LOCAL {
    tag "$meta.id"
    label "process_short"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    path db
    path idmap

    output:
    tuple val(meta), path("*_eggnog_group.csv"), emit: eggnog_group
    path "versions.yml"                        , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    uniprotid=\$(zcat $idmap | grep \$(cat $uniprot_id) | cut -f2)
    zcat $db | grep \$uniprotid | cut -f 5 | tr ',' '\n' | awk -F'.' '{ print \$2 }' > ${prefix}_eggnog_group_raw.txt
    uniprotize_oma_online.py ${prefix}_eggnog_group_raw.txt > ${prefix}_eggnog_group.txt
    csv_adorn.py ${prefix}_eggnog_group.txt EggNOG > ${prefix}_eggnog_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
    END_VERSIONS
    """

}
