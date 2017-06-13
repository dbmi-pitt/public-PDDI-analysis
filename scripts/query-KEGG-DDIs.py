"""  
# Simple Python script to query "http://rest.kegg.jp/" for KEGG DDIs"
#    No extra libraries required.

# Authors: Richard D Boyce, Serkan Ayvaz
#
# September 2013/ Updated September 2014 
# Updated June 2017 by Serkan Ayvaz
# 
""" 

import urllib2
import urllib
import traceback
import sys 
import pickle


sys.path = sys.path + ['.']
from PDDI_Model import getPDDIDict

def query(q,epr):
    """Function that uses urllib/urllib2 to issue a REST query."""

    try:
        opener = urllib2.build_opener(urllib2.HTTPHandler)
        request = urllib2.Request(epr+q)
        request.get_method = lambda: 'GET'
        url = opener.open(request)
        return url.read()
    except Exception, e:
        traceback.print_exc(file=sys.stdout)
        print str(e)
        return ""

if __name__ == "__main__":

    pddiDictL = [] # the main list to save at the end
    keyDict = {} # to help identify duplicates

    keggAPIURL = "http://rest.kegg.jp/ddi/"

    f = open("../PDDI-Datasets/Kegg/all-kegg-drugs-06052017.txt","r")
    buf = f.read()
    f.close()
    keggDrugs = buf.split("\n")

    f = open("../PDDI-Datasets/Kegg/drugbank-to-kegg-mapping-06052017.txt","r")
    buf = f.read()
    f.close()
    l = buf.split("\n")
    keggIdToDrugBankD = {}
    for elt in l:
        if elt == "":
            break
        (drugbankURI,keggURI,name) = elt.split("\t")
          
        indxOfName =name.find("[")        
        drugbankName = name[1:indxOfName-1]
        kid = keggURI.replace("http://bio2rdf.org/kegg:","")
        keggIdToDrugBankD[kid] = drugbankURI + "$" +str(drugbankName)

    # process the KEGG DDIs that contain drug entities that can be mapped to DrugBank ids
    totalQCnt = noResCnt = totalResCnt = skippedCnt = dupCnt = 0
    
       
    for kd in keggDrugs:

       # if totalQCnt % 50 == 0:
         #print "Number of drugs queries : %s" % totalQCnt
#             f = open("../pickle-data/kegg-ddis.pickle","w")
#             pickle.dump(pddiDictL, f)
#             f.close()

        print "INFO: Querying for: %s" % kd
        totalQCnt += 1
        tsvRslts = query(kd, keggAPIURL)
             
        if tsvRslts.strip() == "":
            print "INFO: No result for %s" % kd
            noResCnt += 1
        else:
            print "INFO: Results: %s" % tsvRslts
            tsvRsltsL = tsvRslts.split("\n")
            for r in tsvRsltsL:
                if r == "":
                    break
                rsplL = r.split("\t")
                totalResCnt += len(rsplL) 
                (drug1,drug2,p_or_c,pkMech) = rsplL
                drug1 = drug1.replace("dr:","").replace("cpd:","")
                drug2 = drug2.replace("dr:","").replace("cpd:","")

                if keggIdToDrugBankD.get(drug1) == None:
                    #print "INFO: Skipping results because drug1 did not map to drugbank: %s" % r
                    skippedCnt += 1
                    continue
                if keggIdToDrugBankD.get(drug2) == None:
                    #print "INFO: Skipping results because drug2 did not map to drugbank: %s" % r
                    skippedCnt += 1
                    continue

                # test for duplicate
                k1 = "%s-%s" % (drug1,drug2)
                k2 = "%s-%s" % (drug2,drug1)
                if keyDict.get(k1) != None or keyDict.get(k2) != None:
                    print "INFO: duplicate PDDI (%s) not adding to the list" % k1
                    dupCnt += 1
                    continue
                keyDict[k1] = None
                keyDict[k2] = None
               
                d1=keggIdToDrugBankD.get(drug1).split("$") 
                d2=keggIdToDrugBankD.get(drug2).split("$")
                newPDDI = getPDDIDict()
                newPDDI["source"] = keggAPIURL
                newPDDI["uri"] = keggAPIURL + kd
                newPDDI["drug1"] = d1[0]                 
                newPDDI["object"] = d1[1]                 
                newPDDI["drug2"] = d2[0]                 
                newPDDI["precipitant"] = d2[1]  
                newPDDI["source"] = "Kegg"
                

                if p_or_c == "P":
                    newPDDI["precaution"] = True
                else:
                    newPDDI["contraindication"] = True

                if pkMech == "unclassified":
                    newPDDI["ddiPkMechanism"] = pkMech

                pddiDictL.append(newPDDI)
  
    f = open("../pickle-data/kegg-ddis.pickle","w")
    pickle.dump(pddiDictL, f)
    f.close()

    print """
                Total drugs queried: %d
                No results: %d
                Total DDIs returned: %d
                Total DDIs skipped due to no DrugBank mapping: %d
                Total duplicated PDDIs: %d
         """ % (totalQCnt,noResCnt,totalResCnt,skippedCnt,dupCnt)
         
         