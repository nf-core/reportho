#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Map Ensembl, RefSeq, and UniProt IDs to UniProt IDs."""

import argparse

from ensembl2uniprot import ensembl2uniprot
from refseq2uniprot import refseq2uniprot
from uniprot2uniprot import uniprot2uniprot


def map_uniprot(ids: list[str]) -> list[str]:
    """Map a list of IDs to UniProt IDs."""
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
    parser = argparse.ArgumentParser(
        description="Map Ensembl, RefSeq, and UniProt IDs to UniProt IDs."
    )
    parser.add_argument(
        "-i",
        "--id",
        required=True,
        help="Input ID to map to UniProt.",
    )
    args = parser.parse_args()

    print(map_uniprot([args.id]))


if __name__ == "__main__":
    main()
