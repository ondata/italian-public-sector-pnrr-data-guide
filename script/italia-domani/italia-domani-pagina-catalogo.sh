#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing

URL="https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?orderby=%40jcr%3Acontent%2FobservationDateInEvidence&sort=desc&resultsOffset=0"

# Estrae il numero di pagine
ultima=$(curl -kL  "$URL" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36'  | scrape -be '//li[contains(@class, " d-none")]' | xq -r '.html.body.li|last|.a."#text"')
offset=0        # Inizializza l'offset a 0

# if file exist delete it
if [ -f "$folder"/tmp.txt ]; then
    rm "$folder"/tmp.txt
fi

# estrai URL da ogni pagina
for (( i=1; i<=ultima; i++ )); do
    url="https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?orderby=%40jcr%3Acontent%2FobservationDateInEvidence&sort=desc&resultsOffset=$offset&fulltext=*"


    echo "Chiamata CURL: $url"

    curl -kL  $url \
    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' | \
    scrape -be '//span[@data-url]' | xq -r '"https://www.italiadomani.gov.it" + .html.body.span[]."@data-url"' | sed 's/ /%20/g' >>"$folder"/tmp.txt

    offset=$((offset+8))    # Aggiorna l'offset
done

# converte in HTML
sort "$folder"/tmp.txt | uniq | sed 's|.*|- <&>|' | \
pandoc -f markdown -s -t html --metadata title="catalogo opendata italiadomani" >"$folder"/../../data/italia-domani/web/catalogo-opendata.html

