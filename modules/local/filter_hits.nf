process FILTER_HITS {
    input:
    tuple val(meta), path(score_table)
    val strategy

    output:
    tuple val(meta), path('filtered_hits.txt')

    script:
    """
    filter_hits.py $score_table $strategy > filtered_hits.txt 2> python.err
    """
}
