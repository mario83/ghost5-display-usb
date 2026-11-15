#!/bin/bash
# Host-side setup for Ghost5 display-over-USB spinoff (run on the Pi).
set -euo pipefail
FB5="$HOME/FB5-display-usb"
CFG="$HOME/printer_data/config"

echo "FB5_PRINT_RATE=32" > "$FB5/fb5.conf"
echo "FB5_CAMERA_AREA=0.4" >> "$FB5/fb5.conf"

# Patch install.sh copy to allow USB serial
cp "$FB5/install.sh" "$FB5/install-usb.sh"
python3 - <<'PY'
from pathlib import Path
p = Path.home() / "FB5-display-usb/install-usb.sh"
t = p.read_text()
old = '        *usb*|*USB*|*ACM*) fail "[mcu] serial: $serial - this project needs the Pi UART (GPIO14/15) wired to the board Wi-Fi header, see README";;'
new = '        *usb*|*USB*|*ACM*|*by-id*) ok "[mcu] serial: $serial (USB CH340 spinoff)";;'
if old not in t:
    raise SystemExit("USB fail line not found in install-usb.sh")
p.write_text(t.replace(old, new, 1))
print("patched install-usb.sh")
PY

# Packages WITHOUT arm toolchain (Mac builds firmware)
APT_PKGS="git curl make python3-numpy python3-pil python3-serial python3-venv xvfb xdotool libxtst6 libgirepository1.0-dev gcc libcairo2-dev pkg-config python3-dev gir1.2-gtk-3.0 fonts-nanum libmpv-dev librsvg2-common libopenjp2-7 libdbus-glib-1-dev autoconf build-essential cmake libsystemd-dev"
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y $APT_PKGS

# KlipperScreen
KS_DIR="$HOME/KlipperScreen"
KS_ENV="$HOME/.KlipperScreen-env"
if [ ! -d "$KS_DIR/.git" ]; then
  git clone --depth 1 https://github.com/KlipperScreen/KlipperScreen.git "$KS_DIR"
fi
if [ ! -x "$KS_ENV/bin/python" ]; then
  python3 -m venv "$KS_ENV"
fi
"$KS_ENV/bin/pip" install -U pip setuptools wheel
"$KS_ENV/bin/pip" install -r "$KS_DIR/scripts/KlipperScreen-requirements.txt"
"$KS_ENV/bin/python" -c 'import gi; gi.require_version("Gtk", "3.0"); from gi.repository import Gtk; print("GTK OK")'

# Optional camera panel patch
python3 "$FB5/scripts/patch_ks_camera.py" "$KS_DIR/panels/camera.py" || true

# Ensure fb5-display.cfg present
cp -f "$FB5/config/fb5-display.cfg" "$CFG/fb5-display.cfg"

# Helper: enable display include + baud after MCU flash
cat > "$HOME/enable-display-usb.sh" <<'EOS'
#!/bin/bash
set -e
CFG="$HOME/printer_data/config/printer.cfg"
python3 - <<'PY'
from pathlib import Path
p = Path.home() / "printer_data/config/printer.cfg"
t = p.read_text()
if "[include fb5-display.cfg]" not in t:
    t = "[include fb5-display.cfg]\n\n" + t
# ensure baud line under [mcu]
lines = t.splitlines()
out = []
in_mcu = False
have_baud = False
for i, line in enumerate(lines):
    if line.strip() == "[mcu]":
        in_mcu = True
        out.append(line)
        continue
    if in_mcu and line.startswith("["):
        if not have_baud:
            out.append("baud: 250000")
        in_mcu = False
    if in_mcu and line.strip().startswith("baud:"):
        out.append("baud: 250000")
        have_baud = True
        continue
    out.append(line)
if in_mcu and not have_baud:
    out.append("baud: 250000")
p.write_text("\n".join(out) + "\n")
print("printer.cfg updated with fb5-display + baud 250000")
PY
sudo systemctl restart klipper
echo "Restarted klipper. Check Mainsail / screen backlight."
EOS
chmod +x "$HOME/enable-display-usb.sh"

df -h /
echo "HOST SETUP DONE"
