process FETCH_UNIPROT_SEQUENCES {
    tag "${meta.id}"
    label 'process_short'

    conda "conda-forge::python=3.11.0 conda-forge::biopython=1.83.0 conda-forge::requests=2.31.0"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://community-cr-prod.seqera.io/docker/registry/v2/blobs/sha256/6b/6b2900901bc81cfb5d255a250ee196f4e2f8707ba6de704178eb40151fd849f8/data' :
        'community.wave.seqera.io/library/biopython_python_requests:ba620bb488048968' }"

    input:
    tuple val(meta), path(ids), path(query_fasta)

    output:
    tuple val(meta), path("*_uniprot_sequences.fa")  , emit: fasta
    tuple val(meta), path("*_uniprot_seq_hits.txt")  , emit: hits
    tuple val(meta), path("*_uniprot_seq_misses.txt"), emit: misses
    tuple val("${task.process}"), val('python'), eval("python --version | sed 's/Python //'"), emit: versions_python, topic: versions
    tuple val("${task.process}"), val('biopython'), eval("python -c \"import Bio; print(Bio.__version__)\" | sed 's/^//'"), emit: versions_biopython, topic: versions
    tuple val("${task.process}"), val('requests'), eval("pip show requests | sed -n 's/^Version: //p'"), emit: versions_requests, topic: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix    = task.ext.prefix ?: meta.id
    def add_query = query_fasta == [] ? "" : "cat $query_fasta >> ${prefix}_orthologs.fa"
    """
    fetch_uniprot_sequences.py --ids-path $ids --prefix $prefix > ${prefix}_uniprot_sequences.fa
    $add_query
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_uniprot_sequences.fa
    touch ${prefix}_uniprot_seq_hits.txt
    touch ${prefix}_uniprot_seq_misses.txt
    """
}
