#!/usr/bin/env python3

import argparse
from pathlib import Path

from Bio import SeqIO


def load_ids(ids_path: Path) -> set[str]:
    with ids_path.open() as handle:
        return {line.strip() for line in handle if line.strip()}


def clean_id(identifier: str) -> str:
    """Clean the identifier by removing the FASTA header formatting and species identifier."""
    return identifier.strip().split("|")[0].replace(">", "")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Filter a FASTA file by a list of sequence identifiers.")
    parser.add_argument("input_fasta", type=Path, help="Path to the input FASTA file.")
    parser.add_argument("ids_file", type=Path, help="Path to the file listing identifiers to retain.")
    parser.add_argument("output_fasta", type=Path, help="Path to the filtered output FASTA file.")
    return parser.parse_args()


def main() -> int:
    args = parse_args()

    keep_ids = load_ids(args.ids_file)

    with args.output_fasta.open("w") as handle:
        records = (record for record in SeqIO.parse(args.input_fasta, "fasta") if clean_id(record.id) in keep_ids)
        SeqIO.write(records, handle, "fasta")


if __name__ == "__main__":
    main()
