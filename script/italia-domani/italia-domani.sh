#!/bin/bash

# Impostazione delle opzioni di bash per una maggiore sicurezza
set -x # Stampa i comandi mentre vengono eseguiti
set -e # Esce se un comando fallisce
set -u # Esce se viene usata una variabile non definita
set -o pipefail # Esce se un comando in una pipeline fallisce

# Ottiene il percorso della directory dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea directory per i file temporanei
mkdir -p "$folder"/processing

# Directory contenente i dati grezzi
data="$folder/../../data/italia-domani/rawdata"

# Estrae il foglio "TC_Comuni" dal file Excel dei metadati
foglio="TC_Comuni"
qsv excel -s "$foglio" -Q "$data"/PNRR_Localizzazione_Metadati.xlsx > "$folder"/processing/italia-domani.csv

# Converte il file di localizzazione da Windows-1252 a UTF-8 e rimuove i caratteri di fine riga Windows
iconv -f windows-1252 -t utf-8 < "$data"/PNRR_Localizzazione-Dati_Validati.csv >"$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv
dos2unix "$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv

# Genera il codice ISTAT completo combinando codice provincia e comune
mlrgo -I --csv --ifs ";" put 'if(${Codice Comune}!="0"){$COD_ISTAT_COMUNE=fmtnum(${Codice Provincia},"%03d").fmtnum(${Codice Comune},"%03d")}else{$COD_ISTAT_COMUNE=""}' "$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv

# Sposta il file elaborato nella directory dei dati
mv "$folder"/processing/PNRR_Localizzazione-Dati_Validati.csv "$data"/../PNRR_Localizzazione-Dati_Validati.csv

# Pulisce gli spazi bianchi in tutti i file CSV tranne quello appena elaborato
find "$data" -type f -name "*.csv" -not -name "PNRR_Localizzazione-Dati_Validati.csv"  -print0 | while IFS= read -r -d '' file; do
  name=$(basename "$file" .csv)
  mlrgo --csv --ifs ";" clean-whitespace "$file" >"$data"/../"$name".csv
done

