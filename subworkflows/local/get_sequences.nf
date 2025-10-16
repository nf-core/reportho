include { SPLIT_ID_FORMAT          } from '../../modules/local/split_id_format.nf'
include { FETCH_UNIPROT_SEQUENCES  } from '../../modules/local/fetch_uniprot_sequences.nf'
include { FETCH_ENSEMBL_IDMAP      } from '../../modules/local/fetch_ensembl_idmap.nf'
include { FETCH_ENSEMBL_SEQUENCES  } from '../../modules/local/fetch_ensembl_sequences.nf'
include { FETCH_REFSEQ_SEQUENCES   } from '../../modules/local/fetch_refseq_sequences.nf'
include { FETCH_OMA_SEQUENCES      } from '../../modules/local/fetch_oma_sequences.nf'
include { CAT_CAT as CONCAT_FASTA  } from '../../modules/nf-core/cat/cat/main.nf'
include { CAT_CAT as CONCAT_HITS   } from '../../modules/nf-core/cat/cat/main.nf'
include { CAT_CAT as CONCAT_MISSES } from '../../modules/nf-core/cat/cat/main.nf'

workflow GET_SEQUENCES {
    take:
    ch_ids
    ch_query_fasta

    main:
    ch_versions = Channel.empty()

    SPLIT_ID_FORMAT(ch_ids)
    ch_versions = ch_versions.mix(SPLIT_ID_FORMAT.out.versions)

    ch_id_files = SPLIT_ID_FORMAT.out.ids_split.transpose().branch {
        it ->
            uniprot: it[1] =~ /uniprot/
            ensembl: it[1] =~ /ensembl/
            refseq: it[1] =~ /refseq/
            oma: it[1] =~ /oma/
            unknown: it[1] =~ /unknown/
    }

    ch_fasta  = Channel.empty()
    ch_hits   = Channel.empty()
    ch_misses = Channel.empty()

    FETCH_UNIPROT_SEQUENCES(ch_id_files.uniprot.join(ch_query_fasta))
    ch_fasta    = ch_fasta.mix(FETCH_UNIPROT_SEQUENCES.out.fasta)
    ch_hits     = ch_hits.mix(FETCH_UNIPROT_SEQUENCES.out.hits)
    ch_misses   = ch_misses.mix(FETCH_UNIPROT_SEQUENCES.out.misses)
    ch_versions = ch_versions.mix(FETCH_UNIPROT_SEQUENCES.out.versions)

    FETCH_ENSEMBL_IDMAP()
    ch_versions = ch_versions.mix(FETCH_ENSEMBL_IDMAP.out.versions)

    FETCH_ENSEMBL_SEQUENCES(
        ch_id_files.ensembl.join(ch_query_fasta),
        FETCH_ENSEMBL_IDMAP.out.idmap
    )
    ch_fasta    = ch_fasta.mix(FETCH_ENSEMBL_SEQUENCES.out.fasta)
    ch_hits     = ch_hits.mix(FETCH_ENSEMBL_SEQUENCES.out.hits)
    ch_misses   = ch_misses.mix(FETCH_ENSEMBL_SEQUENCES.out.misses)
    ch_versions = ch_versions.mix(FETCH_ENSEMBL_SEQUENCES.out.versions)

    FETCH_REFSEQ_SEQUENCES(ch_id_files.refseq.join(ch_query_fasta))
    ch_fasta    = ch_fasta.mix(FETCH_REFSEQ_SEQUENCES.out.fasta)
    ch_hits     = ch_hits.mix(FETCH_REFSEQ_SEQUENCES.out.hits)
    ch_misses   = ch_misses.mix(FETCH_REFSEQ_SEQUENCES.out.misses)
    ch_versions = ch_versions.mix(FETCH_REFSEQ_SEQUENCES.out.versions)

    FETCH_OMA_SEQUENCES(ch_id_files.oma.join(ch_query_fasta))
    ch_fasta    = ch_fasta.mix(FETCH_OMA_SEQUENCES.out.fasta)
    ch_hits     = ch_hits.mix(FETCH_OMA_SEQUENCES.out.hits)
    ch_misses   = ch_misses.mix(FETCH_OMA_SEQUENCES.out.misses)
    ch_versions = ch_versions.mix(FETCH_OMA_SEQUENCES.out.versions)

    ch_fasta_grouped  = ch_fasta.groupTuple()
    ch_hits_grouped   = ch_hits.groupTuple()
    ch_misses_grouped = ch_misses.groupTuple()

    CONCAT_FASTA(ch_fasta_grouped)
    ch_versions.mix(CONCAT_FASTA.out.versions)

    CONCAT_HITS(ch_hits_grouped)
    ch_versions.mix(CONCAT_HITS.out.versions)

    ch_misses_mixed = ch_misses_grouped.join(ch_id_files.unknown).map {
        meta, misses, unknown -> [meta, misses + [unknown]]
    }
    CONCAT_MISSES(ch_misses_mixed)
    ch_versions.mix(CONCAT_MISSES.out.versions)

    emit:
    fasta    = CONCAT_FASTA.out.file_out
    hits     = CONCAT_HITS.out.file_out
    misses   = CONCAT_MISSES.out.file_out
    versions = ch_versions
}
