# eXist-db Users Meetup, XML Prague 2024

## Lucene

- developed by Apache Lucene working group
  - <https://lucene.apache.org>
  - current version: 9.10.0 (2024-02-20)
  - version in eXist-db: [4.10.4](https://github.com/eXist-db/exist/blob/7191b8ba7c34eb6c1c9c3734c9b9d1f808df704d/exist-parent/pom.xml#L118)
    - <https://lucene.apache.org/core/4_10_4/>
    - [documentation](https://exist-db.org/exist/apps/doc/lucene)
  - for indexing (phase 1) and searching (phase 2) in documents
    - 1 document =
      - 1 xml file (root element and its descendants)
      - 1 element (not necessary the root) and its descendants

## Indexes

- `collection.xconf`
  - can be in specific (sub)collection
  - stored in the </db/system/config/db/apps> collection
    - synchronization in VS Code doesn't work (doesn't store in the </db/system/config/db/apps> collection)
    - you can use `xst`: `xst upload --include "*.xconf" --verbose --apply-xconf ./data/dictionaries/ /db/apps/exist-db-lucene/data/dictionaries --config admin.xstrc`
  - indexing while
    - uploading/inserting, removing data
    - [updating data](https://exist-db.org/exist/apps/doc/update_ext.xml)
      - `update insert | delete | replace | delete | rename` modifying data
      - problems if the `<text>` element contains XPath with pradicate, like `//list[@type='index']`
    - manually
      - `xst execute "xmldb:reindex('/db/apps/exist-db-lucene/data/dictionaries')" --config admin.xstrc` (doesn't always work)
      - from eXide (always works)
        - be logged in as an `admin`
        - saving `collection.xconf` file (with/out modification)
        - clicking on `OK` button in dialog

## Fields

- used for full-text searching
- like properties of the parent node
- not only text (dates, date times), i.e. atomic types (`xs:date`, `xs:dateTime`, `xs:time`, `xs:integer`, `xs:decimal`...)
- can be computed (values can be computed or taken from different document or part of the document)

## Facets

- used for filtering (existing values in the search result)
- field and facets can use the same expression (and thus the values)
- can be hierachical
- works only if `ft:query` function is used

## Search

- whole text of the field is indexed, but separate words are searched
- whole text of the facet is indexed and exact match is used
- you can search for combination using quotes `""`
- you can search using regular expression if you use `//`

```xpath
//db:article[ft:query(., "title:(xquery AND language) AND xml")]
```

## What is indexed

- Monex
- `report.xqm` [module](https://github.com/daliboris/exist-db-lucene/blob/main/modules/report.xql)

### Debug

- edit `collection.xconf` or `index.xql`
- if `collection.xconf` is modified
  - use `xst upload --include "*.xconf" --verbose --apply-xconf ./data/dictionaries/ /db/apps/exist-db-lucene/data/dictionaries --config admin.xstrc`
  - close and open `collection.xconf` in eXide
- save `collection.xconf` in eXide and apply indexation
- watch eXist log for errors like

```console
7 May 2024 13:55:34,940 [qtp1201614274-3764] WARN  (LuceneFieldConfig.java [build]:135) - XPath error while evaluating expression for field named 'sortKey': Optional[declare namespace tei="http://www.tei-c.org/ns/1.0";
...
org.exist.xquery.XPathException: exerr:ERROR XPTY0004: The actual cardinality for parameter 1 does not match the cardinality declared in the function's signature: idx:get-sortKey($entry as element()?) xs:string. Expected cardinality: zero or one, got 2. [at line 292, column 41, source: /db/apps/exist-db-lucene/index.xql]
In function:
```

- look in the Monex for the content of the field/facet
