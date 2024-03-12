process MAKE_REPORT {
    tag "$meta.id"
    label "process_single"

    input:
    tuple val(meta), path(id), path(taxid), path(oma_group), path(panther_group), path(inspector_group), path(score_table), path(filtered_hits), path(support_plot), path(venn_plot), path(jaccard_plot), path(seq_hits), path(seq_misses), path(str_hits), path(str_misses), path(alignment), path(ml_tree), path(me_tree), path(params_file)

    output:
    tuple val(meta), path("dist/*"), emit: report_files
    path("*_run.sh"), emit: run_script

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix = task.ext.prefix ?: meta.id
    """
    yarn run build
    echo "python3 -m http.server 0" > ${prefix}_run.sh
    """
}
