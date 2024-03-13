#!/usr/bin/env python3

import sys
import gzip

def oma2uniprot_local(oma_ids: list[str], idmap_path: str) -> None:
    mapping = dict()
    with gzip.open(idmap_path, "rt") as f:
        for line in f:
            items = line.split()
            if items[0] not in mapping and "_" not in items[1]:
                mapping[items[0]] = items[1]

    ids_mapped = [mapping[i] for i in oma_ids if i in mapping]
    ids_unmapped = [i for i in oma_ids if i not in mapping]

    for i in ids_mapped + ids_unmapped:
        print(i)


def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: oma2uniprot_local.py [ids] [path]")

    oma2uniprot_local(sys.argv[2:], sys.argv[1])


if __name__ == "__main__":
    main()
