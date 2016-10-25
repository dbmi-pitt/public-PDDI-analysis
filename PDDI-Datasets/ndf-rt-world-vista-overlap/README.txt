Part A - Find unique ingredients and interactions from raw NDF-RT data, ascribe RxCUI's to the appropriate VUID's in this data.

Part B - Transform the NDF-RT data, Load this data with the ascribed RxCUI's.

Part C - Write and polish query to find intersect between the NDF-RT and WorldVista data sets, as well as finding set differences for NDF-RT and WorldVista respectively.

-------------------------------------------------------------------------------------

PART A
A-1 Isolated ingredients from original raw data, which is included in ndf-rt.zip - includes NDF-RT-IXNS.DAT and NDF-RT-IXNS-ingredients-only.DAT:

    A-1.1 FILE: NDF-RT-IXNS.DAT - The original file of all NDF-RT PDDI's in the format:
            IN1 VUID A PRD1 VUID|IN2 VUID A PRD2 VUID|SEVERITY

    A-1.2 FILE: NDF-RT-IXNS-ingredients-only.DAT - All NDF-RT PDDI's, but with product terms truncated. Thus, the "A PRD1 VUID" and "A PRD2 VUID" terms are removed from the original NDF-RT-IXNS.DAT contents to result in a file with the format:
            IN1 VUID|IN2 VUID|SEVERITY

A-2 Created unique-interactions.txt - All unique interactions present in the NDF-RT-IXNS-ingredients-only.DAT file in the same format.

A-3 unique-vuid.txt - Extracted all unique ingredient VUID's involved in any NDF-RT PDDI from the NDF-RT-IXNS-ingredients-only.DAT file.

    A-3.1 Modified unique-vuid.txt to create unique-cs.txt - A comma separated version of unique-vuid.txt to be used with the following query in place of <vuid list>:
        SELECT code, rxcui FROM rxnconso WHERE code IN (<vuid list>) ORDER BY code ASC;
    This query on the RXNCONSO table in the RxNorm database provides the corresponding list of RxCui's for each unique ingredient present in the NDF-RT PDDI set.

    A-3.2 Output of the above query found in vuid-to-rxcui.xlsx

-------------------------------------------------------------------------------------

PART B
B-1 FILE: vuid-rxcui-dict.txt - provides a version of vuid-to-rxcui.xlsx that is amenable to transformation into a Python dictionary through the toDict.py script. This file is in the format:
    VUID1:RxCui1,VUID2:RxCui2,etc

B-2 FILE: NDF-RT-interactions.csv - A comma separated version of NDF-RT-IXNS-ingredients-only.DAT but with additional fields for the RxCUI mappings of each VUID.

B-2 The python script toDict.py transforms the VUID to RxCUI mappings from vuid-rxcui-dict.txt to a dictionary and fills out the new RxCUI fields for the file NDF-RT-interactions.csv according to the mappings in this dictionary.
    
    B-2.1 FILE: NDF-RT-interactions.csv is comma separated version of NDF-RT-IXNS-ingredients-only.DAT but with additional fields for the RxCUI mappings of each VUID, written in step B-2.

-------------------------------------------------------------------------------------

PART C
C-1 FILE: ndf-rt-schema.sql - Creates a new NDF-RT-Interaction table according to the contents of NDF-RT-interactions.csv
    C-1.1 This schema replaced "NULL" strings with actual null entries. Additionally, entries duplicate RxCUI's, where identical ingredient VUID's would be shown to "interact" in the original raw data, were deleted in this schema.

C-2 Querying of data worked with through overlap-sandbox.sql - A sandbox of SQL queries on the NDF-RT-interaction table created above that investigates the properties and characteristics of this new table in comparison to WorldVista's drug_interaction table toward building to an overlap analysis of these two data sets.

C-3 The streamlined, finalized query is stored in overlap_query.sql for finding the overlapping PDDI's between the NDF-RT and WorldVista PDDI data sets.

---

RESULT:

269527 total PDDI's in NDF-RT
264135 PDDI's in NDF-RT where the RxCUI mapping is not null. For the overlap analysis, the RxCUI entry must not be null.
137821 PDDI's in WorldVista when permutations of drugs in drug classes are accounted for.
391668 cumulatively with duplicates and no null entries.
354305 with no duplicates and no null entries.
OVERLAP = 26653

        WorldVista
NDF-RT  26653
        (9.889% in NDF-RT, 19.34% in WorldVista)


