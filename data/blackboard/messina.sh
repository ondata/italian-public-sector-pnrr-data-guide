#!/bin/bash

set -x
set -e
set -u
set -o pipefail

# variabile con il percorso assoluto della cartella dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# crea le cartelle di output
mkdir -p "$folder"/rawdata/cig
mkdir -p "$folder"/cig

# per ogni CIG estratto, interroga l'API di ANAC e salva il file jsonl
while IFS="" read -r line; do
  if [ ! -f "$folder"/rawdata/cig/"$line".jsonl ]; then
    curl -kL "https://api.anticorruzione.it/apicig/1.0.0/getSmartCig/$line" >"$folder"/rawdata/cig/"$line".jsonl
  fi
done <"$folder"/anac-cup-cig-083048-cig.csv

# unisci tutti i file jsonl in un unico file json
if [ ! -f "$folder"/anac-cig.json ]; then
  mlrgo --ijsonl --ojson --no-jvstack  cat "$folder"/rawdata/cig/*.jsonl >"$folder"/anac-cig.json
fi

# estrai dal file JSON, le tabelle in esseo contenute in formato CSV
flatterer --force "$folder"/anac-cig.json "$folder"/cig
