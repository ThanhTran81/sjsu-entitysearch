package org.apache.solr.handler.component;

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

import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.lucene.search.suggest.Lookup;
import org.apache.lucene.search.suggest.Lookup.LookupResult;
import org.apache.lucene.util.Accountable;
import org.apache.lucene.util.BytesRef;
import org.apache.lucene.util.CharsRef;
import org.apache.solr.common.SolrException;
import org.apache.solr.common.params.CommonParams;
import org.apache.solr.common.params.ModifiableSolrParams;
import org.apache.solr.common.params.ShardParams;
import org.apache.solr.common.params.SolrParams;
import org.apache.solr.common.util.NamedList;
import org.apache.solr.common.util.SimpleOrderedMap;
import org.apache.solr.core.SolrCore;
import org.apache.solr.core.SolrEventListener;
import org.apache.solr.search.SolrIndexSearcher;
import org.apache.solr.spelling.suggest.SolrSuggester;
import org.apache.solr.spelling.suggest.SuggesterOptions;
import org.apache.solr.spelling.suggest.SuggesterParams;
import org.apache.solr.spelling.suggest.SuggesterResult;
import org.apache.solr.util.plugin.SolrCoreAware;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.apache.solr.spelling.suggest.SmartSolrSuggester;
import org.apache.solr.spelling.suggest.ContextSuggesterOptions;

/**
 * SuggestComponent: interacts with multiple {@link SmartSolrSuggester} to serve up suggestions
 * Responsible for routing commands and queries to the appropriate {@link SmartSolrSuggester}
 * and for initializing them as specified by SolrConfig
 */
public class SmartSuggestComponent extends SearchComponent implements SolrCoreAware, SuggesterParams, Accountable {
  private static final Logger LOG = LoggerFactory.getLogger(SmartSuggestComponent.class);
  
  /** Name used to identify whether the user query concerns this component */
  public static final String COMPONENT_NAME = "suggest";
  
  /** Name assigned to an unnamed suggester (at most one suggester) can be unnamed */
  private static final String DEFAULT_DICT_NAME = SmartSolrSuggester.DEFAULT_DICT_NAME;
  
  /** SolrConfig label to identify  Config time settings */
  private static final String CONFIG_PARAM_LABEL = "suggester";
  
  /** SolrConfig label to identify boolean value to build suggesters on commit */
  private static final String BUILD_ON_COMMIT_LABEL = "buildOnCommit";
  
  /** SolrConfig label to identify boolean value to build suggesters on optimize */
  private static final String BUILD_ON_OPTIMIZE_LABEL = "buildOnOptimize";

  private static final String SUGGESTION_CONTEXT = "context";
  
  @SuppressWarnings("unchecked")
  protected NamedList initParams;
  
  /**
   * Key is the dictionary name used in SolrConfig, value is the corresponding {@link SmartSolrSuggester}
   */
  protected Map<String, SmartSolrSuggester> suggesters = new ConcurrentHashMap<>();
  
  /** Container for various labels used in the responses generated by this component */
  private static class SuggesterResultLabels {
    static final String SUGGEST = "suggest";
    static final String SUGGESTIONS = "suggestions";
    static final String SUGGESTION_NUM_FOUND = "numFound";
    static final String SUGGESTION_TERM = "term";
    static final String SUGGESTION_WEIGHT = "weight";
    static final String SUGGESTION_PAYLOAD = "payload";
    static final String SUGGESTION_DOCSID = "docIds";
    static final String SUGGESTION_SCORE = "score";
  }
  
  @Override
  @SuppressWarnings("unchecked")
  public void init(NamedList args) {
    super.init(args);
    this.initParams = args;
  }
  
  @Override
  public void inform(SolrCore core) {
    if (initParams != null) {
      LOG.info("Initializing SmartSuggestComponent");
      boolean hasDefault = false;
      for (int i = 0; i < initParams.size(); i++) {
        if (initParams.getName(i).equals(CONFIG_PARAM_LABEL)) {
          NamedList suggesterParams = (NamedList) initParams.getVal(i);
          SmartSolrSuggester suggester = new SmartSolrSuggester();
          String dictionary = suggester.init(suggesterParams, core);
          if (dictionary != null) {
            boolean isDefault = dictionary.equals(DEFAULT_DICT_NAME);
            if (isDefault && !hasDefault) {
              hasDefault = true;
            } else if (isDefault){
              throw new RuntimeException("More than one dictionary is missing name.");
            }
            suggesters.put(dictionary, suggester);
          } else {
            if (!hasDefault){
              suggesters.put(DEFAULT_DICT_NAME, suggester);
              hasDefault = true;
            } else {
              throw new RuntimeException("More than one dictionary is missing name.");
            }
          }
          
          // Register event listeners for this Suggester
          core.registerFirstSearcherListener(new SuggesterListener(core, suggester, false, false));
          boolean buildOnCommit = Boolean.parseBoolean((String) suggesterParams.get(BUILD_ON_COMMIT_LABEL));
          boolean buildOnOptimize = Boolean.parseBoolean((String) suggesterParams.get(BUILD_ON_OPTIMIZE_LABEL));
          if (buildOnCommit || buildOnOptimize) {
            LOG.info("Registering newSearcher listener for suggester: " + suggester.getName());
            core.registerNewSearcherListener(new SuggesterListener(core, suggester, buildOnCommit, buildOnOptimize));
          }
        }
      }
    }
  }

  /** Responsible for issuing build and rebload command to the specified {@link SmartSolrSuggester} */
  @Override
  public void prepare(ResponseBuilder rb) throws IOException {
    SolrParams params = rb.req.getParams();
    LOG.info("SmartSuggestComponent prepare with : " + params);
    if (!params.getBool(COMPONENT_NAME, false)) {
      return;
    }
    
    boolean buildAll = params.getBool(SUGGEST_BUILD_ALL, false);
    boolean reloadAll = params.getBool(SUGGEST_RELOAD_ALL, false);
    
    final Collection<SmartSolrSuggester> querysuggesters;
    if (buildAll || reloadAll) {
      querysuggesters = suggesters.values();
    } else {
      querysuggesters = getSuggesters(params);
    }
    
    if (params.getBool(SUGGEST_BUILD, false) || buildAll) {
      for (SmartSolrSuggester suggester : querysuggesters) {
        suggester.build(rb.req.getCore(), rb.req.getSearcher());
      }
      rb.rsp.add("command", (!buildAll) ? "build" : "buildAll");
    } else if (params.getBool(SUGGEST_RELOAD, false) || reloadAll) {
      for (SmartSolrSuggester suggester : querysuggesters) {
        suggester.reload(rb.req.getCore(), rb.req.getSearcher());
      }
      rb.rsp.add("command", (!reloadAll) ? "reload" : "reloadAll");
    }
  }
  
  /** Dispatch shard request in <code>STAGE_EXECUTE_QUERY</code> stage */
  @Override
  public int distributedProcess(ResponseBuilder rb) {
    SolrParams params = rb.req.getParams();
    LOG.info("SmartSuggestComponent distributedProcess with : " + params);
    if (rb.stage < ResponseBuilder.STAGE_EXECUTE_QUERY) 
      return ResponseBuilder.STAGE_EXECUTE_QUERY;
    if (rb.stage == ResponseBuilder.STAGE_EXECUTE_QUERY) {
      ShardRequest sreq = new ShardRequest();
      sreq.purpose = ShardRequest.PURPOSE_GET_TOP_IDS;
      sreq.params = new ModifiableSolrParams(rb.req.getParams());
      sreq.params.remove(ShardParams.SHARDS);
      rb.addRequest(this, sreq);
      return ResponseBuilder.STAGE_GET_FIELDS;
    }

    return ResponseBuilder.STAGE_DONE;
  }

  /** 
   * Responsible for using the specified suggester to get the suggestions 
   * for the query and write the results 
   * */
  @Override
  public void process(ResponseBuilder rb) throws IOException {
    SolrParams params = rb.req.getParams();
    LOG.info("SmartSuggestComponent process with : " + params);
    if (!params.getBool(COMPONENT_NAME, false) || suggesters.isEmpty()) {
      return;
    }
    
    boolean buildAll = params.getBool(SUGGEST_BUILD_ALL, false);
    boolean reloadAll = params.getBool(SUGGEST_RELOAD_ALL, false);
    Set<SmartSolrSuggester> querySuggesters;
    try {
      querySuggesters = getSuggesters(params);
    } catch(SolrException ex) {
      if (!buildAll && !reloadAll) {
        throw ex;
      } else {
        querySuggesters = new HashSet<>();
      }
    }
    
    String query = params.get(SUGGEST_Q);
    if (query == null) {
      query = rb.getQueryString();
      if (query == null) {
        query = params.get(CommonParams.Q);
      }
    }

    String context = params.get(SUGGESTION_CONTEXT);
    
    if (query != null) {
      int count = params.getInt(SUGGEST_COUNT, 1);
       ContextSuggesterOptions options;
      if (context != null) {
        options = new ContextSuggesterOptions(new CharsRef(query), count, context);
      } else {
        options = new ContextSuggesterOptions(new CharsRef(query), count, null);
      }
      
      Map<String, SimpleOrderedMap<NamedList<Object>>> namedListResults = new HashMap<>();
      for (SmartSolrSuggester suggester : querySuggesters) {
        suggester.setSolrIndexSearcher(rb.req.getSearcher());
        SuggesterResult suggesterResult = suggester.getSuggestions(options);
        toNamedList(suggesterResult, namedListResults);
      }
      rb.rsp.add(SuggesterResultLabels.SUGGEST, namedListResults);
    }
  }
  
  /** 
   * Used in Distributed Search, merges the suggestion results from every shard
   * */
  @Override
  public void finishStage(ResponseBuilder rb) {
    SolrParams params = rb.req.getParams();
    LOG.info("SmartSuggestComponent finishStage with : " + params);
    if (!params.getBool(COMPONENT_NAME, false) || rb.stage != ResponseBuilder.STAGE_GET_FIELDS)
      return;
    int count = params.getInt(SUGGEST_COUNT, 1);
    
    List<SuggesterResult> suggesterResults = new ArrayList<>();
    
    // Collect Shard responses
    for (ShardRequest sreq : rb.finished) {
      for (ShardResponse srsp : sreq.responses) {
        NamedList<Object> resp;
        if((resp = srsp.getSolrResponse().getResponse()) != null) {
          @SuppressWarnings("unchecked")
          Map<String, SimpleOrderedMap<NamedList<Object>>> namedList = 
              (Map<String, SimpleOrderedMap<NamedList<Object>>>) resp.get(SuggesterResultLabels.SUGGEST);
          // LOG.info(srsp.getShard() + " : " + namedList);
          suggesterResults.add(toSuggesterResult(namedList));
        }
      }
    }
    
    // Merge Shard responses
    SuggesterResult suggesterResult = merge(suggesterResults, count);
    Map<String, SimpleOrderedMap<NamedList<Object>>> namedListResults = 
        new HashMap<>();
    toNamedList(suggesterResult, namedListResults);
    
    rb.rsp.add(SuggesterResultLabels.SUGGEST, namedListResults);
  }

  /** 
   * Given a list of {@link SuggesterResult} and <code>count</code>
   * returns a {@link SuggesterResult} containing <code>count</code>
   * number of {@link LookupResult}, sorted by their associated 
   * weights
   * */
  private static SuggesterResult merge(List<SuggesterResult> suggesterResults, int count) {
    SuggesterResult result = new SuggesterResult();
    Set<String> allTokens = new HashSet<>();
    Set<String> suggesterNames = new HashSet<>();
    
    // collect all tokens
    for (SuggesterResult shardResult : suggesterResults) {
      for (String suggesterName : shardResult.getSuggesterNames()) {
        allTokens.addAll(shardResult.getTokens(suggesterName));
        suggesterNames.add(suggesterName);
      }
    }
    
    // Get Top N for every token in every shard (using weights)
    for (String suggesterName : suggesterNames) {
      for (String token : allTokens) {
        Lookup.LookupPriorityQueue resultQueue = new Lookup.LookupPriorityQueue(
            count);
        for (SuggesterResult shardResult : suggesterResults) {
          List<LookupResult> suggests = shardResult.getLookupResult(suggesterName, token);
          if (suggests == null) {
            continue;
          }
          for (LookupResult res : suggests) {
            resultQueue.insertWithOverflow(res);
          }
        }
        List<LookupResult> sortedSuggests = new LinkedList<>();
        Collections.addAll(sortedSuggests, resultQueue.getResults());
        result.add(suggesterName, token, sortedSuggests);
      }
    }
    return result;
  }
  
  @Override
  public String getDescription() {
    return "Smart Suggester component";
  }

  @Override
  public String getSource() {
    return null;
  }
  
  @Override
  public NamedList getStatistics() {
    NamedList<String> stats = new SimpleOrderedMap<>();
    stats.add("totalSizeInBytes", String.valueOf(ramBytesUsed()));
    for (Map.Entry<String, SmartSolrSuggester> entry : suggesters.entrySet()) {
      SmartSolrSuggester suggester = entry.getValue();
      stats.add(entry.getKey(), suggester.toString());
    }
    return stats;
  }
  
  @Override
  public long ramBytesUsed() {
    long sizeInBytes = 0;
    for (SmartSolrSuggester suggester : suggesters.values()) {
      sizeInBytes += suggester.ramBytesUsed();
    }
    return sizeInBytes;
  }
  
  private Set<SmartSolrSuggester> getSuggesters(SolrParams params) {
    Set<SmartSolrSuggester> SmartSolrSuggesters = new HashSet<>();
    for(String suggesterName : getSuggesterNames(params)) {
      SmartSolrSuggester curSuggester = suggesters.get(suggesterName);
      if (curSuggester != null) {
        SmartSolrSuggesters.add(curSuggester);
      } else {
        throw new SolrException(SolrException.ErrorCode.BAD_REQUEST, "No suggester named " + suggesterName +" was configured");
      }
    }
    if (SmartSolrSuggesters.size() == 0) {
        throw new SolrException(SolrException.ErrorCode.BAD_REQUEST, 
            "'" + SUGGEST_DICT + "' parameter not specified and no default suggester configured");
    }
    return SmartSolrSuggesters;
    
  }
  
  private Set<String> getSuggesterNames(SolrParams params) {
    Set<String> suggesterNames = new HashSet<>();
    String[] suggesterNamesFromParams = params.getParams(SUGGEST_DICT);
    if (suggesterNamesFromParams == null) {
      suggesterNames.add(DEFAULT_DICT_NAME);
    } else {
      for (String name : suggesterNamesFromParams) {
        suggesterNames.add(name);
      }
    }
    return suggesterNames;   
  }
  
  /** Convert {@link SuggesterResult} to NamedList for constructing responses */
  private void toNamedList(SuggesterResult suggesterResult, Map<String, SimpleOrderedMap<NamedList<Object>>> resultObj) {
    for(String suggesterName : suggesterResult.getSuggesterNames()) {
      SimpleOrderedMap<NamedList<Object>> results = new SimpleOrderedMap<>();
      for (String token : suggesterResult.getTokens(suggesterName)) {
        SimpleOrderedMap<Object> suggestionBody = new SimpleOrderedMap<>();
        List<LookupResult> lookupResults = suggesterResult.getLookupResult(suggesterName, token);
        suggestionBody.add(SuggesterResultLabels.SUGGESTION_NUM_FOUND, lookupResults.size());
        List<SimpleOrderedMap<Object>> suggestEntriesNamedList = new ArrayList<>();
        for (LookupResult lookupResult : lookupResults) {
          String suggestionString = lookupResult.key.toString();
          // long weight = lookupResult.value;
          int score = lookupResult.score;

          // String docIdsArrayStr = lookupResult.docIdsArrayStr;
          // if (lookupResult.containingDocsBytesRef != null) {
          //   byte[] containingDocsBytes = lookupResult.containingDocsBytesRef.bytes;
          //   for (int i = 0; i < containingDocsBytes.length; i+=4) {
          //     if (i > 0) {
          //       docIdsArrayStr += ",";
          //     }
          //     int finalInt= (containingDocsBytes[i]<<24)&0xff000000|
          //            (containingDocsBytes[i+1]<<16)&0x00ff0000|
          //            (containingDocsBytes[i+2]<< 8)&0x0000ff00|
          //            (containingDocsBytes[i+3]<< 0)&0x000000ff;
              
          //     docIdsArrayStr += finalInt;                           
          //   }
          // }
          
          SimpleOrderedMap<Object> suggestEntryNamedList = new SimpleOrderedMap<>();
          suggestEntryNamedList.add(SuggesterResultLabels.SUGGESTION_TERM, suggestionString);
          suggestEntryNamedList.add(SuggesterResultLabels.SUGGESTION_SCORE, score);
          // suggestEntryNamedList.add(SuggesterResultLabels.SUGGESTION_WEIGHT, weight);
          //suggestEntryNamedList.add(SuggesterResultLabels.SUGGESTION_PAYLOAD, payload);
          //suggestEntryNamedList.add(SuggesterResultLabels.SUGGESTION_DOCSID, docIdsArrayStr);
          suggestEntriesNamedList.add(suggestEntryNamedList);
          
        }
        suggestionBody.add(SuggesterResultLabels.SUGGESTIONS, suggestEntriesNamedList);
        results.add(token, suggestionBody);
      }
      resultObj.put(suggesterName, results);
    }
  }
  
  /** Convert NamedList (suggester response) to {@link SuggesterResult} */
  private SuggesterResult toSuggesterResult(Map<String, SimpleOrderedMap<NamedList<Object>>> suggestionsMap) {
    SuggesterResult result = new SuggesterResult();
    if (suggestionsMap == null) {
      return result;
    }
    // for each token
    for(Map.Entry<String, SimpleOrderedMap<NamedList<Object>>> entry : suggestionsMap.entrySet()) {
      String suggesterName = entry.getKey();
      for (Iterator<Map.Entry<String, NamedList<Object>>> suggestionsIter = entry.getValue().iterator(); suggestionsIter.hasNext();) {
        Map.Entry<String, NamedList<Object>> suggestions = suggestionsIter.next(); 
        String tokenString = suggestions.getKey();
        List<LookupResult> lookupResults = new ArrayList<>();
        NamedList<Object> suggestion = suggestions.getValue();
        // for each suggestion
        for (int j = 0; j < suggestion.size(); j++) {
          String property = suggestion.getName(j);
          if (property.equals(SuggesterResultLabels.SUGGESTIONS)) {
            @SuppressWarnings("unchecked")
            List<NamedList<Object>> suggestionEntries = (List<NamedList<Object>>) suggestion.getVal(j);
            for(NamedList<Object> suggestionEntry : suggestionEntries) {
              String term = (String) suggestionEntry.get(SuggesterResultLabels.SUGGESTION_TERM);
              int score = (int) suggestionEntry.get(SuggesterResultLabels.SUGGESTION_SCORE);
              // Long weight = (Long) suggestionEntry.get(SuggesterResultLabels.SUGGESTION_WEIGHT);
              // String payload = (String) suggestionEntry.get(SuggesterResultLabels.SUGGESTION_PAYLOAD);
              // String docIds = (String) suggestionEntry.get(SuggesterResultLabels.SUGGESTION_DOCSID);
              // System.out.println("docIds = " + docIds);
              LookupResult res = new LookupResult(new CharsRef(term), 0);
              res.score = score;
              lookupResults.add(res);
            }
          }
          result.add(suggesterName, tokenString, lookupResults);
        }
      }
    }
    return result;
  }
  
  /** Listener to build or reload the maintained {@link SmartSolrSuggester} by this component */
  private static class SuggesterListener implements SolrEventListener {
    private final SolrCore core;
    private final SmartSolrSuggester suggester;
    private final boolean buildOnCommit;
    private final boolean buildOnOptimize;

    public SuggesterListener(SolrCore core, SmartSolrSuggester checker, boolean buildOnCommit, boolean buildOnOptimize) {
      this.core = core;
      this.suggester = checker;
      this.buildOnCommit = buildOnCommit;
      this.buildOnOptimize = buildOnOptimize;
    }

    @Override
    public void init(NamedList args) {}

    @Override
    public void newSearcher(SolrIndexSearcher newSearcher,
                            SolrIndexSearcher currentSearcher) {
      if (currentSearcher == null) {
        // firstSearcher event
        try {
          LOG.info("Loading suggester index for: " + suggester.getName());
          suggester.reload(core, newSearcher);
        } catch (IOException e) {
          log.error("Exception in reloading suggester index for: " + suggester.getName(), e);
        }
      } else {
        // newSearcher event
        if (buildOnCommit)  {
          buildSuggesterIndex(newSearcher);
        } else if (buildOnOptimize) {
          if (newSearcher.getIndexReader().leaves().size() == 1)  {
            buildSuggesterIndex(newSearcher);
          } else  {
            LOG.info("Index is not optimized therefore skipping building suggester index for: " 
                    + suggester.getName());
          }
        }
      }

    }

    private void buildSuggesterIndex(SolrIndexSearcher newSearcher) {
      try {
        LOG.info("Building suggester index for: " + suggester.getName());
        suggester.build(core, newSearcher);
      } catch (Exception e) {
        log.error("Exception in building suggester index for: " + suggester.getName(), e);
      }
    }

    @Override
    public void postCommit() {}

    @Override
    public void postSoftCommit() {}
    
  }
}