#!/usr/bin/env python3

import os
import sys
from datetime import datetime
from pathlib import Path

import requests


def download(destination: Path, group: str, prefix: str) -> None:
    now = datetime.now()
    year = now.year
    month = now.month

    # Find the most recent version of this ZIM file
    while True:
        if requests.head(
            f"https://download.kiwix.org/zim/{group}/{prefix}_{year}-{month:02}.zim"
        ).ok:
            break

        month -= 1
        if month == 0:
            month = 12
            year -= 1

        if year <= 2010:
            raise RuntimeError(f"File {group}/{prefix} not found on server after 2010")

    url = f"https://download.kiwix.org/zim/{group}/{prefix}_{year}-{month:02}.zim"
    local_filename = destination / f"{prefix}_{year}-{month:02}.zim"

    if os.path.exists(local_filename):
        print(f"File {local_filename} already exists")
        return

    print(f"Downloading {url}")
    with requests.get(url, stream=True) as r:
        r.raise_for_status()

        with open(local_filename, "wb") as f:
            for chunk in r.iter_content(chunk_size=8192):
                f.write(chunk)

    print(f"Finished downloading {url}")


def main() -> None:
    destination = Path(sys.argv[1])
    files = sys.argv[2:]

    for file in files:
        group, prefix = file.split("/", 1)
        download(destination, group, prefix)


if __name__ == "__main__":
    main()
