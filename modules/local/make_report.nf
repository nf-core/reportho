process MAKE_REPORT {
    tag "$meta.id"
    label "process_single"

    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'docker://itrujnara/orthologs-report:1.0.0' :
        'itrujnara/orthologs-report:1.0.0' }"


    input:
    tuple val(meta), path(id), path(taxid), path(exact), path(score_table), path(filtered_hits), path(support_plot), path(venn_plot), path(jaccard_plot), path(params_file)

    output:
    tuple val(meta), path("*dist/*"), emit: report_files

    when:
    task.ext.when == null || task.ext.when

    script:
    prefix        = task.ext.prefix ?: meta.id
    """
    cp -r /app/* .
    cd public
    ls | grep -v logo | xargs rm # this is a hack, fix later
    cd ..
    cp $id public/id.txt
    cp $taxid public/taxid.txt
    cp $score_table public/score_table.csv
    cp $filtered_hits public/filtered_hits.txt
    cp $support_plot public/supports.png
    cp $venn_plot public/venn.png
    cp $jaccard_plot public/jaccard.png
    cp $params_file public/params.yml
    yarn run build
    echo "python3 -m http.server 0" > dist/${prefix}_run.sh
    mv dist ${prefix}_dist
    """
}
