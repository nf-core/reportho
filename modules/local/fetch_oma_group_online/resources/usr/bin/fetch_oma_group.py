#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch OMA orthologs of a protein by ID."""

import argparse

from omadb import Client as OmaClient


def main() -> None:
    parser = argparse.ArgumentParser(description="Fetch OMA orthologs of a protein by ID.")
    parser.add_argument(
        "-p",
        "--protein-id",
        required=True,
        help="Protein ID to query.",
    )
    args = parser.parse_args()

    oma = OmaClient()

    prot = oma.proteins[args.protein_id]

    if not prot.is_main_isoform:
        for isoform in prot.isoforms:
            if isoform.is_main_isoform:
                prot = oma.proteins[isoform.omaid]
                break

    for ortholog in prot.orthologs:
        print(f"{ortholog.canonicalid}")


if __name__ == "__main__":
    main()
