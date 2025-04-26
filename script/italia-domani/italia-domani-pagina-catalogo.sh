#!/bin/bash

# Impostazione delle opzioni di bash per una maggiore sicurezza
#set -x # Stampa i comandi mentre vengono eseguiti (commentato)
set -e # Esce se un comando fallisce
set -u # Esce se viene usata una variabile non definita
set -o pipefail # Esce se un comando in una pipeline fallisce

# Ottiene il percorso della directory dello script
folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Crea le directory necessarie per l'elaborazione
mkdir -p "$folder"/processing
mkdir -p "$folder"/tmp
mkdir -p "${folder}"/../../data/italia-domani

# URL della pagina del catalogo open data di Italia Domani
URL="https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?orderby=%40jcr%3Acontent%2FobservationDateInEvidence&sort=desc&resultsOffset=0"

# Estrae il numero totale di pagine dal catalogo
ultima=$(google-chrome-stable --no-sandbox --headless --disable-gpu \
    --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" \
    --dump-dom "$URL" |
    scrape -be '//li[contains(@class, " d-none")]' |
    xq -r '.html.body.li|last|.a."#text"' |
    grep -oE '[0-9]+')

offset=0

# Rimuove il file temporaneo se esiste
rm -f "$folder"/tmp.txt

# Scarica la prima pagina del catalogo
google-chrome-stable --no-sandbox --headless --disable-gpu \
    --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" \
    --dump-dom "$URL" |
    scrape -be '//span[@data-url]' |
    xq -r '"https://www.italiadomani.gov.it" + .html.body.span[]."@data-url"' |
    sed 's/ /%20/g' >>"$folder"/tmp.txt

rm -f "$folder"/processing/lista_full.jsonl

# Loop attraverso tutte le pagine del catalogo
for ((i = 1; i <= ultima; i++)); do
    # Costruisce l'URL per ogni pagina successiva
    url="https://www.italiadomani.gov.it/content/sogei-ng/it/it/catalogo-open-data/jcr:content/root/container/opendatasearch.searchResults.html?resultsOffset=$offset"

    # Scarica la pagina corrente
    html=$(google-chrome-stable --no-sandbox --headless --disable-gpu \
        --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36" \
        --dump-dom "$url")

    # Estrae gli URL dei file dalla pagina corrente
    echo "$html" | scrape -be '//span[@data-url]' |
        xq -r '"https://www.italiadomani.gov.it" + .html.body.span[]."@data-url"' |
        sed 's/ /%20/g' >>"$folder"/tmp.txt

    # Estrae i metadati in formato JSON (titolo, file, URL, descrizione, data)
    echo "$html" | scrape -be '//body' |
        xq -c '.html.body.body.section[]|{title:.div[0].div.h4."#text",file:.div[1].div[1].span[0]."@data-url",url:.a."@href",description:.div[0].div.p,data_osservazione:.div[1].div[0].ul.li[1].div.span."#text"}' >>"$folder"/processing/lista_full.jsonl

    # Incrementa l'offset per la prossima pagina
    offset=$((offset + 8))
done

# Elabora il file JSON con i metadati
mlrgo -I --jsonl uniq -a then rename url,page_url then put '$file_url="https://www.italiadomani.gov.it".$file;$page_url="https://www.italiadomani.gov.it".$page_url;$file=sub($file,".+/","")' "$folder"/processing/lista_full.jsonl

# Sposta il file JSON nella directory dei dati
mv "$folder"/processing/lista_full.jsonl "${folder}"/../../data/italia-domani

# Genera le liste degli URL dei file
mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt >"$folder"/lista.txt
mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt >>"$folder"/lista_all_time.txt
mlr --nidx sort -f 1 then uniq -a "$folder"/lista_all_time.txt >"$folder"/lista_all_time.txt.tmp
mv "$folder"/lista_all_time.txt.tmp "$folder"/lista_all_time.txt

# Genera una pagina HTML con i link ai file
mlr --nidx sort -f 1 then uniq -a "$folder"/tmp.txt | sed 's|.*|- <&>|' |
    pandoc -f markdown -s -t html --metadata title="catalogo opendata italiadomani" >"$folder"/../../data/italia-domani/web/catalogo-opendata.html
