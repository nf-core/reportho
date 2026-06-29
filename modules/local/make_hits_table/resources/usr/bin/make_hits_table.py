#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import csv
import argparse
import sys


def main() -> None:
    """
    Convert numbers of hits into CSV.
    """
    parser = argparse.ArgumentParser(description="Convert numbers of hits into CSV.")
    parser.add_argument(
        "-m",
        "--merged-csv",
        required=True,
        help="Path to merged CSV input file.",
    )
    parser.add_argument(
        "-s",
        "--sample-id",
        required=True,
        help="Sample identifier to write in output.",
    )
    args = parser.parse_args()

    # Read the CSV into a list of lists, it has a header
    with open(args.merged_csv) as f:
        reader = csv.DictReader(f)
        data = list(reader)

    if not data:
        print("id")
        return

    sample_id = args.sample_id

    # Get list of databases
    databases = list(data[0].keys())[1:]

    # Get counts
    sums = {db: sum(int(row[db]) for row in data) for db in databases}

    # Print the header
    print("id," + ",".join(databases) + ",total")

    # Print the data
    print(sample_id + "," + ",".join(str(sums[db]) for db in databases) + "," + str(len(data) - 1))

if __name__ == "__main__":
    main()
