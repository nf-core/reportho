#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys

from utils import check_id_mapping_results_ready, safe_post, safe_get


def uniprot2uniprot(uniprot_names: list[str]) -> list[str]:
    """
    Map a list of UniProt names (e.g. BICD2_HUMAN) to UniProt IDs using the UniProt mapping API.
    """
    if len(uniprot_names) == 0:
        return []

    payload = {
        "ids": uniprot_names,
        "from": "UniProtKB_AC-ID",
        "to": "UniProtKB"
    }

    res = safe_post("https://rest.uniprot.org/idmapping/run", data=payload)
    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    job_id = res.json()["jobId"]

    check_id_mapping_results_ready(job_id)

    res = safe_get(f"https://rest.uniprot.org/idmapping/results/{job_id}")

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
