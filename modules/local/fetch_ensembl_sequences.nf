process FETCH_ENSEMBL_SEQUENCES {
    tag "${meta.id}"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' :
        'biocontainers/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' }"

    input:
    tuple val(meta), path(ids), path(query_fasta)
    path ensembl_idmap

    output:
    tuple val(meta), path("*_ensembl_sequences.fa")  , emit: fasta
    tuple val(meta), path("*_ensembl_seq_hits.txt")  , emit: hits
    tuple val(meta), path("*_ensembl_seq_misses.txt"), emit: misses
    path "versions.yml"                              , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    def add_query = query_fasta == [] ? "" : "cat $query_fasta >> ${prefix}_orthologs.fa"
    """
    fetch_ensembl_sequences.py $ids $ensembl_idmap $prefix > ${prefix}_ensembl_sequences.fa
    $add_query

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_ensembl_sequences.fa
    touch ${prefix}_ensembl_seq_hits.txt
    touch ${prefix}_ensembl_seq_misses.txt

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Python Requests: \$(pip show requests | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
