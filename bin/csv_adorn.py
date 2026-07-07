#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Convert a list of IDs into a CSV file with a header.

This is required for csv merge to work."""

import argparse


def csv_adorn(path: str, header: str) -> None:
    print(f"id,{header}")
    with open(path) as f:
        any_data = False
        for line in f:
            any_data = True
            print(line.strip() + ",1")
        if not any_data:
            # this is a stupid hack, but the only way we found that does not break modularity
            print("nothing,0")


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert a list of IDs into a CSV file with a header.")
    parser.add_argument(
        "-p",
        "--path",
        required=True,
        help="Path to the input file containing one ID per line.",
    )
    parser.add_argument(
        "-H",
        "--header",
        required=True,
        help="Header name to append as the second CSV column.",
    )
    args = parser.parse_args()

    csv_adorn(args.path, args.header)


if __name__ == "__main__":
    main()
