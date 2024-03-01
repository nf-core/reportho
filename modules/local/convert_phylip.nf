process CONVERT_PHYLIP {
    input:
    path input_file

    output:
    path "orthologs.phy", emit: phylip
    path "versions.yml", emit: versions

    script:
    """
    clustal2phylip.py $input_file orthologs.phy

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -d ' ' -f 2)
        Biopython: \$(pip show biopython | grep Version | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
