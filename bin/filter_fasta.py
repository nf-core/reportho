#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from Bio import SeqIO


def filter_fasta(in_path, structures, out_path) -> None:
    """
    Filter a FASTA file by a list of structures. Used for 3D-COFFEE.
    """
    fasta = SeqIO.parse(in_path, 'fasta')
    ids = [it.split(".")[0] for it in structures]
    fasta_filtered = [it for it in fasta if it.id in ids]
    SeqIO.write(fasta_filtered, out_path, 'fasta')


def main() -> None:
    in_path = sys.argv[1]
    structures = sys.argv[2:-1]
    out_path = sys.argv[-1]
    filter_fasta(in_path, structures, out_path)


if __name__ == "__main__":
    main()
