process MAKE_REPORT {
    tag "$meta.id"
    label 'process_single'

    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error("Local MAKE_REPORT module does not support Conda. Please use Docker / Singularity / Podman instead.")
    }

    container "nf-core/reportho-orthologs-report:1.0.0"

    input:
    tuple val(meta), path(id), path(taxid), path(exact), path(score_table), path(filtered_hits), path(support_plot), path(venn_plot), path(jaccard_plot), path(orthostats), path(seq_hits), path(seq_misses), path(str_hits), path(str_misses), path(alignment), path(iqtree), path(fastme), path(params_file)

    output:
    tuple val(meta), path("*dist/*"), emit: report_files
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    seqhits_cmd = seq_hits ? "cp $seq_hits public/seq_hits.txt" : ''
    seqmisses_cmd = seq_misses ? "cp $seq_misses public/seq_misses.txt" : ''
    strhits_cmd = str_hits ? "cp $str_hits public/str_hits.txt" : ''
    strmisses_cmd = str_misses ? "cp $str_misses public/str_misses.txt" : ''
    aln_cmd = alignment ? "cp $alignment public/alignment.fa" : ''
    iqtree_cmd = iqtree ? "cp $iqtree public/iqtree.png" : ''
    fastme_cmd = fastme ? "cp $fastme public/fastme.png" : ''
    """
    # copy project files
    cp -r /app/* .
    cd public
    ls | grep -v logo | xargs rm # this is a hack, fix later

    # copy input files
    cd ..
    cp $id public/id.txt
    cp $taxid public/taxid.txt
    cp $score_table public/score_table.csv
    cp $filtered_hits public/filtered_hits.txt
    cp $support_plot public/supports.png
    cp $venn_plot public/venn.png
    cp $jaccard_plot public/jaccard.png
    cp $orthostats public/orthostats.yml
    cp $params_file public/params.yml
    $seqhits_cmd
    $seqmisses_cmd
    $strhits_cmd
    $strmisses_cmd
    $aln_cmd
    $iqtree_cmd
    $fastme_cmd

    # build the report
    yarn run build

    # create the run script
    echo "python3 -m http.server 0" > dist/run.sh
    chmod u+x dist/run.sh

    # add prefix to directory name
    mv dist ${prefix}_dist

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Node: \$(node --version)
        Yarn: \$(yarn --version)
        React: \$(yarn info react version | awk 'NR==2{print;exit}')
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    mkdir ${prefix}_dist
    touch ${prefix}_dist/${prefix}_run.sh

    cat <<- END_VERSIONS > versions.yml
    ${task.process}:
        Node: \$(node --version)
        Yarn: \$(yarn --version)
        React: \$(yarn info react version | awk 'NR==2{print;exit}')
    END_VERSIONS
    """
}
