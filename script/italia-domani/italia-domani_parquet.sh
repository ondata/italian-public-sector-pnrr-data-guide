#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}/tmp"
mkdir -p "${folder}/../../data/italia-domani/parquet"

# Pulizia temporanea in caso di errore
trap "rm -f '${folder}/tmp/tmp.csv'" EXIT

# soltanto i CSV nella versione corrente
<"${folder}/lista.txt" grep '.csv' | grep -vP "(_v|\d)" | while IFS= read -r url; do
    nome=$(basename "${url}" .csv | tr ' ' '_')

    # se non esiste scarica il file
    if [ ! -f "${folder}/../../data/italia-domani/parquet/${nome}.parquet" ]; then

        # Scarica il file
        curl -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
            -skL "${url}" >"${folder}/tmp/tmp.csv"

        # se il nome del file è "PNRR_Soggetti" scrivi "evviva"
        if [[ "${nome}" == "PNRR_Soggetti" ]]; then
            awk -F';' 'NR == 1 || NF == 12 {print}' "${folder}/tmp/tmp.csv" >"${folder}/tmp/tmp_ok.csv"
            mv "${folder}/tmp/tmp_ok.csv" "${folder}/tmp/tmp.csv"
        fi

        # Controlla la codifica del file
        charset=$(chardetect --minimal "${folder}/tmp/tmp.csv" | tr '[:lower:]' '[:upper:]')

        # Se MACROMAN, modificalo in ISO-8859-1
        if [[ "${charset}" == "MACROMAN" ]]; then
            charset="ISO-8859-1"
        fi

        # Verifica e converte in UTF-8 se necessario
        if [[ -z "${charset}" ]]; then
            echo "Errore: impossibile rilevare la codifica di ${url}" >&2
            continue
        elif [[ "${charset}" != "UTF-8" && "${charset}" != "UTF-8-SIG" ]]; then
            mv "${folder}/tmp/tmp.csv" "${folder}/tmp/tmp_original.csv"
            iconv -f "${charset}" -t UTF-8 "${folder}/tmp/tmp_original.csv" -o "${folder}/tmp/tmp.csv"
            rm -f "${folder}/tmp/tmp_original.csv"
        fi

        # Converte il file CSV in Parquet
        duckdb -c "COPY (SELECT * FROM read_csv_auto('${folder}/tmp/tmp.csv',decimal_separator=',',sample_size=-1)) TO '${folder}/../../data/italia-domani/parquet/${nome}.parquet' (FORMAT 'parquet', CODEC 'ZSTD')"
    fi

done

# Pulizia finale del file temporaneo
rm -f "${folder}/tmp/tmp.csv"
