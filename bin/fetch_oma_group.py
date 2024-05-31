#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

import sys
from warnings import warn
from utils import safe_get


def main() -> None:
    """
    Fetch members of an OMA group by ID.
    """
    if len(sys.argv) < 2:
        raise ValueError("Too few arguments. Usage: fetch_oma_group_by_id.py <id>")

    id = sys.argv[1]

    res = safe_get(f"https://omabrowser.org/api/group/{id}")

    if res.status_code == 404:
        warn("ID not found")
        return
    elif not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")

    json = res.json()
    for member in json["members"]:
        print(f"{member['canonicalid']}")

if __name__ == "__main__":
    main()
