""" Simple Python script to load pubchem ids with matchin Drugbank IDs"
    No extra libraries required.

# Authors: Serkan Ayvaz, Richard D Boyce, Yifan Ning
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
 
Pubchem_DATA = "../PDDI-Datasets/Twosides/drugbank4-to-pubchem.tsv"


def Pubchem_Pickle_Generator():
    # open the Pubchem data file and parse it incrementally
     
    mapDictL = []

    f = open(Pubchem_DATA, 'r')
    while 1 :
        if not f:
            f.close()
            raise StopIteration
        
        l = f.readline()
        if l == "":
            f.close()
            break
        else:
            if l.find("pubchemCompoundId") != -1: # skips header and stops at EOF
               l = f.readline()
       
        elts = l.strip("\n").split("\t")
 
  
        newD = {"drugbankid":None,"drugbankName":None,"pubchemCompoundId":None, "pubchemSubstanceId":None}
        newD["drugbankid"] =  elts[0]
        newD["drugbankName"] =  elts[1]
        if len(elts) > 2 and elts[2] != None: 
            newD["pubchemSubstanceId"] =  elts[2] 
        if len(elts) > 3 and elts[3] != None: 
            newD["pubchemCompoundId"] =  elts[3]
               #elts[3] != None:
            
        mapDictL.append(newD)

        print "drugbankid: %s drugbankName: %s-- pubchemSubstanceId:%s pubchemCompoundId: %s" % (newD["drugbankid"],newD["drugbankName"], newD["pubchemSubstanceId"],newD["pubchemCompoundId"])
               
    return mapDictL       
   
if __name__ == "__main__":
  
    gen=Pubchem_Pickle_Generator()
    f = open("../pickle-data/pubchem-to-drugbank-mapping.pickle","w")
    pickle.dump(gen, f)
    f.close()
        

