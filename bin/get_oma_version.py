#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Get the version of the OMA database and API."""

from utils import safe_get, handle_http_response


def main() -> None:
    headers = {"User-Agent": "pyomadb/2.1.0"}
    res = safe_get("https://omabrowser.org/api/version", headers=headers)
    retry, json = handle_http_response(res)
    if retry:
        res = safe_get("https://omabrowser.org/api/version", headers=headers)
        _, json = handle_http_response(res)
    print(f"    OMA Database: {json['oma_version']}")
    print(f"    OMA API: {json['api_version']}")


if __name__ == "__main__":
    main()
