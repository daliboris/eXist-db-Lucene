declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace exist = "http://exist.sourceforge.net/NS/exist";

let $query := "reversal: /[Bb]io.*/ "

 
let $collection := "/db/apps/exist-db-lucene/data/dictionaries"
let $hits := collection($collection)//tei:entry[ft:query(., $query)]
for $hit in $hits
  let $expanded := util:expand($hit)
  return $expanded//exist:match