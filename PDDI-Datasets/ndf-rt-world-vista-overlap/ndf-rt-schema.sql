DROP TABLE IF EXISTS NDF_RT_INTERACTION CASCADE;

CREATE TABLE NDF_RT_INTERACTION (
    drug_interaction_id INT NOT NULL,
    drug_1_vuid VARCHAR(50),
    drug_1_rxcui VARCHAR(50),
    severity VARCHAR(250),
    drug_2_vuid VARCHAR(50),
    drug_2_rxcui VARCHAR(50),
    PRIMARY KEY (drug_interaction_id)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;

LOAD DATA LOCAL INFILE './NDF-RT-interactions.csv' INTO TABLE NDF_RT_INTERACTION FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES (drug_interaction_id, drug_1_vuid, drug_2_vuid, severity, drug_1_rxcui, drug_2_rxcui);

UPDATE NDF_RT_INTERACTION
SET drug_2_rxcui = TRIM(TRAILING '\r' FROM drug_2_rxcui);

SET SQL_SAFE_UPDATES=0;

UPDATE NDF_RT_INTERACTION
SET drug_1_rxcui = NULL
WHERE drug_1_rxcui = 'NULL';

UPDATE NDF_RT_INTERACTION
SET drug_2_rxcui = NULL
WHERE drug_2_rxcui = 'NULL';

# 269527 in data set total, 67 duplicates need to be removed => 269460

DELETE FROM NDF_RT_INTERACTION WHERE drug_1_rxcui = drug_2_rxcui;
