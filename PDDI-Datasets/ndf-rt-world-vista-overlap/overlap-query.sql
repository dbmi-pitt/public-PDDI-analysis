CREATE VIEW drug_class_interaction AS (SELECT g.Drug_Name AS Drug_Name_1,
       g.RxNorm AS Drug_1_RxNorm,
       g.Class_Code AS Class_Code_1,
       h.Drug_Name AS Drug_Name_2,
       h.RxNorm AS Drug_2_RxNorm,
       h.Class_Code AS Class_Code_2,
       i.*
FROM drug_interaction i
LEFT JOIN drug_group g
ON (i.Drug_1_Code = TRIM(TRAILING '\r' FROM g.Class_Code))
LEFT JOIN drug_group h
ON (i.Drug_2_Code = TRIM(TRAILING '\r' FROM h.Class_Code)));

SELECT *
FROM drug_class_interaction w
INNER JOIN NDF_RT_INTERACTION n
ON ((w.Drug_1_RxCUI = n.drug_1_rxcui AND w.Drug_2_RxCUI = n.drug_2_rxcui)
	OR (w.Drug_1_RxNorm = n.drug_1_rxcui AND w.Drug_2_RxCUI = n.drug_2_rxcui)
	OR (w.Drug_1_RxCUI = n.drug_1_rxcui AND w.Drug_2_RxNorm = n.drug_2_rxcui)
    OR (w.Drug_1_RxNorm = n.drug_1_rxcui AND w.Drug_2_RxNorm = n.drug_2_rxcui));
