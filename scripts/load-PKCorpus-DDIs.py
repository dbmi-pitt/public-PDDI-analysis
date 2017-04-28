""" Simple Python script to build a dictionary of DDIs from the PK Corpus"

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

#PKCorpus_DATA = "../PDDI-Datasets/PK-Corpus/PKCorpus_Mapped.csv"
PKCorpus_DATA_INCHI_AND = "../PDDI-Datasets/PK-Corpus/PKCorpus_MappedINCHI_AND.csv"
PKCorpus_DATA_INCHI_OR = "../PDDI-Datasets/PK-Corpus/PKCorpus_MappedINCHI_OR.csv" 

def PKCorpus_Pickle_Generator(datafile):
    # open the PKCorpus_ data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           PKCorpus_Mapped PDDI.
   
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
         pddi["whoAnnotated"], 
         pddi["precipitant"],
         pddi["drug2"],
         #pddi["ddiPkEffect"],
         pddi["evidenceStatement"],
         pddi["source"]
        )=(
            elts[0], 
            "http://bio2rdf.org/drugbank:" + str(elts[3]), 
            elts[6],
            elts[4], 
            "http://bio2rdf.org/drugbank:" +str(elts[7]),
            #elts[10],
            elts[11],  
            "PK-Corpus"
          )  
        print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
              
        # return the dictionary entry
        pddiDictL.append(pddi)
                     
    return pddiDictL       
   

if __name__ == "__main__":
 
    gen=PKCorpus_Pickle_Generator(PKCorpus_DATA_INCHI_AND)  
    f = open("../pickle-data/pkcorpus-ddis-inchi-and.pickle","w")
    pickle.dump(gen, f)
    f.close()

    gen=PKCorpus_Pickle_Generator(PKCorpus_DATA_INCHI_OR)  
    f = open("../pickle-data/pkcorpus-ddis-inchi-or.pickle","w")
    pickle.dump(gen, f)
    f.close()
    
     
