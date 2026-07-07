#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch members of a Panther group by ID."""

import os
import argparse
import subprocess
import sys
from warnings import warn

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import safe_get, handle_http_response # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch members of a Panther group by ID."
    )
    parser.add_argument(
        "-i",
        "--input-id",
        required=True,
        help="Input UniProt ID used for the Panther ortholog query.",
    )
    parser.add_argument(
        "-o",
        "--organism",
        required=True,
        help="Organism taxonomy identifier for the Panther query.",
    )
    args = parser.parse_args()

    url = f"https://www.pantherdb.org/services/oai/pantherdb/ortholog/matchortho?geneInputList={args.input_id}&organism={args.organism}&orthologType=all"
    def request():
        return safe_get(url)

    res = request()
    json = handle_http_response(res, retry_method=request)

    try:
        for i in json["search"]["mapping"]["mapped"]:
            uniprot_id = i["target_gene"].split("|")[-1].split("=")[-1]
            print(f"{uniprot_id}")
    except KeyError:
        warn("No results found")
        pass # yes, I mean this, we just want to return an empty file if nothing is found

    try:
        print(f"{json['search']['product']['content']} {json['search']['product']['version']}", file="panther_version.txt")
    except KeyError:
        print("error", file="panther_version.txt")

if __name__ == "__main__":
    main()
