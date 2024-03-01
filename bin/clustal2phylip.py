#!/usr/bin/env python3

from Bio import SeqIO
import sys

def clustal2phylip(input_file, output_file):
    records = list(SeqIO.parse(input_file, "clustal"))
    SeqIO.write(records, output_file, "phylip")


def main():
    if len(sys.argv) < 3:
        print("Usage: clustal2phylip.py input_file output_file")
        sys.exit(1)
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    clustal2phylip(input_file, output_file)


if __name__ == "__main__":
    main()
