process FETCH_PANTHER_GROUP_LOCAL {
    tag "$meta.id"
    label 'process_short'

    conda "conda-forge::python=3.12.3 conda-forge::ripgrep=14.1.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/python_ripgrep:6f07fd6cbda0142b' :
        'community.wave.seqera.io/library/python_ripgrep:324b372792aae9ce' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    path panther_db

    output:
    tuple val(meta), path("*_panther_group.csv"), emit: panther_group
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('ripgrep'), eval("rg --version | sed '1!d; s/ripgrep //; s/ .*//'"), emit: versions_ripgrep, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    # Get the Uniprot ID
    id=\$(cat ${uniprot_id})

    # Search the PANTHER database for the given Uniprot ID
    rg \$id $panther_db | tr '|' ' ' | tr '\\t' ' ' | cut -d' ' -f3,6 | awk -v id="\$id" -F'UniProtKB=' '{ for(i=0;i<=NF;i++) { if(\$i !~ id) s=s ? s OFS \$i : \$i } print s; s="" }' > ${prefix}_panther_group_raw.txt || touch ${prefix}_panther_group_raw.txt

    # Convert output to CSV
    csv_adorn.py --path ${prefix}_panther_group_raw.txt --header PANTHER > ${prefix}_panther_group.csv
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_panther_group.csv
    """
}
