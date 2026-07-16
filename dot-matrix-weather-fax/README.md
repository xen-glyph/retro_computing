# Dot Matrix Weather Fax

A Linux command-line utility that retrieves current weather information from
the United States National Weather Service, formats it as a compact one-page
plain-text bulletin, and optionally prints it through the system's default
CUPS printer.

The project began on a Raspberry Pi connected to an OKI Microline 321 Turbo,
but it is intentionally printer-agnostic. Panasonic, Epson, Star, Citizen,
IBM, OKI, line printers, laser printers, and other CUPS-supported devices can
all be used.

The main design rule is simple: **send text to a text printer**. The program
does not render the report as a PNG or PDF. This allows impact printers to use
their resident character generator, producing cleaner, faster, more readable
output.

## Features

- Interactive setup using a United States ZIP code
- Current conditions from a nearby NWS observation station
- Active watches, warnings, and advisories
- Five-day daytime outlook
- Detailed forecasts for the next two periods
- Area Forecast Discussion key messages and short-term discussion
- Automatic trimming to preserve a one-page report
- Plain-text output optimized for approximately 78 columns
- Generate-only and generate-and-print modes
- Optional automatic printing with a systemd timer
- No hard-coded printer model or queue name

## Example

```text
——————————————————————————————————————————————————————————————————————————————
                           WEATHER FAX
                  Meridian, ID | ZIP 83642 | NWS BOI
——————————————————————————————————————————————————————————————————————————————

Generated: Thursday, July 16, 2026 | 08:00 MDT

CURRENT CONDITIONS
——————————————————————————————————————————————————————————————————————————————
Temperature  70 F                           | Clear
Dew Point    54 F                           | Humidity 56%
Wind         ESE 25 mph                     | Pressure 29.90 inHg
Visibility   10.0 mi                        | Station KMAN
```

A complete sample is included in `examples/sample-weather-fax.txt`.

## Platform and coverage

This release is intended for:

- Linux
- Python 3.10 or newer
- CUPS
- A configured default printer
- United States locations

The program currently uses:

- `api.weather.gov` for NWS forecasts, observations, alerts, and AFD products
- `api.zippopotam.us` to resolve a US ZIP code to latitude and longitude

It does not currently support non-US postal codes or non-NWS weather services.

## Dependencies

Debian, Ubuntu, Raspberry Pi OS, Linux Mint:

```bash
sudo apt update
sudo apt install python3 python3-requests cups-client
```

Fedora:

```bash
sudo dnf install python3 python3-requests cups-client
```

Arch Linux:

```bash
sudo pacman -S python python-requests cups
```

The Python dependency is also listed in `requirements.txt`.

## Printer setup

Configure the printer in CUPS before installing this program. Confirm that a
default printer exists:

```bash
lpstat -p
lpstat -d
```

Print a basic test:

```bash
printf "Native text printer test\n" | lp
```

The utility deliberately calls `lp` without a queue name, so it uses the
system's default printer. To change the default:

```bash
lpoptions -d YOUR_QUEUE_NAME
```

## Installation

Clone or download the repository:

```bash
git clone https://github.com/xen-glyph/dot-matrix-weather-fax.git
cd dot-matrix-weather-fax
```

Install dependencies and the executable:

```bash
sudo apt install python3 python3-requests cups-client
sudo install -m 0755 weather-fax /usr/local/bin/weather-fax
```

Or run the included installer:

```bash
chmod +x install.sh
./install.sh
```

## First run

Launch the interactive menu:

```bash
weather-fax
```

Choose **Set / Change Location**, enter a five-digit US ZIP code, and then
generate a report.

The user-specific configuration is stored at:

```text
~/.config/dot-matrix-weather-fax/config.json
```

Do not commit this file to GitHub if it contains your home ZIP code or
coordinates.

## Usage

Interactive menu:

```bash
weather-fax
```

Generate without printing:

```bash
weather-fax --generate
```

Generate and print through the default CUPS printer:

```bash
weather-fax --print
```

Show the version:

```bash
weather-fax --version
```

Generated reports are written to:

```text
/tmp/dot-matrix-weather-fax/weather-fax.txt
```

Inspect the report:

```bash
cat /tmp/dot-matrix-weather-fax/weather-fax.txt
```

Check the page length:

```bash
wc -l /tmp/dot-matrix-weather-fax/weather-fax.txt
```

## Automatic daily printing with systemd

Example unit files are included under `systemd/`.

Copy them:

```bash
sudo cp systemd/weather-fax.service /etc/systemd/system/
sudo cp systemd/weather-fax.timer /etc/systemd/system/
```

Edit the service:

```bash
sudo nano /etc/systemd/system/weather-fax.service
```

Replace every instance of `YOUR_USERNAME` with the Linux account that owns the
weather-fax configuration.

The included timer prints daily at 8:00 AM. Change this line to select another
time:

```ini
OnCalendar=*-*-* 08:00:00
```

Then enable the timer:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now weather-fax.timer
```

Confirm the next run:

```bash
systemctl status weather-fax.timer
systemctl list-timers weather-fax.timer
```

View service logs:

```bash
journalctl -u weather-fax.service --since today
```

Run the scheduled service immediately for testing:

```bash
sudo systemctl start weather-fax.service
```

**That command will print immediately** if the printer is online.

## Text encoding and separators

The report uses Unicode em dashes for horizontal separators because they
produce a clean line on many printers. The systemd service sets `LANG=C.UTF-8`.

Some older printer drivers or resident character sets may not support the em
dash. In that case, change this line near the top of `weather-fax`:

```python
RULE = "—" * WIDTH
```

to:

```python
RULE = "-" * WIDTH
```

## NWS User-Agent

The National Weather Service asks API clients to identify themselves. The
default identifies this GitHub project. You can override it with an
environment variable:

```bash
export WEATHER_FAX_USER_AGENT="my-weather-fax/1.0 (you@example.com)"
weather-fax --generate
```

For systemd, add this under `[Service]`:

```ini
Environment=WEATHER_FAX_USER_AGENT=my-weather-fax/1.0 (you@example.com)
```

## Troubleshooting

Check the printer and queue:

```bash
lpstat -t
```

Check pending jobs:

```bash
lpstat -o
```

Restart CUPS:

```bash
sudo systemctl restart cups
```

Cancel all jobs on a queue:

```bash
cancel -a YOUR_QUEUE_NAME
```

Generate without printing to isolate printer problems:

```bash
weather-fax --generate
```

Check the service log:

```bash
journalctl -u weather-fax.service -n 100 --no-pager
```

## Privacy

The configuration contains the selected ZIP code and approximate coordinates.
It remains under the user's home directory and is not transmitted anywhere
except to the public weather and ZIP lookup APIs needed to generate the
report.

## Weather safety

This project is for personal informational use. Do not rely on it as your only
source of hazardous-weather information. Always follow official National
Weather Service alerts and instructions from local authorities.

## License

MIT License. See `LICENSE`.

## Author

Created by Caleb Moose.

GitHub: [xen-glyph](https://github.com/xen-glyph)
