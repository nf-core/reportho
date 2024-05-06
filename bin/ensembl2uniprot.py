#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

import requests
from utils import check_id_mapping_results_ready


def ensembl2uniprot(ensembl_ids: list[str]) -> list[str]:
    """
    Convert a list of Ensembl IDs to UniProt IDs using the UniProt mapping API.
    """
    if len(ensembl_ids) == 0:
        return []

    payload = {
        "ids": ensembl_ids,
        "from": "Ensembl",
        "to": "UniProtKB"
    }

    res = requests.post("https://rest.uniprot.org/idmapping/run", data=payload)
    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    job_id = res.json()["jobId"]

    # wait for the job to finish
    check_id_mapping_results_ready(job_id)

    res = requests.get(f"https://rest.uniprot.org/idmapping/results/{job_id}")

    json = res.json()

    mapped_ids = [i["from"] for i in json["results"] if len(i["to"]) > 0]
    unmapped_ids = [i for i in ensembl_ids if i not in mapped_ids]
    hits = [i["to"] for i in json["results"] if len(i["to"]) > 0]

    return hits + unmapped_ids


def main() -> None:
    # note: this script is mostly not intended to be used in the command line
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: ensembl2uniprot.py <id>")

    print(ensembl2uniprot([sys.argv[1]]))

if __name__ == "__main__":
    main()
