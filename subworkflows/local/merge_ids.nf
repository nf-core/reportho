include { SPLIT_TAXIDS                } from "../../modules/local/split_taxids.nf"
include { GAWK as MERGE_FASTA_IDS     } from '../../modules/nf-core/gawk/main.nf'
include { DIAMOND_CLUSTER             } from '../../modules/nf-core/diamond/cluster/main.nf'
include { GAWK as POSTPROCESS_DIAMOND } from '../../modules/nf-core/gawk/main.nf'
include { GAWK as GROUP_DIAMOND       } from '../../modules/nf-core/gawk/main.nf'
include { CAT_CAT as MERGE_DIAMOND    } from '../../modules/nf-core/cat/cat/main.nf'
include { CAT_CAT as MERGE_ALL        } from '../../modules/nf-core/cat/cat/main.nf'
include { GAWK as REDUCE_IDMAP        } from '../../modules/nf-core/gawk/main.nf'

workflow MERGE_IDS {
    take:
    ch_fasta_all

    main:
    ch_versions = Channel.empty()
    ch_id_clusters = Channel.empty()

    // Split fasta by taxid
    SPLIT_TAXIDS (
        ch_fasta_all
    )

    ch_versions = ch_versions.mix(SPLIT_TAXIDS.out.versions)

    // Branch by number of entries
    SPLIT_TAXIDS.out.fastas
        .transpose()
        .map {
            meta, file -> [ meta, file, (file.text =~ />(.*)/).results().count() ]
        }
        .branch {
            single_entry: it[2] == 1
            multiple_entries: it[2] > 1
        }
        .set { ch_fasta_counts }

    // Merge IDs from single-entry fastas
    MERGE_FASTA_IDS(
        ch_fasta_counts.single_entry
            .map { meta, file, count -> [ meta, file ] }
            .groupTuple(),
        []
    )

    ch_versions = ch_versions.mix(MERGE_FASTA_IDS.out.versions)

    // Merge IDs from multi-entry fastas
    DIAMOND_CLUSTER (
        ch_fasta_counts.multiple_entries
            .map { meta, file, count -> [ meta, file ] }
    )

    ch_versions = ch_versions.mix(DIAMOND_CLUSTER.out.versions)

    MERGE_DIAMOND (
        DIAMOND_CLUSTER.out.tsv.groupTuple()
    )

    ch_versions = ch_versions.mix(MERGE_DIAMOND.out.versions)

    POSTPROCESS_DIAMOND (
        MERGE_DIAMOND.out.file_out,
        []
    )

    ch_versions = ch_versions.mix(POSTPROCESS_DIAMOND.out.versions)

    GROUP_DIAMOND (
        POSTPROCESS_DIAMOND.out.output,
        []
    )

    ch_versions = ch_versions.mix(GROUP_DIAMOND.out.versions)

    MERGE_ALL (
        MERGE_FASTA_IDS.out.output
            .join(GROUP_DIAMOND.out.output)
            .map { meta, ids1, ids2 -> [ meta, [ids1, ids2] ] }
    )

    ch_versions = ch_versions.mix(MERGE_ALL.out.versions)

    ch_id_clusters = ch_id_clusters.mix(MERGE_ALL.out.file_out)

    // Reduce idmap
    REDUCE_IDMAP (
        MERGE_ALL.out.file_out,
        []
    )

    ch_versions = ch_versions.mix(REDUCE_IDMAP.out.versions)

    ch_id_map = REDUCE_IDMAP.out.output

    emit:
    id_clusters = ch_id_clusters
    id_map      = ch_id_map
    versions    = ch_versions
}
