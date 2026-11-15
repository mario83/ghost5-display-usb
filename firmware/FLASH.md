# Flash firmware display USB (FSMC + USART3)

1. Copia `Robin_nano35.bin` (questa cartella) sulla SD FAT32 in root.
2. Spegnere stampante, SD nella scheda madre, accendere.
3. Attendi flash; file → `ROBIN_NANO35.CUR`.
4. Togli SD, USB al Pi, in Mainsail: Firmware Restart.

Build: Aregus fb5-native-display, USART3, FLASH 28KiB, WANT_FSMC_LCD, baud default 250000.
