#!/usr/bin/env python3

# Written by Igor Trujnara, released under the MIT license
# See https://opensource.org/license/mit for details

"""Get the version of the OMA database and API."""

from omadb import Client as OmaClient


def main() -> None:
    client = OmaClient()
    version = client.version
    print(f"OMA Database: {version.oma_version}")
    print(f"OMA API: {version.api_version}")


if __name__ == "__main__":
    main()
