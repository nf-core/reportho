#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from ensembl2uniprot import ensembl2uniprot
from refseq2uniprot import refseq2uniprot
from uniprot2uniprot import uniprot2uniprot


def map_uniprot(ids: list[str]) -> list[str]:
    """
    Map a list of IDs to UniProt IDs.
    """
    ensembl_ids = []
    refseq_ids = []
    uniprot_names = []
    uniprot_ids = []

    for i in ids:
        # heuristic identification, we don't need regex here
        if i.startswith("ENS"):
            ensembl_ids.append(i)
        elif i.startswith("NP_") or i.startswith("XP_"):
            refseq_ids.append(i)
        elif "_" in i:
            uniprot_names.append(i)
        else:
            uniprot_ids.append(i)

    ensembl_mapped = ensembl2uniprot(ensembl_ids)
    refseq_mapped = refseq2uniprot(refseq_ids)
    uniprot_mapped = uniprot2uniprot(uniprot_names)

    return ensembl_mapped + refseq_mapped + uniprot_mapped + uniprot_ids


def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: map_uniprot.py <id>")

    print(map_uniprot([sys.argv[1]]))


if __name__ == "__main__":
    main()
