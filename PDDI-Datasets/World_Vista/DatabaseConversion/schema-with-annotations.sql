DROP TABLE IF EXISTS Drug_Interaction_With_Annotations CASCADE;
DROP TABLE IF EXISTS Drug_Interaction CASCADE;
DROP TABLE IF EXISTS ATC_Code CASCADE;
DROP TABLE IF EXISTS Drug_Group CASCADE;
DROP TABLE IF EXISTS tmp CASCADE;

CREATE TABLE Drug_Group (
    Drug_Name VARCHAR(250) NOT NULL,
    RxNorm VARCHAR(50),
    Source_File INT NOT NULL,
    Clinical_Source VARCHAR(50) NOT NULL,
    Class_Name VARCHAR(250) NOT NULL,
    Class_Code VARCHAR(50) NOT NULL,
    PRIMARY KEY (Drug_Name , Source_File , Class_Name)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;

CREATE TABLE ATC_Code (
    ATC_Code VARCHAR(20) NOT NULL,
    Drug_Name VARCHAR(250) NOT NULL,
    PRIMARY KEY (ATC_Code , Drug_Name)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;

CREATE TABLE Drug_Interaction (
    Drug_Interaction_ID INT NOT NULL,
    Drug_1_Name VARCHAR(250),
    Drug_1_RxCUI VARCHAR(50),
    Drug_1_Class_Name VARCHAR(250),
    Drug_1_Code VARCHAR(50),
    Drug_2_Name VARCHAR(250),
    Drug_2_RxCUI VARCHAR(50),
    Drug_2_Class_Name VARCHAR(250),
    Drug_2_Code VARCHAR(50),
    Clinical_Source VARCHAR(50) NOT NULL,
    Source_File VARCHAR(100) NOT NULL,
    Description VARCHAR(2000),
    Severity VARCHAR(500),
    `Comment` VARCHAR(3000),
    PRIMARY KEY (Drug_Interaction_ID)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;

CREATE TABLE Drug_Interaction_With_Annotations (
    Drug_Interaction_ID INT NOT NULL,
    Drug_1_Name VARCHAR(250),
    Drug_1_RxCUI VARCHAR(50),
    Drug_1_Class_Name VARCHAR(250),
    Drug_1_Code VARCHAR(50),
    Drug_2_Name VARCHAR(250),
    Drug_2_RxCUI VARCHAR(50),
    Drug_2_Class_Name VARCHAR(250),
    Drug_2_Code VARCHAR(50),
    Clinical_Source VARCHAR(50) NOT NULL,
    Source_File VARCHAR(100) NOT NULL,
    Description VARCHAR(2000),
    Severity VARCHAR(500),
    `Comment` VARCHAR(3000),
    Clinical_Consequence_Annotations VARCHAR(3000),
    Management_Option_Annotations VARCHAR(3000),
    Suspected_Typo_Annotations VARCHAR(3000),
    Annotator_Notes VARCHAR(3000),
    PRIMARY KEY (Drug_Interaction_ID)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\eng_groups2015_xml_v3.tsv' INTO TABLE Drug_Group FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Name, RxNorm, Source_File, Clinical_Source, Class_Name, Class_Code);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\eng_groups_tables_2015_xml_v3_v5_atc_codes.tsv' INTO TABLE ATC_Code FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (ATC_Code, Drug_Name);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\eng_tables2015-xml-v5.tsv' INTO TABLE Drug_Interaction FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Drug_1_Name, Drug_1_RxCUI, Drug_1_Class_Name, Drug_1_Code, Drug_2_Name, Drug_2_RxCUI, Drug_2_Class_Name, Drug_2_Code, Clinical_Source, Source_File, Description, Severity, `Comment`);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\eng_tables2015-xml-v5.tsv' INTO TABLE Drug_Interaction_With_Annotations FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Drug_1_Name, Drug_1_RxCUI, Drug_1_Class_Name, Drug_1_Code, Drug_2_Name, Drug_2_RxCUI, Drug_2_Class_Name, Drug_2_Code, Clinical_Source, Source_File, Description, Severity, `Comment`);

CREATE TABLE tmp (
    Drug_Interaction_ID INT NOT NULL,
    Drug_1_Name VARCHAR(250),
    Drug_1_RxCUI VARCHAR(50),
    Drug_1_Class_Name VARCHAR(250),
    Drug_1_Code VARCHAR(50),
    Drug_2_Name VARCHAR(250),
    Drug_2_RxCUI VARCHAR(50),
    Drug_2_Class_Name VARCHAR(250),
    Drug_2_Code VARCHAR(50),
    Clinical_Source VARCHAR(50) NOT NULL,
    Source_File VARCHAR(100) NOT NULL,
    Description VARCHAR(2000),
    Severity VARCHAR(500),
    `Comment` VARCHAR(3000),
    Clinical_Consequence_Annotations VARCHAR(3000),
    Management_Option_Annotations VARCHAR(3000),
    Suspected_Typo_Annotations VARCHAR(3000),
    Annotator_Notes VARCHAR(3000),
    PRIMARY KEY (Drug_Interaction_ID)
)  ENGINE=INNODB DEFAULT CHARSET=UTF8;

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_consequences_1.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Clinical_Consequence_Annotations);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Clinical_Consequence_Annotations = VALUES(Clinical_Consequence_Annotations);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_mgmt_1.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Management_Option_Annotations);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Management_Option_Annotations = VALUES(Management_Option_Annotations);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_typos_1.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Suspected_Typo_Annotations);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Suspected_Typo_Annotations = VALUES(Suspected_Typo_Annotations);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_anotes_1.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Annotator_Notes);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Annotator_Notes = VALUES(Annotator_Notes);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_consequences_2.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Clinical_Consequence_Annotations);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Clinical_Consequence_Annotations = VALUES(Clinical_Consequence_Annotations);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_mgmt_2.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Management_Option_Annotations);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Management_Option_Annotations = VALUES(Management_Option_Annotations);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_typos_2.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Suspected_Typo_Annotations);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Suspected_Typo_Annotations = VALUES(Suspected_Typo_Annotations);

LOAD DATA LOCAL INFILE 'C:\\Users\\Eric\\Documents\\GitHub\\public-PDDI-analysis\\PDDI-Datasets\\World_Vista\\DatabaseConversion\\drug_id_and_description_anotes_2.tsv' REPLACE INTO TABLE tmp FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (Drug_Interaction_ID, Annotator_Notes);

INSERT INTO Drug_Interaction_With_Annotations
SELECT * FROM tmp
ON DUPLICATE KEY UPDATE Drug_Interaction_ID = VALUES(Drug_Interaction_ID), Annotator_Notes = VALUES(Annotator_Notes);

DROP TABLE IF EXISTS tmp CASCADE;