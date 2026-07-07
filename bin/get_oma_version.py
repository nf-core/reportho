#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Get the version of the OMA database and API."""

from utils import safe_get, handle_http_response


def main() -> None:
    headers = {"User-Agent": "pyomadb/2.1.0"}
    def request_version():
        return safe_get("https://omabrowser.org/api/version", headers=headers)

    res = request_version()
    json = handle_http_response(res, retry_method=request_version)
    print(f"    OMA Database: {json['oma_version']}")
    print(f"    OMA API: {json['api_version']}")


if __name__ == "__main__":
    main()
