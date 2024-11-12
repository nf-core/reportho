include { SPLIT_TAXIDS } from "../../modules/local/split_taxids.nf"

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
        .tap { ch_with_count }
        .branch {
            single_entry: it[2] == 1
            multiple_entries: it[2] > 1
        }
        .map { meta, file, count -> [ meta, file ] }
        .set { ch_fasta_counts }

    ch_fasta_counts.multiple_entries.view()

    // Merge IDs from single-entry fastas


    emit:
    ch_id_clusters
}
