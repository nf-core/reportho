#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import csv
import re
import sys


def main() -> None:
    """
    Get score and format information from a merged CSV file.
    """
    if len(sys.argv) < 2:
        print("Usage: python make_score_table.py <merged_csv>")
        sys.exit(1)

    # Read the CSV into a list of lists, it has a header
    with open(sys.argv[1]) as f:
        reader = csv.reader(f)
        data = list(reader)

    if not data:
        return

    # Get the header and the data
    header = data[0]
    data = data[1:]

    # Calculate a score column
    scores = [sum([int(i) for i in row[1:]]) for row in data]

    # Find database information by ID
    id_formats = []
    for row in data:
        if re.match(r"[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}", row[0]):
            id_formats.append("uniprot")
        elif re.match(r"ENS[A-Z]+\d{11}(\.\d+)?", row[0]):
            id_formats.append("ensembl")
        elif re.match(r"(AC|AP|NC|NG|NM|NP|NR|NT|NW|WP|XM|XP|XR|YP|ZP)_\d+", row[0]):
            id_formats.append("refseq")
        else:
            id_formats.append("unknown")

    # Print the header
    print("id,id_format," + ",".join(header[1:]) + ",score")

    # Print the data
    for i, row in enumerate(data):
        # this if cleans up the stupid hack from csv_adorn
        if scores[i] == 0:
            continue
        print(row[0] + "," + id_formats[i] + "," + ",".join(row[1:]) + "," + str(scores[i]))


if __name__ == "__main__":
    main()
