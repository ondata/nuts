#!/bin/bash

### requisiti ###
# Mapshaper https://github.com/mbloch/mapshaper
# Miller https://github.com/johnkerl/miller
# GDAL/OGR https://gdal.org/
### requisiti ###

set -x

folder="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# estrai soltanto Codice Provincia (Storico)(1) e Codice NUTS2 2021 (3) da file anagrafico con Codici statistici
mlr --csv cut -f "Codice Provincia (Storico)(1)","Codice NUTS2 2021 (3)" \
  then label COD_PROV,NUTS2 \
  then uniq -a \
  then put -S '$COD_PROV=sub($COD_PROV,"^0+","")' "$folder"/risorse/Codici-statistici-e-denominazioni-al-01_01_2021.csv >"$folder"/processing/codici.csv

# estrai dati anagrafici NUTS
mlr --csv rename Description,Nome then cut -f NUTS-Code,Nome "$folder"/risorse/codiciNUTS.csv >"$folder"/processing/codiciNUTS.csv

### file geografici generalizzati ###

rm "$folder"/processing/Com01012020_WGS84.*
find "$folder"/risorse/Limiti01012020 -name "Com01012020_WGS84.*" | xargs -I {} sh -c "cp {} $folder/processing"

# JOIN tra file geofrafici e codici NUTS2
mapshaper-xl "$folder"/processing/Com01012020_WGS84.shp -join "$folder"/processing/codici.csv keys=COD_PROV,COD_PROV -o "$folder"/processing/tmp.shp

# dissolvi poligono per codice NUTS
mapshaper-xl "$folder"/processing/tmp.shp -dissolve2 NUTS2 copy-fields=COD_RIP,COD_REG -o "$folder"/processing/NUTS2.shp
rm "$folder"/processing/tmp.*

# aggiungi dati anagrafici NUTS2
mapshaper-xl "$folder"/processing/NUTS2.shp -join "$folder"/processing/codiciNUTS.csv keys=NUTS2,NUTS-Code -o "$folder"/processing/tmp.shp
ogr2ogr "$folder"/processing/NUTS2.shp "$folder"/processing/tmp.shp
rm "$folder"/processing/tmp.*

# applica 0 padding a colonna COD_REG
ogrinfo -sql "ALTER TABLE NUTS2 ALTER COLUMN COD_REG TYPE character(2)" "$folder"/processing/NUTS2.shp
ogrinfo -dialect sqlite -sql "UPDATE NUTS2 SET COD_REG = printf('%02d', COD_REG)" "$folder"/processing/NUTS2.shp

### file geografici non generalizzati ###

rm "$folder"/processing/Com01012020_.*
find "$folder/risorse/Limiti01012020_g" -name "Com01012020_g_WGS84*" | xargs -I {} sh -c "cp {} $folder/processing"

# JOIN tra file geofrafici e codici NUTS2
mapshaper-xl "$folder"/processing/Com01012020_g_WGS84.shp -join "$folder"/processing/codici.csv keys=COD_PROV,COD_PROV -o "$folder"/processing/tmp.shp

# dissolvi poligono per codice NUTS
mapshaper-xl "$folder"/processing/tmp.shp -dissolve2 NUTS2 copy-fields=COD_RIP,COD_REG -o "$folder"/processing/NUTS2_g.shp
rm "$folder"/processing/tmp.*

# aggiungi dati anagrafici NUTS2
mapshaper-xl "$folder"/processing/NUTS2_g.shp -join "$folder"/processing/codiciNUTS.csv keys=NUTS2,NUTS-Code -o "$folder"/processing/tmp.shp
ogr2ogr "$folder"/processing/NUTS2_g.shp "$folder"/processing/tmp.shp

# applica 0 padding a colonna COD_REG
ogrinfo -sql "ALTER TABLE NUTS2_g ALTER COLUMN COD_REG TYPE character(2)" "$folder"/processing/NUTS2_g.shp
ogrinfo -dialect sqlite -sql "UPDATE NUTS2_g SET COD_REG = printf('%02d', COD_REG)" "$folder"/processing/NUTS2_g.shp

# crea geojson
ogr2ogr -f geojson -lco RFC7946=YES "$folder"/processing/NUTS2_g.geojson "$folder"/processing/NUTS2_g.shp

# pulizia
rm "$folder"/processing/tmp.*
rm "$folder"/processing/Com01012020_*
