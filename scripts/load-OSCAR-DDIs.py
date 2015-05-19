""" Simple Python script to build a dictionary of DDIs from the OSCAR"

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

OSCAR_DATA = "../PDDI-Datasets/OSCAR/OSCAR_DDIs_Mapped.csv"

def OSCAR_Pickle_Generator():
    # open the OSCAR data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           OSCAR  PDDI.
   
    pddiDictL = []
    f = open(OSCAR_DATA, 'r')
    
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
         pddi["effectConcept"], 
         pddi["severity"], 
         pddi["evidence"], 
         pddi["evidenceStatement"], 
         pddi["source"]
        )=(
            elts[1], 
            elts[3],  
            elts[5],
            elts[7], 
            elts[8],
            elts[9],
            elts[10],
            elts[11],
            "OSCAR"
          ) 
            
        print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
              
        # return the dictionary entry
        pddiDictL.append(pddi)
                     
    return pddiDictL       
   

if __name__ == "__main__":

    gen=OSCAR_Pickle_Generator()  
    f = open("../pickle-data/oscar-ddis.pickle","w")
    pickle.dump(gen, f)
    f.close()

