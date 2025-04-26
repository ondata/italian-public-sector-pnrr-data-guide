#!/bin/bash

# Impostazione delle opzioni di bash per una maggiore sicurezza
set -x # Stampa i comandi mentre vengono eseguiti
set -e # Esce se un comando fallisce
set -u # Esce se viene usata una variabile non definita
set -o pipefail # Esce se un comando in una pipeline fallisce

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea le directory necessarie
mkdir -p "${folder}/tmp"
mkdir -p "${folder}/../../data/italia-domani/parquet"

# Configura pulizia del file temporaneo in caso di interruzione
trap "rm -f '${folder}/tmp/tmp.csv'" EXIT

# Elabora solo i CSV nella versione corrente (esclude versioni precedenti)
<"${folder}/lista.txt" grep '.csv' | grep -vP "(_v|\d)" | while IFS= read -r url; do
    nome=$(basename "${url}" .csv | tr ' ' '_')

    # Verifica se il file Parquet non esiste già
    if [ ! -f "${folder}/../../data/italia-domani/parquet/${nome}.parquet" ]; then

        # Scarica il file CSV
        curl -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
            -skL "${url}" >"${folder}/tmp/tmp.csv"

        # Gestione speciale per PNRR_Soggetti: filtra righe con 12 campi
        if [[ "${nome}" == "PNRR_Soggetti" ]]; then
            awk -F';' 'NR == 1 || NF == 12 {print}' "${folder}/tmp/tmp.csv" >"${folder}/tmp/tmp_ok.csv"
            mv "${folder}/tmp/tmp_ok.csv" "${folder}/tmp/tmp.csv"
        fi

        # Rileva e gestisce la codifica del file
        charset=$(chardetect --minimal "${folder}/tmp/tmp.csv" | tr '[:lower:]' '[:upper:]')

        # Gestione speciale per codifica MACROMAN
        if [[ "${charset}" == "MACROMAN" ]]; then
            charset="ISO-8859-1"
        fi

        # Conversione in UTF-8 se necessario
        if [[ -z "${charset}" ]]; then
            echo "Errore: impossibile rilevare la codifica di ${url}" >&2
            continue
        elif [[ "${charset}" != "UTF-8" && "${charset}" != "UTF-8-SIG" ]]; then
            mv "${folder}/tmp/tmp.csv" "${folder}/tmp/tmp_original.csv"
            iconv -f "${charset}" -t UTF-8 "${folder}/tmp/tmp_original.csv" -o "${folder}/tmp/tmp.csv"
            rm -f "${folder}/tmp/tmp_original.csv"
        fi

        # Converte CSV in Parquet usando DuckDB con compressione ZSTD
        duckdb -c "COPY (SELECT * FROM read_csv_auto('${folder}/tmp/tmp.csv',decimal_separator=',',sample_size=-1,nullstr = ['N/A',''],dateformat='%d/%m/%Y')) TO '${folder}/../../data/italia-domani/parquet/${nome}.parquet' (FORMAT 'parquet', CODEC 'ZSTD')"
    fi
done

# Rimuove il file temporaneo
rm -f "${folder}/tmp/tmp.csv"
