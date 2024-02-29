include { TCOFFEE_ALIGN } from '../modules/nf-core/tcoffee/align/main'
include { TCOFFEE_ALIGN as TCOFFEE_3DALIGN } from '../modules/nf-core/tcoffee/align/main'

workflow ALIGN {
    take:
    ch_fasta
    ch_pdb

    main:

    ch_versions = Channel.empty()

    if (params.use_structures) {
        // add 3D alignment later
        ch_alignment = Channel.from([[:], []])
    }
    else {
        TCOFFEE_ALIGN (
            ch_fasta,
            [[:], []],
            [[:], [], []]
        )

        TCOFFEE_ALIGN.out.alignment
            .set(ch_alignment)

        ch_versions
            .mix(TCOFFEE_ALIGN.out.versions)
            .set(ch_versions)
    }

    emit:
    alignment = ch_alignment
    versions  = ch_versions

}
