#!/usr/bin/env python3

import sys

import requests
from utils import check_id_mapping_results_ready


def refseq2uniprot(refseq_ids: list[str]) -> list[str]:
    """
    Map a list of RefSeq IDs to UniProt IDs using the UniProt mapping API.
    """
    if len(refseq_ids) == 0:
        return []

    payload = {
        "ids": refseq_ids,
        "from": "RefSeq_Protein",
        "to": "UniProtKB"
    }

    res = requests.post("https://rest.uniprot.org/idmapping/run", data=payload)
    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    job_id = res.json()["jobId"]

    check_id_mapping_results_ready(job_id)

    res = requests.get(f"https://rest.uniprot.org/idmapping/results/{job_id}")

    json = res.json()

    mapped_ids = [i["from"] for i in json["results"] if len(i["to"]) > 0]
    unmapped_ids = [i for i in refseq_ids if i not in mapped_ids]
    hits = [i["to"] for i in json["results"] if len(i["to"]) > 0]

    return hits + unmapped_ids

def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: refseq2uniprot.py [id]")

    print(refseq2uniprot([sys.argv[1]]))

if __name__ == "__main__":
    main()
