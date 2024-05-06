#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

import requests


def main() -> None:
    """
    Fetch members of a Panther group by ID.
    """
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: fetch_panther_group.py <id> <organism>")

    res = requests.get(f"https://www.pantherdb.org/services/oai/pantherdb/ortholog/matchortho?geneInputList={sys.argv[1]}&organism={sys.argv[2]}&orthologType=all")

    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    json = res.json()
    for i in json["search"]["mapping"]["mapped"]:
        uniprot_id = i["target_gene"].split("|")[-1].split("=")[-1]
        print(f"{uniprot_id}")
    print(f"{json['search']['product']['content']} {json['search']['product']['version']}", file=sys.stderr)

if __name__ == "__main__":
    main()
