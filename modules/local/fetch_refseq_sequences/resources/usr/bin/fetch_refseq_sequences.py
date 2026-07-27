#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch protein sequences from the RefSeq database using the NCBI eutils API."""

import argparse
import os
import subprocess
import sys
from xml.dom import minidom

from Bio import Entrez

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(["which", "utils.py"], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import SequenceInfo, list_to_file, split_ids  # noqa: E402


def get_taxid(node: minidom.Element) -> str:
    """Extract the taxid from the XML object."""
    taxid = node.getElementsByTagName("TSeq_taxid")[0].firstChild.wholeText
    return taxid


def get_sequence(node: minidom.Element) -> str:
    """Extract the sequence from the XML object."""
    seq = node.getElementsByTagName("TSeq_sequence")[0].firstChild.wholeText
    return seq


def get_prot_id(node: minidom.Element) -> str:
    """Extract the protein ID from the XML object."""
    prot_id = node.getElementsByTagName("TSeq_accver")[0].firstChild.wholeText.split(".")[0]
    return prot_id


def fetch_slice(ids: list[str], db: str = "protein") -> list[SequenceInfo]:
    """Fetch sequences for given protein IDs from the RefSeq database."""
    id_string = ",".join(ids)
    fasta = Entrez.efetch(db=db, id=id_string, rettype="fasta", retmode="xml")
    seqs = minidom.parse(fasta).getElementsByTagName("TSeq")
    return [SequenceInfo(prot_id=get_prot_id(seq), taxid=get_taxid(seq), sequence=get_sequence(seq)) for seq in seqs]


def fetch_sequences(ids: list[str], db: str = "protein") -> list[SequenceInfo]:
    """Fetch sequences for given protein IDs from the RefSeq database in slices of 100."""
    seqs = []
    for s in split_ids(ids, 100):
        seqs += fetch_slice(s, db)
    return seqs


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch protein sequences from the RefSeq database using the NCBI eutils API."
    )
    parser.add_argument(
        "-i",
        "--ids-path",
        required=True,
        help="Path to file containing RefSeq IDs, one per line.",
    )
    parser.add_argument(
        "-p",
        "--prefix",
        required=True,
        help="Prefix used for hits and misses output files.",
    )
    args = parser.parse_args()

    with open(args.ids_path) as f:
        ids = f.read().splitlines()
    seqs = fetch_sequences(ids)
    seqs_valid = [i for i in seqs if i.is_valid()]

    ids_valid = set([i.prot_id for i in seqs_valid])
    ids_invalid = set(ids) - ids_valid

    prefix = args.prefix
    list_to_file(list(ids_valid), f"{prefix}_refseq_seq_hits.txt")
    list_to_file(list(ids_invalid), f"{prefix}_refseq_seq_misses.txt")

    for s in seqs_valid:
        print(s)


if __name__ == "__main__":
    main()
