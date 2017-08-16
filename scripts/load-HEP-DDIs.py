""" Simple Python script to build a dictionary of HEP DDIs "


# Authors: Serkan Ayvaz
#
# June 2017

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


HEP_DDI_DATA = "../PDDI-Datasets/HEP-drug-interactions/HEP-drug-interactions.tsv"


def HEP_DDI_Pickle_Generator():
    # open the HEP-drug-interactions data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           HEP-drug-interactions .
   
    pddiDictL = []
    f = open(HEP_DDI_DATA, 'r')
    
    while 1 :
        if not f:
            f.close()
            raise StopIteration
        
        l = f.readline()
        if l == "":
            f.close()
            break
        else:
            if l.find("Drug 1") != -1: # skips header and stops at EOF
               l = f.readline()
      
              
            elts = l.strip("\n").split("\t")
            pddi = getPDDIDict()
            (pddi["object"], 
             pddi["drug1"],
             pddi["precipitant"], 
             pddi["drug2"],
             pddi["evidenceStatement"], 
             pddi["label"],
             pddi["source"]
             ) = (
                  elts[0], 
                  "http://bio2rdf.org/drugbank:" + str(elts[1]), 
                  elts[2], 
                  "http://bio2rdf.org/drugbank:" + str(elts[3]), 
                  elts[4], 
                  elts[5],  
                  "HEP"
                  )
            
            print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
           
  
            # return the dictionary entry
            pddiDictL.append(pddi) 
         
    return pddiDictL       
   

if __name__ == "__main__":

    gen=HEP_DDI_Pickle_Generator()  
    f = open("../pickle-data/hep-ddis.pickle","w")
    pickle.dump(gen, f)
    f.close()
