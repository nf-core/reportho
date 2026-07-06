#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch orthologs for a given UniProt ID from the OrthoInspector database."""

import os
import argparse
import subprocess
import sys

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import safe_get, handle_http_response # noqa: E402


def fetch_inspector_by_id(uniprot_id: str, db_id: str = "Eukaryota2019") -> None:
    """Fetch orthologs for a given UniProt ID from the OrthoInspector database."""
    url = f"https://lbgi.fr/api/orthoinspector/{db_id}/protein/{uniprot_id}/orthologs"
    res = safe_get(url)

    retry, json = handle_http_response(res)
    if retry:
        res = safe_get(url)
        _, json = handle_http_response(res)

    orthologs = set()

    for i in json["data"]:
        for j in i["orthologs"]:
            orthologs.add(j)

    print("\n".join(orthologs))


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch orthologs for a given UniProt ID from the OrthoInspector database."
    )
    parser.add_argument(
        "-i",
        "--uniprot-id",
        required=True,
        help="UniProt ID of the query protein.",
    )
    parser.add_argument(
        "-d",
        "--db-id",
        required=True,
        help="OrthoInspector database version identifier.",
    )
    args = parser.parse_args()

    fetch_inspector_by_id(args.uniprot_id, args.db_id)


if __name__ == "__main__":
    main()
