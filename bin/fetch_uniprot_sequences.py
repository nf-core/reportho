#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch protein sequences from the UniProt database using the UniProt REST API."""

import io
import sys

from Bio import SeqIO
from utils import list_to_file, safe_get, SequenceInfo, split_ids


def fetch_slice(ids: list[str]) -> list[SeqIO.SeqRecord]:
    """Fetch sequences for given UniProt IDs from the EBI database."""
    payload: dict[str,str] = {"accession": ','.join(ids)}
    headers: dict[str,str] = {"Accept": "text/x-fasta"}
    res = safe_get("https://www.ebi.ac.uk/proteins/api/proteins",
                       params = payload,
                       headers = headers)
    if not res.ok:
        return []

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
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: fetch_uniprot_sequences.py <ids_path> <prefix>")

    with open(sys.argv[1]) as f:
        ids = f.read().splitlines()

    seqs = fetch_ebi(ids)
    seqs_valid = [i for i in seqs if i.is_valid()]

    for i in seqs_valid:
        print(i)

    ids_valid = set([i.prot_id for i in seqs_valid])
    ids_invalid = set(ids) - ids_valid

    prefix = sys.argv[2]
    list_to_file(list(ids_valid), f"{prefix}_uniprot_seq_hits.txt")
    list_to_file(list(ids_invalid), f"{prefix}_uniprot_seq_misses.txt")


if __name__ == "__main__":
    main()
