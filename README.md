# eXist-db Lucene

Fulltext search in eXist-db using Lucene. Sample database for eXist-db Users Meetup on XML Prague 2024.

## How to use it

- download the [latest relase](https://github.com/daliboris/eXist-db-Lucene/releases/latest) from the GitHub repository
- clone or download this repository to have access to [sample files](https://github.com/daliboris/eXist-db-Lucene/tree/main/sample)
- install `exist-db-lucene.xar` package to eXist-db
  - [you can use prepared script](Useful-scripts.md#installing-package)
- upload sample data to the `exist-db-lucene` repository
  - [you can use prepared script](Useful-scripts.md#uploading-dictionary-medatata-and-data)
- try [sample queries](Presentation.md#sample-queries) using `VS Code`, `xst`, or `oXygen XML Editor`

For **login** use

user: `xml`

password: `prague`

## eXist-db package for lexicographic data

### Indexing

- data located in the collection _data_ and subcollections
- one index field for searching text in whole entry
- field for sorting based on the frequency of the lemma in the corpus
- advanced indexing of translation equivalents, including relevance boosting based on
  - position of the equivalent in the meaning
  - frequency of the lemma in the corpus
  - order of the sense in the entry
  - uniqueness of the sense
- processing equivalent without gloss (i.e. text in brackets)
- omission of indexing of data in subentries (i.e. frequency, number of meanings, reversals, definitions...)
- separate indexing of Czech and English reversals
- advanced indexing of reversals with fields for
  - text content
  - language of the reversal
  - order of the sense in the entry
  - uniqueness of the sense

### REST API

- REST API available on [api.html](api.html)
- API for updating files in collections
- API for uploading a ZIP file to a collection
- API for generating statistics on collections and indexes

### Build and Installation

- **build.xml** modifications for data repository
- modules **pre-install.xql** and **post-install.xql**
- setting owner of subcollections

## Other materials

- useful [xst scripts](Useful-scripts.md) for uploading or removing packages and data
- notes for [presentation](Presentation.md) on Lucene in eXist-db from XML Prague 2024
