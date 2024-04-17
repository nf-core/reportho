include { IQTREE                   } from "../../modules/nf-core/iqtree/main"
include { FASTME                   } from "../../modules/nf-core/fastme/main"
include { CONVERT_PHYLIP           } from "../../modules/local/convert_phylip"
include { PLOT_TREE as PLOT_IQTREE } from "../../modules/local/plot_tree"
include { PLOT_TREE as PLOT_FASTME } from "../../modules/local/plot_tree"

workflow MAKE_TREES {
    take:
    ch_alignment

    main:

    ch_versions = Channel.empty()
    ch_mltree   = Channel.empty()
    ch_metree   = Channel.empty()
    ch_mlplot   = Channel.empty()
    ch_meplot   = Channel.empty()

    if (params.use_iqtree) {
        IQTREE (
            ch_alignment,
            []
        )

        ch_mltree = IQTREE.out.phylogeny

        ch_versions
            .mix(IQTREE.out.versions)
            .set { ch_versions }

        PLOT_IQTREE (
            IQTREE.out.phylogeny,
            "iqtree"
        )

        ch_mlplot = PLOT_IQTREE.out.plot

        ch_versions
            .mix(PLOT_IQTREE.out.versions)
            .set { ch_versions }
    }

    if (params.use_fastme) {

        CONVERT_PHYLIP (
            ch_alignment
        )

        ch_versions
            .mix(CONVERT_PHYLIP.out.versions)
            .set { ch_versions }

        FASTME (
            CONVERT_PHYLIP.out.phylip.map { [it[0], it[1], []] }
        )

        ch_metree = FASTME.out.nwk

        ch_versions
            .mix(FASTME.out.versions)
            .set { ch_versions }

        PLOT_FASTME (
            FASTME.out.nwk,
            "fastme"
        )

        ch_meplot = PLOT_FASTME.out.plot

        ch_versions
            .mix(PLOT_FASTME.out.versions)
            .set { ch_versions }
    }

    emit:
    mltree   = ch_mltree
    metree   = ch_metree
    mlplot   = ch_mlplot
    meplot   = ch_meplot
    versions = ch_versions
}
