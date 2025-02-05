#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import requests


def main() -> None:
    headers = {"content-type": "application/json"}
    res = requests.get("https://rest.ensembl.org/info/species", headers = headers)

    for entry in res.json()["species"]:
        print(f"{entry['name']},{entry['taxon_id']}")


if __name__ == "__main__":
    main()
