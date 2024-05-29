process FETCH_OMA_GROUP_LOCAL {
    tag "$meta.id"
    label 'process_single'

    conda "conda-forge::python=3.12.3 conda-forge::ripgrep=14.1.0"
    container "community.wave.seqera.io/library/python_ripgrep:324b372792aae9ce"

    input:
    tuple val(meta), path(uniprot_id), path(taxid), path(exact)
    path db
    path uniprot_idmap
    path ensembl_idmap
    path refseq_idmap

    output:
    tuple val(meta), path("*_oma_group.csv"), emit: oma_group
    path "versions.yml"                     , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    # Obtain the OMA ID for the given Uniprot ID of the query protein
    omaid=\$(uniprot2oma_local.py $uniprot_idmap $uniprot_id)

    # Perform the database search for the given query in OMA
    touch ${prefix}_oma_group_oma.txt
    zcat $db | rg \$omaid | head -1 | cut -f3- | awk '{gsub(/\\t/,"\\n"); print}' > ${prefix}_oma_group_oma.txt || test -f ${prefix}_oma_group_oma.txt

    # Convert the OMA ids to Uniprot, Ensembl and RefSeq ids
    oma2uniprot_local.py $uniprot_idmap ${prefix}_oma_group_oma.txt > ${prefix}_oma_group_raw.txt
    uniprotize_oma_local.py ${prefix}_oma_group_raw.txt $ensembl_idmap $refseq_idmap > ${prefix}_oma_group.txt

    # Add the OMA column to the csv file
    csv_adorn.py ${prefix}_oma_group.txt OMA > ${prefix}_oma_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
        ripgrep: \$(rg --version | head -n1 | cut -d' ' -f2)
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_oma_group.csv

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Python: \$(python --version | cut -f2)
        ripgrep: \$(rg --version | head -n1 | cut -d' ' -f2)
    END_VERSIONS
    """
}
