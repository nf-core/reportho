include { IDENTIFY_SEQ_ONLINE          } from "../../../modules/local/identify_seq_online/main"
include { WRITE_SEQINFO                } from "../../../modules/local/write_seqinfo/main"

include { FETCH_OMA_GROUP_ONLINE       } from "../../../modules/local/fetch_oma_group_online/main"
include { FETCH_PANTHER_GROUP_ONLINE   } from "../../../modules/local/fetch_panther_group_online/main"
include { FETCH_INSPECTOR_GROUP_ONLINE } from "../../../modules/local/fetch_inspector_group_online/main"

include { FETCH_OMA_GROUP_LOCAL        } from "../../../modules/local/fetch_oma_group_local/main"
include { FETCH_PANTHER_GROUP_LOCAL    } from "../../../modules/local/fetch_panther_group_local/main"
include { FETCH_EGGNOG_GROUP_LOCAL     } from "../../../modules/local/fetch_eggnog_group_local/main"

include { CSVTK_JOIN as MERGE_CSV      } from "../../../modules/nf-core/csvtk/join/main"

workflow GET_ORTHOLOGS {
    take:
    ch_samplesheet_query
    ch_samplesheet_fasta
    ch_oma_groups
    ch_oma_uniprot
    ch_oma_ensembl
    ch_oma_refseq
    ch_panther
    ch_eggnog
    ch_eggnog_idmap

    main:
    ch_orthogroups  = channel.empty()

    ch_samplesheet_fasta = ch_samplesheet_fasta.map { meta, fasta ->
        if (params.offline_run) {
            error "Tried to use FASTA input in an offline run. Aborting pipeline for user safety."
        }
        return [meta, fasta]
    }

    // Preprocessing - find the ID and taxid of the query sequences

    ch_fasta = ch_samplesheet_fasta
        .map { meta, fasta -> [meta, file(fasta)] }

    IDENTIFY_SEQ_ONLINE (
        ch_fasta
    )

    WRITE_SEQINFO (
        ch_samplesheet_query,
        params.offline_run
    )

    ch_query = IDENTIFY_SEQ_ONLINE.out.seqinfo.mix(WRITE_SEQINFO.out.seqinfo)

    // Ortholog fetching

    // OMA

    if (params.use_all || !params.skip_oma) {
        if (params.local_databases) {
            FETCH_OMA_GROUP_LOCAL (
                ch_query,
                ch_oma_groups,
                ch_oma_uniprot,
                ch_oma_ensembl,
                ch_oma_refseq
            )

            ch_orthogroups = ch_orthogroups
                .mix(FETCH_OMA_GROUP_LOCAL.out.oma_group)
        }
        else {
            FETCH_OMA_GROUP_ONLINE (
                ch_query
            )

            ch_orthogroups = ch_orthogroups
                .mix(FETCH_OMA_GROUP_ONLINE.out.oma_group)
        }
    }

    // PANTHER

    if (params.use_all || !params.skip_panther) {
        if (params.local_databases) {
            FETCH_PANTHER_GROUP_LOCAL (
                ch_query,
                ch_panther
            )

            ch_orthogroups = ch_orthogroups
                .mix(FETCH_PANTHER_GROUP_LOCAL.out.panther_group)
        } else {
            FETCH_PANTHER_GROUP_ONLINE (
                ch_query
            )

            ch_orthogroups = ch_orthogroups
                .mix(FETCH_PANTHER_GROUP_ONLINE.out.panther_group)
        }
    }

    // OrthoInspector

    if ((params.use_all || !params.skip_orthoinspector) && !params.local_databases) {
        FETCH_INSPECTOR_GROUP_ONLINE (
            ch_query,
            params.orthoinspector_version
        )

        ch_orthogroups = ch_orthogroups
            .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.inspector_group)
    }

    // EggNOG

    if (params.use_all || (!params.skip_eggnog && params.local_databases)) {
        FETCH_EGGNOG_GROUP_LOCAL (
            ch_query,
            ch_eggnog,
            ch_eggnog_idmap,
            ch_oma_ensembl,
            ch_oma_refseq
        )

        ch_orthogroups = ch_orthogroups
            .mix(FETCH_EGGNOG_GROUP_LOCAL.out.eggnog_group)
    }

    // Result merging

    MERGE_CSV (
        ch_orthogroups.groupTuple()
    )

    emit:
    seqinfo     = ch_query
    id          = ch_query.map { _meta, query_id, _taxid, _exact -> query_id }
    taxid       = ch_query.map { _meta, _query_id, query_taxid, _exact -> query_taxid }
    exact       = ch_query.map { _meta, _query_id, _taxid, is_exact -> is_exact }
    orthogroups = ch_orthogroups
    orthologs   = MERGE_CSV.out.csv
}
