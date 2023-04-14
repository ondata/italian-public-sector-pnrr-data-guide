#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# per estrarre, ordinare, comprimere file pnrr opencup
# in questo modo ad aggiornamento sarà più comodo fare il diff

qsv excel --dates-whitelist 'Data' progetti_cup_20230120.xlsx >progetti_cup_20230120.csv

mlr -I --csv sort -f CODICE_CUP,STATO,CODI_CODICE_REGIONE,REGIONE,CODI_CODICE_PROVINCIA,PROVINCIA,CODI_CODICE_COMUNE,COMUNE progetti_cup_20230120.csv

gzip -c progetti_cup_20230120.csv > progetti_cup_20230120.csv.gz

rm progetti_cup_20230120.csv
