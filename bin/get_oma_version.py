#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Get the version of the OMA database and API."""

from utils import handle_http_request


def main() -> None:
    headers = {"User-Agent": "pyomadb/2.1.0"}
    json = handle_http_request("https://omabrowser.org/api/version", headers=headers)
    print(f"    OMA Database: {json['oma_version']}")
    print(f"    OMA API: {json['api_version']}")


if __name__ == "__main__":
    main()
