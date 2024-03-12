process MAKE_REPORT {
    tag "$meta.id"
    label "process_single"

    input:
    tuple val(meta), path(id), path(taxid), path(oma_group), path(panther_group), path(inspector_group), path(score_table), path(filtered_hits), path(support_plot), path(venn_plot), path(jaccard_plot), path(seq_hits), path(seq_misses), path(str_hits), path(str_misses), path(alignment), path(ml_tree), path(me_tree), path(params_file)

    output:
    tuple val(meta), path("dist/*") , emit: report_files
    path("*_run.sh")                , emit: run_script

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    cp_str_hits = params.use_structures ? "cp $str_hits > public/str_hits.txt" : ""
    cp_str_misses = params.use_structures ? "cp $str_misses > public/str_misses.txt" : ""
    cp_ml_tree = params.use_iqtree ? "cp $ml_tree > public/ml_tree.png" : ""
    cp_me_tree = params.use_fastme ? "cp $me_tree > public/me_tree.png" : ""
    """
    cp $id > public/id.txt
    cp $taxid > public/taxid.txt
    cp $oma_group > public/oma_group.txt
    cp $panther_group > public/panther_group.txt
    cp $inspector_group > public/inspector_group.txt
    cp $score_table > public/score_table.txt
    cp $filtered_hits > public/filtered_hits.txt
    cp $support_plot > public/support_plot.png
    cp $venn_plot > public/venn_plot.png
    cp $jaccard_plot > public/jaccard_plot.png
    cp $seq_hits > public/seq_hits.txt
    cp $seq_misses > public/seq_misses.txt
    $cp_str_hits
    $cp_str_misses
    cp $alignment > public/alignment.fa
    $cp_ml_tree
    $cp_me_tree
    cp $params_file > public/params.yml
    yarn run build
    echo "python3 -m http.server 0" > ${prefix}_run.sh
    """
}
