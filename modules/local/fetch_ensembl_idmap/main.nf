process FETCH_ENSEMBL_IDMAP {
    tag "idmap"
    label 'process_short'

    conda "conda-forge::python=3.12.9 conda-forge::requests=2.32.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/1c/1c915e07bc896c1ee384b521d49f45e1244c18299f88ad0b02fa8d221f0a7c7e/data' :
        'community.wave.seqera.io/library/python_requests:222028ddf1c9e3c2' }"

    output:
    path "ensembl_idmap.csv", emit: idmap
    path "versions.yml"     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    """
    fetch_ensembl_idmap.py > ensembl_idmap.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    """
    touch ensembl_idmap.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
