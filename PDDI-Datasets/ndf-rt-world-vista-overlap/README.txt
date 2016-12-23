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
    
    C-3.1 In order to account for the variety of drugs that can be included in a "Drug Group" a temporary table is created called "Drug_Class_Interaction" that represents left join of the "Drug_Interaction" and "Drug_Group" tables. This temporary table uses the "COALESCE" function to consolidate the RxCUI's for drugs in a drug group and for individual drugs into one single column.
    For example:
        COALESCE(i.Drug_1_RxCUI,g.RxNorm)
    g.RxNorm provides several RxCUI's for drugs that would be in a drug group, and i.Drug_1_RxCUI provides an RxCUI for individual drugs. These would otherwise be in separate columns, but to ease the complexity of querying, they are coalesced into one column. Duplicate sets drug 1 and drug 2 RxCUI's, as well as interactions where drug 1 and drug 2 RxCUI's are identical are excluded from this table.

    C-3.2 Duplicate drug 1 and drug 2 RxCUI's are removed from this new table so that the final query would not count these among overlaps. The intersect between the NDF-RT and this dataset went down drastically to 11980 from 33515.

    C-3.3 Duplicate drug 1 and drug 2 RxCUI's are also no longer counted in the NDF-RT data set. While these do not necessarily mean the interactions are the same, a small set of VUID's share the same RxCUI and, or the same interactions are represented with different severities. For the sake of comparison with WorldVista, though, these duplicates were grouped together in the NDF-RT data set so that only unique drug 1 and drug 2 RxCUI sets are included. The intersect of this version of the NDF-RT data set and WorldVista again went down to 8074 from 11980.
    
    C-3.3 The final query comes after creating this table, where a "UNION ALL" provides provides the intersect of drug interactions in the NDF-RT and WorldVista datasets. The function "HAVING COUNT(*) > 1" provides the intersect between the two datasets.

    C-3.3 The other queries in this file use left join functions to address set differences in the NDF-RT and WorldVista data sets, respectively. That is, the unique PDDI's that are only seen in the NDF-RT data set and the unique PDDI's that are only seen in the WorldVista data set are queried.
    
    C-3.4 All queries were joined with the RXNCONSO table from the rxnorm schema in order to include names for the drugs, and these queries were outputted into .csv files called "worldvista-NDFRT-overlap.csv", "NDFRT-set-difference.csv", and "worldvista-set-difference.csv". These queries used another "GROUP BY" function because one RxCUI could return several name variations for the same drug in the RXNCONSO table. For WorldVista set differences, this join had to become a "LEFT JOIN" because some RxCUI's did not have entries in the RXNCONSO table.
    
    C-3.5 "Inner join" functions were used to identify reverse duplicates within each of the NDF-RT and WorldVista PDDI sets (ex. pairs of [drug a, drug b] would be repeated as [drug b, drug a]. This removed 132034 rows from the NDF-RT data set and removed 45649 rows from the WorldVista Drug_Class_Interaction table. This further reduced the overlap from 8074 to 4032 PDDI's, and reduced the set differences from 251862 PDDI's that only appeared in NDF-RT to 125936 PDDI's. For the WorldVista set differences, this figure reduced from 83352 PDDI's to 41745 PDDI's that only appeard in WorldVista.

-------------------------------------------------------------------------------------

PART D
D-1 Previously, there were VUID's that when mapped to RxCUI's via the RXNCONSO table, the returned RxCUI's appeared to be nonexistent in RxNav. Thus, we conclude that these should not be included in the NDF-RT interaction set as they are a sort of false positive in mapping of VUID's.
For example:
    "Mirtazapine","15996","ATROPINE/BENZOIC/GELSEMIUM/HYOSCYAMINE/METHENAMINE/METHYLENE/PHE","689591"
    "Mirtazapine","15996","ATROPINE/BENZOIC/HYOSCYAMINE/METHENAMINE/METHYLENE/PHENYL","689592"
    "Mirtazapine","15996","HYOSCYAMINE/METHAMINE/METHYLENE BLUE/PHENYL SALICYLATE/SODIUM BI","689939"
    "Mirtazapine","15996","HYOSCYAMINE/METHENAMINE/METHYLENE BLUE/PHENYL SALICYLATE/SODIUM","690126"
RxCUI 689591, 689592, 689939, and 690126 were RxCUI mappings found from the RXNCONSO table but were not found elsewhere in the RxNav or RXNREL tables. We decided to therefore drop these mappings as faulty and reconsidered them as "null" to adjust the analysis.

D-2 The following query was used to find these "false positive" mappings for the purpose of removing them from the NDF-RT PDDI set:
    SELECT v.CODE, v.RXCUI, v.STR, r.RXCUI1, x.RXCUI2 FROM (
    SELECT CODE, RXCUI, STR FROM RXNCONSO WHERE CODE IN (<vuid list>))
    AS v
    LEFT JOIN RXNREL r
    ON r.RXCUI1 = v.RXCUI
    LEFT JOIN RXNREL x
    ON x.RXCUI2= v.RXCUI
    WHERE r.RXCUI1 IS NULL
    AND x.RXCUI2 IS NULL;
918 mappings (listed in null-rxcui.csv) dropped out. Now, the number of PDDI's in NDF-RT included in the analysis decreased dramatically from 129968 to 54503 PDDI's. Value for PDDI's in which the RxCUI is not null went down from 264068  to 111298.

D-3 Analysis re-run. Overlap decreased from 4032 to 4014, set NDF-RT differences decreased from 125936  to 50489, and set WorldVista differences increased slightly from 41745  to 41763 

D-4 VA combo products (for example: ACETAMINOPHEN/DEXTROMETHORPHAN/DOXYLAMINE/PHENYLEPHRINE) also seem to inflate the VA dataset compared to WorldVista. Through the query below, these products were identified (listed in VA-combos.csv) and also taken out:
    SELECT c.CODE, r.RXCUI2, c.STR, r.RELA, r.RXCUI1, d.STR FROM rxnorm.RXNREL r
    INNER JOIN (
    SELECT CODE, RXCUI, STR FROM RXNCONSO WHERE CODE IN (<vuid list>))
    c
    ON c.RXCUI = r.RXCUI2
    INNER JOIN RXNCONSO d ON r.RXCUI1 = d.RXCUI
    WHERE (r.RELA = 'has_part')
    GROUP BY RXCUI2, RXCUI1
    ORDER BY RXCUI2, RXCUI1;
This query returned 759 combo products to be dropped out, which had 1876 individual ingredients conglomerated among these combo products.

D-5 Analysis re-run to give the new results below. PDDI's in NDF-RT where the RxCUI mapping is not null decreased from 111298 to 35630, and decreased from 109006 to 35466 for distinct sets of these RxCUI pairs. When reverse duplicates were eliminated, the count for this decreased from 54503 to 17733 PDDI's.
    Results changes:
        Overlap decreased from 4014 to 4012
        NDF-RT set differences decreased from 50489 to 13721
        WorldVista set differences decreased from 41763 to 41765
---

RESULTS:

269523 total PDDI's in NDF-RT where drug 1 and drug 2 RxCUI's are not equivalent.
    35630 PDDI's in NDF-RT where the RxCUI mapping is not null. For the overlap analysis, the RxCUI entry must not be null. A large number of PDDI's drop out due to the existence of "false positive" mappings for VUID's, in which the RxCUI mapped from the RXNCONSO table is actually not found in RxNav or the RXNREL table. Even more dropped out when combo products were removed.
    35466 PDDI's in this set for distinct sets of drug 1 and drug 2 RxCUI's and no null entries.
    17733 PDDI's in this set when reverse duplicates are eliminated (ex. pairs of [drug a, drug b] would be repeated as [drug b, drug a].
93279 PDDI's in WorldVista for distinct sets of drug 1 and drug 2 RxCUI's and all drugs in drug classes are accounted for.
    91890 PDDI's in WorldVista for distinct sets of drug 1 and drug 2 RxCUI's, all drugs in drug classes are accounted for and no null entries.
    91426 PDDI's in this set for distinct sets of drug 1 and drug 2 RxCUI's, no null entries, and drug 1 and drug 2 RxCUI's are not equivalent.
    45777 PDDI's in this set when reverse duplicates are eliminated (ex. pairs of [drug a, drug b] would be repeated as [drug b, drug a].
OVERLAP = 4012

        WorldVista
NDF-RT  4012
        (22.625% in NDF-RT, 8.764% in WorldVista)

4012 / 17733 = 22.625% in NDF-RT
4012 / 45777 = 8.764% in WorldVista

In NDF-RT, there are 13721 distinct PDDI set differences that are not found in the WorldVista data set and are only in the NDF-RT data set (no null entries, only distinct RxCUI's for both). This is equivalent to the number of distinct PDDI's with no null entries (17733) minus the number of overlapping PDDI's (4012).

In WorldVista, there are 41765 distinct PDDI set differences that are not found in the NDF-RT data set  and are only in the WorldVista data set (no null entries, only distinct RxCUI's for both). This is equivalent to the number of distinct PDDI's with no null entries (45777) minus the number of overlapping PDDI's (4012).

Some of the reason for the low overlap becomes clear when looking at  Mirtazapine. There are only 4 interaction in common with the NDFRT:

"Rasagiline","134748","Mirtazapine","15996"
"Mirtazapine","15996","CLONIDINE","2599"
"Mirtazapine","15996","SELEGILINE","9639"
"Mirtazapine","15996","HYDROXYBUTYRATE SODIUM 04","9899"

Yet, there are 174 interactions involving mirtazapine (rxcui 15996) found only in the Worldvista. Plain and simply, this comes down to an explosion of interactions because mirtazapine is mentioned in the "sedative hypnotics" group ("N04-N05-N06") which includes 187 drugs total. There is an interaction between "sedative hypnotics" ("N04-N05-N06") and "sedative hypnotics" which would result in 186 interactions with mirtazapine (subtracting mirtazapine + mirtazapine). Eight others are subtracted because the interacting drug  has a null RxNorm identifier. This leaves 178 interactions, 4 of which are in NDF-RT.  = 174 interactions involving mirtazapine in the worldvista PDDIs.

Conversely, inspection of the NDF-RT interactions shows that the majority of mirtazapine interactions unique to that resource involve combination products. Also, there are some natural products which might not be included in the wordvista dataset (or might not have rxnorm identifiers):

"TRANYLCYPROMINE","10734","Mirtazapine","15996"
"METHENAMINE/NA BIPHOSPHA/PHENYL SALICYLATE/METHELENE/HYOSCYAMINE","1117215","Mirtazapine","15996"
"Mirtazapine","15996","linezolid","190376"
"Mirtazapine","15996","CHLORTHALIDONE/CLONIDINE","214418"
"Mirtazapine","15996","ST. JOHN'S WORT EXTRACT","258326"
"Mirtazapine","15996","Isocarboxazid","6011"
"Mirtazapine","15996","METHYLENE BLUE","6878"
"Mirtazapine","15996","ATROPINE/BENZOIC/GELSEMIUM/HYOSCYAMINE/METHENAMINE/METHYLENE/PHE","689591"
"Mirtazapine","15996","ATROPINE/BENZOIC/HYOSCYAMINE/METHENAMINE/METHYLENE/PHENYL","689592"
"Mirtazapine","15996","HYOSCYAMINE/METHAMINE/METHYLENE BLUE/PHENYL SALICYLATE/SODIUM BI","689939"
"Mirtazapine","15996","HYOSCYAMINE/METHENAMINE/METHYLENE BLUE/PHENYL SALICYLATE/SODIUM","690126"
"Mirtazapine","15996","MULTIVITAMIN,HERBAL","693419"
"Mirtazapine","15996","AMIODARONE","703"
"Mirtazapine","15996","HYOSCYAMINE/METHENAMINE/METHYLENE/PHENYL SALICYL/SODIUM PHOS","751130"
"Mirtazapine","15996","Phenelzine Sulfate","8124"
"Mirtazapine","15996","TRAUMEEL","822349"
"Mirtazapine","15996","PROCARBAZINE","8702"

