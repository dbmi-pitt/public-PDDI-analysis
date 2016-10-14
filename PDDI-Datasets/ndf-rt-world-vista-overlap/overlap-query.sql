CREATE VIEW Drug_Class_Interaction AS (SELECT g.Drug_Name AS Drug_Name_1,
       g.RxNorm AS Drug_1_RxNorm,
       g.Class_Code AS Class_Code_1,
       h.Drug_Name AS Drug_Name_2,
       h.RxNorm AS Drug_2_RxNorm,
       h.Class_Code AS Class_Code_2,
       i.*
FROM Drug_Interaction i
LEFT JOIN Drug_Group g
ON (i.Drug_1_Code = TRIM(TRAILING '\r' FROM g.Class_Code))
LEFT JOIN Drug_Group h
ON (i.Drug_2_Code = TRIM(TRAILING '\r' FROM h.Class_Code)));

SELECT * FROM (
	SELECT Drug_1_RxCui AS rxcui_1, 
		   Drug_1_RxCui AS rxnorm_1, 
		   Drug_2_RxCui AS rxcui_2, 
		   Drug_2_RxCui AS rxnorm_2
	FROM NDF_RT_INTERACTION
	UNION ALL
	SELECT Drug_1_RxCUI, Drug_1_RxNorm, Drug_2_RxCUI, Drug_2_RxNorm
	FROM Drug_Class_Interaction
) AS all_pddi 
GROUP BY rxcui_1, rxnorm_1, rxcui_2, rxnorm_2
HAVING COUNT(*) > 1;
