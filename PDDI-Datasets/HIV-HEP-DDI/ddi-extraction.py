# ddi-extraction.py
# Read .html files in folders:
#   HEP-drug-interactions
#   HIV-drug-interactions
#   HIV-Insite-interactions
# Retrieve 2 drug names, quality of evidence, summary, and description of ddi
# Consolidate all such DDI's from each folder as .csv file

# import fileinput
import glob
import os

from bs4 import BeautifulSoup

################### GLOBAL VARIABLES ###################

DEBUG = True

# INPUT FILE FOLDERS
HEP_DDI_PATH = "../HEP-drug-interactions"
HIV_DDI_PATH = "../HIV-drug-interactions"
HIV_INSITE_DDI_PATH = "../HIV-Insite-interactions"

# OUTPUT FILES
HEP_OUTFILE = "./HIV-HEP-DDI/HEP-drug-interactions.csv"
HIV_OUTFILE = "./HIV-HEP-DDI/HIV-drug-interactions.csv"
HIV_INSITE_OUTFILE = "./HIV-HEP-DDI/HIV-Insite-interactions.csv"

########################################################

# uncomment one at a time. Comment both out for HIV-drug-interactions folder
os.chdir(HEP_DDI_PATH)
# os.chdir(HIV_DDI_PATH)
# os.chdir(HIV_INSITE_DDI_PATH)
for file in glob.glob("*.html"):
    if DEBUG:
        print(file)

    f = open(file)
    soup = BeautifulSoup(f, "html.parser")
    ddi_list = soup.findAll('div', attrs={'class': 'interaction-block interaction-list'})
    # Each "interaction-block interaction-list" includes:
    # 2 drug names: <div class="interaction-block-inner">
    # Quality of evidence: <p><strong>Quality of Evidence:</strong>Very Low</p>
    #       <p class="interaction-block-header *">
    #       * can be:
    #           "interaction-block-header orange"
    #           "interaction-block-header green"
    #           "interaction-block-header gray outline"
    #           "interaction-block-header green outline"
    #           "interaction-block-header red"
    #           "interaction-block-header gray"
    # Summary: <strong>Summary:</strong> <div class="interaction-info-divide">
    # Description: <strong>Description:</strong> <div class="interaction-info-divide">
    for ddi in ddi_list:
        s = BeautifulSoup(str(ddi), "html.parser")
        drugs = s.findAll('div', attrs={'class': 'interaction-block-inner'})
        # quality = s.findAll('p', attrs={'class': ''})
        info = s.findAll('div', attrs={'class': 'interaction-info-divide'})
        # TODO find by <strong>, "interaction-info-divide" is not specific.
        for node in drugs:
            if DEBUG:
                print node
            drug = ''.join(node.findAll(text=True)).encode('utf-8')
            drug1 = drug.split('\n')[1]
            drug2 = drug.split('\n')[2]
            if DEBUG:
                print(drug1)
                print(drug2)
        # for node in quality:
        #     if DEBUG:
        #         print node
        #     q = ''.join(node.findAll(text=True))
        #     if DEBUG:
        #         print(q)
        for node in info:
            if DEBUG:
                print node
            q = ''.join(node.findAll(text=True)).encode('utf-8')
            if DEBUG:
                print(q)
