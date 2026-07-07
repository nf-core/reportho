#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Fetch members of an OMA group by ID."""

import os
import argparse
import subprocess
import sys
from warnings import warn

bin_dir = os.path.dirname(os.path.realpath(subprocess.check_output(
    ['which', 'utils.py'], text=True).strip()))
sys.path.insert(0, bin_dir)

from utils import safe_get, handle_http_response


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Fetch members of an OMA group by ID."
    )
    parser.add_argument(
        "-g",
        "--group-id",
        required=True,
        help="OMA group ID to query.",
    )
    args = parser.parse_args()

    id = args.group_id
    headers = {"User-Agent": "pyomadb/2.1.0"}

    def request():
        return safe_get(f"https://omabrowser.org/api/group/{id}", headers=headers)

    res = request()
    json = handle_http_response(res, retry_method=request)

    if json == dict():
        warn("ID not found")
        return

    for member in json["members"]:
        print(f"{member['canonicalid']}")


if __name__ == "__main__":
    main()
