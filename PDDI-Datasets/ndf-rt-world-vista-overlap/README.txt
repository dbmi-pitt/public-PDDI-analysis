ndf-rt.zip - includes NDF-RT-IXNS.DAT and NDF-RT-IXNS-ingredients-only.DAT:

    NDF-RT-IXNS.DAT - The original file of all NDF-RT PDDI's in the format:
    IN1 VUID A PRD1 VUID|IN2 VUID A PRD2 VUID|SEVERITY

    NDF-RT-IXNS-ingredients-only.DAT - All NDF-RT PDDI's, but with product terms truncated. Thus, the "A PRD1 VUID" and "A PRD2 VUID" terms are removed from the original NDF-RT-IXNS.DAT contents to result in a file with the format:
    IN1 VUID|IN2 VUID|SEVERITY

unique-interactions.txt - All unique interactions present in the NDF-RT-IXNS-ingredients-only.DAT file in the same format.

unique-vuid.txt - All unique ingredient VUID's involved in any NDF-RT PDDI from the NDF-RT-IXNS-ingredients-only.DAT file.

unique-cs.txt - A comma separated version of unique-vuid.txt to be used with the following query in place of <vuid list>:
SELECT code, rxcui FROM rxnconso WHERE code IN (<vuid list>) ORDER BY code ASC;
This query on the RXNCONSO table in the RxNorm database provides the corresponding list of RxCui's for each unique ingredient present in the NDF-RT PDDI set.

vuid-to-rxcui.xlsx - is the output of the above query.

vuid-rxcui-dict.txt - provides a version of vuid-to-rxcui.xlsx that is amenable to transformation into a Python dictionary through the toDict.py script. This file is in the format:
VUID:RxCui,

NDF-RT-interactions.csv - A comma separated version of NDF-RT-IXNS-ingredients-only.DAT but with additional fields for the RxCUI mappings of each VUID.

toDict.py - A python script that transforms the VUID to RxCUI mappings from vuid-rxcui-dict.txt to a dictionary and fills out the new RxCUI fields for NDF-RT-interactions.csv according to the mappings in this dictionary.

ndf-rt-schema.sql - Creates a new NDF-RT-Interaction table according to the contents of NDF-RT-interactions.csv

overlap-sandbox.sql - A sandbox of SQL queries on the NDF-RT-interaction table created above that investigates the properties and characteristics of this new table in comparison to WorldVista's drug_interaction table toward building to an overlap analysis of these two data sets.

overlap_query.sql - gives the simplified view of the finalized query (which is included in overlap-sandbox.sql) for finding the overlapping PDDI's between the NDF-RT and WorldVista PDDI data sets.

---

RESULT:

269527 in NDF-RT
2846 in WorldVista
265435 cumulatively with duplicates
261303 with no duplicates
OVERLAP = 581

        WorldVista
NDF-RT  581
        (0.2156% in NDF-RT, 20.41% in WorldVista)


