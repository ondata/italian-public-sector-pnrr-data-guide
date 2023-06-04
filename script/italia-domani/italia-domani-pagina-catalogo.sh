#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing

URL="https://italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?orderby=%40jcr%3Acontent%2FobservationDateInEvidence&sort=desc"

curl -kL  "$URL" \
-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' | \
sed 's|"/content/|"https://www.italiadomani.gov.it/content/|g' | \
scrape -be '///span[@data-url]/@data-url' | sed -r 's/https:/\nhttps:/g' | \
grep -Po '\b(?:https?|ftp)://\S+\b' | grep 'domani' | sort | \
sed 's|.*|- <&>|' | \
pandoc -f markdown -s -t html --metadata title="catalogo opendata italiadomani" >"$folder"/../../data/italia-domani/web/catalogo-opendata.html

