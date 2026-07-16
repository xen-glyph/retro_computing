#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "This installer currently supports Linux only." >&2
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required." >&2
    exit 1
fi

if ! python3 -c "import requests" >/dev/null 2>&1; then
    echo "Python package 'requests' is missing."
    echo "On Debian/Ubuntu/Raspberry Pi OS: sudo apt install python3-requests"
    exit 1
fi

if ! command -v lp >/dev/null 2>&1; then
    echo "The CUPS 'lp' command is missing."
    echo "On Debian/Ubuntu/Raspberry Pi OS: sudo apt install cups-client"
    exit 1
fi

sudo install -m 0755 weather-fax /usr/local/bin/weather-fax

echo
echo "Installed: /usr/local/bin/weather-fax"
echo "Run 'weather-fax' to configure your ZIP code."
echo "Example systemd files are available in ./systemd/"
