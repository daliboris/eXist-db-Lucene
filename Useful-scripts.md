# Useful scripts

## eXist-db

### Installing package

```shell
xst package install ./build/exist-db-lucene.xar --config .existdb.json
```

### Uninstalling package

```shell
xst package uninstall exist-db-lucene --config .existdb.json
```

### Uploading index conficguration

```shell
xst upload --include "*.xconf" --verbose --apply-xconf ./data/dictionaries/ /db/apps/exist-db-lucene/data/dictionaries --config .existdb.json
```

### Uploading dictionary medatata and data

```shell
xst upload -i "LeDIIR-FACS-about.xml" -v ./sample/about /db/apps/exist-db-lucene/data/about --config xml.xstrc

xst upload -i "LeDIIR-FACS-entry.xml" -v ./sample/dictionaries /db/apps/exist-db-lucene/data/dictionaries --config xml.xstrc

xst upload -i "LeDIIR-FACS.xml" -v ./sample/dictionaries /db/apps/exist-db-lucene/data/dictionaries --config xml.xstrc
```

### Removing dictionary medatata and data

```shell
xst remove /db/apps/exist-db-lucene/data/about/LeDIIR-FACS-about.xml --config xml.xstrc
xst remove /db/apps/exist-db-lucene/data/dictionaries/LeDIIR-FACS-entry.xml --config xml.xstrc
xst remove /db/apps/exist-db-lucene/data/dictionaries/LeDIIR-FACS.xml --config xml.xstrc
```
