DROP TABLE IF EXISTS NDF_RT_Interaction CASCADE;

CREATE TABLE NDF_RT_Interaction (
    Drug_Interaction_ID INT NOT NULL,
    Drug_1_VUID VARCHAR(50),
    Drug_1_RxCUI VARCHAR(50),
    Severity VARCHAR(250),
    Drug_2_VUID VARCHAR(50),
    Drug_2_RxCUI VARCHAR(50),
    PRIMARY KEY (Drug_Interaction_ID)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Desktop\\ndf-rt\\NDF-RT-interactions.csv' INTO TABLE NDF_RT_Interaction FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Drug_1_VUID, Drug_2_VUID, Severity, Drug_1_RxCUI, Drug_2_RxCUI);

UPDATE NDF_RT_Interaction
SET Drug_2_RxCUI = TRIM(TRAILING '\r' FROM Drug_2_RxCUI);

SET SQL_SAFE_UPDATES=0;

UPDATE NDF_RT_Interaction
SET Drug_1_RxCUI = NULL
WHERE Drug_1_RxCUI = 'NULL';

UPDATE NDF_RT_Interaction
SET Drug_2_RxCUI = NULL
WHERE Drug_2_RxCUI = 'NULL';