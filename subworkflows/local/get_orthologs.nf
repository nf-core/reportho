include { IDENTIFY_SEQ_ONLINE          } from "../../modules/local/identify_seq_online"
include { WRITE_SEQINFO                } from "../../modules/local/write_seqinfo"
include { FETCH_OMA_GROUP_ONLINE       } from "../../modules/local/fetch_oma_group_online"
include { FETCH_PANTHER_GROUP_ONLINE   } from "../../modules/local/fetch_panther_group_online"
include { FETCH_INSPECTOR_GROUP_ONLINE } from "../../modules/local/fetch_inspector_group_online"
include { MAKE_SCORE_TABLE             } from "../../modules/local/make_score_table"

workflow GET_ORTHOLOGS {
    take:
    ch_samplesheet

    main:

    ch_samplesheet.view()

    if (!params.uniprot_query) {
        ch_samplesheet
            .map { it -> [it[0], file(it[1])] }
            .set { ch_inputfile }


        IDENTIFY_SEQ_ONLINE (
            ch_inputfile
        )

        IDENTIFY_SEQ_ONLINE.out
            .set { ch_query }
    } else {
        WRITE_SEQINFO (
            ch_samplesheet
        )

        WRITE_SEQINFO.out.view()

        // WRITE_SEQINFO.out
        //     .set { ch_query }
    }

    // FETCH_OMA_GROUP_ONLINE (
    //     ch_query
    // )

    // FETCH_OMA_GROUP_ONLINE.out.view()

    // FETCH_PANTHER_GROUP_ONLINE (
    //     ch_query
    // )

    // FETCH_PANTHER_GROUP_ONLINE.out.view()

    // FETCH_INSPECTOR_GROUP_ONLINE (
    //     ch_query
    // )

    // FETCH_INSPECTOR_GROUP_ONLINE.out.view()

    // MAKE_SCORE_TABLE (
    //     FETCH_OMA_GROUP_ONLINE.out.map { it[0] },
    //     FETCH_OMA_GROUP_ONLINE.out.map { it[1] },
    //     FETCH_PANTHER_GROUP_ONLINE.out.map { it[1] },
    //     FETCH_INSPECTOR_GROUP_ONLINE.out.map { it[1] }
    // )

    // MAKE_SCORE_TABLE.out.view()
}
