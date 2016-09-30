SELECT w.drug_1_rxcui AS world_vista_drug_1,
       w.drug_2_rxcui AS world_vista_drug_2,
       n.drug_1_rxcui AS ndf_rt_drug_1,
       n.drug_2_rxcui AS ndf_rt_drug_2
FROM drug_interaction w
INNER JOIN ndf_rt_interaction n
ON (w.drug_1_rxcui = n.drug_1_rxcui AND w.drug_2_rxcui = n.drug_2_rxcui);

