""" Simple Python script to build a dictionary of DDIs from the TWOSIDES database"

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
import re
import time

sys.path = sys.path + ['.']
from PDDI_Model import getPDDIDict

TWOSIDES_DATA = "../PDDI-Datasets/Twosides/3003377s-twosides.tsv"

def twosides_f_generator():
    # open the twosides data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           twosides PDDI.
    f = open(TWOSIDES_DATA, 'r')
    
    while 1:
        if not f:
            f.close()
            raise StopIteration
        
        l = f.readline()
        while l.find("CID") == -1: # skips header and stops at EOF
            l = f.readline()
            if l == "":
                f.close()
                raise StopIteration

        elts = l.strip("\n").split("\t")
        pddi = getPDDIDict()
        (pddi["drug1"], 
         pddi["drug2"], 
         #pddi["label"], 
         pddi["effectConcept"], 
         pddi["certainty"], 
         pddi["source"]
         ) = (
              elts[0], 
              elts[1], 
              #elts[4], 
              elts[5], 
              elts[7],
             "Twosides"
              )
       
        # return the dictionary entry
        yield pddi
    
    
if __name__ == "__main__":
    
    # process the DDIs that contain drug entities that can be mapped to DrugBank ids
    pddiDictL = []
 
    # process the DDIs that contain drug entities that can be mapped to DrugBank ids
    f = open("../pickle-data/pubchem-to-drugbank-mapping.pickle", 'r')
    pc2dbL = pickle.load(f)
    f.close()
    pc2dbD = {} 
        
    for d in pc2dbL:
        if not d["pubchemCompoundId"]:
            continue 

        if not pc2dbD.has_key(d["pubchemCompoundId"]): 
            pc2dbD[d["pubchemCompoundId"]] = "http://bio2rdf.org/drugbank:" +str(d["drugbankid"])+ "$" +str(d["drugbankName"])
        else:
            print "WARNING: there are multiple drugbank entries for pubchemcompound %s (mapped to DrugBank: %s); only used the first drugbank entry " % (d["pubchemCompoundId"],d["drugbankid"])

    gen = twosides_f_generator()
    
    i = 0
    for ddi in gen:
        i += 1
        rgx = re.compile("CID0+")
        (oldD1, oldD2) = (ddi["drug1"], ddi["drug2"])

        ddi["drug1"] = rgx.sub("", ddi["drug1"])
        if pc2dbD.has_key(ddi["drug1"]):
            st=pc2dbD[ddi["drug1"]].split("$")
            ddi["drug1"] =  st[0] 
            ddi["object"] =  st[1]
            #pc2dbD[ddi["drug1"]]
        else:
            #print ddi["drug1"]
            continue

        ddi["drug2"] = rgx.sub("", ddi["drug2"])
        if pc2dbD.has_key(ddi["drug2"]):   
            st=pc2dbD[ddi["drug2"]].split("$")     
            ddi["drug2"] =  st[0] 
            ddi["precipitant"] =  st[1]
            
        else:
            #print ddi["drug2"]
            continue
  
        #print "Drug1: %s --  Drug2: %s" % (ddi["drug1"] ,ddi["drug2"] )
        pddiDictL.append(ddi)
       

    f = open("../pickle-data/twosides-ddis.pickle","w")
    pickle.dump(pddiDictL, f)
    f.close()
    
        
