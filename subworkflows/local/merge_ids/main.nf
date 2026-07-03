include { SPLIT_TAXIDS                      } from "../../../modules/local/split_taxids"
include { GAWK as MERGE_FASTA_IDS           } from '../../../modules/nf-core/gawk/main.nf'
include { DIAMOND_CLUSTER                   } from '../../../modules/nf-core/diamond/cluster/main.nf'
include { GAWK as POSTPROCESS_DIAMOND       } from '../../../modules/nf-core/gawk/main.nf'
include { GAWK as GROUP_DIAMOND             } from '../../../modules/nf-core/gawk/main.nf'
include { FIND_CONCATENATE as MERGE_DIAMOND } from '../../../modules/nf-core/find/concatenate/main.nf'
include { FIND_CONCATENATE as MERGE_ALL     } from '../../../modules/nf-core/find/concatenate/main.nf'
include { GAWK as REDUCE_IDMAP              } from '../../../modules/nf-core/gawk/main.nf'

workflow MERGE_IDS {
    take:
    ch_fasta_all

    main:
    ch_id_clusters = channel.empty()

    // Split fasta by taxid
    SPLIT_TAXIDS (
        ch_fasta_all
    )

    // Branch by number of entries
    SPLIT_TAXIDS.out.fastas
        .transpose()
        .map {
            meta, file -> [ meta, file, (file.text =~ />(.*)/).results().count() ]
        }
        .branch { row ->
            single_entry: row[2] == 1
            multiple_entries: row[2] > 1
        }
        .set { ch_fasta_counts }

    // Merge IDs from single-entry fastas
    MERGE_FASTA_IDS(
        ch_fasta_counts.single_entry
            .map { meta, file, count -> [ meta, file ] }
            .groupTuple(),
        [],
        false
    )

    // Merge IDs from multi-entry fastas
    DIAMOND_CLUSTER (
        ch_fasta_counts.multiple_entries
            .map { meta, file, count -> [ meta, file ] }
    )

    MERGE_DIAMOND (
        DIAMOND_CLUSTER.out.tsv.groupTuple()
    )

    POSTPROCESS_DIAMOND (
        MERGE_DIAMOND.out.file_out,
        [],
        false
    )

    GROUP_DIAMOND (
        POSTPROCESS_DIAMOND.out.output,
        [],
        false
    )

    MERGE_ALL (
        MERGE_FASTA_IDS.out.output
            .join(GROUP_DIAMOND.out.output)
            .map { meta, ids1, ids2 -> [ meta, [ids1, ids2] ] }
    )

    ch_id_clusters = ch_id_clusters.mix(MERGE_ALL.out.file_out)

    // Reduce idmap
    REDUCE_IDMAP (
        MERGE_ALL.out.file_out,
        [],
        false
    )

    ch_id_map = REDUCE_IDMAP.out.output

    emit:
    id_clusters = ch_id_clusters
    id_map      = ch_id_map
}
