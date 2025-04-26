# Introduzione

Alcuni script correlati ai dati PNRR di Italia Domani.

## italia-domani.sh

Script per la gestione e la pulizia dei dati PNRR, inclusa la conversione dei codici ISTAT dei comuni.

## italia-domani-pagina-catalogo.sh

Scarica e processa i dati dal catalogo open data di Italia Domani, generando una lista di risorse disponibili.

## Versione duckdb del catalogo dati di Italiadomani

L'URL è https://raw.githubusercontent.com/ondata/italian-public-sector-pnrr-data-guide/main/data/italia-domani/parquet/pnrr.db

È un database DuckDB che contiene le tabelle del catalogo dati di Italiadomani, ma come viste che puntano alla versione parquet dei file del catalogo.

### italia-domani_parquet.sh

Converte i file CSV scaricati in formato Parquet, gestendo automaticamente le diverse codifiche dei caratteri. Da lanciare dopo `italia-domani-pagina-catalogo.sh` per avere il puntamento alle ultime versioni dei file CSV.

### italia-domani_duckdb.sh

Crea un database DuckDB con viste sui file Parquet e genera metadati sulle tabelle disponibili. Da lanciare dopo `italia-domani_parquet.sh`.
