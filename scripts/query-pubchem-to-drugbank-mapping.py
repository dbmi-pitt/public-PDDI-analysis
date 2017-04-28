""" Simple Python script to query http://drugbank.bio2rdf.org/sparql for pubchem ids"
    No extra libraries required.

# Authors: Richard D Boyce, Michel Dumontier
#
# July 2012
# 

"""

import json
import urllib2
import urllib
import traceback
import sys 
import pickle

def query(q,epr,f='application/json'):
    """Function that uses urllib/urllib2 to issue a SPARQL query.
       By default it requests json as data format for the SPARQL resultset"""

    try:
        params = {'query': q}
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


def queryEndpoint(sparql_service, q):
    print "query string: %s" % q
    json_string = query(q, sparql_service)
    #print "%s" % json_string
    resultset=json.loads(json_string)
    
    return resultset

def getQueryString(offset):
    return """ 
PREFIX n3:	<http://bio2rdf.org/drugbank_vocabulary:>

SELECT *
WHERE {
  ?s a n3:Drug;
     n3:xref ?pubchem. 
  FILTER regex(str(?pubchem),"http://bio2rdf.org/pubchem")
}
OFFSET %d
LIMIT 10000
""" % offset


if __name__ == "__main__":

    mapDictL = []
    sparql_service = "http://drugbank.bio2rdf.org/sparql"

    offset = 0
    q = getQueryString(offset)
    resultset = queryEndpoint(sparql_service, q)

    while len(resultset["results"]["bindings"]) != 0 and offset < 20000:
        #print json.dumps(resultset,indent=1)
        for i in range(0, len(resultset["results"]["bindings"])):
            uri = resultset["results"]["bindings"][i]["s"]["value"]
            newD = {"pubchemcompound":None, "pubchemsubstance":None}
            newD["uri"] = uri
            chem = resultset["results"]["bindings"][i]["pubchem"]["value"]
            if chem.find("pubchemcompound") != -1:
                newD["pubchemcompound"] = chem
            else:
                newD["pubchemsubstance"] = chem
            
            mapDictL.append(newD)

        offset += 10000
        q = getQueryString(offset)
        resultset = queryEndpoint(sparql_service, q)

    print "INFO: No results at offset %d" % offset 

    f = open("pubchem-to-drugbank-mapping.pickle","w")
    pickle.dump(mapDictL, f)
    f.close()
        

