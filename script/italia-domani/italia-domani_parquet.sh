#!/bin/bash

# Impostazione delle opzioni di bash per una maggiore sicurezza
set -x # Stampa i comandi mentre vengono eseguiti
set -e # Esce se un comando fallisce
set -u # Esce se viene usata una variabile non definita
set -o pipefail # Esce se un comando in una pipeline fallisce

# Gestione parametri
FORCE=0
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE=1
            shift
            ;;
    esac
done

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea le directory necessarie
mkdir -p "${folder}"/tmp
mkdir -p "${folder}"/../../data/italia-domani/parquet

# Configura pulizia del file temporaneo in caso di interruzione
trap "rm -f '${folder}/tmp/tmp.csv'" EXIT

# Elabora solo i CSV nella versione corrente (esclude versioni precedenti)
<"${folder}"/lista.txt grep '.csv' | grep -vP "(_v|\d)" | while IFS= read -r url; do
    nome=$(basename "${url}" .csv | tr ' ' '_')

    # Verifica se il file Parquet non esiste già o se è stato richiesto il force
    if [ ! -f "${folder}/../../data/italia-domani/parquet/${nome}.parquet" ] || [ "$FORCE" -eq 1 ]; then

        # Scarica il file CSV
        curl -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36' \
            -skL "${url}" >"${folder}/tmp/tmp.csv"

        # Rimuovi ###+ da PNRR_Gare.csv
        if [[ "${nome}" == "PNRR_Gare" ]]; then
            sed -i -r 's/###+//g' "${folder}/tmp/tmp.csv"
        fi

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
        if [[ "${nome}" == "PNRR_Gare" ]]; then
            duckdb -c "COPY (
                WITH source AS (
                    SELECT * FROM read_csv_auto('${folder}/tmp/tmp.csv',decimal_separator=',',sample_size=-1,nullstr = ['N/A',''],dateformat='%d/%m/%Y')
                )
                SELECT
                    * EXCLUDE (\"Importo Complessivo Gara\", \"Importo Aggiudicazione\"),
                    CAST(REPLACE(REPLACE(\"Importo Complessivo Gara\", '.', ''), ',', '.') AS FLOAT) AS \"Importo Complessivo Gara\",
                    CAST(REPLACE(REPLACE(\"Importo Aggiudicazione\", '.', ''), ',', '.') AS FLOAT) AS \"Importo Aggiudicazione\"
                FROM source
            ) TO '${folder}/../../data/italia-domani/parquet/${nome}.parquet' (FORMAT 'parquet', CODEC 'ZSTD')"
        else
            duckdb -c "COPY (SELECT * FROM read_csv_auto('${folder}/tmp/tmp.csv',decimal_separator=',',sample_size=-1,nullstr = ['N/A',''],dateformat='%d/%m/%Y',normalize_names = true)) TO '${folder}/../../data/italia-domani/parquet/${nome}.parquet' (FORMAT 'parquet', CODEC 'ZSTD')"
        fi
    fi
done

# Rimuove il file temporaneo
rm -f "${folder}/tmp/tmp.csv"
