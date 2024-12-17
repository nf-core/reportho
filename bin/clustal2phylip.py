#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from Bio import SeqIO


def clustal2phylip(input_file, output_file) -> None:
    """
    Convert a ClustalW alignment file to a PHYLIP file.
    """
    records = list(SeqIO.parse(input_file, "clustal"))
    SeqIO.write(records, output_file, "phylip")


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: clustal2phylip.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    clustal2phylip(input_file, output_file)


if __name__ == "__main__":
    main()
