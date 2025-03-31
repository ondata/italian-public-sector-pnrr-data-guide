#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/processing
mkdir -p "$folder"/tmp
mkdir -p "${folder}"/../../data/italia-domani

URL="https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?orderby=%40jcr%3Acontent%2FobservationDateInEvidence&sort=desc&resultsOffset=0"

# Estrae il numero di pagine
ultima=$(google-chrome-stable --headless --disable-gpu \
    --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" \
    --dump-dom "$URL" |
    scrape -be '//li[contains(@class, " d-none")]' |
    xq -r '.html.body.li|last|.a."#text"')

offset=0

# cancella tmp.txt se esiste
rm -f "$folder"/tmp.txt

# Prima pagina
google-chrome-stable --headless --disable-gpu \
    --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" \
    --dump-dom "$URL" |
    scrape -be '//span[@data-url]' |
    xq -r '"https://www.italiadomani.gov.it" + .html.body.span[]."@data-url"' |
    sed 's/ /%20/g' >>"$folder"/tmp.txt

rm -f "$folder"/processing/lista_full.jsonl

for ((i = 1; i <= ultima; i++)); do
    url="https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?resultsOffset=$offset"

    html=$(google-chrome-stable --headless --disable-gpu \
        --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" \
        --dump-dom "$url")

    # Estrai gli URL dei file
    echo "$html" | scrape -be '//span[@data-url]' |
        xq -r '"https://www.italiadomani.gov.it" + .html.body.span[]."@data-url"' |
        sed 's/ /%20/g' >>"$folder"/tmp.txt

    # Estrai JSON
    echo "$html" | scrape -be '//body' |
        xq -c '.html.body.body.section[]|{title:.div[0].div.h4."#text",file:.div[1].div[1].span[0]."@data-url",url:.a."@href",description:.div[0].div.p,data_osservazione:.div[1].div[0].ul.li[1].div.span."#text"}' >>"$folder"/processing/lista_full.jsonl

    offset=$((offset + 8))
done

mlrgo -I --jsonl uniq -a then rename url,page_url then put '$file_url="https://www.italiadomani.gov.it".$file;$page_url="https://www.italiadomani.gov.it".$page_url;$file=sub($file,".+/","")' "$folder"/processing/lista_full.jsonl

mv "$folder"/processing/lista_full.jsonl "${folder}"/../../data/italia-domani

mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt >"$folder"/lista.txt
mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt >>"$folder"/lista_all_time.txt
mlr --nidx sort -f 1 then uniq -a "$folder"/lista_all_time.txt >"$folder"/lista_all_time.txt.tmp
mv "$folder"/lista_all_time.txt.tmp "$folder"/lista_all_time.txt

mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt | sed 's|.*|- <&>|' |
    pandoc -f markdown -s -t html --metadata title="catalogo opendata italiadomani" >"$folder"/../../data/italia-domani/web/catalogo-opendata.html
