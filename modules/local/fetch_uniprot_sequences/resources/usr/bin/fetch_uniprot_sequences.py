#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch protein sequences from the UniProt database using the UniProt REST API."""

import io
import argparse
import os
import subprocess
import sys

from Bio import SeqIO

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import list_to_file, safe_get, SequenceInfo, split_ids, handle_http_response # noqa: E402


def fetch_slice(ids: list[str]) -> list[SeqIO.SeqRecord]:
    """Fetch sequences for given UniProt IDs from the EBI database."""
    payload: dict[str,str] = {"accession": ','.join(ids)}
    headers: dict[str,str] = {"Accept": "text/x-fasta"}
    url = "https://www.ebi.ac.uk/proteins/api/proteins"
    res = safe_get(url, params=payload, headers=headers)

    retry, res = handle_http_response(res, False)
    if retry:
        res = safe_get(url, params=payload, headers=headers)
        _, res = handle_http_response(res, False)

    tmp = io.StringIO(res.content.decode())
    seqs = SeqIO.parse(tmp, "fasta")

    return list(seqs)


def fetch_ebi(ids: list[str]) -> list[SequenceInfo]:
    """Fetch sequences for given UniProt IDs from the EBI database in slices of 100.

    Note: The EBI database contains UniProt data and allows batch requests.
    """
    seqs = []
    for s in split_ids(ids, 100):
        seqs = seqs + fetch_slice(s)
    return [to_seqinfo(seq) for seq in seqs]


def to_seqinfo(entry: SeqIO.SeqRecord) -> SequenceInfo:
    """Convert a SeqRecord object to a custom SequenceInfo object."""
    prot_id = entry.description.split('|')[1]
    taxid = entry.description.split("OX=")[1].split(' ')[0]
    seq = str(entry.seq)
    return SequenceInfo(prot_id = prot_id,
                        taxid = taxid,
                        sequence = seq)


def main():
    parser = argparse.ArgumentParser(
        description="Fetch protein sequences from the UniProt database using the UniProt REST API."
    )
    parser.add_argument(
        "-i",
        "--ids-path",
        required=True,
        help="Path to file containing UniProt IDs, one per line.",
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

    seqs = fetch_ebi(ids)
    seqs_valid = [i for i in seqs if i.is_valid()]

    for i in seqs_valid:
        print(i)

    ids_valid = set([i.prot_id for i in seqs_valid])
    ids_invalid = set(ids) - ids_valid

    prefix = args.prefix
    list_to_file(list(ids_valid), f"{prefix}_uniprot_seq_hits.txt")
    list_to_file(list(ids_invalid), f"{prefix}_uniprot_seq_misses.txt")


if __name__ == "__main__":
    main()
