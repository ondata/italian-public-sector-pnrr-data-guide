#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing

data="$folder/../../data/italia-domani/rawdata"

foglio="TC_Comuni"
qsv excel -s "$foglio" -Q "$data"/PNRR_Localizzazione_Metadati.xlsx > "$folder"/processing/italia-domani.csv

# '$COD_ISTAT=fmtnum($COD_ISTAT,"%06d")'
# Codice Comune Codice Provincia
iconv -f windows-1252 -t utf-8 < "$data"/PNRR_Localizzazione-Dati_Validati.csv >"$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv
dos2unix "$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv
mlrgo -I --csv --ifs ";" put 'if(${Codice Comune}!="0"){$COD_ISTAT_COMUNE=fmtnum(${Codice Provincia},"%03d").fmtnum(${Codice Comune},"%03d")}else{$COD_ISTAT_COMUNE=""}' "$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv

mv "$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv "$data"/../PNRR_Localizzazione-Dati_Validati.csv

find "$data" -type f -name "*.csv" -not -name "PNRR_Localizzazione-Dati_Validati.csv"  -print0 | while IFS= read -r -d '' file; do
  name=$(basename "$file" .csv)
  mlrgo --csv --ifs ";" clean-whitespace "$file" >"$data"/../"$name".csv
done

