""" Simple Python script to query "http://sparql.bioontology.org/sparql/ for NDFRT DDIs"
    No extra libraries required.

# Authors: Richard D Boyce, Michel Dumontier, Serkan Ayvaz
#
# July 2014
# 

"""

import json
import urllib2
import urllib
import traceback
import sys 
import pickle

sys.path = sys.path + ['.']
from PDDI_Model import getPDDIDict

def query(q,apikey,epr,f='application/json'):
    """Function that uses urllib/urllib2 to issue a SPARQL query.
       By default it requests json as data format for the SPARQL resultset"""

    try:
        params = {'query': q, 'apikey': apikey}
        params = urllib.urlencode(params)
        opener = urllib2.build_opener(urllib2.HTTPHandler)
        request = urllib2.Request(epr+'?'+params)
        request.add_header('Accept', f)
        request.get_method = lambda: 'GET'
        url = opener.open(request)
        return url.read()
    except Exception, e:
        traceback.print_exc(file=sys.stdout)
        raise e

if __name__ == "__main__":

    pddiDictL = []
    sparql_service = "http://sparql.bioontology.org/sparql/"

    #To get your API key register at http://bioportal.bioontology.org/accounts/new
    api_key = "74028721-e60e-4ece-989b-1d2c17d14e9c"

    query_string = """ 
                    PREFIX owl:  <http://www.w3.org/2002/07/owl#>
                    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
                    PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
                    PREFIX ndfrt: <http://purl.bioontology.org/ontology/NDFRT/>
                    SELECT *
                    FROM <http://bioportal.bioontology.org/ontologies/NDFRT>
                    WHERE {
                      ?s ndfrt:NDFRT_KIND ?o;
                      skos:prefLabel ?label;
                      ndfrt:SEVERITY ?severity. FILTER (regex(str(?o), "interaction", "i"))
                      ?s ndfrt:has_participant ?targetDrug.
                    }     
                    """
    print "query_string: %s" % query_string
    json_string = query(query_string, api_key, sparql_service)
    resultset=json.loads(json_string)

    if len(resultset["results"]["bindings"]) == 0:
        print "INFO: No result for %s" % d
    else:
        #print json.dumps(resultset,indent=1)
        cache = [None, None]
        for i in range(0, len(resultset["results"]["bindings"])):
            uri = resultset["results"]["bindings"][i]["s"]["value"]
            if uri == cache[0]:
                newPDDI = getPDDIDict()
                newPDDI["source"] = sparql_service
                newPDDI["uri"] = uri
                newPDDI["drug1"] = cache[1]
                newPDDI["drug2"] = resultset["results"]["bindings"][i]["targetDrug"]["value"]
                newPDDI["label"] = resultset["results"]["bindings"][i]["label"]["value"]
                newPDDI["severity"] = resultset["results"]["bindings"][i]["severity"]["value"]
                pddiDictL.append(newPDDI)
                cache = [None, None]
            else:
                cache[0] = uri
                cache[1] = resultset["results"]["bindings"][i]["targetDrug"]["value"]
                continue

    f = open("ndfrt-ddis.pickle","w")
    pickle.dump(pddiDictL, f)
    f.close()
        
