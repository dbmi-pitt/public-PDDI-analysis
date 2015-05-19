""" Simple Python script to build a dictionary of DDIs from the SemMedDB"

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

SemMedDB_DATA = "../PDDI-Datasets/SemMedDB/SemMedDB_DDIs_Mapped.csv"

def SemMedDB_Pickle_Generator():
    # open the SemMedDB data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           SemMedDB  PDDI.
   
    pddiDictL = []

    f = open(SemMedDB_DATA, 'r')
    
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
         pddi["evidence"], 
         pddi["source"]
        )=(
            elts[0], 
            "http://bio2rdf.org/drugbank:" + str(elts[2]),
            elts[3],              
            "http://bio2rdf.org/drugbank:" + str(elts[5]),
            elts[6],
            "SemMedDB"
          ) 
            
        print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
              
        # return the dictionary entry
        pddiDictL.append(pddi)
                     
    return pddiDictL       
   

if __name__ == "__main__":

    gen=SemMedDB_Pickle_Generator()  
    f = open("../pickle-data/semmeddb-ddis.pickle","w")
    pickle.dump(gen, f)
    f.close()

