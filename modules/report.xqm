xquery version "3.1" encoding "utf-8";

module namespace rpt = "http://teilex0/ns/xquery/report"; 
declare namespace cc="http://exist-db.org/collection-config/1.0";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace ft="http://exist-db.org/xquery/lucene";

declare variable $rpt:collection external := "/db/apps/exist-db-lucene/data/dictionaries";
declare variable $rpt:max-items external := 20; 
declare variable $rpt:item-id external := (); 

declare function rpt:get-collection-statistics() 
{ 
 let $files := uri-collection($rpt:collection)
 return
 <collection path="{$rpt:collection}" count="{count($files)}" xml-count="{count($files[ends-with(., '.xml')])}">
 {for $file in $files return
  <file name="{$file}" />
 }
 </collection>
};

declare function rpt:get-nodes-statistics() {
 let $entries := collection($rpt:collection)//tei:entry
 let $divs := collection($rpt:collection)//tei:div
 return
 <nodes path="{$rpt:collection}">
 {
  <node name="div" count="{count($divs)}" />,
  <node name="entry" count="{count($entries)}" />
 }
 </nodes>
};

declare function rpt:get-fields-statistics($fields as element(cc:field)*) 
{ 
 let $query-start-time := util:system-time()
 let $result := for $field in $fields return rpt:get-field-statistics($field)
 let $query-end-time := util:system-time()
 return $result
};

declare function rpt:get-field-statistics($field as element(cc:field)) 
{ 
let $name := $field/@name
let $all-items := collection($rpt:collection)//tei:entry[ft:query(., $name || ":(*)", map { "leading-wildcard": "yes", "filter-rewrite": "yes", "fields": ($name) })] ! ft:field(., $name)
let $items := if($rpt:max-items le 0) then
    $all-items else $all-items[position() le $rpt:max-items]
return <field name="{$name}" count="{count($all-items)}" distinct="{count(distinct-values($all-items))}">{ ($field/@boost, for $f at $i in $items
        group by $label := $f
        return <item name="{$label}" count="{count($f)}" />
        )
        }</field> 

};

declare function rpt:get-facets-statistics($facets as element(cc:facet)*) 
{ 
 let $query-start-time := util:system-time()
 let $result := for $item in $facets return rpt:get-facet-statistics($item)
 let $query-end-time := util:system-time()
 return $result
}; 

declare function rpt:get-facet-statistics($facet as element(cc:facet)) 
{ 
let $name := $facet/@dimension
let $result := collection($rpt:collection)//tei:entry[ft:query(.,"*", map { "leading-wildcard": "yes", "filter-rewrite": "yes" })]
let $all-facets := ft:facets($result, $name, ())
let $facets := if($rpt:max-items = 0) then
    $all-facets else ft:facets($result, $name, $rpt:max-items) 

return <facet name="{$name}" count="{map:size($all-facets)}">{ 
          map:for-each($facets, function($label, $count) {
            <item name="{$label}" count="{$count}" />
          })}
        </facet> 

};

declare function rpt:get-index-statistics () 
{
 let $config := doc("/db/system/config" || $rpt:collection || "/" || "collection.xconf")
 
 
 let $fields := $config//cc:text[@qname='tei:entry']/cc:field
 let $facets := $config//cc:text[@qname='tei:entry']/cc:facet

return
 <statistics>{
  rpt:get-collection-statistics(),
  rpt:get-nodes-statistics(),
  rpt:get-fields-statistics($fields),
  rpt:get-facets-statistics($facets)
 }
 </statistics>

}; 

declare function rpt:get-entry-fields() {
 let $config := doc("/db/system/config" || $rpt:collection || "/" || "collection.xconf")
 
 
 let $config-fields := $config//cc:text[@qname='tei:entry']/cc:field
 let $config-facets := $config//cc:text[@qname='tei:entry']/cc:facet

 
let $options := map {
"leading-wildcard": "yes",
"filter-rewrite": "yes",
"fields": $config-fields 
}

let $query := ()


let $ftq := collection($rpt:collection)//id($rpt:item-id)/ancestor-or-self::tei:entry[ft:query(., $query, $options)]

let $fields := if (empty($ftq)) 
 then () 
  else
  for $field in $options?fields
  return <rpt:field name="{$field}">{
    let $items :=  ft:field($ftq, $field)
    return
       if(count($items) lt 2) 
        then $items 
       else 
        for $item at $i in $items  
         return <rpt:item n="{$i}">{$item}</rpt:item>
    }</rpt:field>


return <rpt:details id="{$rpt:entry-id}"> {
 if (empty($ftq)) then () 
  else
 ($ftq, <rpt:fields>{$fields}</rpt:fields>) 
 }
 </rpt:details>
};


declare function rpt:report($request as map(*)) { 
  let $rpt:max-items := $request?properties?count
  return rpt:get-index-statistics()
};
