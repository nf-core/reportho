import requests
import time

POLLING_INTERVAL = 0.5

def check_id_mapping_results_ready(job_id):
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
