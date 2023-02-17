#!/bin/bash

set -x
set -e
set -u
set -o pipefail

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for i in atti bandi esiti;do
  qsv searchset -i -s cig "$folder"/../../data/messina/anac-cup-cig-083048-cig.csv "$folder"/../../data/scp/v_od_"$i".csv | mlr --csv clean-whitespace>"$folder"/../../data/messina/scp-"$i"-083048.csv
done
