process MAKE_REPORT {
    tag "$meta.id"
    label 'process_short'

    container "nf-core/orthologs-report:1.1.0"

    input:
    tuple val(meta), path(id), path(taxid), path(exact), path(score_table), path(filtered_hits), path(support_plot), path(venn_plot), path(jaccard_plot), path(orthostats), path(seq_hits), path(seq_misses), path(merge_stats), path(clusters), path(params_file)

    output:
    tuple val(meta), path("${prefix}/*"), emit: report_files
    path "versions.yml"                 , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    // Exit if running this module with -profile conda / -profile mamba
    if (workflow.profile.tokenize(',').intersect(['conda', 'mamba']).size() >= 1) {
        error("Local MAKE_REPORT module does not support Conda. Please use Docker / Singularity / Podman instead.")
    }

    prefix         = task.ext.prefix ?: meta.id
    seqhits_cmd    = seq_hits ? "cp $seq_hits public/seq_hits.txt" : ''
    seqmisses_cmd  = seq_misses ? "cp $seq_misses public/seq_misses.txt" : ''
    mergestats_cmd = merge_stats ? "cp $merge_stats public/merge_stats.csv" : ''
    clusters_cmd   = clusters ? "cp $clusters public/clusters.csv" : ''
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
    $mergestats_cmd
    $clusters_cmd
    $seqhits_cmd
    $seqmisses_cmd

    # build the report
    yarn run build

    # create the run script
    echo "python3 -m http.server 0" > dist/run.sh
    chmod u+x dist/run.sh

    # change output directory name
    mv dist ${prefix}

    cat <<- END_VERSIONS > versions.yml
    "${task.process}":
        Node: \$(node --version)
        Yarn: \$(yarn --version)
        React: \$(yarn info react version | awk 'NR==2{print;exit}')
    END_VERSIONS
    """

    stub:
    """
    mkdir ${prefix}
    touch ${prefix}/run.sh

    cat <<- END_VERSIONS > versions.yml
    ${task.process}:
        Node: \$(node --version)
        Yarn: \$(yarn --version)
        React: \$(yarn info react version | awk 'NR==2{print;exit}')
    END_VERSIONS
    """
}
