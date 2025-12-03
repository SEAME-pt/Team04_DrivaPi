#!/bin/bash
docker run -d --name kuksa-databroker \
  -p 55555:55555 \
  -v $(pwd)/config/vss/drivapi.vss.json:/etc/kuksa/drivapi.vss.json \
  ghcr.io/eclipse-kuksa/kuksa-databroker:master \
  --metadata /etc/kuksa/drivapi.vss.json
