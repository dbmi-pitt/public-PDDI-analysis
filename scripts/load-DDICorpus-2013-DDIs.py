""" Simple Python script to build a dictionary of DDIs from the DDI Corpus 2013"

# Authors: Serkan Ayvaz, Richard D Boyce 
#
# August/September 2014

"""

"#from SPARQLWrapper import SPARQLWrapper, JSON"
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

DDICORPUS2013_DATA_INCHI_AND = "../PDDI-Datasets/DDI-Corpus2013/DDICorpus2013MappedINCHI_AND.csv"
DDICORPUS2013_DATA_INCHI_OR = "../PDDI-Datasets/DDI-Corpus2013/DDICorpus2013MappedINCHI_OR.csv"

def DDICorpus2013_Pickle_Generator(datafile):
    # open the DDI-Corpus2013 data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           DDI-Corpus2013 PDDI.
   
    pddiDictL = []

    f = open(datafile, 'r')
    
    while 1 :
        if not f:
            f.close()
            raise StopIteration
        
        l = f.readline()
        if l == "":
            f.close()
            break
        else:
            if l.find("Drug_1") != -1: # skips header and stops at EOF
               l = f.readline()
        
        
        elts = l.strip("\n").split("$")
        pddi = getPDDIDict()
        
        (
         pddi["object"],
         pddi["drug1"],
         pddi["precipitant"],
         pddi["drug2"],
         pddi["ddiType"],
         pddi["evidenceStatement"],
         pddi["source"]
        )=(
            elts[0], 
            "http://bio2rdf.org/drugbank:" + str(elts[1]), 
            elts[3], 
            "http://bio2rdf.org/drugbank:" +str(elts[4]),
            elts[6],
            elts[8],  
            "DDI-Corpus-2013"
          )
           
        #print "ID: %s - object: %s: %s-- precipitant:%s : %s" % (elts[0],pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
        print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
                    
        # return the dictionary entry
        pddiDictL.append(pddi)
                     
    return pddiDictL       
   

if __name__ == "__main__":

    gen=DDICorpus2013_Pickle_Generator(DDICORPUS2013_DATA_INCHI_AND)  
    f = open("../pickle-data/ddicorpus2013-ddis-inchi-and.pickle","w") 
    pickle.dump(gen, f)
    f.close()
 
    gen=DDICorpus2013_Pickle_Generator(DDICORPUS2013_DATA_INCHI_OR)  
    f = open("../pickle-data/ddicorpus2013-ddis-inchi-or.pickle","w")
    pickle.dump(gen, f)
    f.close()
