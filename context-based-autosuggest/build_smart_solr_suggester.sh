rm -rf bin/*

javac -d ./bin -cp ../build/lucene-libs/lucene-core-4.10.3-SNAPSHOT.jar:../build/lucene-libs/lucene-analyzers-common-4.10.3-SNAPSHOT.jar:../build/lucene-libs/lucene-suggest-4.10.3-SNAPSHOT.jar:../build/solr-core/solr-core-4.10.3-SNAPSHOT.jar:../dist/solr-solrj-4.10.3-SNAPSHOT.jar:/Users/hainguyen/.ivy2/cache/org.slf4j/slf4j-api/jars/slf4j-api-1.7.6.jar src/java/org/apache/solr/spelling/suggest/*.java src/java/org/apache/lucene/search/suggest/analyzing/SmartAnalyzingSuggester.java

cd bin

jar cf temp.jar org

cd ..

javac -d ./bin -cp ../build/lucene-libs/lucene-core-4.10.3-SNAPSHOT.jar:../build/lucene-libs/lucene-analyzers-common-4.10.3-SNAPSHOT.jar:../build/lucene-libs/lucene-suggest-4.10.3-SNAPSHOT.jar:../build/solr-core/solr-core-4.10.3-SNAPSHOT.jar:../dist/solr-solrj-4.10.3-SNAPSHOT.jar:/Users/hainguyen/.ivy2/cache/org.slf4j/slf4j-api/jars/slf4j-api-1.7.6.jar:bin/temp.jar src/java/org/apache/solr/handler/component/SmartSuggestComponent.java

cd bin

jar cf smart.jar org

cp smart.jar ~/Documents/search/solr-4.10.3/myPlugins/