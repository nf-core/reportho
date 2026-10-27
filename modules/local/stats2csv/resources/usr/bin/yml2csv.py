#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import argparse

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
        "-y",
        "--yaml",
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

    with open(args.yaml) as f:
        data = yaml.safe_load(f)

    if not data:
        with open(args.output_file, "w") as f:
            print("id,percent_max,percent_privates,norm_mean", file=f)
        return

    with open(args.output_file, "w") as f:
        print("id,percent_max,percent_privates,norm_mean", file=f)
        print(f"{args.sample_id},{data['percent_max']},{data['percent_privates']},{data['norm_mean']}", file=f)


if __name__ == "__main__":
    main()
