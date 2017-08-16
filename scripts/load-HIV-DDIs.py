""" Simple Python script to build a dictionary of HIV DDIs "


# Authors: Serkan Ayvaz
#
# April 2017

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


HIV_DDI_DATA = "../PDDI-Datasets/HIV-drug-interactions/HIV-drug-interactions.tsv"


def hiv_DDI_Pickle_Generator():
    # open the HIV-drug-interactions data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           HIV-drug-interactions .
   
    pddiDictL = []
    f = open(HIV_DDI_DATA, 'r')
    
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
                  "HIV"
                  )
            
            print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
            #print "effectConcept: %s:-- ddiPkMechanism: %s" % (pddi["effectConcept"],pddi["ddiPkMechanism"] )
               
            # return the dictionary entry
            pddiDictL.append(pddi) 
         
    return pddiDictL       
   

if __name__ == "__main__":

    gen=hiv_DDI_Pickle_Generator()  
    f = open("../pickle-data/hiv-ddis.pickle","w")
    pickle.dump(gen, f)
    f.close()
