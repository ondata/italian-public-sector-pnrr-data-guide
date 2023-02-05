#!/bin/bash

set -x
set -e
set -u
set -o pipefail

# variabile con il percorso assoluto della cartella dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# crea le cartelle di output
mkdir -p "$folder"/../../data/messina/rawdata/cig
mkdir -p "$folder"/../../data/messina/cig

# per ogni CIG estratto, interroga l'API di ANAC e salva il file jsonl
while IFS="" read -r line; do
  if [ ! -f "$folder"/../../data/messina/rawdata/cig/"$line".jsonl ]; then
    curl -kL "https://api.anticorruzione.it/apicig/1.0.0/getSmartCig/$line" >"$folder"/../../data/messina/rawdata/cig/"$line".jsonl
  fi
done <"$folder"/../../data/messina/anac-cup-cig-083048-cig.csv

# unisci tutti i file jsonl in un unico file json
if [ ! -f "$folder"/../../data/messina/anac-cig.json ]; then
  mlrgo --ijsonl --ojson --no-jvstack  cat "$folder"/../../data/messina/rawdata/cig/*.jsonl >"$folder"/../../data/messina/anac-cig.json
fi

# estrai dal file JSON, le tabelle in esseo contenute in formato CSV
flatterer --force "$folder"/../../data/messina/anac-cig.json "$folder"/../../data/messina/cig
