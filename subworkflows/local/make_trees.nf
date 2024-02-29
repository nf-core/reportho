include { IQTREE } from "../../modules/nf-core/iqtree/main"
include { FASTME } from "../../modules/nf-core/fastme/main"

workflow MAKE_TREES {
    take:
    ch_alignment

    main:

    ch_versions = Channel.empty()
    ch_mltree   = Channel.empty()
    ch_metree   = Channel.empty()

    if (params.use_iqtree) {
        ch_alnfile = ch_alignment.
            map { meta, path -> path }

        IQTREE (
            ch_alnfile,
            []
        )

        ch_mltree = IQTREE.out.phylogeny

        ch_versions
            .mix(IQTREE.out.versions)
            .set { ch_versions }
    }

    if (params.use_fastme) {
        ch_alnfile = ch_alignment.
            map { meta, path -> path }

        FASTME (
            ch_alnfile,
            []
        )

        ch_metree = FASTME.out.phylogeny

        ch_versions
            .mix(FASTME.out.versions)
            .set { ch_versions }
    }

    emit:
    mltree   = ch_mltree
    metree   = ch_metree
    versions = ch_versions
}
