include { TCOFFEE_ALIGN                    } from '../../modules/nf-core/tcoffee/align/main'
include { TCOFFEE_ALIGN as TCOFFEE_3DALIGN } from '../../modules/nf-core/tcoffee/align/main'
include { FILTER_FASTA                     } from '../../modules/local/filter_fasta'
include { CREATE_TCOFFEETEMPLATE           } from '../../modules/local/create_tcoffeetemplate'


workflow ALIGN {
    take:
    ch_fasta
    ch_pdb

    main:

    ch_versions  = Channel.empty()
    ch_alignment = Channel.empty()

    if (params.use_structures) {
        ch_for_filter = ch_fasta.map{ meta, fasta -> [meta.id, meta, fasta] }
            .combine(ch_pdb.map{ meta, pdb -> [meta.id, pdb] }, by: 0)
            .map {
                id, meta, fasta, pdb -> [meta, fasta, pdb]
            }

        FILTER_FASTA(
            ch_for_filter
        )

        ch_versions = ch_versions.mix(FILTER_FASTA.out.versions)

        CREATE_TCOFFEETEMPLATE(
            ch_pdb
        )

        ch_3dcoffee = FILTER_FASTA.out.fasta.map{ meta, fasta -> [meta.id, meta, fasta] }
            .combine(CREATE_TCOFFEETEMPLATE.out.template.map{ meta, template -> [meta.id, template] }, by: 0)
            .combine(ch_pdb.map{ meta, pdb -> [meta.id, pdb] }, by: 0)
            .multiMap {
                id, meta, fasta, template, pdb ->
                    fasta: [meta, fasta]
                    pdb:   [meta, template, pdb]
            }

        TCOFFEE_3DALIGN (
            ch_3dcoffee.fasta,
            [[:], []],
            ch_3dcoffee.pdb,
            false
        )

        TCOFFEE_3DALIGN.out.alignment
            .set { ch_alignment }

        ch_versions = ch_versions.mix(TCOFFEE_3DALIGN.out.versions)

    }
    else {
        TCOFFEE_ALIGN (
            ch_fasta,
            [[:], []],
            [[:], [], []],
            false
        )

        TCOFFEE_ALIGN.out.alignment
            .set { ch_alignment }

        ch_versions = ch_versions.mix(TCOFFEE_ALIGN.out.versions)
    }

    emit:
    alignment = ch_alignment
    versions  = ch_versions

}
