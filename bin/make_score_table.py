#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Get score and format information from a merged CSV file."""

import csv
import re
import sys


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: python make_score_table.py <merged_csv> <diamond_mapping>")
        sys.exit(1)

    # Read the CSV into a list of lists, it has a header
    with open(sys.argv[1]) as f:
        reader = csv.reader(f)
        data = list(reader)

    if not data:
        return

    # Read the mapping into a dictionary
    mapping = {}

    with open(sys.argv[2]) as f:
        for line in f:
            ids = line.strip().split("\t")
            mapping[ids[0]] = ids[1:] if len(ids) > 1 else []

    # Invert the mapping
    canonical_map = {v: k for k, vs in mapping.items() for v in vs}

    # Get the header and the data
    header = data[0]
    content = data[1:]

    # Get the canonical IDs
    new_data = {}

    for row in content:
        if row[0] in canonical_map:
            can_id = canonical_map[row[0]]
            curr_row = new_data.get(can_id, [0] * len(row[1:]))
            # This evil comprehension merges synonymous rows
            new_data[can_id] = [(int(i) or int(j)) for i, j in zip(row[1:], curr_row)]
        else:
            new_data[row[0]] = [(int(i) or int(j)) for i, j in zip(row[1:], new_data.get(row[0], [0] * len(row[1:])))]

    # Convert the dictionary to a list of lists
    merged_list = [[k] + v for k, v in new_data.items()]

    # Calculate a score column
    scores = [sum([int(i) for i in row[1:]]) for row in merged_list]

    # Find database information by ID
    id_formats = []
    for row in merged_list:
        if re.match(r"[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}", row[0]):
            id_formats.append("uniprot")
        elif re.match(r"ENS[A-Z]+\d{11}(\.\d+)?", row[0]):
            id_formats.append("ensembl")
        elif re.match(r"(AC|AP|NC|NG|NM|NP|NR|NT|NW|WP|XM|XP|XR|YP|ZP)_\d+", row[0]):
            id_formats.append("refseq")
        elif re.match(r"[A-Z]{5}[0-9]{5}", row[0]):
            id_formats.append("oma")
        else:
            id_formats.append("unknown")

    # Print the header
    print("id,id_format," + ",".join(header[1:]) + ",score")

    # Print the data
    for i, row in enumerate(merged_list):
        # this if cleans up the stupid hack from csv_adorn
        if scores[i] == 0:
            continue
        print(row[0] + "," + id_formats[i] + "," + ",".join([str(i) for i in row[1:]]) + "," + str(scores[i]))

if __name__ == "__main__":
    main()
