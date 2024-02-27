#!/usr/bin/env python3

import requests
import sys

def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: fetch_oma_group_by_id.py [id]")

    id = sys.argv[1]

    res = requests.get(f"https://omabrowser.org/api/group/{id}")

    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    json = res.json()
    for member in json["members"]:
        print(f"{member['canonicalid']}")

if __name__ == "__main__":
    main()
