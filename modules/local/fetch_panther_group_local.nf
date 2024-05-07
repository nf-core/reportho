process FETCH_PANTHER_GROUP_LOCAL {
    tag "$meta.id"
    label "process_short"

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' :
        'biocontainers/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' }"

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
    grep \$id AllOrthologs.txt | tr '|' ' ' | tr '\t' ' ' | cut -d' ' -f3,6 | awk -v id="\$id" -F'UniProtKB=' '{ for(i=0;i<=NF;i++) { if(\$i !~ id) s=s ? s OFS \$i : \$i } print s; s="" }' > ${prefix}_panther_group_raw.txt
    csv_adorn.py ${prefix}_panther_group_raw.txt PANTHER > ${prefix}_panther_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_panther_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
    END_VERSIONS
    """
}
