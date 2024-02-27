#!/usr/bin/env python3

import requests
import sys

def main() -> None:
    if len(sys.argv) < 3:
        raise ValueError("Too few arguments. Usage: fetch_panther_group.py [id] [organism]")

    res = requests.get(f"https://www.pantherdb.org/services/oai/pantherdb/ortholog/matchortho?geneInputList={sys.argv[1]}&organism={sys.argv[2]}&orthologType=all")

    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    json = res.json()
    for i in json["search"]["mapping"]["mapped"]:
        uniprot_id = i["target_gene"].split("|")[-1].split("=")[-1]
        print(f"{uniprot_id}")

if __name__ == "__main__":
    main()
