var fields = {
    // Sure to include text
    'rdfs:label': 'rdf:langString',
    'rdfs:comment': 'rdf:langString',
    'abstract': 'rdf:langString',
    'awardName': 'xsd:string',
    'publication': 'xsd:string',
    'locationName': 'xsd:string',
    'dc:title': 'xsd:string', // Title that's a plain xsd:string, not rdf:langString (i.e. doesn't carry a language tag)
    'description': 'rdf:langString',
    'foaf:familyName': 'rdf:langString',
    'foaf:givenName': 'rdf:langString',
    'foaf:name': 'rdf:langString',
    'foaf:nick': 'rdf:langString',
    'foaf:surname': 'rdf:langString',
    'address': 'rdf:langString',
    'alias': 'rdf:langString',
    'dc:type': 'xsd:string',
    'dbpprop:type': 'rdf:langString',
    'exhibition': 'xsd:string',
    'foaf:gender': 'xsd:string',
    'foaf:mbox': 'xsd:string',
    'role': 'xsd:string',
    'title': 'rdf:langString',
    'synonym': 'xsd:string',
    'dc:description': 'xsd:string',

    // Sure to include resource
    'owl:sameAs': 'owl:Thing',
    'creator': 'Person',
    'author': 'Person',
    'director': 'Person',
    'executiveProducer': 'Person',
    'producer': 'resource',
    'activity': 'owl:Thing',
    'influenced': 'Person',
    'influencedBy': 'Person',
    'designer': 'Person',
    'writer': 'Person',
    'mainCharacter': 'Person',
    'editor': 'Agent',
    'starring': 'Actor',
    'occupation': 'PersonFunction',
    'foundedBy': 'Agent',
    'followedBy': 'owl:Thing',
    'follows': 'owl:Thing',
    'founder': 'owl:Thing',
    'album': 'Album',
    'company': 'Organisation',
    'country': 'Country',
    'currentCity': 'City',
    'almaMater': 'EducationalInstitution',
    'award': 'Award',
    'college': 'EducationalInstitution',
    'contest': 'Contest',
    'created': 'Work',
    'employer': 'Organisation',
    'education': 'owl:Thing',
    'educationPlace': 'Place',
    'movie': 'Film',
    'notableWork': 'Work',
    'personFunction': 'PersonFunction',
    'profession': 'owl:Thing',
    'project': 'Project',
    'school': 'EducationalInstitution',
    'university': 'EducationalInstitution',
    'academyAward': 'Award',
    'cesarAward': 'Award',
    'emmyAward': 'Award',
    'field': 'owl:Thing',
    'goldenGlobeAward': 'Award',
    'grammyAward': 'Award',
    'knownFor': 'owl:Thing',
    'mentor': 'Artist',
    'training': 'EducationalInstitution',
    'tvShow': 'TelevisionShow',
    'industry': 'owl:Thing',
    'basedOn': 'Work',
    'dc:publisher': 'Agent',
    'dct:references': 'owl:Thing',
    'dct:source': 'owl:Thing',
    'museum': 'Museum',
    'producedBy': 'Company',
    'productionCompany': 'Company',
    'productionCompany': 'Company',
    'dbpprop:artist': 'resource',
    'dbpprop:museum': 'resource',
    'dbpprop:city': 'resource',
    'dbpprop:directedby' : 'resource',
    'dbpprop:director': 'resource',
    'dbpprop:education': 'resource',
    'dbpprop:producer': 'resource',
    'dbpprop:influenced': 'resource',
    'dbpprop:creator': 'resource',
    'dbpprop:writer': 'resource',
    'dbpprop:writtenby': 'resource',
    'dbpprop:almaMater': 'resource',
    'dbpprop:name': 'rdf:langString',
    'dbpprop:nationality': 'resource',
    'dbpprop:notableWorks': 'resource',
    'dbpprop:occupation': 'resource',
    'dbpprop:placeOfBirth': 'resource',
    'dbpprop:shortDescription': 'resource',
    'dbpprop:title': 'rdf:langString',
    'dc:subject': 'owl:Thing',
    'dct:subject': 'owl:Thing',
    'dcterms:subject': 'owl:Thing',
    'achievement': 'owl:Thing',
    'rdfs:seeAlso': 'owl:Thing',
    'mainInterest': 'owl:Thing',
    'organisation': 'Organisation',
    'isPartOf': 'owl:Thing',
    'event': 'Event',
    'genre': 'Genre',
    'foaf:isPrimaryTopicOf': 'foaf:Document',
    'foaf:primaryTopic': 'resource',
    'foaf:topic': 'owl:Thing',
    'institution': 'Organisation',
    'location': 'Place',
    'locationCountry': 'Country',
    'dbpprop:story': 'resource',
    'dbpprop:subject': 'resource'

    // Think
    //'rdf:type': 'owl:Thing',
    
    // Exclude
    //'language': 'Language',
    //'league': 'SportsLeague',
    //'owningCompany': 'Company',
    //'owningOrganisation': 'Organisation',
    //'publisher': 'Company',
    //'region': 'Place',
    //'skills': 'owl:Thing',
    //'manufacturer': 'Organisation',
    //'sport': 'Sport',
    //'team': 'SportsTeam',
    //'agency': 'owl:Thing',
    //'citizenship': 'owl:Thing',
    //'hometown': 'Settlement',
    //'honours': 'owl:Thing',
    //'nationality': 'Country',
    //'roleInEvent': 'Event',
    //'sportDiscipline': 'Sport',
    //'alternativeTitle': 'rdf:langString',
    // 'keyPerson': 'Person',
    // 'leader': 'Person',
    // 'opponent': 'Person',
    // 'parent': 'Person',
    // 'partner': 'Person',
    // 'spouse': 'Person',
    // 'colleague': 'Person',
    // 'friend': 'Person',
    // 'painter': 'Person',
    // 'narrator': 'Person',
    // 'composer': 'Person',
    // 'chiefEditor': 'Person',
    // 'coverArtist': 'Person',
    // 'mayor': 'Mayor',
    // 'radio': 'RadioStation',
    // 'musicComposer': 'MusicalArtist',
};

var output = '';
 
for (var prop in fields) {
    if (fields.hasOwnProperty(prop)) {
        var isDBPediaOwl = prop.indexOf(":") === -1;
        var isString = fields[prop] === 'xsd:string';

        var fieldMatch = "";
    
        if (isDBPediaOwl) {
          fieldMatch = 'dbpedia-owl:' + prop;
        } else {
          fieldMatch = prop;
        }

        var fieldName = fieldMatch;
        fieldName = fieldName.replace(':', '_');

        if (isString) {
          output += '<xsl:template match="/rdf:RDF/rdf:Description/' + fieldMatch + '">'
                  + '<field name="' + fieldName + '_text' + '">'
                  + '<xsl:value-of select="." />'
                  + '</field></xsl:template>';
        } else {
          output += '<xsl:template match="/rdf:RDF/rdf:Description/' + fieldMatch + '[@xml:lang=\'en\']">'
                  + '<field name="' + fieldName + '_text' + '">'
                  + '<xsl:value-of select="." />'
                  + '</field></xsl:template>';

          output += '<xsl:template match="/rdf:RDF/rdf:Description/' + fieldMatch + '[@rdf:resource]">'
                  + '<field name="' + fieldName + '_resource' + '">'
                  + '<xsl:value-of select="@rdf:resource" />'
                  + '</field></xsl:template>';
        }
    }
}

console.log(output);
 
var relatedClasses = [
    'Album',
    'Organisation',
    'Country',
    'City',
    'Event',
    'Genre',
    'Mayor' ,
    'Sport',
    'Place',
    'Company',
    'PersonFunction',
    'Language',
    'SportsLeague',
    'SportsTeam',
    'EducationalInstitution',
    'Award',
    'Contest',
    'Work',
    'Settlement',
    'Film',
    'Project',
    'RadioStation',
    'Artist',
    'TelevisionShow',
    'Actor',
    'Museum'
];