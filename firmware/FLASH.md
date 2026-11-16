# Flash firmware display USB (FSMC + USART3)

1. Copia `Robin_nano35.bin` (questa cartella) sulla SD FAT32 in root.
2. Spegnere stampante, SD nella scheda madre, accendere.
3. Attendi flash; file → `ROBIN_NANO35.CUR`.
4. Togli SD, USB al Pi, in Mainsail: Firmware Restart.

Build: Aregus fb5-native-display, USART3, FLASH 28KiB, WANT_FSMC_LCD.

| File | Baud | Note |
|------|------|------|
| `Robin_nano35.bin` | **2000000** | default (CH340 max) |
| `Robin_nano35-1M.bin` | 1000000 | fallback |
| `Robin_nano35-500k.bin` | 500000 | fallback |
| `Robin_nano35-250k.bin` | 250000 | fallback |

For any fallback: rename to `Robin_nano35.bin` on the SD before flash, and set matching `baud:` under `[mcu]` on the Pi.
