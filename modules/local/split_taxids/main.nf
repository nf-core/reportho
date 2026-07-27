process SPLIT_TAXIDS {
    tag "$input_file"
    label 'process_short'

    conda "conda-forge::gawk=5.3.1"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/gawk:5.3.1' :
        'biocontainers/gawk:5.3.1' }"

    input:
    tuple val(meta), path(input_file)

    output:
    tuple val(meta), path("*.fa"), emit: fastas
    tuple val("${task.process}"), val('gawk'), eval("awk -Wversion | sed '1!d; s/.*Awk //; s/,.*//'"), topic: versions, emit: versions_gawk

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

    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_0.fa
    """
}
