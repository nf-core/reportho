#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Map OMA IDs to UniProt using local Ensembl and RefSeq ID mapping files."""

import argparse
import gzip


def uniprotize_oma(oma_ids_path: str, ensembl_idmap_path: str, refseq_idmap_path: str) -> None:
    """Map IDs from OMA to UniProt using local Ensembl and RefSeq ID mapping files."""
    with open(oma_ids_path) as f:
        oma_ids = f.read().splitlines()

    ensembl_mapping = dict()
    with gzip.open(ensembl_idmap_path, "rt") as f:
        for line in f:
            items = line.split()
            if items[0] not in ensembl_mapping and "_" not in items[1]:
                ensembl_mapping[items[0]] = items[1]

    ensembl_ids_mapped = [ensembl_mapping[i] for i in oma_ids if i in ensembl_mapping]
    ensembl_ids_unmapped = [i for i in oma_ids if i not in ensembl_mapping]

    refseq_mapping = dict()
    with gzip.open(refseq_idmap_path, "rt") as f:
        for line in f:
            items = line.split()
            if items[0] not in refseq_mapping and "_" not in items[1]:
                refseq_mapping[items[0]] = items[1].split(";")[0]

    refseq_ids_mapped = [refseq_mapping[i] for i in ensembl_ids_unmapped if i in refseq_mapping]
    refseq_ids_unmapped = [i for i in ensembl_ids_unmapped if i not in refseq_mapping]

    for i in refseq_ids_unmapped + ensembl_ids_mapped + refseq_ids_mapped:
        print(i)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Map OMA IDs to UniProt using local Ensembl and RefSeq ID mapping files."
    )
    parser.add_argument(
        "-i",
        "--ids-path",
        required=True,
        help="Path to input file containing OMA IDs.",
    )
    parser.add_argument(
        "-e",
        "--ensembl-idmap",
        required=True,
        help="Path to gzipped Ensembl ID mapping file.",
    )
    parser.add_argument(
        "-r",
        "--refseq-idmap",
        required=True,
        help="Path to gzipped RefSeq ID mapping file.",
    )
    args = parser.parse_args()

    uniprotize_oma(args.ids_path, args.ensembl_idmap, args.refseq_idmap)


if __name__ == "__main__":
    main()
