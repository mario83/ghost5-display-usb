# Ghost 5 — native display over USB

KlipperScreen on the stock Flying Bear Ghost 5 panel (ILI9488 over FSMC), talking to a Raspberry Pi over the board **CH340 USB** link (USART3), based on [Aregus393/FB5-klipperscreen-for-native-display](https://github.com/Aregus393/FB5-klipperscreen-for-native-display).

License: **GPL-3.0** (same as Klipper / Aregus).

## What you get

| Path | Contents |
|------|----------|
| `firmware/` | Prebuilt `Robin_nano35.bin` (FSMC + USB, **500k**), optional `Robin_nano35-250k.bin`, Kconfig snapshot, `FLASH.md` |
| `config/fb5-display.cfg` | Display/touch include for `printer.cfg` |
| `scripts/` | Host setup and USB throughput check |

## Requirements

- Flying Bear Ghost 5 / Reborn V2.0 (STM32F103 “Robin nano”-class board with CH340)
- Raspberry Pi (3B tested) with Klipper + Moonraker/Mainsail
- [Aregus393/FB5-klipperscreen-for-native-display](https://github.com/Aregus393/FB5-klipperscreen-for-native-display) on the Pi (mirror / KlipperScreen helpers; use their `fb5-native-display` Klipper host)
- USB cable Pi ↔ board (serial `/dev/serial/by-id/…USB_Serial…`)
- FAT32 SD card for MCU flash

## Flash MCU (display + USB)

1. Copy `firmware/Robin_nano35.bin` to the SD card root as `Robin_nano35.bin`.
2. Power off the printer, insert the SD into the **mainboard** slot, power on.
3. After flash the file becomes `ROBIN_NANO35.CUR`. The panel may stay black until KlipperScreen starts.
4. Remove the SD. Connect USB between board and Pi.
5. On the Pi, enable the display include and baud, then start the UI (see below).

Default serial baud: **500000** (`firmware/Robin_nano35.bin`). If the link is unstable, flash `Robin_nano35-250k.bin` instead and set `baud: 250000` under `[mcu]`.

## Host setup (Pi)

```bash
# 1) Deploy Aregus FB5 tools + this repo’s config/scripts onto the Pi
#    (typical layout: ~/FB5-display-usb with install.sh, mirror, ks-start, etc.)

# 2) Packages, KlipperScreen, Xvfb helpers
bash scripts/pi-setup-host.sh

# 3) After MCU flash: include display cfg + baud 500000 and restart Klipper
~/enable-display-usb.sh   # created by pi-setup-host.sh

# 4) Start KlipperScreen + framebuffer mirror
~/FB5-display-usb/scripts/ks-start.sh
```

Optional autostart:

```cron
@reboot sleep 25 && /home/pi/FB5-display-usb/scripts/ks-start.sh >> /home/pi/FB5-display-usb/logs/ks-start.log 2>&1
```

On Pi 3B, keep the mirror load modest, e.g. `FB5_PRINT_RATE=32` in `~/FB5-display-usb/fb5.conf`.

Point `[mcu] serial:` at the CH340 `by-id` path and keep `baud:` in sync with the flashed firmware.

## Policy

- Do **not** update Klipper from Mainsail while using the Aregus `fb5-native-display` host fork — it will overwrite the fork.
- Keep `[mcu] baud:` matched to the flashed image (500000 default, or 250000 with the alternate bin).
- Screen blanking after idle is normal KlipperScreen behavior; disable with `screen_blanking: off` if you want the panel always on.

## Credits

- [Klipper](https://github.com/Klipper3d/klipper) (GPL-3.0)
- [Aregus393/FB5-klipperscreen-for-native-display](https://github.com/Aregus393/FB5-klipperscreen-for-native-display)
- [KlipperScreen](https://github.com/KlipperScreen/KlipperScreen)
