for i in $( ls *.xml); do
    cat $i | curl -X POST -H 'Content-Type: text/xml' -d @- http://localhost:8983/solr/collection1/update
    echo item: $i
done