#!/usr/bin/env python3

import sys

def csv_adorn(path: str, header: str) -> None:
    print(f"id,{header}")
    with open(path, "r") as f:
        for line in f:
            print(line.strip() + ",1")


def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: oma_csv.py [path] [header]")

    csv_adorn(sys.argv[1], sys.argv[2])


if __name__ == "__main__":
    main()
