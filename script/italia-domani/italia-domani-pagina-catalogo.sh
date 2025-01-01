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
ultima=$(curl -kL "$URL" -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' | scrape -be '//li[contains(@class, " d-none")]' | xq -r '.html.body.li|last|.a."#text"')
offset=0 # Inizializza l'offset a 0

# if file exist delete it
if [ -f "$folder"/tmp.txt ]; then
    rm "$folder"/tmp.txt
fi

curl 'https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?orderby=%40jcr%3Acontent%2FobservationDateInEvidence&sort=desc' \
    -H 'accept: */*' \
    -H 'accept-language: it,en-US;q=0.9,en;q=0.8' \
    -H 'content-type: text/html' \
    -H 'cookie: HttpOnly; HttpOnly; HttpOnly; HttpOnly; thirdPart=true' \
    -H 'priority: u=1, i' \
    -H 'referer: https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data.html?orderby=%40jcr%3Acontent%2FobservationDateInEvidence&sort=desc' \
    -H 'sec-ch-ua: "Chromium";v="128", "Not;A=Brand";v="24", "Google Chrome";v="128"' \
    -H 'sec-ch-ua-mobile: ?0' \
    -H 'sec-ch-ua-platform: "Windows"' \
    -H 'sec-fetch-dest: empty' \
    -H 'sec-fetch-mode: cors' \
    -H 'sec-fetch-site: same-origin' \
    -H 'user-agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36' | scrape -be '//span[@data-url]' | xq -r '"https://www.italiadomani.gov.it" + .html.body.span[]."@data-url"' | sed 's/ /%20/g' >>"$folder"/tmp.txt

# if "$folder"/processing/lista_full.jsonl  exist delete it
if [ -f "$folder"/processing/lista_full.jsonl ]; then
    rm "$folder"/processing/lista_full.jsonl
fi

# estrai URL da ogni pagina
for ((i = 1; i <= ultima; i++)); do
    url="https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?resultsOffset=$offset"

    #echo "Chiamata CURL: $url"

    #    curl -kL  $url \
    #    -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' >>"$folder"/tmp.html

    curl -kL $url \
        -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' |
        scrape -be '//span[@data-url]' | xq -r '"https://www.italiadomani.gov.it" + .html.body.span[]."@data-url"' | sed 's/ /%20/g' >>"$folder"/tmp.txt

    curl -kL $url -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36' | scrape -be '//body' | xq -c '.html.body.body.section[]|{title:.div[0].div.h4."#text",file:.div[1].div[1].span[0]."@data-url",url:.a."@href",description:.div[0].div.p,data_osservazione:.div[1].div[0].ul.li[1].div.span."#text"}' >>"$folder"/processing/lista_full.jsonl
    offset=$((offset + 8)) # Aggiorna l'offset
done

mlr -I --jsonl uniq -a then rename url,page_url then put '$file_url="https://www.italiadomani.gov.it".$file;$page_url="https://www.italiadomani.gov.it".$page_url;$file=sub($file,".+/","")' "$folder"/processing/lista_full.jsonl

mv "$folder"/processing/lista_full.jsonl "${folder}"/../../data/italia-domani

# converte in HTML
mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt >"$folder"/lista.txt
mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt >>"$folder"/lista_all_time.txt
mlr --nidx sort -f 1 then uniq -a "$folder"/lista_all_time.txt >"$folder"/lista_all_time.txt.tmp
mv "$folder"/lista_all_time.txt.tmp "$folder"/lista_all_time.txt
mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt | sed 's|.*|- <&>|' |
    pandoc -f markdown -s -t html --metadata title="catalogo opendata italiadomani" >"$folder"/../../data/italia-domani/web/catalogo-opendata.html
