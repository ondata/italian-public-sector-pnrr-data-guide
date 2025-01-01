#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}"/tmp

if [ -f "${folder}"/../../data/italia-domani/parquet/pnrr.db ]; then
    rm "${folder}"/../../data/italia-domani/parquet/pnrr.db
fi

mlr --ijsonl --onidx cut -f file_url then put '$file_url=sub($file_url,"^(.+/)(.+)(\..+)$","\2.")' "${folder}"/../../data/italia-domani/lista_full.jsonl >"${folder}"/tmp/tmp.txt

find "${folder}"/../../data/italia-domani/parquet -name "*.parquet" | grep -Ff tmp.txt | while read -r file; do
    table=$(basename "${file}" .parquet)
    duckdb "${folder}"/../../data/italia-domani/parquet/pnrr.db -c "create or replace view \"${table}\" AS
select * from read_parquet('https://raw.githubusercontent.com/ondata/italian-public-sector-pnrr-data-guide/refs/heads/main/data/italia-domani/parquet/${table}.parquet')"
done

find "${folder}"/../../data/italia-domani/parquet -name "*.parquet" | grep -Ff tmp.txt | mlr --inidx --ojsonl label file then put '$file=sub($file,"^(.+/)(.+)(\..+)$","\2.csv")' >"${folder}"/tmp/tmp.jsonl

mlr --jsonl join -j file -f "${folder}"/tmp/tmp.jsonl then unsparsify "${folder}"/../../data/italia-domani/lista_full.jsonl >"${folder}"/tmp/tmp2.jsonl

mlr --jsonl --from "${folder}"/tmp/tmp2.jsonl rename file,view,file_url,view_source then put '$view=sub($view,"\..+","")' then reorder -f view,title,page_url,view_source then put '$data_osservazione=strftime(strptime($data_osservazione, "%d/%m/%y"),"%Y-%m-%d")' then sort -t view then clean-whitespace >"${folder}"/tmp/info_tabelle.jsonl

duckdb "${folder}"/../../data/italia-domani/parquet/pnrr.db -c "create table info_viste as select * from read_ndjson('${folder}/tmp/info_tabelle.jsonl')"
