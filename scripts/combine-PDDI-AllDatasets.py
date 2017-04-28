"""
# Combine-PDDI-AllDatasets.py
#
# Combine the drug-drug interaction datasets publicly available
#
# Authors: Serkan Ayvaz
#
# August/September 2014

"""
import pickle
import json
import urllib2
import urllib
import traceback
import pickle
import sys
import re
sys.path = sys.path + ['.']

from PDDI_Model import getPDDIDict

# See PDDI_Model for the structure of the PDDI dictionaries being parsed
DIKB_OBSERVED_PDDI_FILE = "../pickle-data/dikb-observed-ddis.pickle"
DIKB_PREDICTED_PDDI_FILE = "../pickle-data/dikb-predicted-ddis.pickle"
TWOSIDES_PDDI_FILE = "../pickle-data/twosides-ddis.pickle"
DRUGBANK_PDDI_FILE = "../pickle-data/drugbank4-ddis.pickle"
NDFRT_PDDI_FILE_INCHI_AND = "../pickle-data/ndfrt-mapped-ddis-inchi-and.pickle"
NDFRT_PDDI_FILE_INCHI_OR = "../pickle-data/ndfrt-mapped-ddis-inchi-or.pickle"
KEGG_PDDI_FILE = "../pickle-data/kegg-ddis.pickle"
CREDIBLEMEDS_PDDI_FILE = "../pickle-data/crediblemeds-ddis.pickle"
DDICORPUS2011_PDDI_FILE_INCHI_AND = "../pickle-data/ddicorpus2011-ddis-inchi-and.pickle"
DDICORPUS2011_PDDI_FILE_INCHI_OR = "../pickle-data/ddicorpus2011-ddis-inchi-or.pickle"
DDICORPUS2013_PDDI_FILE_INCHI_AND = "../pickle-data/ddicorpus2013-ddis-inchi-and.pickle"
DDICORPUS2013_PDDI_FILE_INCHI_OR = "../pickle-data/ddicorpus2013-ddis-inchi-or.pickle"
NLMCORPUS_PDDI_FILE_INCHI_AND = "../pickle-data/nlmcorpus-ddis-inchi-and.pickle"
NLMCORPUS_PDDI_FILE_INCHI_OR = "../pickle-data/nlmcorpus-ddis-inchi-or.pickle"
PKCORPUS_PDDI_FILE_INCHI_AND = "../pickle-data/pkcorpus-ddis-inchi-and.pickle"
PKCORPUS_PDDI_FILE_INCHI_OR= "../pickle-data/pkcorpus-ddis-inchi-or.pickle"
ONCHIGHPRIORITY_PDDI_FILE = "../pickle-data/onchighpriority-ddis.pickle"
ONCNONINTERUPTIVE_PDDI_FILE = "../pickle-data/oncnoninteruptive-ddis.pickle"
OSCAR_PDDI_FILE = "../pickle-data/oscar-ddis.pickle"
SEMMEDDB_PDDI_FILE = "../pickle-data/semmeddb-ddis.pickle"  

 
def loadPickle(FILE_Name):
     f = open(FILE_Name, 'r')
     pickle_file = pickle.load(f)
     f.close()    
     
     return pickle_file
      
def writePDDIs(fname,PDDIs,label):
    f = open(fname, "w")
    s = "drug1\tobject\tdrug2\tprecipitant\tcertainty\tcontraindication\tdateAnnotated\tddiPkEffect\tddiPkMechanism\teffectConcept\thomepage\tlabel\tnumericVal\tobjectUri\tpathway\tprecaution\tprecipUri\tseverity\turi\twhoAnnotated\tsource\tddiType\tevidence\tevidenceSource\tevidenceStatement\tresearchStatementLabel\tresearchStatement\n"  

    for a in PDDIs:
        rgx = re.compile(" ")       
        obj = a.get('object').strip()
        obj = rgx.sub("_",obj)    
                        
        pre = a.get('precipitant').strip()
        pre = rgx.sub("_", pre)
        
        s += "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" % (
           a.get('drug1'),
           obj,
           a.get('drug2'),
           pre, 
           a.get('certainty'),
           a.get('contraindication'),
           a.get('dateAnnotated'),
           a.get('ddiPkEffect'),
           a.get('ddiPkMechanism'),
           a.get('effectConcept'),
           a.get('homepage'),
           a.get('label'),
           a.get('numericVal'),
           a.get('objectUri'),           
           a.get('pathway'),           
           a.get('precaution'),  
           a.get('precipUri'),   
           a.get('severity'),  
           a.get('uri'), 
           a.get('whoAnnotated'), 
           a.get('source'), 
           a.get('ddiType'),
           a.get('evidence'),
           a.get('evidenceSource'),
           a.get('evidenceStatement'), 
           a.get('researchStatementLabel'),
           a.get('researchStatement')  
          )       
     
    f.write(s)
    f.close()
    
def writePDDIsForProtocolTest(fname,PDDIs,label):
    f = open(fname, "w")
    s = "object\tprecipitant\teffectConcept\tsource\n"  

    for a in PDDIs:
        rgx = re.compile(" ") 
        obj = a.get('object').strip()
        obj = rgx.sub("_",obj)       
        
        pre = a.get('precipitant').strip()
        pre = rgx.sub("_", pre)
        
        s += "%s\t%s\t%s\t%s\n" % (
           obj,
           pre, 
           a.get('effectConcept'),
           a.get('source')
          )       
      
    f.write(s)
    f.close()
       
def combinePDDIDatasets(IsForProtocol,IsConservativeMapping): 
       
    DIKB_OBSERVED_L = loadPickle(DIKB_OBSERVED_PDDI_FILE)    
    DIKB_PREDICTED_L = loadPickle(DIKB_PREDICTED_PDDI_FILE)   
    DRUGBANK_L = loadPickle(DRUGBANK_PDDI_FILE)   
    TWOSIDES_L = loadPickle(TWOSIDES_PDDI_FILE)    
    KEGG_L = loadPickle(KEGG_PDDI_FILE) 
    CREDIBLEMEDS_L = loadPickle(CREDIBLEMEDS_PDDI_FILE)       
    ONCHIGHPRIORITY_L = loadPickle(ONCHIGHPRIORITY_PDDI_FILE)  
    ONCNONINTERUPTIVE_L = loadPickle(ONCNONINTERUPTIVE_PDDI_FILE)  
    OSCAR_L = loadPickle(OSCAR_PDDI_FILE) 
    SEMMEDDB_L = loadPickle(SEMMEDDB_PDDI_FILE)   

    if IsConservativeMapping:
        NDFRT_L = loadPickle(NDFRT_PDDI_FILE_INCHI_AND)    
        DDICORPUS2011_L = loadPickle(DDICORPUS2011_PDDI_FILE_INCHI_AND) 
        DDICORPUS2013_L = loadPickle(DDICORPUS2013_PDDI_FILE_INCHI_AND) 
        NLMCORPUS_L = loadPickle(NLMCORPUS_PDDI_FILE_INCHI_AND) 
        PKCORPUS_L = loadPickle(PKCORPUS_PDDI_FILE_INCHI_AND)
    else: 
        NDFRT_L = loadPickle(NDFRT_PDDI_FILE_INCHI_OR)    
        DDICORPUS2011_L = loadPickle(DDICORPUS2011_PDDI_FILE_INCHI_OR) 
        DDICORPUS2013_L = loadPickle(DDICORPUS2013_PDDI_FILE_INCHI_OR) 
        NLMCORPUS_L = loadPickle(NLMCORPUS_PDDI_FILE_INCHI_OR) 
        PKCORPUS_L = loadPickle(PKCORPUS_PDDI_FILE_INCHI_OR)
        
        
    allPDDIs = ( DIKB_OBSERVED_L + DIKB_PREDICTED_L + DRUGBANK_L + TWOSIDES_L + NDFRT_L + KEGG_L 
                 + CREDIBLEMEDS_L +DDICORPUS2011_L + DDICORPUS2013_L + NLMCORPUS_L + PKCORPUS_L 
                 + ONCHIGHPRIORITY_L + ONCNONINTERUPTIVE_L + OSCAR_L + SEMMEDDB_L        
               )
    
    
    if IsForProtocol:
        if IsConservativeMapping:
              writePDDIsForProtocolTest("../analysis-results/CombinedDatasetForProtocolTestConservative.csv",allPDDIs,"Combined")
        else:
              writePDDIsForProtocolTest("../analysis-results/CombinedDatasetForProtocolTestNotConservative.csv",allPDDIs,"Combined")
    else:  
        if IsConservativeMapping:
              writePDDIs("../analysis-results/CombinedDatasetConservative.csv",allPDDIs,"Combined")
        else:
             writePDDIs("../analysis-results/CombinedDatasetNotConservative.csv",allPDDIs,"Combined")
  
   
    # report
    print '''Dataset PDDI Breakdown 

Number of PDDIs:   
    DIKB: %d 
    Drugbank: %d 
    Twosides: %d
    NDF-RT: %d 
    KEGG: %d 
    CredibleMeds: %d
    DDI Corpus 2011: %d
    DDI Corpus 2013: %d
    NLM Corpus: %d     
    PK Corpus: %d   
    ONC High-Priority : %d 
    ONC Non-Interuptive : %d 
    OSCAR : %d 
    SemMedDB : %d 
    
    Total: %d   
    
------------------------------------------------------------------------------------------


''' % ( len(DIKB_OBSERVED_L + DIKB_PREDICTED_L),len(DRUGBANK_L),len(TWOSIDES_L),len(NDFRT_L),
        len(KEGG_L),len(CREDIBLEMEDS_L),len(DDICORPUS2011_L),len(DDICORPUS2013_L),
        len(NLMCORPUS_L), len(PKCORPUS_L), len(ONCHIGHPRIORITY_L), len(ONCNONINTERUPTIVE_L),
        len(OSCAR_L), len(SEMMEDDB_L), len(allPDDIs)
      ) 
            
if __name__ == "__main__":        
     #combinePDDIDatasets(True, True)    #Conservative Mapping Test
     combinePDDIDatasets(True, False)   #Not Conservative Mapping Test
     #combinePDDIDatasets(False)  



