#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Convert Diamond output into a CSV summary table."""

import argparse
import sys


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert Diamond output into a CSV summary table.")
    parser.add_argument(
        "-c",
        "--clusters",
        required=True,
        help="Path to input clusters file.",
    )
    parser.add_argument(
        "-s",
        "--sample-id",
        required=True,
        help="Sample identifier to write in output.",
    )
    args = parser.parse_args()

    with open(args.clusters) as f:
        clusters = f.readlines()

    if not clusters:
        print("id,one,many")
        return

    sample_id = args.sample_id

    # Get counts
    one = 0
    many = 0
    in_clusters = 0
    total = 0
    for cluster in clusters:
        count = len(cluster.split('\t'))
        if count == 1:
            one += 1
            total += 1
        else:
            many += 1
            in_clusters += count
            total += count

    # Print the header
    print("id,one,many,in_clusters,total")

    # Print the data
    print(sample_id + "," + str(one) + "," + str(many) + "," + str(in_clusters) + "," + str(total))


if __name__ == "__main__":
    main()
