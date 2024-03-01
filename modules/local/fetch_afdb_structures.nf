process FETCH_AFDB_STRUCTURES {
    tag "$meta.id"
    label "process_single"

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' :
        'biocontainers/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' }"

    input:
    tuple val(meta), path(ids)

    output:
    tuple val(meta), path("*.pdb") , emit: pdb
    path "hits.txt"                , emit: hits
    path "misses.txt"              , emit: misses
    path "af_versions.txt"         , emit: af_versions
    path "versions.yml"            , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    fetch_afdb_structures.py $ids 2> af_versions.txt

    cat <<- END_VERSIONS > versions.yml
    "${task.process}"
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
