import time
from typing import Any

import requests

POLLING_INTERVAL = 0.5

def check_id_mapping_results_ready(job_id):
    """
    Wait until the ID mapping job is finished.
    """
    while True:
        request = requests.get(f"https://rest.uniprot.org/idmapping/status/{job_id}")
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
    res = requests.get(url)
    if not res.ok:
        print(f"HTTP error. Code: {res.status_code}")
        return (False, dict())
    json: dict[str, Any] = res.json()
    return (True, json)
