#!/bin/bash

# Impostazione delle opzioni di bash per una maggiore sicurezza
set -x # Stampa i comandi mentre vengono eseguiti
set -e # Esce se un comando fallisce
set -u # Esce se viene usata una variabile non definita
set -o pipefail # Esce se un comando in una pipeline fallisce

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea directory temporanea
mkdir -p "${folder}"/tmp

# Rimuove il database esistente se presente
if [ -f "${folder}"/../../data/italia-domani/parquet/pnrr.db ]; then
    rm "${folder}"/../../data/italia-domani/parquet/pnrr.db
fi

# Estrae i nomi dei file dal JSON e prepara la lista dei file da processare
mlr --ijsonl --onidx cut -f file_url then put '$file_url=sub($file_url,"^(.+/)(.+)(\..+)$","\2.")' "${folder}"/../../data/italia-domani/lista_full.jsonl >"${folder}"/tmp/tmp.txt

# Crea viste nel database DuckDB per ogni file Parquet
find "${folder}"/../../data/italia-domani/parquet -name "*.parquet" | grep -Ff "${folder}"/tmp/tmp.txt | while read -r file; do
    table=$(basename "${file}" .parquet)
    # Crea una vista nel database per ogni file Parquet, leggendo direttamente da GitHub
    duckdb "${folder}"/../../data/italia-domani/parquet/pnrr.db -c "create or replace view \"${table}\" AS
select * from read_parquet('https://raw.githubusercontent.com/ondata/italian-public-sector-pnrr-data-guide/refs/heads/main/data/italia-domani/parquet/${table}.parquet')"
done

# Prepara i metadati delle tabelle
find "${folder}"/../../data/italia-domani/parquet -name "*.parquet" | grep -Ff "${folder}"/tmp/tmp.txt | mlr --inidx --ojsonl label file then put '$file=sub($file,"^(.+/)(.+)(\..+)$","\2.csv")' >"${folder}"/tmp/tmp.jsonl

# Unisce i metadati delle tabelle con le informazioni complete
mlr --jsonl join -j file -f "${folder}"/tmp/tmp.jsonl then unsparsify "${folder}"/../../data/italia-domani/lista_full.jsonl >"${folder}"/tmp/tmp2.jsonl

# Formatta e ordina le informazioni sulle tabelle
mlr --jsonl --from "${folder}"/tmp/tmp2.jsonl rename file,view,file_url,view_source then put '$view=sub($view,"\..+","")' then reorder -f view,title,page_url,view_source then put '$data_osservazione=strftime(strptime($data_osservazione, "%d/%m/%y"),"%Y-%m-%d")' then sort -t view then clean-whitespace >"${folder}"/tmp/info_tabelle.jsonl

# Crea tabella con i metadati nel database
duckdb "${folder}"/../../data/italia-domani/parquet/pnrr.db -c "create table info_viste as select * from read_ndjson('${folder}/tmp/info_tabelle.jsonl')"
