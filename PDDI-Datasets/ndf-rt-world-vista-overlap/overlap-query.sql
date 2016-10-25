CREATE VIEW Drug_Class_Interaction AS (
SELECT g.Drug_Name AS Drug_Name_1,
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

SELECT * FROM(
	SELECT * FROM (
		SELECT drug_1_rxcui AS rxcui_1, 
			   drug_1_rxcui AS rxnorm_1, 
			   drug_2_rxcui AS rxcui_2, 
			   drug_2_rxcui AS rxnorm_2
		FROM NDF_RT_INTERACTION
		WHERE drug_1_rxcui is not null
		AND drug_2_rxcui is not null
		UNION ALL
		SELECT Drug_1_RxCUI, Drug_1_RxNorm, Drug_2_RxCUI, Drug_2_RxNorm
		FROM Drug_Class_Interaction
		WHERE (Drug_1_RxCUI is not null
		OR Drug_1_RxNorm is not null)
		AND (Drug_2_RxCUI is not null
		OR Drug_2_RxNorm is not null)
	) AS all_pddi 
	GROUP BY rxcui_1, rxnorm_1, rxcui_2, rxnorm_2
	HAVING COUNT(*) > 1) as overlap_pddi
WHERE ((rxnorm_1 != rxnorm_2) OR (rxnorm_1 is null OR rxnorm_2 is null)) AND
	  ((rxcui_1 != rxnorm_2) OR (rxcui_1 is null OR rxnorm_2 is null)) AND
      ((rxnorm_1 != rxcui_2) OR (rxnorm_1 is null OR rxcui_2 is null)) AND
      ((rxcui_1 != rxcui_2) OR (rxcui_1 is null OR rxcui_2 is null));
