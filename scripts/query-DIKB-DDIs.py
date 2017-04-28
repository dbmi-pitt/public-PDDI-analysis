""" Simple Python script to query http://dbmi-icode-01.dbmi.pitt.edu:2020/sparql for DIKB observed and predicted DDIs"
    No extra libraries required.

# Authors: Richard D Boyce, Michel Dumontier, Serkan Ayvaz
#
# July 2012/ Updated September 2014 
# 

"""

import json
import urllib2
import urllib
import traceback
import pickle
import sys
sys.path = sys.path + ['.']

from PDDI_Model import getPDDIDict

def query(q,epr,f='application/sparql-results+json'):
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

if __name__ == "__main__":

    # load all observed DDIs
    pddiDictL = []
    sparql_service = "http://dbmi-icode-01.dbmi.pitt.edu/dikb/sparql"

    query_string = """ 
PREFIX swanpav: <http://purl.org/swan/1.2/pav/>
PREFIX meta: <http://www4.wiwiss.fu-berlin.de/bizer/d2r-server/metadata#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX prvTypes: <http://purl.org/net/provenance/types#>
PREFIX swandr: <http://purl.org/swan/1.2/discourse-relationships/>
PREFIX d2r: <http://sites.wiwiss.fu-berlin.de/suhl/bizer/d2r-server/config.rdf#>
PREFIX map: <file:////home/rdb20/Downloads/d2r-server-0.7-DIKB/mapping.n3#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX swande: <http://purl.org/swan/1.2/discourse-elements#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX prv: <http://purl.org/net/provenance/ns#>
PREFIX db: <http://dbmi-icode-01.dbmi.pitt.edu:2020/resource/>
PREFIX siocns: <http://rdfs.org/sioc/ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX prvFiles: <http://purl.org/net/provenance/files#>
PREFIX ndfrt: <http://purl.bioontology.org/ontology/NDFRT/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ncbit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX dikbEvidence: <http://dbmi-icode-01.dbmi.pitt.edu/dikb-evidence/DIKB_evidence_ontology_v1.3.owl#>
PREFIX dikbD2R: <http://dbmi-icode-01.dbmi.pitt.edu:2020/vocab/resource/>
PREFIX swanco: <http://purl.org/swan/1.2/swan-commons#>
PREFIX prvIV: <http://purl.org/net/provenance/integrity#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX swanci: <http://purl.org/swan/1.2/citations/>

SELECT * WHERE {
  ?s dikbD2R:ObjectDrugOfInteraction ?o.
  ?s dikbD2R:PrecipitantDrugOfInteraction ?p.
  ?s rdf:type dikbD2R:DDIObservation.
  ?s rdfs:label ?label.
  ?o owl:sameAs ?oDB.
  ?p owl:sameAs ?pDB.
}
     
"""
    print "OBSERVED DDIs query_string: %s" % query_string
    json_string = query(query_string, sparql_service)
    #print "%s" % json_string
    resultset=json.loads(json_string)

    if len(resultset["results"]["bindings"]) == 0:
        print "INFO: No result!"
    else:
        #print json.dumps(resultset,indent=1)
        for i in range(0, len(resultset["results"]["bindings"])):
            newPDDI = getPDDIDict()
            newPDDI["uri"] = resultset["results"]["bindings"][i]["s"]["value"]
            newPDDI["object"] = resultset["results"]["bindings"][i]["o"]["value"].replace("http://dbmi-icode-01.dbmi.pitt.edu/dikb/resource/Drugs/","")
            newPDDI["precipitant"] = resultset["results"]["bindings"][i]["p"]["value"].replace("http://dbmi-icode-01.dbmi.pitt.edu/dikb/resource/Drugs/","")
            newPDDI["drug1"] = resultset["results"]["bindings"][i]["oDB"]["value"].replace("http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugs/","http://bio2rdf.org/drugbank:")
            newPDDI["drug2"] = resultset["results"]["bindings"][i]["pDB"]["value"].replace("http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugs/","http://bio2rdf.org/drugbank:")
            newPDDI["label"] = resultset["results"]["bindings"][i]["label"]["value"] 
            newPDDI["source"] = "DIKB"     
            pddiDictL.append(newPDDI)

    f = open("../pickle-data/dikb-observed-ddis.pickle","w")
    pickle.dump(pddiDictL, f)
    f.close()

    # do the same for predicted DDIs
    pddiDictL = []
    query_string = """ 
PREFIX swanpav: <http://purl.org/swan/1.2/pav/>
PREFIX meta: <http://www4.wiwiss.fu-berlin.de/bizer/d2r-server/metadata#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX prvTypes: <http://purl.org/net/provenance/types#>
PREFIX swandr: <http://purl.org/swan/1.2/discourse-relationships/>
PREFIX d2r: <http://sites.wiwiss.fu-berlin.de/suhl/bizer/d2r-server/config.rdf#>
PREFIX map: <file:////home/rdb20/Downloads/d2r-server-0.7-DIKB/mapping.n3#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX swande: <http://purl.org/swan/1.2/discourse-elements#>
PREFIX dc: <http://purl.org/dc/elements/1.1/>
PREFIX prv: <http://purl.org/net/provenance/ns#>
PREFIX db: <http://dbmi-icode-01.dbmi.pitt.edu:2020/resource/>
PREFIX siocns: <http://rdfs.org/sioc/ns#>
PREFIX foaf: <http://xmlns.com/foaf/0.1/>
PREFIX prvFiles: <http://purl.org/net/provenance/files#>
PREFIX ndfrt: <http://purl.bioontology.org/ontology/NDFRT/>
PREFIX obo: <http://purl.obolibrary.org/obo/>
PREFIX ncbit: <http://ncicb.nci.nih.gov/xml/owl/EVS/Thesaurus.owl#>
PREFIX dikbEvidence: <http://dbmi-icode-01.dbmi.pitt.edu/dikb-evidence/DIKB_evidence_ontology_v1.3.owl#>
PREFIX dikbD2R: <http://dbmi-icode-01.dbmi.pitt.edu:2020/vocab/resource/>
PREFIX swanco: <http://purl.org/swan/1.2/swan-commons#>
PREFIX prvIV: <http://purl.org/net/provenance/integrity#>
PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX swanci: <http://purl.org/swan/1.2/citations/>

SELECT * WHERE {
  ?s dikbD2R:ObjectDrugOfInteraction ?o.
  ?s dikbD2R:PrecipitantDrugOfInteraction ?p.
  ?s dikbD2R:EnzymeInhibited ?e.
  ?s rdf:type dikbD2R:DDIPrediction.
  ?s rdfs:label ?label.
  ?o owl:sameAs ?oDB.
  ?p owl:sameAs ?pDB.
}
     
"""
    print "PREDICTED DDIs query_string: %s" % query_string
    json_string = query(query_string, sparql_service)
    resultset=json.loads(json_string)
    print "%s" % json_string
    
    if len(resultset["results"]["bindings"]) == 0:
        print "INFO: No result!" 
    else:
        #print json.dumps(resultset,indent=1)
        for i in range(0, len(resultset["results"]["bindings"])):
            newPDDI = getPDDIDict() 
            newPDDI["uri"] = resultset["results"]["bindings"][i]["s"]["value"] 
            newPDDI["object"] = resultset["results"]["bindings"][i]["o"]["value"].replace("http://dbmi-icode-01.dbmi.pitt.edu/dikb/resource/Drugs/","")
            newPDDI["precipitant"] = resultset["results"]["bindings"][i]["p"]["value"].replace("http://dbmi-icode-01.dbmi.pitt.edu/dikb/resource/Drugs/","")
            newPDDI["drug1"] = resultset["results"]["bindings"][i]["oDB"]["value"].replace("http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugs/","http://bio2rdf.org/drugbank:")
            newPDDI["drug2"] = resultset["results"]["bindings"][i]["pDB"]["value"].replace("http://www4.wiwiss.fu-berlin.de/drugbank/resource/drugs/","http://bio2rdf.org/drugbank:")
            newPDDI["label"] = resultset["results"]["bindings"][i]["label"]["value"] 
            newPDDI["pathway"] = resultset["results"]["bindings"][i]["e"]["value"]
            newPDDI["source"] = "DIKB"              
            pddiDictL.append(newPDDI)

    f = open("../pickle-data/dikb-predicted-ddis.pickle","w")
    pickle.dump(pddiDictL, f)
    f.close()
