<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
   xmlns:dbpedia-owl="http://dbpedia.org/ontology/" 
   xmlns:dbpprop="http://dbpedia.org/property/" 
   xmlns:dc="http://purl.org/dc/elements/1.1/" 
   xmlns:dct="http://purl.org/dc/terms/" 
   xmlns:dcterms="http://purl.org/dc/terms/" 
   xmlns:foaf="http://xmlns.com/foaf/0.1/" 
   xmlns:ns8="http://www.w3.org/ns/prov#" 
   xmlns:owl="http://www.w3.org/2002/07/owl#" 
   xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
   xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
   xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
   xmlns:wdrs="http://www.w3.org/2007/05/powder-s#" 
   version="1.0" exclude-result-prefixes="xsl rdf dc dct rdfs owl dbpedia-owl foaf dcterms wdrs dbpprop ns8 skos">
   
   <xsl:output omit-xml-declaration="yes" indent="yes" />
   <xsl:template match="*|@*|text()">
      <xsl:apply-templates />
   </xsl:template>
   
   <xsl:template match="/">
      <!-- <add overwrite="true"> -->
      <xsl:for-each select="rdf:RDF/rdf:Description">
      <xsl:if test="rdfs:label">
         <doc>
            <field name="uri">
               <xsl:value-of select="@rdf:about" />
            </field>
            <!-- <field name="timestamp">NOW</field> -->
            <xsl:apply-templates />
         </doc>
      </xsl:if>
      </xsl:for-each>
      <!-- </add> -->
   </xsl:template>
   
   <xsl:template match="/rdf:RDF/rdf:Description/rdfs:label[not(@*)]|/rdf:RDF/rdf:Description/rdfs:label[@xml:lang='en']">
      <field name="rdfs_label_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/rdfs:label[@rdf:resource]">
      <field name="rdfs_label_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/rdfs:comment[@xml:lang='en']">
      <field name="rdfs_comment_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/rdfs:comment[@rdf:resource]">
      <field name="rdfs_comment_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:abstract[@xml:lang='en']">
      <field name="dbpedia-owl_abstract_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:abstract[@rdf:resource]">
      <field name="dbpedia-owl_abstract_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:awardName">
      <field name="dbpedia-owl_awardName_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:publication">
      <field name="dbpedia-owl_publication_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:locationName">
      <field name="dbpedia-owl_locationName_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dc:title">
      <field name="dc_title_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:description[@xml:lang='en']">
      <field name="dbpedia-owl_description_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:description[@rdf:resource]">
      <field name="dbpedia-owl_description_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:familyName[@xml:lang='en']">
      <field name="foaf_familyName_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:familyName[@rdf:resource]">
      <field name="foaf_familyName_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:givenName[@xml:lang='en']">
      <field name="foaf_givenName_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:givenName[@rdf:resource]">
      <field name="foaf_givenName_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:name[@xml:lang='en']">
      <field name="foaf_name_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:name[@rdf:resource]">
      <field name="foaf_name_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:nick[@xml:lang='en']">
      <field name="foaf_nick_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:nick[@rdf:resource]">
      <field name="foaf_nick_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:surname[@xml:lang='en']">
      <field name="foaf_surname_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:surname[@rdf:resource]">
      <field name="foaf_surname_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:address[@xml:lang='en']">
      <field name="dbpedia-owl_address_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:address[@rdf:resource]">
      <field name="dbpedia-owl_address_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:alias[@xml:lang='en']">
      <field name="dbpedia-owl_alias_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:alias[@rdf:resource]">
      <field name="dbpedia-owl_alias_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dc:type">
      <field name="dc_type_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:type[@xml:lang='en']">
      <field name="dbpprop_type_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:type[@rdf:resource]">
      <field name="dbpprop_type_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:exhibition">
      <field name="dbpedia-owl_exhibition_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:gender">
      <field name="foaf_gender_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:mbox">
      <field name="foaf_mbox_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:role">
      <field name="dbpedia-owl_role_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:title[@xml:lang='en']">
      <field name="dbpedia-owl_title_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:title[@rdf:resource]">
      <field name="dbpedia-owl_title_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:synonym">
      <field name="dbpedia-owl_synonym_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dc:description">
      <field name="dc_description_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/owl:sameAs[@xml:lang='en']">
      <field name="owl_sameAs_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/owl:sameAs[@rdf:resource]">
      <field name="owl_sameAs_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:creator[@xml:lang='en']">
      <field name="dbpedia-owl_creator_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:creator[@rdf:resource]">
      <field name="dbpedia-owl_creator_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:author[@xml:lang='en']">
      <field name="dbpedia-owl_author_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:author[@rdf:resource]">
      <field name="dbpedia-owl_author_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:director[@xml:lang='en']">
      <field name="dbpedia-owl_director_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:director[@rdf:resource]">
      <field name="dbpedia-owl_director_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:executiveProducer[@xml:lang='en']">
      <field name="dbpedia-owl_executiveProducer_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:executiveProducer[@rdf:resource]">
      <field name="dbpedia-owl_executiveProducer_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:producer[@xml:lang='en']">
      <field name="dbpedia-owl_producer_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:producer[@rdf:resource]">
      <field name="dbpedia-owl_producer_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:activity[@xml:lang='en']">
      <field name="dbpedia-owl_activity_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:activity[@rdf:resource]">
      <field name="dbpedia-owl_activity_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:influenced[@xml:lang='en']">
      <field name="dbpedia-owl_influenced_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:influenced[@rdf:resource]">
      <field name="dbpedia-owl_influenced_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:influencedBy[@xml:lang='en']">
      <field name="dbpedia-owl_influencedBy_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:influencedBy[@rdf:resource]">
      <field name="dbpedia-owl_influencedBy_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:designer[@xml:lang='en']">
      <field name="dbpedia-owl_designer_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:designer[@rdf:resource]">
      <field name="dbpedia-owl_designer_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:writer[@xml:lang='en']">
      <field name="dbpedia-owl_writer_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:writer[@rdf:resource]">
      <field name="dbpedia-owl_writer_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:mainCharacter[@xml:lang='en']">
      <field name="dbpedia-owl_mainCharacter_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:mainCharacter[@rdf:resource]">
      <field name="dbpedia-owl_mainCharacter_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:editor[@xml:lang='en']">
      <field name="dbpedia-owl_editor_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:editor[@rdf:resource]">
      <field name="dbpedia-owl_editor_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:starring[@xml:lang='en']">
      <field name="dbpedia-owl_starring_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:starring[@rdf:resource]">
      <field name="dbpedia-owl_starring_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:occupation[@xml:lang='en']">
      <field name="dbpedia-owl_occupation_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:occupation[@rdf:resource]">
      <field name="dbpedia-owl_occupation_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:foundedBy[@xml:lang='en']">
      <field name="dbpedia-owl_foundedBy_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:foundedBy[@rdf:resource]">
      <field name="dbpedia-owl_foundedBy_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:followedBy[@xml:lang='en']">
      <field name="dbpedia-owl_followedBy_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:followedBy[@rdf:resource]">
      <field name="dbpedia-owl_followedBy_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:follows[@xml:lang='en']">
      <field name="dbpedia-owl_follows_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:follows[@rdf:resource]">
      <field name="dbpedia-owl_follows_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:founder[@xml:lang='en']">
      <field name="dbpedia-owl_founder_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:founder[@rdf:resource]">
      <field name="dbpedia-owl_founder_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:album[@xml:lang='en']">
      <field name="dbpedia-owl_album_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:album[@rdf:resource]">
      <field name="dbpedia-owl_album_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:company[@xml:lang='en']">
      <field name="dbpedia-owl_company_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:company[@rdf:resource]">
      <field name="dbpedia-owl_company_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:country[@xml:lang='en']">
      <field name="dbpedia-owl_country_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:country[@rdf:resource]">
      <field name="dbpedia-owl_country_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:currentCity[@xml:lang='en']">
      <field name="dbpedia-owl_currentCity_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:currentCity[@rdf:resource]">
      <field name="dbpedia-owl_currentCity_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:almaMater[@xml:lang='en']">
      <field name="dbpedia-owl_almaMater_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:almaMater[@rdf:resource]">
      <field name="dbpedia-owl_almaMater_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:award[@xml:lang='en']">
      <field name="dbpedia-owl_award_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:award[@rdf:resource]">
      <field name="dbpedia-owl_award_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:college[@xml:lang='en']">
      <field name="dbpedia-owl_college_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:college[@rdf:resource]">
      <field name="dbpedia-owl_college_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:contest[@xml:lang='en']">
      <field name="dbpedia-owl_contest_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:contest[@rdf:resource]">
      <field name="dbpedia-owl_contest_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:created[@xml:lang='en']">
      <field name="dbpedia-owl_created_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:created[@rdf:resource]">
      <field name="dbpedia-owl_created_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:employer[@xml:lang='en']">
      <field name="dbpedia-owl_employer_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:employer[@rdf:resource]">
      <field name="dbpedia-owl_employer_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:education[@xml:lang='en']">
      <field name="dbpedia-owl_education_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:education[@rdf:resource]">
      <field name="dbpedia-owl_education_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:educationPlace[@xml:lang='en']">
      <field name="dbpedia-owl_educationPlace_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:educationPlace[@rdf:resource]">
      <field name="dbpedia-owl_educationPlace_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:movie[@xml:lang='en']">
      <field name="dbpedia-owl_movie_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:movie[@rdf:resource]">
      <field name="dbpedia-owl_movie_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:notableWork[@xml:lang='en']">
      <field name="dbpedia-owl_notableWork_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:notableWork[@rdf:resource]">
      <field name="dbpedia-owl_notableWork_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:personFunction[@xml:lang='en']">
      <field name="dbpedia-owl_personFunction_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:personFunction[@rdf:resource]">
      <field name="dbpedia-owl_personFunction_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:profession[@xml:lang='en']">
      <field name="dbpedia-owl_profession_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:profession[@rdf:resource]">
      <field name="dbpedia-owl_profession_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:project[@xml:lang='en']">
      <field name="dbpedia-owl_project_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:project[@rdf:resource]">
      <field name="dbpedia-owl_project_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:school[@xml:lang='en']">
      <field name="dbpedia-owl_school_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:school[@rdf:resource]">
      <field name="dbpedia-owl_school_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:university[@xml:lang='en']">
      <field name="dbpedia-owl_university_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:university[@rdf:resource]">
      <field name="dbpedia-owl_university_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:academyAward[@xml:lang='en']">
      <field name="dbpedia-owl_academyAward_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:academyAward[@rdf:resource]">
      <field name="dbpedia-owl_academyAward_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:cesarAward[@xml:lang='en']">
      <field name="dbpedia-owl_cesarAward_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:cesarAward[@rdf:resource]">
      <field name="dbpedia-owl_cesarAward_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:emmyAward[@xml:lang='en']">
      <field name="dbpedia-owl_emmyAward_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:emmyAward[@rdf:resource]">
      <field name="dbpedia-owl_emmyAward_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:field[@xml:lang='en']">
      <field name="dbpedia-owl_field_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:field[@rdf:resource]">
      <field name="dbpedia-owl_field_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:goldenGlobeAward[@xml:lang='en']">
      <field name="dbpedia-owl_goldenGlobeAward_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:goldenGlobeAward[@rdf:resource]">
      <field name="dbpedia-owl_goldenGlobeAward_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:grammyAward[@xml:lang='en']">
      <field name="dbpedia-owl_grammyAward_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:grammyAward[@rdf:resource]">
      <field name="dbpedia-owl_grammyAward_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:knownFor[@xml:lang='en']">
      <field name="dbpedia-owl_knownFor_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:knownFor[@rdf:resource]">
      <field name="dbpedia-owl_knownFor_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:mentor[@xml:lang='en']">
      <field name="dbpedia-owl_mentor_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:mentor[@rdf:resource]">
      <field name="dbpedia-owl_mentor_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:training[@xml:lang='en']">
      <field name="dbpedia-owl_training_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:training[@rdf:resource]">
      <field name="dbpedia-owl_training_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:tvShow[@xml:lang='en']">
      <field name="dbpedia-owl_tvShow_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:tvShow[@rdf:resource]">
      <field name="dbpedia-owl_tvShow_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:industry[@xml:lang='en']">
      <field name="dbpedia-owl_industry_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:industry[@rdf:resource]">
      <field name="dbpedia-owl_industry_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:basedOn[@xml:lang='en']">
      <field name="dbpedia-owl_basedOn_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:basedOn[@rdf:resource]">
      <field name="dbpedia-owl_basedOn_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dc:publisher[@xml:lang='en']">
      <field name="dc_publisher_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dc:publisher[@rdf:resource]">
      <field name="dc_publisher_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dct:references[@xml:lang='en']">
      <field name="dct_references_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dct:references[@rdf:resource]">
      <field name="dct_references_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dct:source[@xml:lang='en']">
      <field name="dct_source_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dct:source[@rdf:resource]">
      <field name="dct_source_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:museum[@xml:lang='en']">
      <field name="dbpedia-owl_museum_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:museum[@rdf:resource]">
      <field name="dbpedia-owl_museum_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:producedBy[@xml:lang='en']">
      <field name="dbpedia-owl_producedBy_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:producedBy[@rdf:resource]">
      <field name="dbpedia-owl_producedBy_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:productionCompany[@xml:lang='en']">
      <field name="dbpedia-owl_productionCompany_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:productionCompany[@rdf:resource]">
      <field name="dbpedia-owl_productionCompany_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:artist[@xml:lang='en']">
      <field name="dbpprop_artist_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:artist[@rdf:resource]">
      <field name="dbpprop_artist_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:museum[@xml:lang='en']">
      <field name="dbpprop_museum_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:museum[@rdf:resource]">
      <field name="dbpprop_museum_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:city[@xml:lang='en']">
      <field name="dbpprop_city_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:city[@rdf:resource]">
      <field name="dbpprop_city_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:directedby[@xml:lang='en']">
      <field name="dbpprop_directedby_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:directedby[@rdf:resource]">
      <field name="dbpprop_directedby_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:director[@xml:lang='en']">
      <field name="dbpprop_director_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:director[@rdf:resource]">
      <field name="dbpprop_director_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:education[@xml:lang='en']">
      <field name="dbpprop_education_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:education[@rdf:resource]">
      <field name="dbpprop_education_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:producer[@xml:lang='en']">
      <field name="dbpprop_producer_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:producer[@rdf:resource]">
      <field name="dbpprop_producer_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:influenced[@xml:lang='en']">
      <field name="dbpprop_influenced_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:influenced[@rdf:resource]">
      <field name="dbpprop_influenced_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:creator[@xml:lang='en']">
      <field name="dbpprop_creator_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:creator[@rdf:resource]">
      <field name="dbpprop_creator_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:writer[@xml:lang='en']">
      <field name="dbpprop_writer_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:writer[@rdf:resource]">
      <field name="dbpprop_writer_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:writtenby[@xml:lang='en']">
      <field name="dbpprop_writtenby_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:writtenby[@rdf:resource]">
      <field name="dbpprop_writtenby_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:almaMater[@xml:lang='en']">
      <field name="dbpprop_almaMater_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:almaMater[@rdf:resource]">
      <field name="dbpprop_almaMater_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:name[@xml:lang='en']">
      <field name="dbpprop_name_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:name[@rdf:resource]">
      <field name="dbpprop_name_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:nationality[@xml:lang='en']">
      <field name="dbpprop_nationality_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:nationality[@rdf:resource]">
      <field name="dbpprop_nationality_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:notableWorks[@xml:lang='en']">
      <field name="dbpprop_notableWorks_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:notableWorks[@rdf:resource]">
      <field name="dbpprop_notableWorks_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:occupation[@xml:lang='en']">
      <field name="dbpprop_occupation_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:occupation[@rdf:resource]">
      <field name="dbpprop_occupation_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:placeOfBirth[@xml:lang='en']">
      <field name="dbpprop_placeOfBirth_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:placeOfBirth[@rdf:resource]">
      <field name="dbpprop_placeOfBirth_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:shortDescription[@xml:lang='en']">
      <field name="dbpprop_shortDescription_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:shortDescription[@rdf:resource]">
      <field name="dbpprop_shortDescription_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:title[@xml:lang='en']">
      <field name="dbpprop_title_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:title[@rdf:resource]">
      <field name="dbpprop_title_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dc:subject[@xml:lang='en']">
      <field name="dc_subject_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dc:subject[@rdf:resource]">
      <field name="dc_subject_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dct:subject[@xml:lang='en']">
      <field name="dct_subject_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dct:subject[@rdf:resource]">
      <field name="dct_subject_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dcterms:subject[@xml:lang='en']">
      <field name="dcterms_subject_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dcterms:subject[@rdf:resource]">
      <field name="dcterms_subject_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:achievement[@xml:lang='en']">
      <field name="dbpedia-owl_achievement_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:achievement[@rdf:resource]">
      <field name="dbpedia-owl_achievement_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/rdfs:seeAlso[@xml:lang='en']">
      <field name="rdfs_seeAlso_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/rdfs:seeAlso[@rdf:resource]">
      <field name="rdfs_seeAlso_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:mainInterest[@xml:lang='en']">
      <field name="dbpedia-owl_mainInterest_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:mainInterest[@rdf:resource]">
      <field name="dbpedia-owl_mainInterest_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:organisation[@xml:lang='en']">
      <field name="dbpedia-owl_organisation_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:organisation[@rdf:resource]">
      <field name="dbpedia-owl_organisation_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:isPartOf[@xml:lang='en']">
      <field name="dbpedia-owl_isPartOf_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:isPartOf[@rdf:resource]">
      <field name="dbpedia-owl_isPartOf_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:event[@xml:lang='en']">
      <field name="dbpedia-owl_event_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:event[@rdf:resource]">
      <field name="dbpedia-owl_event_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:genre[@xml:lang='en']">
      <field name="dbpedia-owl_genre_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:genre[@rdf:resource]">
      <field name="dbpedia-owl_genre_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:isPrimaryTopicOf[@xml:lang='en']">
      <field name="foaf_isPrimaryTopicOf_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:isPrimaryTopicOf[@rdf:resource]">
      <field name="foaf_isPrimaryTopicOf_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:primaryTopic[@xml:lang='en']">
      <field name="foaf_primaryTopic_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:primaryTopic[@rdf:resource]">
      <field name="foaf_primaryTopic_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:topic[@xml:lang='en']">
      <field name="foaf_topic_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/foaf:topic[@rdf:resource]">
      <field name="foaf_topic_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:institution[@xml:lang='en']">
      <field name="dbpedia-owl_institution_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:institution[@rdf:resource]">
      <field name="dbpedia-owl_institution_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:location[@xml:lang='en']">
      <field name="dbpedia-owl_location_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:location[@rdf:resource]">
      <field name="dbpedia-owl_location_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:locationCountry[@xml:lang='en']">
      <field name="dbpedia-owl_locationCountry_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpedia-owl:locationCountry[@rdf:resource]">
      <field name="dbpedia-owl_locationCountry_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:story[@xml:lang='en']">
      <field name="dbpprop_story_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:story[@rdf:resource]">
      <field name="dbpprop_story_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:subject[@xml:lang='en']">
      <field name="dbpprop_subject_text">
         <xsl:value-of select="." />
      </field>
   </xsl:template>
   <xsl:template match="/rdf:RDF/rdf:Description/dbpprop:subject[@rdf:resource]">
      <field name="dbpprop_subject_resource">
         <xsl:value-of select="@rdf:resource" />
      </field>
   </xsl:template>
</xsl:stylesheet>
