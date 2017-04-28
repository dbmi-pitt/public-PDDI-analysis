""" Simple Python script to build the NDFRT-Drugbank mapping pickle"

# Authors: Richard D Boyce, Serkan Ayvaz  Michel Dumontier
#
# September 2014
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
from DrugMap import getDrug
from PDDI_Model import getPDDIDict

#NDFRT_Drugbank_DATA = "../PDDI-Datasets/Ndf-rt/NDFRT-Drugbank-mapping.csv"

NDFRT_Drugbank_DATA_INCHI_AND = "../PDDI-Datasets/Ndf-rt/NDFRTMappedINCHI_AND.csv"
NDFRT_Drugbank_DATA_INCHI_OR = "../PDDI-Datasets/Ndf-rt/NDFRTMappedINCHI_OR.csv"
NDFRT_PDDI_FILE = "../pickle-data/ndfrt-ddis.pickle"
NDFRT_PDDI_FILE_XREF_INCHI_AND = "../pickle-data/ndfrt-ddis-xref-inchi-and.pickle" 
NDFRT_PDDI_FILE_XREF_INCHI_OR = "../pickle-data/ndfrt-ddis-xref-inchi-or.pickle" 
 
   
def mapDrugPairs(list, xref):
    """ map drug pairs to PDDI dicts. Each key points to a list of PDDIs that share a drug pair """
    pddiDictL = []
    for p in list:  
        d1 = p["drug1"]
        d2 = p["drug2"] 
        
        if xref.has_key(d1) and xref.has_key(d2):
            pddi = getPDDIDict()        
            (
             pddi["object"],
             pddi["drug1"],
             pddi["precipitant"],
             pddi["drug2"],
             pddi["severity"],
             pddi["uri"],
             pddi["label"], 
             pddi["source"]        
            )=( 
                xref[d1]["drugname"],
                "http://bio2rdf.org/drugbank:" + str(xref[d1]["mappedIDs"][0]), 
                xref[d2]["drugname"],
                "http://bio2rdf.org/drugbank:" + str(xref[d2]["mappedIDs"][0]),  
                p["severity"],
                p["uri"], 
                p["label"],
                "NDF-RT"
              )
           
            print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
           
            # return the dictionary entry
            pddiDictL.append(pddi)
                     
    return pddiDictL     
  
def NDFRT_XREF_Pickle_Generator(datafile):
    # open the  data file and parse it incrementally   
    drugDictL = {}  
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
            if l.find("NUI") != -1: # skips header and stops at EOF
               l = f.readline()
         
            elts = l.strip("\n").split("$")  
            
            drug = getDrug()            
            (drug["drugname"], drug["nui"])= (elts[3],elts[0])
            drug["mappedIDs"].append(elts[2])
                                     
            if not drugDictL.has_key(drug["nui"]):
                     drugDictL[drug["nui"]] = drug
                     #print drug["nui"]   
                     #print drugDictL[drug["nui"]]   
            else:
                    newdrug =  drugDictL[drug["nui"]]   
                    newdrug["mappedIDs"].append(drug["mappedIDs"])
                    drugDictL[drug["nui"]]=newdrug
                    #print newdrug
                    #print drugDictL[drug["nui"]]

            #print "object: %s: %s-- precipitant:%s : %s" % (pddi["object"],pddi["drug1"],pddi["precipitant"], pddi["drug2"])
                
    return drugDictL       
  
def Generate_NDFRT_Mapping_Pickle(xreffile):   
      
    f = open(NDFRT_PDDI_FILE, 'r')
    ndfrtList = pickle.load(f)
    f.close()
    
    f = open(xreffile, 'r')
    ndftrtMapping = pickle.load(f)
    f.close()     

    ndfrtPairs = mapDrugPairs(ndfrtList,ndftrtMapping)  
         
    return ndfrtPairs
    
if __name__ == "__main__":
    
    gen=NDFRT_XREF_Pickle_Generator(NDFRT_Drugbank_DATA_INCHI_AND)  
    f = open("../pickle-data/ndfrt-ddis-xref-inchi-and.pickle","w")
    pickle.dump(gen, f)
    f.close()
    
    gen=NDFRT_XREF_Pickle_Generator(NDFRT_Drugbank_DATA_INCHI_OR)  
    f = open("../pickle-data/ndfrt-ddis-xref-inchi-or.pickle","w")
    pickle.dump(gen, f)
    f.close()
    
     
    results=Generate_NDFRT_Mapping_Pickle(NDFRT_PDDI_FILE_XREF_INCHI_AND)
    f = open("../pickle-data/ndfrt-mapped-ddis-inchi-and.pickle","w")
    pickle.dump(results, f)
    f.close()
     
     
    results=Generate_NDFRT_Mapping_Pickle(NDFRT_PDDI_FILE_XREF_INCHI_OR)
    f = open("../pickle-data/ndfrt-mapped-ddis-inchi-or.pickle","w")
    pickle.dump(results, f)
    f.close()
 
 

    
