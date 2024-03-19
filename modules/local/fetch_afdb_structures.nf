process FETCH_AFDB_STRUCTURES {
    tag "$meta.id"
    label "process_single"

    // add container here when available

    input:
    tuple val(meta), path(ids)

    output:
    tuple val(meta), path("*.pdb") , emit: pdb
    path "hits.txt"                , emit: hits
    path "misses.txt"              , emit: misses
    path "versions.yml"            , emit: versions

    script:
    """
    fetch_afdb_structures.py $ids

    cat <<- END_VERSIONS > versions.yml
    "${task.process}"
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
