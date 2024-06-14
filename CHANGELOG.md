# nf-core/reportho: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.1](https://github.com/nf-core/reportho/releases/tag/1.0.1) [2024-06-11]

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
