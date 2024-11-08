#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys
from xml.dom import minidom

from Bio import Entrez
from utils import list_to_file, SequenceInfo, split_ids


def get_taxid(node: minidom.Element) -> str:
    taxid = node.getElementsByTagName("TSeq_taxid")[0].firstChild.wholeText
    return taxid


def get_sequence(node: minidom.Element) -> str:
    seq = node.getElementsByTagName("TSeq_sequence")[0].firstChild.wholeText
    return seq


def get_prot_id(node: minidom.Element) -> str:
    prot_id = node.getElementsByTagName("TSeq_accver")[0].firstChild.wholeText.split(".")[0]
    return prot_id


def fetch_slice(ids: list[str], db: str = "protein") -> list[SequenceInfo]:
    id_string = ",".join(ids)
    fasta = Entrez.efetch(db=db, id=id_string, rettype="fasta", retmode="xml")
    seqs = minidom.parse(fasta).getElementsByTagName("TSeq")
    return [SequenceInfo(prot_id=get_prot_id(seq),
                            taxid=get_taxid(seq),
                            sequence=get_sequence(seq)) for seq in seqs]


def fetch_sequences(ids: list[str], db: str = "protein") -> list[SequenceInfo]:
    seqs = []
    for s in split_ids(ids, 100):
        seqs += fetch_slice(s, db)
    return seqs


def main() -> None:
    if len(sys.argv) < 2:
        print("Too few arguments. Usage: fetch_refseq_sequences.py <id_file>")
        sys.exit(1)
    with open(sys.argv[1], "r") as f:
        ids = f.read().splitlines()
    seqs = fetch_sequences(ids)
    seqs_valid = [i for i in seqs if i.is_valid()]

    ids_valid = set([i.prot_id for i in seqs_valid])
    ids_invalid = set(ids) - ids_valid

    prefix = sys.argv[2]
    list_to_file(list(ids_valid), f"{prefix}_refseq_seq_hits.txt")
    list_to_file(list(ids_invalid), f"{prefix}_refseq_seq_misses.txt")

    for s in seqs_valid:
        print(s)


if __name__ == "__main__":
    main()
