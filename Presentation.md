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

### Getting value

- XPath
  - `@expression="tei:form[@type=('lemma', 'variant')]/tei:pron"`
- XQuery
  - `@expression="nav:get-metadata(., 'pronunciation')"`
  - /index.xql
    - ​module namespace idx="http://teipublisher.com/index";
  - /data/dictionaries/collexction.xconf
    - `<module uri="http://teipublisher.com/index" prefix="nav" at="../../index.xql"/>`

### Indexing while

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

### Indexing using eXide

![Confirmation dialog](/resources/images/indexing-exide-confirmation.png)

![Infoboxes](/resources/images/indexing-exide-messages.png)

## Fields

```xml
<field name="domain" expression="nav:get-metadata(., 'domain')" />
```

- used for full-text searching
- like properties of the parent node
- not only text (dates, date times), i.e. atomic types (`xs:date`, `xs:dateTime`, `xs:time`, `xs:integer`, `xs:decimal`...)
- can be computed (values can be computed or taken from different document or part of the document)

```xquery
ft:field($item, "domain")
```

## Binary fields

`<field name="sortKey" expression="nav:get-metadata(., 'sortKey')" binary="yes" />`

- used for sorting or filtering
- content can be retrieved, but not queried

```xquery
 ft:binary-field($entry, "sortKey", "xs:string")
 ```

## Facets

`<facet dimension="domain" expression="nav:get-metadata(., 'domain')" />`

- used for filtering (existing values in the search result)
- field and facets can use the same expression (and thus the values)
- can be hierachical
- works only if `ft:query` function is used

## Search

```xml
<ref xml:lang="en" type="reversal">many times</ref>
```

- whole text is indexed, but separate words are searched
  - //tei:entry[ft:query(., " reversal: **many** ")]
- search for combination of words using double quotes ""
  - //tei:entry[ft:query(., ' reversal: **"many times"** ')]
- search with regular expression using slashes //
  - //tei:entry[ft:query(., " reversal: **/[Bb]iologic.*/** ")]
- search parts of words using wildcards (* and ?)
  - //tei:entry[ft:query(., ' reversal: " **time*** " ')]

## Using fields

- return fields (for futher processing)
  - //db:entry[ft:query(., (), map { **"fields": ("sortKey")** })]

```xquery
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[
  ft:query(., "reversal:although", map { "fields" : "sortKey" } )
  ]
for $hit in $hits
   order by ft:field($hit, "sortKey")
   return $hit
```

## Highlighting

```xquery
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[ft:query(., "reversal:although")]
for $hit in $hits
  let $expanded := util:expand($hit)
  return $expanded
```

```xml
<ref xml:lang="en" type="reversal">
   <exist:match>although</exist:match>
</ref>
```

## Filtering (facets)

```xml
<gram type="pos" expand="Adjective">adj</gram>
```

- can be used only on the result of full-text search (ft:query())

```xqeury
let $options := map {
    "facets": map {
        "pos": ("subst", "adj"),
    }
}
```

```xqpth
//tei:entry[ft:query(., (), $options)]
```

## What is indexed

### Monex

![Monex, step 1](/resources/images/index-monex-step-01.png)

![Monex, step 2](/resources/images/index-monex-step-02.png)

![Monex, step 3](/resources/images/index-monex-step-03.png)

![Monex, step 4](/resources/images/index-monex-step-04.png)

### Report

- see `report.xqm` [module](https://github.com/daliboris/exist-db-lucene/blob/main/modules/report.xql)

![Report, step 1](/resources/images/rest-api-statistics-01.png)

![Report, step 1](/resources/images/rest-api-statistics-02.png)

### Debuging

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

## Sample queries

- query field using whole word

```xquery
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $query := "reversal:biologically"

let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[ft:query(., $query)]
return $hits
```

- query field using wildcards

```xquery
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $query := "reversal:bio*"

let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[ft:query(., $query)]
return $hits
```

- query field using wildcards at the beginning

```xquery
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $query := "reversal:*log*"
let $options := map { "leading-wildcard": "yes",
    "filter-rewrite": "yes"}

let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[ft:query(., $query, $options)]
   return $hits
```

- retrieve the filed and use it for sorting

```xquery
declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $query := "partOfSpeechAll:adj"
let $options := map { "fields" : "sortKey" }

let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[ft:query(., $query, $options)]
for $hit in $hits
   order by ft:field($hit, "sortKey")
   return $hit
```
