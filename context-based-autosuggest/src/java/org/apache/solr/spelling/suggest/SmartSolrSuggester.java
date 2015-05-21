package org.apache.solr.spelling.suggest;

/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import java.io.*;
import java.net.*;
// import java.io.Closeable;
// import java.io.File;
// import java.io.FileInputStream;
// import java.io.FileOutputStream;
// import java.io.IOException;
import java.util.List;

import org.apache.lucene.search.spell.Dictionary;
import org.apache.lucene.search.suggest.Lookup;
import org.apache.lucene.search.suggest.Lookup.LookupResult;
import org.apache.lucene.util.Accountable;
import org.apache.lucene.util.IOUtils;
import org.apache.solr.common.util.NamedList;
import org.apache.solr.core.CloseHook;
import org.apache.solr.core.SolrCore;
import org.apache.solr.search.SolrIndexSearcher;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.lucene.search.suggest.analyzing.SmartAnalyzingSuggester;
import org.apache.solr.search.DocSet;
import org.apache.solr.search.SortedIntDocSet;
import org.apache.solr.search.BitDocSet;
import java.util.Comparator;
import org.apache.lucene.util.BytesRef;
import java.util.Collections;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.TermQuery;
import org.apache.lucene.index.Term;
import java.util.Iterator;
import java.util.Arrays;

import org.apache.lucene.index.IndexReader;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.StoredField;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

/** 
 * Responsible for loading the lookup and dictionary Implementations specified by 
 * the SolrConfig. 
 * Interacts (query/build/reload) with Lucene Suggesters through {@link Lookup} and
 * {@link Dictionary}
 * */
public class SmartSolrSuggester implements Accountable {
  private static final Logger LOG = LoggerFactory.getLogger(SmartSolrSuggester.class);
  
  /** Name used when an unnamed suggester config is passed */
  public static final String DEFAULT_DICT_NAME = "default";
  
  /** Label to identify the name of the suggester */
  public static final String NAME = "name";
  
  /** Location of the source data - either a path to a file, or null for the
   * current IndexReader.
   * */
  public static final String LOCATION = "sourceLocation";
  
  /** Fully-qualified class of the {@link Lookup} implementation. */
  public static final String LOOKUP_IMPL = "lookupImpl";
  
  /** Fully-qualified class of the {@link Dictionary} implementation */
  public static final String DICTIONARY_IMPL = "dictionaryImpl";
  
  /**
   * Name of the location where to persist the dictionary. If this location
   * is relative then the data will be stored under the core's dataDir. If this
   * is null the storing will be disabled.
   */
  public static final String STORE_DIR = "storeDir";
  
  static SuggesterResult EMPTY_RESULT = new SuggesterResult();
  
  private String sourceLocation;
  private File storeDir;
  private Dictionary dictionary;
  private Lookup lookup;
  private String lookupImpl;
  private String dictionaryImpl;
  private String name;

  private LookupFactory factory;
  private DictionaryFactory dictionaryFactory;

  private SolrIndexSearcher solrIndexSearcher;
  private ArrayList<Integer> containingDocsList;
  private ArrayList<Integer> relatedDocsList;
  private int[] contextContainingDocsArr;
  private int[] contextRelatedDocsArr;

  public void setSolrIndexSearcher(SolrIndexSearcher solrIndexSearcher) {
    System.out.println("setSolrIndexSearcher()");
    this.solrIndexSearcher = solrIndexSearcher;
  }
  
  /** 
   * Uses the <code>config</code> and the <code>core</code> to initialize the underlying 
   * Lucene suggester
   * */
  public String init(NamedList<?> config, SolrCore core) {
    LOG.info("init: " + config);

    // read the config
    name = config.get(NAME) != null ? (String) config.get(NAME)
        : DEFAULT_DICT_NAME;
    sourceLocation = (String) config.get(LOCATION);
    lookupImpl = (String) config.get(LOOKUP_IMPL);
    dictionaryImpl = (String) config.get(DICTIONARY_IMPL);
    String store = (String)config.get(STORE_DIR);

    if (lookupImpl == null) {
      lookupImpl = LookupFactory.DEFAULT_FILE_BASED_DICT;
      LOG.info("No " + LOOKUP_IMPL + " parameter was provided falling back to " + lookupImpl);
    }
    // initialize appropriate lookup instance
    factory = core.getResourceLoader().newInstance(lookupImpl, LookupFactory.class);
    lookup = factory.create(config, core);
    core.addCloseHook(new CloseHook() {
      @Override
      public void preClose(SolrCore core) {
        if (lookup != null && lookup instanceof Closeable) {
          try {
            ((Closeable) lookup).close();
          } catch (IOException e) {
            LOG.warn("Could not close the suggester lookup.", e);
          }
        }
      }
      
      @Override
      public void postClose(SolrCore core) {}
    });

    // if store directory is provided make it or load up the lookup with its content
    if (store != null) {
      System.out.println(">>> #1 SmartSolrSuggester.init() - store = " + store);
      storeDir = new File(store);
      System.out.println(">>> #2 SmartSolrSuggester.init() - storeDir = " + storeDir);

      if (!storeDir.isAbsolute()) {
        storeDir = new File(core.getDataDir() + File.separator + storeDir);
        System.out.println(">>> #3 SmartSolrSuggester.init() - !storeDir.isAbsolute(), new storeDir = " + storeDir);
      }

      if (!storeDir.exists()) {
        storeDir.mkdirs();
        System.out.println(">>> #4 SmartSolrSuggester.init() - !storeDir.exists(), storeDir.mkdirs()");
      } else {
        // attempt reload of the stored lookup
        try {
          lookup.load(new FileInputStream(new File(storeDir, factory.storeFileName())));
        } catch (IOException e) {
          LOG.warn("Loading stored lookup data failed, possibly not cached yet");
        }
      }
    }
    
    // dictionary configuration
    if (dictionaryImpl == null) {
      dictionaryImpl = (sourceLocation == null) ? DictionaryFactory.DEFAULT_INDEX_BASED_DICT : 
        DictionaryFactory.DEFAULT_FILE_BASED_DICT;
      LOG.info("No " + DICTIONARY_IMPL + " parameter was provided falling back to " + dictionaryImpl);
    }
    
    dictionaryFactory = core.getResourceLoader().newInstance(dictionaryImpl, DictionaryFactory.class);
    dictionaryFactory.setParams(config);
    LOG.info("Dictionary loaded with params: " + config);

    return name;
  }

  /** Build the underlying Lucene Suggester */
  public void build(SolrCore core, SolrIndexSearcher searcher) throws IOException {
    LOG.info("build()");

    dictionary = dictionaryFactory.create(core, searcher);
    lookup.build(dictionary);
    if (storeDir != null) {
      File target = new File(storeDir, factory.storeFileName());
      if(!lookup.store(new FileOutputStream(target))) {
        LOG.error("Store Lookup build fialed");
      } else {
        LOG.info("Stored suggest data to: " + target.getAbsolutePath());
      }
    }
  }

  /** Reloads the underlying Lucene Suggester */
  public void reload(SolrCore core, SolrIndexSearcher searcher) throws IOException {
    LOG.info("reload()");
    if (dictionary == null && storeDir != null) {
      // this may be a firstSearcher event, try loading it
      FileInputStream is;
      try {
        is = new FileInputStream(new File(storeDir, factory.storeFileName()));
        if (lookup.load(is)) {
          return;  // loaded ok
        }
      } catch(IOException ex){
        System.out.println (ex.toString());
        System.out.println("Could not find file " + factory.storeFileName());
      } 

      /* finally {
        IOUtils.closeWhileHandlingException(is);
      } */
      LOG.debug("load failed, need to build Lookup again");
    }
    // loading was unsuccessful - build it again
    build(core, searcher);
  }

  /** Returns suggestions based on the {@link SuggesterOptions} passed */
  public SuggesterResult getSuggestions(ContextSuggesterOptions options) throws IOException {
    //LOG.debug("getSuggestions: " + options.token);
    if (lookup == null) {
      LOG.info("Lookup is null - invoke suggest.build first");
      return EMPTY_RESULT;
    }
    
    SuggesterResult res = new SuggesterResult();
    List<LookupResult> suggestions = ((SmartAnalyzingSuggester)lookup).lookup(options.token, null, false, options.count);

    // Sort resutls
    if (options.context != null) {
      this.setContainingAndRelatedDocs(options.context.toLowerCase());
      contextContainingDocsArr = convertIntegers(containingDocsList);
      contextRelatedDocsArr = convertIntegers(relatedDocsList);

      // System.out.println("#8 (Lookup - SmartSolrSuggester) Context containingDocsArr = " + Arrays.toString(contextContainingDocsArr));
      // System.out.println("#9 (Lookup - SmartSolrSuggester) Context relatedDocsArr = " + Arrays.toString(contextRelatedDocsArr));

      List<LookupResult> zeroList = new ArrayList<LookupResult>();
      List<LookupResult> nonZeroList = new ArrayList<LookupResult>();

      // System.out.println(">>> #10 suggestions = " + suggestions);

      for (LookupResult curResult : suggestions) {
        curResult.score = this.getScore(curResult.containingDocsBytesRef);
        // System.out.println(">>> #14 curResult.score = " + curResult.score);
        if (curResult.score == 0) {
          zeroList.add(curResult);
        } else if (curResult.score > 0) {
          nonZeroList.add(curResult);
        }
      }

      ScoreComparator scoreComparator = new ScoreComparator();
      Collections.sort(nonZeroList, scoreComparator);

      nonZeroList.addAll(zeroList);
      suggestions = nonZeroList; 
    }
    
    if (suggestions.size() > 25) {
      suggestions = suggestions.subList(0, 25);
    } 
    // System.out.println(">>> #17 suggestions = " + suggestions);
    res.add(getName(), options.token.toString(), suggestions);
    return res;
  }

  private class ScoreComparator implements Comparator<LookupResult> {
    public ScoreComparator() throws IOException {
      // System.out.println(">>> #15 ScoreComparator()");
    }

    @Override
    public int compare(LookupResult left, LookupResult right) {
      // System.out.println(">>> #16 compare() left = " + left.score + " - right = " + right.score);

      if (left.score > right.score) {
        return -1;
      } else if (left.score == right.score) {
        return 0;
      } else {
        return 1;
      }
    }
  }

  public int[] convertIntegers(List<Integer> integers) {
    int[] ret = new int[integers.size()];
    Iterator<Integer> iterator = integers.iterator();
    for (int i = 0; i < ret.length; i++)
    {
        ret[i] = iterator.next().intValue();
    }
    return ret;
  }

  public void setContainingAndRelatedDocs(String queryTerm) throws IOException {
    Set<Integer> containingDocsSet = new HashSet<Integer>();
    Set<Integer> relatedDocsset = new HashSet<Integer>();

    String url = "http://localhost:8983/solr/collection1/select";
    String charset = "UTF-8";  // Or in Java 7 and later, use the constant: java.nio.charset.StandardCharsets.UTF_8.name()
    String q = "\""+ queryTerm + "\"";
    String fl = "uri,relatedDocs";
    String wt = "csv";

    String queryString = String.format("q=%s&fl=%s&wt=%s",
                    URLEncoder.encode(q, charset), 
                    URLEncoder.encode(fl, charset),
                    URLEncoder.encode(wt, charset));

    String finalUrl = url + "?" + queryString;
    System.out.println(">>> finalUrl = " + finalUrl);

    URLConnection connection = new URL(finalUrl).openConnection();
    connection.setRequestProperty("Accept-Charset", charset);
    BufferedReader in = new BufferedReader(new InputStreamReader(connection.getInputStream()));
    String line;

    while ((line = in.readLine()) != null) {
      if (!line.equals("uri,relatedDocs")) {
        List<String> uriList = Arrays.asList(line.split(","));
        if (uriList.size() > 0) {
          containingDocsSet.add(uriList.get(0).hashCode());

          for (int i = 1; i < uriList.size(); i++) {
            relatedDocsset.add(uriList.get(i).hashCode());
          }
        }
      }
    }
    
    in.close();

    containingDocsList = new ArrayList<Integer>(containingDocsSet);
    for (Integer curDocId : containingDocsList) {
      relatedDocsset.remove(curDocId);
    }
    
    relatedDocsList = new ArrayList<Integer>(relatedDocsset);

    Collections.sort(containingDocsList);
    Collections.sort(relatedDocsList);
  }

  public int getScore(BytesRef currentSuggestBytesRef) throws IOException {
    byte[] currentSuggestBytes = currentSuggestBytesRef.bytes;
    int currentSuggestDocsLength = (int)(currentSuggestBytes.length/4);
    int[] currentSuggestDocs = new int[currentSuggestDocsLength];
    int score = 0;
    int count = 0;

    for (int i = 0; i < currentSuggestBytes.length; i+=4) {
      int finalInt= (currentSuggestBytes[i]<<24)&0xff000000|
             (currentSuggestBytes[i+1]<<16)&0x00ff0000|
             (currentSuggestBytes[i+2]<< 8)&0x0000ff00|
             (currentSuggestBytes[i+3]<< 0)&0x000000ff;

      currentSuggestDocs[count] = finalInt;
      count++;
    }

    Arrays.sort(currentSuggestDocs);
    // System.out.println(">>> #10 (Lookup - SmartSolrSuggester.getScore) current suggested term docs = " + Arrays.toString(currentSuggestDocs));

    if (contextContainingDocsArr != null && currentSuggestDocs.length != 0 && contextContainingDocsArr.length != 0) {
      int overlappedScore;
      if (currentSuggestDocs.length < contextContainingDocsArr.length) {
        overlappedScore = SortedIntDocSet.intersectionSize(currentSuggestDocs, contextContainingDocsArr);
      } else {  
        overlappedScore = SortedIntDocSet.intersectionSize(contextContainingDocsArr, currentSuggestDocs);
      }
      score += overlappedScore * 10;
      // System.out.println(">>> #11 first score = " + score);
    }

    if (contextRelatedDocsArr != null && currentSuggestDocs.length != 0 && contextRelatedDocsArr.length != 0) {
      int overlappedScore;
      if (currentSuggestDocs.length < contextRelatedDocsArr.length) {
        overlappedScore = SortedIntDocSet.intersectionSize(currentSuggestDocs, contextRelatedDocsArr);
      } else {
        overlappedScore = SortedIntDocSet.intersectionSize(contextRelatedDocsArr, currentSuggestDocs);
      }
      score += overlappedScore * 5;
      // System.out.println(">>> #12 mid-score = " + score);
    }
    
    // System.out.println(">>> #13 final score = " + score);
    return score;
  }

  private Set<String> getRelevantFields(String... fields) {
    Set<String> relevantFields = new HashSet<>();
    for (String relevantField : fields) {
      if (relevantField != null) {
        relevantFields.add(relevantField);
      }
    }
    return relevantFields;
  }

  public SortedIntDocSet getContextSortedDocIdSet(String context) throws IOException {
    LOG.info("----> context = " + context);
    Query query = new TermQuery(new Term("text", context.toLowerCase()));
    DocSet tempDocSet = this.solrIndexSearcher.getDocSet(query);
    
    int[] tempDocIdsArray = new int[0];
    
    if (tempDocSet instanceof BitDocSet) {
      BitDocSet bitDocSet = (BitDocSet)tempDocSet;
      int numDocs = bitDocSet.size();
      tempDocIdsArray = new int[numDocs];
      Iterator iter = bitDocSet.iterator();
      int curIdx = 0;
      
      while (iter.hasNext() && curIdx < numDocs) {
        tempDocIdsArray[curIdx++] = (Integer)iter.next();
      }
      LOG.info("---> tempDocSet instanceof BitDocSet");
    } else if (tempDocSet instanceof SortedIntDocSet) {
      tempDocIdsArray = ((SortedIntDocSet)tempDocSet).getDocs();
      LOG.info("---> tempDocSet instanceof SortedIntDocSet of length " + tempDocIdsArray.length);
    } else {
      LOG.info("---> tempDocSet instanceof SortedIntDocSet" + tempDocSet.getClass());
    }

    List<Integer> finalList = new ArrayList<Integer>();

    for (int i = 0; i < tempDocIdsArray.length; i++) {
      Document doc = this.solrIndexSearcher.getIndexReader().document(tempDocIdsArray[i]);

      String uri = doc.get("uri");
      System.out.println("uri = " + uri);
      String[] relatedDocs = doc.getValues("relatedDocs");
      System.out.println("relatedDocs = " + Arrays.toString(relatedDocs));

      if (uri != null) {
        finalList.add(uri.hashCode());
      }

      for (int j = 0; j < relatedDocs.length; j++) {
        finalList.add(relatedDocs[j].hashCode());
      }
    }

    tempDocIdsArray = new int[finalList.size()];
    
    for(int i = 0; i < tempDocIdsArray.length; i++) {
      tempDocIdsArray[i] = finalList.get(i);
    }

    Arrays.sort(tempDocIdsArray);
    return new SortedIntDocSet(tempDocIdsArray);
  }

  /** Returns the unique name of the suggester */
  public String getName() {
    return name;
  }

  @Override
  public long ramBytesUsed() {
    return lookup.ramBytesUsed();
  }
  
  @Override
  public String toString() {
    return "SmartSolrSuggester [ name=" + name + ", "
        + "sourceLocation=" + sourceLocation + ", "
        + "storeDir=" + ((storeDir == null) ? "" : storeDir.getAbsoluteFile()) + ", "
        + "lookupImpl=" + lookupImpl + ", "
        + "dictionaryImpl=" + dictionaryImpl + ", "
        + "sizeInBytes=" + ((lookup!=null) ? String.valueOf(ramBytesUsed()) : "0") + " ]";
  }

}
