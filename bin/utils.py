# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details
# Includes code written by UniProt contributors published under CC-BY 4.0 license

import sys
import time
from typing import Any

import requests

POLLING_INTERVAL = 0.5

def safe_get(url: str):
    """
    Get a URL and return the response.
    """
    try:
        return requests.get(url, timeout = 300)
    except requests.exceptions.Timeout as e:
        print(f"Request timed out. This might be due to a server issue. If this persists, try again later. Details:\n{e}", file=sys.stderr)
        sys.exit(10)
    except requests.exceptions.RequestException as e:
        print(f"A network issue occurred. Retrying request. Details:\n{e}", file=sys.stderr)
        sys.exit(10)


def safe_post(url: str, data: dict = dict(), json: dict = dict()):
    """
    Post data to a URL and return the response.
    """
    try:
        return requests.post(url, data = data, json = json, timeout = 300)
    except requests.exceptions.Timeout as e:
        print(f"Request timed out. This might be due to a server issue. If this persists, try again later. Details:\n{e}", file=sys.stderr)
        sys.exit(10)
    except requests.exceptions.RequestException as e:
        print(f"A network issue occurred. Retrying request. Details:\n{e}", file=sys.stderr)
        sys.exit(10)


def check_id_mapping_results_ready(job_id):
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
