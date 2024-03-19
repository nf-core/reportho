#!/usr/bin/env python3

import sys
import gzip

def uniprot2oma_local(uniprot_path: list[str], idmap_path: str) -> None:
    with open(uniprot_path[0], "r") as f:
        uniprot_ids = f.read().splitlines()

    mapping = dict()
    with gzip.open(idmap_path, "rt") as f:
        for line in f:
            items = line.split()
            if items[1] not in mapping:
                mapping[items[1]] = items[0]

    ids_mapped = [mapping[i] for i in uniprot_ids if i in mapping]
    ids_unmapped = [i for i in uniprot_ids if i not in mapping]

    for i in ids_mapped + ids_unmapped:
        print(i)


def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: uniprot2oma_local.py [ids] [path]")

    uniprot2oma_local(sys.argv[2:], sys.argv[1])


if __name__ == "__main__":
    main()
