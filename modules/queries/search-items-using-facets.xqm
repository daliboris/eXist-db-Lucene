declare namespace tei = "http://www.tei-c.org/ns/1.0";

let $query := ()
let $options := map {
    "facets": map {
        "partOfSpeech": ("subst", "v")
    }
}
 
let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[ft:query(., $query, $options)]
return $hits