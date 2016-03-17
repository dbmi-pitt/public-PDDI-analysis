import os
import sys
import xml.etree.ElementTree as ET

ENG_GROUPS2015_XML_V3_ID_CODES = "eng_groups2015_xml_v3.tsv"
groups_outfile = open(ENG_GROUPS2015_XML_V3_ID_CODES, 'w')

groups_outfile.write("Drug Name\tRxNorm\tSource File\tClinical Source\tClass Name\tClass Code\n")
atc_dict = {}

for file in os.listdir("./eng_groups2015-xml-v3"):  
  if file.endswith(".xml"):
    file = "./eng_groups2015-xml-v3/" + file
    with open(file) as f:
      tree = ET.parse(f)
      root = tree.getroot()

      # CLASS
      if(root.tag == 'CLASS'):
        class_name = root.get('name')
        class_code = root.get('code')

      for i in root.getchildren():

        # SOURCE
        for j in i.getchildren():
          if(j.tag == 'CLINICAL_SOURCE'):
            clinical_source = j.text
          if(j.tag == 'SOURCE_FILE'):
            source_file = j.text
        
        # DRUG
        if(i.tag == 'DRUG'):
          drug_name = i.get('name')
          rxnorm = i.get('rxnorm')

          if rxnorm is None:
            rxnorm = ''

          groups_outfile.write("%s\t%s\t%s\t%s\t%s\t%s\n" % ((drug_name.upper()).rstrip('\n'), rxnorm.rstrip('\n'), source_file.rstrip('\n'), clinical_source.rstrip('\n'), class_name.rstrip('\n'), class_code.rstrip('\n')) )

          for j in i.getchildren():
            if(j.tag == 'ATC'):
              atc_code = j.get('code')
              atc_dict[atc_code.rstrip('\n') + "\t" + drug_name.upper()] = ""
    
	
groups_outfile.close()





ENG_TABLES2015_XML_V5 = "eng_tables2015-xml-v5.tsv"
tables_outfile = open(ENG_TABLES2015_XML_V5, 'w')

tables_outfile.write("Drug Interaction ID\tDrug 1 Name\tDrug 1 RxCUI\tDrug 1 Class Name\tDrug 1 Code\tDrug 2 Name\tDrug 2 RxCUI\tDrug 2 Class Name\tDrug 2 Code\tClinical Source\tSource File\tDescription\tSeverity\tComment\n")

drug_interaction_id = 0
drug_codes = {}
drug_code_id = 0
drug_class_codes = {}
drug_class_code_id = 0
general_drug_id = 0
drug_interaction_id = 0

for file in os.listdir("./eng_tables2015-xml-v5"):
  if file.endswith(".xml"):
    file = "./eng_tables2015-xml-v5/" + file

    with open(file) as f:
      tree = ET.parse(f)
      root = tree.getroot()
      
      for i in root.getchildren():
        if(i.tag == 'INTERACTION'):
          comment = ''
          drug_1_name = ''
          drug_1_rxcui = ''
          drug_1_class_name = ''
          drug_1_code = ''
          drug_2_name = ''
          drug_2_rxcui = ''
          drug_2_class_name = ''
          drug_2_code = ''
          description = ''
          severity = ''
          source_file = ''
          clinical_source = ''

          for j in i.getchildren():
            
            # SOURCE
            if(j.tag == 'SOURCE'):
              for k in j.getchildren():
                if(k.tag == 'CLINICAL_SOURCE'):
                  clinical_source = k.text
                if(k.tag == 'SOURCE_FILE'):
                  source_file = k.text

            # DRUG1
            if(j.tag == 'DRUG1'):
              for k in j.getchildren():
                if(k.tag == 'DRUG'):
                  drug_1_name = k.get('name')
                  drug_1_rxcui = k.get('rxcui')

                  for l in k.getchildren():
                    if(l.tag == 'ATC'):
                      atc_dict[l.get('code').rstrip('\n') + "\t" + drug_1_name.upper().rstrip('\n')] = ""

                if(k.tag == 'CLASS'):
                  drug_1_class_name = k.get('name')
                  drug_1_code = k.get('code')

            # DRUG2
            if(j.tag == 'DRUG2'):
              for k in j.getchildren():
                if(k.tag == 'DRUG'):
                  drug_2_name = k.get('name')
                  drug_2_rxcui = k.get('rxcui')

                  for l in k.getchildren():
                    if(l.tag == 'ATC'):
                      atc_dict[l.get('code').rstrip('\n') + "\t" + drug_2_name.upper().rstrip('\n')] = ""

                if(k.tag == 'CLASS'):
                  drug_2_class_name = k.get('name')
                  drug_2_code = k.get('code')
                  
            # DESCRIPTION
            if(j.tag == 'DESCRIPTION'):
              description = j.text

            # SEVERITY
            if(j.tag == 'SEVERITY'):
              severity = j.text

            # COMMENT
            if(j.tag == 'COMMENT'):
              comment = j.text

          if comment is None:
            comment = ''
          if description is None:
            description = ''
          if severity is None:
            severity = ''
          if source_file is None:
            source_file = ''
          if clinical_source is None:
            clinical_source = ''
          if drug_1_name is None:
            drug_1_name = ''
          if drug_1_rxcui is None:
            drug_1_rxcui = ''
          if drug_1_class_name is None:
            drug_1_class_name = ''
          if drug_1_code is None:
            drug_1_code = ''
          if drug_2_name is None:
            drug_2_name = ''
          if drug_2_rxcui is None:
            drug_2_rxcui = ''
          if drug_2_class_name is None:
            drug_2_class_name = ''
          if drug_2_code is None:
            drug_2_code = ''

          tables_outfile.write("%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n" % ( (str(drug_interaction_id)).rstrip('\n'), (drug_1_name.upper()).rstrip('\n'), drug_1_rxcui.rstrip('\n'), drug_1_class_name.rstrip('\n'), drug_1_code.rstrip('\n'), (drug_2_name.upper()).rstrip('\n'), drug_2_rxcui.rstrip('\n'), drug_2_class_name.rstrip('\n'), drug_2_code.rstrip('\n'), clinical_source.rstrip('\n'), source_file.rstrip('\n'), description.rstrip('\n').replace('\n', ''), severity.rstrip('\n'), comment.rstrip('\n')))
          drug_interaction_id += 1

tables_outfile.close()

ENG_GROUPS2015_XML_V3_ATC_CODES = "eng_groups_tables_2015_xml_v3_v5_atc_codes.tsv"
atc_codes_outfile = open(ENG_GROUPS2015_XML_V3_ATC_CODES, 'w')
atc_codes_outfile.write("ATC Code\tDrug Name\n")

for key, value in atc_dict.items():
  atc_codes_outfile.write("%s\n" % ( key.rstrip(' \t\n\r') ) )

atc_codes_outfile.close()

sys.exit(0)