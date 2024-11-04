#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from utils import split_ids_by_format


def split_ids(ids: list[str], prefix: str) -> None:
    file_uniprot = open(f"{prefix}_uniprot_ids.txt", 'w')
    file_ensembl = open(f"{prefix}_ensembl_ids.txt", 'w')
    file_refseq = open(f"{prefix}_refseq_ids.txt", 'w')
    file_oma = open(f"{prefix}_oma_ids.txt", 'w')
    file_unknown = open(f"{prefix}_unknown_ids.txt", 'w')

    ids_format = split_ids_by_format(ids)

    for i in ids_format.get("uniprot", []):
        print(i, file = file_uniprot)
    for i in ids_format.get("ensembl", []):
        print(i, file = file_ensembl)
    for i in ids_format.get("refseq", []):
        print(i, file = file_refseq)
    for i in ids_format.get("oma", []):
        print(i, file = file_oma)
    for i in ids_format.get("unknown", []):
        print(i, file = file_unknown)

    file_uniprot.close()
    file_ensembl.close()
    file_refseq.close()
    file_oma.close()
    file_unknown.close()


def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: split_ids.py <id_list> <prefix>")
    with open(sys.argv[1]) as f:
        ids = f.read().splitlines()
    split_ids(ids, sys.argv[2])


if __name__ == "__main__":
    main()
