CREATE TABLE Groups (
	atc_code varchar(10) NOT NULL,
	drug_name varchar(100) NOT NULL,
	rxnorm varchar(10),
	source_file INT(4) NOT NULL,
	clinical_source varchar(10) NOT NULL,
	class_name varchar(100) NOT NULL,
	class_code varchar(50) NOT NULL,
	PRIMARY KEY (atc_code)
);

CREATE TABLE Tables (
	drug_1_atc_code varchar(7),
	drug_1_name varchar(100),
	drug_1_rxcui INT(10),
	drug_1_class varchar(100),
	drug_1_code varchar(20),
	drug_2_atc_code varchar(7),
	drug_2_name varchar(100),
	drug_2_rxcui INT(10),
	drug_2_class varchar(100),
	drug_2_code varchar(20),
	clinical_source varchar(10) NOT NULL,
	source_file varchar(50) NOT NULL,
	description varchar(500),
	severity varchar(200),
	interaction_comment varchar(500),
	PRIMARY KEY (drug_1_atc_code, drug_1_name, drug_1_class, drug_1_code, drug_2_atc_code, drug_2_name, drug_2_class, drug_2_code)
);

ALTER TABLE Tables ADD CONSTRAINT Tables_fk0 FOREIGN KEY (drug_1_atc_code) REFERENCES Groups(atc_code);

ALTER TABLE Tables ADD CONSTRAINT Tables_fk1 FOREIGN KEY (drug_2_atc_code) REFERENCES Groups(atc_code);