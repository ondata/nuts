#!/bin/bash

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$folder"/risorse
mkdir -p "$folder"/processing

### codici statistici territoriali ###

URLcodici="https://www.istat.it/storage/codici-unita-amministrative/Elenco-codici-statistici-e-denominazioni-delle-unita-territoriali.zip"
nomeCodici="Elenco-codici-statistici-e-denominazioni-delle-unita-territoriali.zip"

# scarica i dati
if [[ ! -f "$folder"/risorse/"$nomeCodici" ]]; then
  curl -kL "$URLcodici" >"$folder"/risorse/"$nomeCodici"
fi

# decomprimi il file
yes | unzip -j "$folder"/risorse/"$nomeCodici" -d "$folder"/risorse

# cambia codifica da WINDOWS-1252 -t a UTF-8
iconv <"$folder"/risorse/Codici-statistici-e-denominazioni-al-01_01_2021.csv -f WINDOWS-1252 -t UTF-8 >"$folder"/risorse/tmp.csv
mv "$folder"/risorse/tmp.csv "$folder"/risorse/Codici-statistici-e-denominazioni-al-01_01_2021.csv

# cambia separatore decimale e rimuovi spazi ridondanti errati
mlr -I --csv --ifs ";" clean-whitespace "$folder"/risorse/Codici-statistici-e-denominazioni-al-01_01_2021.csv

### limiti geografici non generalizzati ###

URLshapefile_g="https://www.istat.it/storage/cartografia/confini_amministrativi/generalizzati/Limiti01012020_g.zip"
nomiShapefile_g="Limiti01012020_g.zip"

if [[ ! -f "$folder"/risorse/"$nomiShapefile_g" ]]; then
  curl -kL "$URLshapefile_g" >"$folder"/risorse/"$nomiShapefile_g"
fi

# decomprimi il file
yes | unzip "$folder"/risorse/"$nomiShapefile_g" -d "$folder"/risorse

### limiti geografici non generalizzati ###
URLshapefile="https://www.istat.it/storage/cartografia/confini_amministrativi/non_generalizzati/Limiti01012020.zip"
nomiShapefile="Limiti01012020.zip"

if [[ ! -f "$folder"/risorse/"$nomiShapefile" ]]; then
  curl -kL "$URLshapefile" >"$folder"/risorse/"$nomiShapefile"
fi

# decomprimi il file
yes | unzip "$folder"/risorse/"$nomiShapefile" -d "$folder"/risorse

### anagrafica NUTS ###

curl 'https://ec.europa.eu/eurostat/ramon/nomenclatures/index.cfm?TargetUrl=ACT_OTH_CLS_DLD&StrNom=NUTS_33&StrFormat=CSV&StrLanguageCode=EN&IntKey=&IntLevel=&bExport=' \
  --data-raw 'TxtDelimiter=%2C&BtnDownload=Download' \
  --compressed >"$folder"/risorse/codiciNUTS.csv

mlr -I --csv --irs "\r" cat "$folder"/risorse/codiciNUTS.csv
