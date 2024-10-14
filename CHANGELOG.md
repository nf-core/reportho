# nf-core/reportho: Changelog

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v1.1.0dev - [date]

Initial release of nf-core/reportho, created with the [nf-core](https://nf-co.re/) template.

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
