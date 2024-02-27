#!/usr/bin/env python3

import requests
from utils import check_id_mapping_results_ready
import sys

def uniprot2uniprot(uniprot_names: list[str]) -> list[str]:
    if len(uniprot_names) == 0:
        return []

    payload = {
        "ids": uniprot_names,
        "from": "UniProtKB_AC-ID",
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
    unmapped_ids = [i for i in uniprot_names if i not in mapped_ids]
    hits = [i["to"] for i in json["results"] if len(i["to"]) > 0]

    return hits + unmapped_ids

def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: uniprot2uniprot.py [id]")

    print(uniprot2uniprot([sys.argv[1]]))

if __name__ == "__main__":
    main()
