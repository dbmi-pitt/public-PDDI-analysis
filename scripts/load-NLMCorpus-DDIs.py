""" Simple Python script to build a dictionary of DDIs from the NLM Corpus"

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

NLMCorpus_DATA_INCHI_AND = "../PDDI-Datasets/NLM-Corpus/NLMCorpus_MappedINCHI_AND.csv"
NLMCorpus_DATA_INCHI_OR = "../PDDI-Datasets/NLM-Corpus/NLMCorpus_MappedINCHI_OR.csv"


def NLMCorpus_Pickle_Generator(datafile):
    # open the NLMCorpus_ data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           NLMCorpus_Mapped PDDI.
   
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
            "http://bio2rdf.org/drugbank:" + str(elts[2]), 
            elts[3], 
            "http://bio2rdf.org/drugbank:" +str(elts[5]),
            elts[6],
            elts[7],  
            "NLM-Corpus"
          )
           
        print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
              
        # return the dictionary entry
        pddiDictL.append(pddi)
                     
    return pddiDictL       
   

if __name__ == "__main__":

    gen=NLMCorpus_Pickle_Generator(NLMCorpus_DATA_INCHI_AND)  
    f = open("../pickle-data/nlmcorpus-ddis-inchi-and.pickle","w")
    pickle.dump(gen, f)
    f.close()

    gen=NLMCorpus_Pickle_Generator(NLMCorpus_DATA_INCHI_OR)  
    f = open("../pickle-data/nlmcorpus-ddis-inchi-or.pickle","w")
    pickle.dump(gen, f)
    f.close()
    
     

