#!/usr/bin/env python3

import sys

import yaml


def main() -> None:
    if len(sys.argv) < 4:
        print("Usage: yml2csv.py <id> <input_file> <output_file>")
        sys.exit(1)

    sample_id = sys.argv[1]
    input_file = sys.argv[2]
    output_file = sys.argv[3]

    with open(input_file) as f:
        data = yaml.safe_load(f)

    with open(output_file, "w") as f:
        print("id,percent_max,percent_privates,goodness", file=f)
        print(f"{sample_id},{data['percent_max']},{data['percent_privates']},{data['goodness']}", file=f)

if __name__ == "__main__":
    main()
