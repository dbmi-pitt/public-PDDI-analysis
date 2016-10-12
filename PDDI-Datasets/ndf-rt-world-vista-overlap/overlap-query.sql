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

SELECT * FROM (
	SELECT drug_1_rxcui AS rxcui_1, 
		   drug_1_rxcui AS rxnorm_1, 
		   drug_2_rxcui AS rxcui_2, 
		   drug_2_rxcui AS rxnorm_2
	FROM ndf_rt_interaction
	UNION ALL
	SELECT Drug_1_RxCUI, Drug_1_RxNorm, Drug_2_RxCUI, Drug_2_RxNorm
	FROM drug_class_interaction
) AS all_pddi 
GROUP BY rxcui_1, rxnorm_1, rxcui_2, rxnorm_2
HAVING COUNT(*) > 1;
