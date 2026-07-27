include { IDENTIFY_SEQ_ONLINE          } from "../../../modules/local/identify_seq_online/main.nf"
include { WRITE_SEQINFO                } from "../../../modules/local/write_seqinfo/main.nf"

include { FETCH_OMA_GROUP_ONLINE       } from "../../../modules/local/fetch_oma_group_online/main.nf"
include { FETCH_PANTHER_GROUP_ONLINE   } from "../../../modules/local/fetch_panther_group_online/main.nf"
include { FETCH_INSPECTOR_GROUP_ONLINE } from "../../../modules/local/fetch_inspector_group_online/main.nf"

include { FETCH_OMA_GROUP_LOCAL        } from "../../../modules/local/fetch_oma_group_local/main.nf"
include { FETCH_PANTHER_GROUP_LOCAL    } from "../../../modules/local/fetch_panther_group_local/main.nf"
include { FETCH_EGGNOG_GROUP_LOCAL     } from "../../../modules/local/fetch_eggnog_group_local/main.nf"

include { CSVTK_JOIN as MERGE_CSV      } from "../../../modules/nf-core/csvtk/join/main.nf"

workflow GET_ORTHOLOGS {
    take:
    ch_samplesheet_query
    ch_samplesheet_fasta
    offline_run
    use_all
    skip_oma
    local_databases
    ch_oma_groups
    ch_oma_uniprot
    ch_oma_ensembl
    ch_oma_refseq
    skip_panther
    ch_panther
    skip_orthoinspector
    orthoinspector_version
    skip_eggnog
    ch_eggnog
    ch_eggnog_idmap

    main:
    ch_orthogroups  = channel.empty()

    ch_samplesheet_fasta = ch_samplesheet_fasta.map { meta, fasta ->
        if (offline_run) {
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
        offline_run
    )

    ch_query = IDENTIFY_SEQ_ONLINE.out.seqinfo.mix(WRITE_SEQINFO.out.seqinfo)

    // Ortholog fetching

    // OMA

    if (use_all || !skip_oma) {
        if (local_databases) {
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

    if (use_all || !skip_panther) {
        if (local_databases) {
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

    if ((use_all || !skip_orthoinspector) && !local_databases) {
        FETCH_INSPECTOR_GROUP_ONLINE (
            ch_query,
            orthoinspector_version
        )

        ch_orthogroups = ch_orthogroups
            .mix(FETCH_INSPECTOR_GROUP_ONLINE.out.inspector_group)
    }

    // EggNOG

    if (use_all || (!skip_eggnog && local_databases)) {
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
