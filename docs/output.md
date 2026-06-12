# nf-core/reportho: Output

## Introduction

This document describes the output produced by the pipeline. Most of the plots are taken from the report, which summarizes results at the end of the pipeline.

The directories listed below will be created in the results directory after the pipeline has finished. All paths are relative to the top-level results directory.

## Pipeline overview

The pipeline is built using [Nextflow](https://www.nextflow.io/) and processes data using the following steps:

- [Query identification](#query-identification) - obtaining basic information on the query
- [Ortholog fetching](#ortholog-fetching) - obtaining ortholog predictions from public databases
- [Sequence fetching](#sequence-fetching) - obtaining ortholog sequences form public databases
- [ID merging](#id-merging) - merging identifiers based on their sequence
- [Ortholog scoring](#ortholog-scoring) - creation of a score table
- [Ortholog filtering](#ortholog-filtering) - selection of final ortholog list
- [Ortholog plotting](#ortholog-plotting) - creation of plots describing the predictions
- [Ortholog statistics](#ortholog-statistics) - calculation of several statistics about the predictions
- [Report generation](#report-generation) - creation of a human-readable report
- [Pipeline information](#pipeline-information) - basic information about the pipeline run

### Query identification

<details markdown="1">
<summary>Output files</summary>

- `seqinfo/`
  - `*_id.txt`: File containing Uniprot identifier of the query or the closest BLAST hit.
  - `*_taxid.txt`: File containing NCBI taxon ID of the query/closest hit.
  - `*_exact.txt`: File containing information on whether the query was found in the database (`true`), or the output is the top BLAST hit (`false`).
  </details>

Query information necessary for further steps is obtained here. If a sequence was passed, it is identified using [OMA](https://omabrowser.org). A Uniprot identifier is obtained, along with indication whether it was an exact or closest match. For either query type, an NCBI taxon ID is obtained using the OMA API.

### Ortholog fetching

<details markdown="1">
<summary>Output files</summary>

- `orthologs/`
  - `[dbname]/`
    - `*_[dbname]_group.csv`: A CSV file with the hits from the database. It has an additional column necessary for later merging.
    </details>

Ortholog predictions are fetched from the databases. Each database can be used locally or online, subject to the feasibility of these access modes. The databases currently supported are:

- OMA (online and local)
- PANTHER (online and local)
- OrthoInspector (online)
- EggNOG (local).

### Sequence fetching

<details markdown="1">
<summary>Output files</summary>

- `sequences/`
  - `*_orthologs.fa`: A FASTA file containing all ortholog sequences that could be found.
  - `*_seq_hits.txt`: The list of all orthologs whose sequence was found.
  - `*_seq_misses.txt`: The list of all orthologs whose sequence was not found.
  </details>

If identifier merging is performed, protein sequences of all orthologs in FASTA format are fetched. The identifiers are split by their format (based on regex) and sequences are fetched from the corresponding databases. Identifiers of unsupported format are automatically registered as misses. The currently supported sequence databases are:

- Uniprot
- RefSeq
- Ensembl
- OMA

### Identifier merging

<details markdown="1">
<summary>Output files</summary>

- `merge/`
  - `*_clusters.tsv`: A TSV file containing the clusters found by Diamond (including singletons)
  - `*_idmap.tsv`: A TSV file containing only non-singleton clusters, used for scoring.
  </details>

In some cases, multiple identifiers might refer to the same sequence. This step uses Diamond to identify such cases and construct a table of possible synonymous IDs. If this table seems incorrect, merge parameter tuning might be necessary.

### Ortholog scoring

<details markdown="1">
<summary>Output files</summary>

- `orthologs/`
  - `merge_csv/`
    - `*.csv`: A merged CSV file with predictions from all the databases.
  - `score_table/`
    - `*_score_table.csv`: A merged CSV with a score column added. The score is the number of databases supporting the prediction.
    </details>

At this step, the predictions are combined into a single table. They are also assigned a score which is used for later filtering. The score is the number of supporting sources.

### Ortholog filtering

<details markdown="1">
<summary>Output files</summary>

- `orthologs/`
  - `filter_hits/`
    - `*_minscore_*.txt`: Lists of predictions passing different score thresholds, from 1 to the number of sources. For example, `BicD2_minscore_2.txt` would include orthologs of BicD2 supported by at least 2 sources.
    - `*_centroid.txt`: A list of predictions from the source with the highest agreement with other sources.
    - `*_filtered_hits.txt`: The final list of orthologs, chosen based on user-defined criteria.
    </details>

In this step, the predictions are split into lists with different minimal scores, indicating each level of support. Additionally, the source with the highest total agreement is found.

The final list of orthologs is determined in one of two ways. If `--use_centroid` is set, the highest-agreement source will be used. Otherwise, orthologs with a score higher than `--min_score` are used.

### Ortholog plotting

<details markdown="1">
<summary>Output files</summary>

- `orthologs/`
  - `plots/`
    - `*_supports.png`: A bar plot representing the number of predictions from each source and the support of the predictions.
    - `*_venn.png`: A Venn diagram representing the intersections between databases.
    - `*_jaccard.png`: A tile plot representing the Jaccard index (pairwise agreement) between databases.
    </details>

Plots representing certain aspects of the predictions are generated using `ggplot`.

### Ortholog statistics

<details markdown="1">
<summary>Output files</summary>

- `orthologs/`
  - `stats/`
    - `*_stats.yml`: A YAML file containing ortholog statistics.
  - `hits/`
    - `*_hits.yml`: A YAML file containing hit counts per database.
    </details>

The following statistics of the predictions are calculated:

- percentage of consensus - the fraction of predictions which are supported by all the sources
- percentage of privates - the fractions of predictions which are supported by only 1 source
- goodness - the ratio of the real sum of scores to the theoretical maximum (i.e. the number of databases times the number of predictions).

### Report generation

<details markdown="1">
<summary>Output files</summary>

- `*_dist/`
  - `*.html`: The report in HTML format.
  - `run.sh`: A script to correctly open the report.
  - Other files necessary for the report.
- `multiqc/`
  - `multiqc_report.html`: A MultiQC report containing summary of all samples.
  </details>

The report is generated per sample in the form of a React application. It must be hosted on localhost to work correctly. This can be done manually or with the run script provided.

A single MultiQC report is also generated. It contains a comparison of hit count and statistics for each sample, as well as a list of software versions used in the run.

### Pipeline information

<details markdown="1">
<summary>Output files</summary>

- `pipeline_info/`
  - Reports generated by Nextflow: `execution_report.html`, `execution_timeline.html`, `execution_trace.txt` and `pipeline_dag.dot`/`pipeline_dag.svg`.
  - Reports generated by the pipeline: `pipeline_report.html`, `pipeline_report.txt` and `software_versions.yml`. The `pipeline_report*` files will only be present if the `--email` / `--email_on_fail` parameter's are used when running the pipeline.
  - Reformatted samplesheet files used as input to the pipeline: `samplesheet.valid.csv`.
  - Parameters used by the pipeline run: `params.json`.

</details>

[Nextflow](https://www.nextflow.io/docs/latest/tracing.html) provides excellent functionality for generating various reports relevant to the running and execution of the pipeline. This will allow you to troubleshoot errors with the running of the pipeline, and also provide you with other information such as launch commands, run times and resource usage.
