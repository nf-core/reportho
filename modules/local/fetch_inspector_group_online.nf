process FETCH_INSPECTOR_GROUP_ONLINE {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' :
        'biocontainers/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' }"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    val inspector_version

    output:
    tuple val(meta), path("*_inspector_group.csv") , emit: inspector_group
    path "versions.yml"                            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    uniprot_id=\$(cat $uniprot_id)
    fetch_inspector_group.py \$uniprot_id $inspector_version > ${prefix}_inspector_group.txt
    csv_adorn.py ${prefix}_inspector_group.txt OrthoInspector > ${prefix}_inspector_group.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
        OrthoInspector Database: $inspector_version
    END_VERSIONS
    """
}
