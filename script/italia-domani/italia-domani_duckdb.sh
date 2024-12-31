#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "${folder}/tmp"

if [ -f "${folder}"/../../data/italia-domani/parquet/pnrr.db ]; then
    rm "${folder}"/../../data/italia-domani/parquet/pnrr.db
fi

find "${folder}"/../../data/italia-domani/parquet -name "*.parquet" | while read -r file; do
    table=$(basename "${file}" .parquet)
    duckdb "${folder}"/../../data/italia-domani/parquet/pnrr.db -c "create or replace view \"${table}\" AS
select * from read_parquet('https://raw.githubusercontent.com/ondata/italian-public-sector-pnrr-data-guide/refs/heads/main/data/italia-domani/parquet/${table}.parquet')"
done
