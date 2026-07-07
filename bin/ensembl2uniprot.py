#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Convert Ensembl IDs to UniProt IDs using the UniProt mapping API."""

import argparse

from utils import check_id_mapping_results_ready, handle_http_request


def ensembl2uniprot(ensembl_ids: list[str]) -> list[str]:
    """Convert a list of Ensembl IDs to UniProt IDs using the UniProt mapping API."""
    if len(ensembl_ids) == 0:
        return []

    payload = {"ids": ensembl_ids, "from": "Ensembl", "to": "UniProtKB"}

    json = handle_http_request("https://rest.uniprot.org/idmapping/run", method="POST", data=payload)

    job_id = json["jobId"]

    # wait for the job to finish
    check_id_mapping_results_ready(job_id)

    json = handle_http_request(f"https://rest.uniprot.org/idmapping/results/{job_id}")

    mapped_ids = [i["from"] for i in json["results"] if len(i["to"]) > 0]
    unmapped_ids = [i for i in ensembl_ids if i not in mapped_ids]
    hits = [i["to"] for i in json["results"] if len(i["to"]) > 0]

    return hits + unmapped_ids


def main() -> None:
    parser = argparse.ArgumentParser(description="Convert Ensembl IDs to UniProt IDs using the UniProt mapping API.")
    parser.add_argument(
        "-i",
        "--id",
        required=True,
        help="Ensembl ID to convert.",
    )
    args = parser.parse_args()

    print(ensembl2uniprot([args.id]))


if __name__ == "__main__":
    main()
