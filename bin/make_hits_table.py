#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import csv
import sys


def main() -> None:
    """
    Convert numbers of hits into CSV.
    """
    if len(sys.argv) < 3:
        print("Usage: python make_hit_table.py <merged_csv> <sample_id>")
        sys.exit(1)

    # Read the CSV into a list of lists, it has a header
    with open(sys.argv[1]) as f:
        reader = csv.DictReader(f)
        data = list(reader)

    sample_id = sys.argv[2]

    # Get list of databases
    databases = list(data[0].keys())[1:]

    # Get counts
    sums = {db: sum(int(row[db]) for row in data) for db in databases}

    # Print the header
    print("id," + ",".join(databases))

    # Print the data
    print(sample_id + "," + ",".join(str(sums[db]) for db in databases))

if __name__ == "__main__":
    main()
