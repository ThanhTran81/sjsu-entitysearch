export SOLR_DOCS=/Users/hainguyen/Documents/search/dbpedia_data/out_data/yago-AmericanFilmDirectors
java -Dcommit=yes -Durl=http://localhost:8983/solr/collection1/update -jar post.jar $SOLR_DOCS/*.xml