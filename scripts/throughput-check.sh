#!/bin/bash
# Run on Pi after finish-after-flash.sh — baud/error smoke test.
set -e
echo "== printer state =="
curl -s http://127.0.0.1:7125/printer/info | python3 -c 'import sys,json; r=json.load(sys.stdin)["result"]; print(r["state"], r.get("state_message","")[:80])'
echo "== fsmc objects =="
curl -s "http://127.0.0.1:7125/printer/objects/list" | python3 -c 'import sys,json; print([x for x in json.load(sys.stdin)["result"]["objects"] if "fsmc" in x])'
echo "== SERIAL_ERRORS =="
curl -s -X POST http://127.0.0.1:7125/printer/gcode/script -H 'Content-Type: application/json' -d '{"script":"SERIAL_ERRORS"}'
sleep 1
curl -s 'http://127.0.0.1:7125/server/gcode_store?count=15' | python3 -c 'import sys,json
for m in json.load(sys.stdin)["result"]["gcode_store"][-12:]:
 print(m["message"])'
echo "Baud target for CH340 spinoff: 500000 (fallback image: Robin_nano35-250k.bin @ 250000)."
