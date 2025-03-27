process SPLIT_TAXIDS {
    tag "$input_file"
    label 'process_short'

    conda "conda-forge::python=3.12.0 conda-forge::biopython=1.84.0 conda-forge::requests=2.32.3"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-bc54124b36864a4af42a9db48b90a404b5869e7e:5258b8e5ba20587b7cbf3e942e973af5045a1e59-0' :
        'community.wave.seqera.io/library/python_requests_biopython:3c0f15f68130f062' }"

    input:
    tuple val(meta), path(input_file)

    output:
    tuple val(meta), path("*.fa"), emit: fastas
    path "versions.yml"          , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def prefix = task.ext.prefix ?: meta.id
    """
    awk -v RS=">" 'NR > 1 {
        split(\$1, header, "|")
        id = header[2]
        out_filename = "${prefix}_" id ".fa"
        print ">" \$0 >> out_filename
        close(out_filename)
    }' $input_file


    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        awk: \$(awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_0.fa

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        awk: \$(awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//')
    END_VERSIONS
    """
}
