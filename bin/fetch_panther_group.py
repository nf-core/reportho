#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from utils import safe_get


def main() -> None:
    """
    Fetch members of a Panther group by ID.
    """
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: fetch_panther_group.py <id> <organism>")

    res = safe_get(f"https://www.pantherdb.org/services/oai/pantherdb/ortholog/matchortho?geneInputList={sys.argv[1]}&organism={sys.argv[2]}&orthologType=all")

    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    json = res.json()
    try:
        for i in json["search"]["mapping"]["mapped"]:
            uniprot_id = i["target_gene"].split("|")[-1].split("=")[-1]
            print(f"{uniprot_id}")
    except KeyError:
        pass # yes, I mean this, we just want to return an empty file if nothing is found

    try:
        print(f"{json['search']['product']['content']} {json['search']['product']['version']}", file=sys.stderr)
    except KeyError:
        print("error", file=sys.stderr)

if __name__ == "__main__":
    main()
