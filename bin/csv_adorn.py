#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys


def csv_adorn(path: str, header: str) -> None:
    """
    Convert a list of IDs into a CSV file with a header. Used for later table merge.
    """
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
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: oma_csv.py <path> <header>")

    csv_adorn(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
