process MAKE_SCORE_TABLE {
    input:
    val meta
    path oma_group
    path panther_group
    path inspector_group

    output:
    tuple val(meta), path('score_table.csv')

    script:
    """
    make_score_table.py $oma_group $panther_group $inspector_group > score_table.csv
    """
}
