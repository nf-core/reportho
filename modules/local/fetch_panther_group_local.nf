process FETCH_PANTHER_GROUP_LOCAL {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.12.3 conda-forge::ripgrep=14.1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/python_ripgrep:6f07fd6cbda0142b' :
        'community.wave.seqera.io/library/python_ripgrep:324b372792aae9ce' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    path panther_db

    output:
    tuple val(meta), path("*_panther_group.csv"), emit: panther_group
    path "versions.yml"                         , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    id=\$(cat ${uniprot_id})
    touch ${prefix}_panther_group_raw.txt
    rg \$id $panther_db | tr '|' ' ' | tr '\\t' ' ' | cut -d' ' -f3,6 | awk -v id="\$id" -F'UniProtKB=' '{ for(i=0;i<=NF;i++) { if(\$i !~ id) s=s ? s OFS \$i : \$i } print s; s="" }' > ${prefix}_panther_group_raw.txt || test -f ${prefix}_panther_group_raw.txt
    csv_adorn.py ${prefix}_panther_group_raw.txt PANTHER > ${prefix}_panther_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        ripgrep: \$(rg --version | head -n1 | cut -d' ' -f2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_panther_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        ripgrep: \$(rg --version | head -n1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
