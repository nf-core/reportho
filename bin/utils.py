# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details
# Includes code written by UniProt contributors published under CC-BY 4.0 license

from collections import defaultdict as dd
from dataclasses import dataclass
import re
import sys
import time
from typing import Any

import requests

POLLING_INTERVAL = 0.5

def safe_get(url: str, **kwargs) -> requests.Response:
    """
    Get a URL and return the response.
    """
    try:
        return requests.get(url, timeout = 300, **kwargs)
    except requests.exceptions.Timeout as e:
        print(f"Request timed out. This might be due to a server issue. If this persists, try again later. Details:\n{e}", file=sys.stderr)
        sys.exit(10)
    except requests.exceptions.RequestException as e:
        print(f"A network issue occurred. Retrying request. Details:\n{e}", file=sys.stderr)
        sys.exit(10)


def safe_post(url: str, **kwargs) -> requests.Response:
    """
    Post data to a URL and return the response.
    """
    try:
        return requests.post(url, timeout = 300, **kwargs)
    except requests.exceptions.Timeout as e:
        print(f"Request timed out. This might be due to a server issue. If this persists, try again later. Details:\n{e}", file=sys.stderr)
        sys.exit(10)
    except requests.exceptions.RequestException as e:
        print(f"A network issue occurred. Retrying request. Details:\n{e}", file=sys.stderr)
        sys.exit(10)


def check_id_mapping_results_ready(job_id: str) -> bool:
    """
    Wait until the ID mapping job is finished.
    """
    while True:
        request = safe_get(f"https://rest.uniprot.org/idmapping/status/{job_id}")
        j = request.json()
        if "jobStatus" in j:
            if j["jobStatus"] == "RUNNING":
                time.sleep(POLLING_INTERVAL)
            else:
                # raise Exception(j["jobStatus"])
                pass
        else:
            return True


def fetch_seq(url: str) -> tuple[bool, dict]:
    """
    Get JSON from a URL.
    """
    res = safe_get(url)
    if not res.ok:
        print(f"HTTP error. Code: {res.status_code}")
        return (False, dict())
    json: dict[str, Any] = res.json()
    return (True, json)


def split_ids(ids: list[str], slice_size: int) -> list[list[str]]:
    """
    Split a list into chunks of given size. Useful for APIs with limited batch size.
    """
    slices = []
    for i in range(0, len(ids), slice_size):
        slices.append(ids[i:min(i + slice_size, len(ids))])
    return slices


def split_ids_by_format(ids: list[str]) -> dict[str, list[str]]:
    """
    Split protein IDs by database format.
    """
    ids_format = dd(list)

    for i in ids:
        if re.match(r"[OPQ][0-9][A-Z0-9]{3}[0-9]|[A-NR-Z][0-9]([A-Z][A-Z0-9]{2}[0-9]){1,2}", i):
            ids_format["uniprot"].append(i)
        elif re.match(r"ENS[A-Z]+\d{11}(\.\d+)?", i):
            ids_format["ensembl"].append(i)
        elif re.match(r"(AC|AP|NC|NG|NM|NP|NR|NT|NW|WP|XM|XP|XR|YP|ZP)_\d+", i):
            ids_format["refseq"].append(i)
        elif re.match(r"[A-Z]{5}[0-9]{5}"):
            ids_format["oma"].append(i)
        else:
            ids_format["unknown"].append(i)

    return ids_format


@dataclass
class SequenceInfo():
    """
    Information about a sequence for the fetching step.
    """
    prot_id: str
    taxid: str
    sequence: str

    def __str__(self):
        return f">{self.prot_id}|{self.taxid}\n{self.sequence}"
    
    def is_valid(self):
        return self.taxid is not None and self.sequence is not None
    

def list_to_file(items: list, path: str):
    """
    Print all elements of a list to a text file, one item per line.
    Warning: will overwrite the text file if it exists.
    """
    with open(path, 'w') as f:
        for i in items:
            f.write(i + '\n')
