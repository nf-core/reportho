#!/usr/bin/env python3

from typing import Any
import requests
import sys

def fetch_seq(url: str):
    res = requests.get(url)
    if not res.ok:
        print(f"HTTP error. Code: {res.status_code}")
        return (False, dict())
    json: dict[str, Any] = res.json()
    return (True, json)


def main() -> None:
    if len(sys.argv) < 2:
        raise ValueError("Not enough arguments. Usage: fetch_oma_groupid.py [filename]")

    prot_id = sys.argv[1]
    success, json = fetch_seq(f"https://omabrowser.org/api/protein/{prot_id}")

    if not success:
        raise ValueError("Fetch failed, aborting")

    entry: dict = dict()
    if json["is_main_isoform"]:
        entry = json

    if entry == dict():
        if len(json["alternative_isoforms_urls"]) > 0:
            isoform = json["alternative_isoforms_urls"][0]
            success, json = fetch_seq(isoform)
            if not success:
                raise ValueError("Isoform fetch failed, aborting")
            if json["is_main_isoform"]:
                entry = json
            else:
                raise ValueError("Isoform not found")
    print(entry['oma_group'])


if __name__ == "__main__":
    main()
