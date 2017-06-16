""" Simple Python script to build a dictionary of DDIs from the Drugbank 4 database"

# Authors: Serkan Ayvaz
# Added June 2014 
# Updated June 2017 by Serkan Ayvaz

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

Drugbank4_DATA = "../PDDI-Datasets/DrugBank/Drugbank5-PDDIs.csv"
#Drugbank4_DATA = "../PDDI-Datasets/DrugBank/drugbank4-DDIs.csv"

def Drugbank4_Pickle_Generator():
    # open the load-Drugbank4-DDIs data file and parse it incrementally
    #
    # @returns: a PDDI drug model dictionary containing all of the data in a single
    #           a PDDI.
   
    pddiDictL = []
    
    f = open(Drugbank4_DATA, 'r')
    
    while 1 :
        if not f:
            f.close()
            raise StopIteration
        
        l = f.readline()
        if l == "":
            f.close()
            break
        else:
            if l.find("object_drugbank") != -1: # skips header and stops at EOF
               l = f.readline() 
        
        elts = l.strip("\n").split("$")
          
        pddi = getPDDIDict()             
        (pddi["object"], 
         pddi["drug1"],
         pddi["precipitant"], 
         pddi["drug2"], 
         #pddi["label"], 
         pddi["source"]
         ) = (
              elts[1], 
              "http://bio2rdf.org/drugbank:" + str(elts[0]), 
              elts[3], 
             # elts[4], 
              "http://bio2rdf.org/drugbank:" + str(elts[2]), 
              "Drugbank"
              )

        #print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
        print "object: %s -- precipitant: %s" % (pddi["drug1"], pddi["drug2"])
             
        # return the dictionary entry
        pddiDictL.append(pddi)

         
    return pddiDictL       
   

if __name__ == "__main__":

    gen=Drugbank4_Pickle_Generator()
  
    f = open("../pickle-data/drugbank5-ddis.pickle","w")
    pickle.dump(gen, f)
    f.close()

