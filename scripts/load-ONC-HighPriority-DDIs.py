""" Simple Python script to build a dictionary of DDIs from the ONC High Priority"

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

ONCHighPriority_DATA = "../PDDI-Datasets/ONC-High-Priority/ONC_High_Priority_Mapped.csv"

def ONC_HighPriority_Pickle_Generator():
    # open the ONCHighPriority data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           ONCHighPriority  PDDI.
   
    pddiDictL = []
    f = open(ONCHighPriority_DATA, 'r')
    
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
         pddi["source"]
        )=(
            elts[0],            
            "http://bio2rdf.org/drugbank:" + str(elts[1]), 
            elts[2],        
            "http://bio2rdf.org/drugbank:" + str(elts[3]), 
            "ONC-HighPriority"
          )           
            
        print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
              
        # return the dictionary entry
        pddiDictL.append(pddi)
                     
    return pddiDictL       
   

if __name__ == "__main__":

    gen=ONC_HighPriority_Pickle_Generator()  
    f = open("../pickle-data/onchighpriority-ddis.pickle","w")
    pickle.dump(gen, f)
    f.close()

