## Cosa è questo repo

La **suddivisione territoriale statistica standard** in Europa (EUROSTAT) è la [**NUTS**](https://www.wikiwand.com/it/Nomenclatura_delle_unit%C3%A0_territoriali_statistiche). In Italia è di particolare interesse in alcuni contesti, come ad esempio quello della **sanità**, per il quale il paese è suddiviso funzionalmente non nelle 20 regioni "classiche", ma nelle 21 zone `NUTS2` (il Trentino-Alto Adige suddiviso nelle due province autonome).

Una fonte classica per i file geografici con i limiti amministrativi è [**ISTAT**](https://www.istat.it/it/archivio/222527), che però **non pubblica** ad esempio **file "tagliati" secondo `NUTS2`** (è appunto il livello gerarchico regionale).<br>
Questo *repository* per raccogliere alcuni file geografici suddivisi secondo NUTS (al momento soltanto 2).

Abbiamo chiesto ad ISTAT di pubblicare file geografici anche secondo `NUTS2`: al momento non li pubblicheranno ma ci hanno suggerito una modalità per farlo in autonomia e si sono detti interessati a farlo nel futuro.<br>
È fondamentale per due ragioni:

- le [API ISTAT SDMX](https://www.istat.it/it/metodi-e-strumenti/web-service-sdmx) espongono le informazioni geografiche, secondo NUTS (📚 qui [la nostra guida](https://ondata.github.io/guida-api-istat/)). Attenzione quelli qui esposti sono i codici nella codifica del 2006;
- come detto sopra, in alcuni contesti (sanità, scuola, protezione civile, ecc.) il taglio geografico non è quello regionale "classico", ma coincide proprio con il `NUTS2`.

## NUTS2

A partire dai [file geografici ISTAT](https://www.istat.it/it/archivio/222527), e dall'[elenco dei codici delle suddivisioni statistiche](https://www.istat.it/storage/codici-unita-amministrative/Elenco-codici-statistici-e-denominazioni-delle-unita-territoriali.zip) (sempre di ISTAT), sono stati generati dei [file geografici](https://github.com/ondata/covid19italia/tree/master/risorse/fileGeografici) raggruppati per codice `NUTS2` (aggiornamento 2016).

Nel dettaglio:

- [NUTS2_g.zip](processing/NUTS2_g.zip), file con limiti generalizzati (minore dettaglio), formato shapefile, sistema di coordinate [`EPSG:32632`](https://epsg.io/32632);
- [NUTS2.zip](processing/NUTS2.zip), file con limiti non generalizzati, formato shapefile, sistema di coordinate [`EPSG:32632`](https://epsg.io/32632);
- [NUTS2_g.geojson](processing/NUTS2_g.geojson), file con limiti generalizzati, sistema di coordinate [`EPSG:4326`](https://epsg.io/4326).

EUROSTAT pubblica i [file geografici con le suddivisioni NUTS](https://ec.europa.eu/eurostat/web/gisco/geodata/reference-data/administrative-units-statistical-units/nuts), ma questi generati qui hanno **due elementi di diversità**:

- sono generati a partire dai file ISTAT, quindi esiste anche quello con **più dettaglio geografico**, che su EUROSTAT non è presente;
- qui sono presenti anche i **codici regionali ISTAT**.

Due script correlati:

- [`risorse.sh`](risorse.sh), per scaricare le risorse di base per la generazioni dei nuovi file. Va lanciato prima del successivo;
- [`NUTS2.sh`](NUTS2.sh), per generare i file geografici con questo "taglio".
