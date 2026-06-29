#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import argparse
import sys

import yaml


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert YAML stats file to CSV.")
    parser.add_argument(
        "-s",
        "--sample-id",
        required=True,
        help="Sample identifier for the output row.",
    )
    parser.add_argument(
        "-i",
        "--input-file",
        required=True,
        help="Path to input YAML stats file.",
    )
    parser.add_argument(
        "-o",
        "--output-file",
        required=True,
        help="Path to output CSV file.",
    )
    args = parser.parse_args()

    sample_id = args.sample_id
    input_file = args.input_file
    output_file = args.output_file

    with open(input_file) as f:
        data = yaml.safe_load(f)

    if not data:
        with open(output_file, "w") as f:
            print("id,percent_max,percent_privates,goodness", file=f)
        return

    with open(output_file, "w") as f:
        print("id,percent_max,percent_privates,goodness", file=f)
        print(f"{sample_id},{data['percent_max']},{data['percent_privates']},{data['goodness']}", file=f)

if __name__ == "__main__":
    main()
