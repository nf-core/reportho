# nf-core/reportho: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.2.0dev](https://github.com/nf-core/reportho/releases/tag/dev) - TBD

### Added

### Changed

- [#107](https://github.com/nf-core/reportho/pull/107) - Update nf-core template to version 4.0.2

### Fixed

- [#114](https://github.com/nf-core/reportho/pull/114) - Fix clobber issues in fetch_eggnog_group_local, fetch_oma_group_local, and fetch_panther_group_local modules

### Removed

### Dependencies

| Dependency | Old version | New version |
| ---------- | ----------- | ----------- |

### Parameters

| Params | status |
| ------ | ------ |

### Developer section

#### Added

- [#120](https://github.com/nf-core/reportho/pull/120) - Local module meta files for better documentation of module inputs/outputs

#### Changed

- [#100](https://github.com/nf-core/reportho/pull/100) - Back to dev (1.2.0dev)
- [#107](https://github.com/nf-core/reportho/pull/107) - Module structure migrated to nf-core standard directory format
- [#116](https://github.com/nf-core/reportho/pull/116) - Migrate modules to use module binaries instead of global bin/

#### Fixed

- [#118](https://github.com/nf-core/reportho/pull/118) - Fix YAML schema link in local module and subworkflow metas

#### Removed

## [v1.1.0](https://github.com/nf-core/reportho/releases/tag/1.1.0) - Reliable Rudder - [2025-10-21]

The rudder is a control surface which is used to turn the ship. It is the main (and sometimes only) direct source of directional control.

This is the second release of reportho. The main change is the addition of identifier merging, which is supposed to alleviate issues related to synonymous IDs. We have removed the MSA and phylogeny modules, as we want to chain into other purpose-built nf-core pipelines instead (especially `multiplesequencealign`). If your analysis relies on these functionalities, you can keep using 1.0.1 for now.

### `Credits`

We thank Daniel Májer from Gabaldón Lab for his assistance in implementing sequence merging.

### `Added`

- The pipeline can now download sequences from UniProt, RefSeq and Ensembl
- Identification of synonymous identifiers using Diamond
- Array specific profile inside custom config, coupled with the above improves overall cluster usage and increases scheduler friendliness

### `Removed`

- MSA and phylogeny modules; an nf-core/multiplesequencealign samplesheet generator will be added in a later version

### `Changed`

- Minor refactors in local modules
- Better resource request per process, thanks to custom label
- test_full config now runs all databases queries

### `Fixed`

- The pipeline should not crash if no orthologs are found for a query; please inform us if you identify any issues

### `Dependencies`

The following dependencies have changed:

| Program  | Old version | New version |
| -------- | ----------- | ----------- |
| Diamond  |             | 2.1.9       |
| T-COFFEE | 13.46.0     |             |

## [v1.0.1](https://github.com/nf-core/reportho/releases/tag/1.0.1) [2024-06-14]

### `Fixed`

- Fixed minor bugs that caused compilation errors in the structural alignment section
- Restricted publishing of intermediate files

## [v1.0.0](https://github.com/nf-core/reportho/releases/tag/1.0.0) - Magnificent Mainsail - [2024-06-11]

Although its location and design may vary greatly, the mainsail is always a key source of propulsion for a ship.

This is the initial release of nf-core/reportho, created with the [nf-core](https://nf-co.re/) template.

### `Credits`

The following people have made significant contributions to the release through design, development and review:

- [Igor Trujnara](https://github.com/itrujnara)
- [Luisa Santus](https://github.com/luisas)
- [Jose Espinosa-Carrasco](https://github.com/JoseEspinosa)
- [Alessio Vignoli](https://github.com/alessiovignoli)

We also thank everyone else from the nf-core community who has participated in planning and development.

### `Added`

The pipeline was created. In particular, it has the following features:

- fetching of ortholog predictions from public databases, through APIs and from local snapshots
- systematic comparison of the predictions and calculation of comparison statistics
- creation of an ortholog list with user-defined criteria
- basic downstream analysis of the obtained ortholog list
- generation of a human-readable report

### `Dependencies`

The pipeline has the following notable dependencies:

| Program         | Version |
| --------------- | ------- |
| Python          | 3.11.0  |
| Python Requests | 2.31.0  |
| Biopython       | 1.83    |
| R               | 4.3.3   |
| PyYAML          | 5.4.1   |
| T-COFFEE        | 13.46.0 |
| pigz            | 2.8     |
| csvtk           | 0.26.0  |
| Node            | 21.6.2  |
| Yarn            | 1.22.19 |
| React           | 18.3.1  |

At release date, the following database versions were current and used for testing the pipeline:

| Database       | Version       |
| -------------- | ------------- |
| OMA            | Jul2023       |
| PANTHER        | 18            |
| OrthoInspector | Eukaryota2023 |
| EggNOG         | 5.0           |
