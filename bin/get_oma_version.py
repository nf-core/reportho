#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

from utils import safe_get


def main() -> None:
    """
    Get the version of the OMA database and API.
    """
    res = safe_get("https://omabrowser.org/api/version")
    if not res.ok:
        raise ValueError(f"HTTP error: {res.status_code}")
    json = res.json()
    print(f"    OMA Database: {json['oma_version']}")
    print(f"    OMA API: {json['api_version']}")


if __name__ == "__main__":
    main()
