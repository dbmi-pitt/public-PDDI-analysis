CREATE TABLE `Drug_Group` (
	`Drug_Name` varchar(100) NOT NULL,
	`RxNorm` INT(10),
	`Source_File` INT(10) NOT NULL,
	`Clinical_Source` varchar(20) NOT NULL,
	`Class_Name` varchar(300) NOT NULL,
	`Class_Code` varchar(50) NOT NULL,
	PRIMARY KEY (`Drug_Name`)
);

CREATE TABLE `Drug_Interaction` (
	`Drug_Interaction_ID` INT(10) NOT NULL,
	`Drug_1_Name` varchar(100),
	`Drug_1_RxCUI` varchar(50),
	`Drug_1_Class_Name` varchar(300),
	`Drug_1_Code` varchar(50),
	`Drug_2_Name` varchar(100),
	`Drug_2_RxCUI` varchar(50),
	`Drug_2_Class_Name` varchar(300),
	`Drug_2_Code` varchar(50),
	`Clinical_Source` varchar(20) NOT NULL,
	`Source_File` varchar(300) NOT NULL,
	`Description` varchar(3000),
	`Severity` varchar(2000),
	`Comment` varchar(3000),
	PRIMARY KEY (`Drug_Interaction_ID`)
);

CREATE TABLE `ATC_Code` (
	`ATC_Code` varchar(20) NOT NULL,
	`Drug_Name` varchar(100) NOT NULL,
	PRIMARY KEY (`ATC_Code`,`Drug_Name`)
);

-- ALTER TABLE `Drug_Group` ADD CONSTRAINT `Drug_Group_fk0` FOREIGN KEY (`Drug_Name`) REFERENCES `ATC_Code`(`Drug_Name`);

-- ALTER TABLE `Drug_Interaction` ADD CONSTRAINT `Drug_Interaction_fk0` FOREIGN KEY (`Drug_1_Name`) REFERENCES `ATC_Code`(`Drug_Name`);

-- ALTER TABLE `Drug_Interaction` ADD CONSTRAINT `Drug_Interaction_fk1` FOREIGN KEY (`Drug_1_Class_Name`) REFERENCES `Drug_Group`(`Class_Name`);

-- ALTER TABLE `Drug_Interaction` ADD CONSTRAINT `Drug_Interaction_fk2` FOREIGN KEY (`Drug_1_Code`) REFERENCES `Drug_Group`(`Class_Code`);

-- ALTER TABLE `Drug_Interaction` ADD CONSTRAINT `Drug_Interaction_fk3` FOREIGN KEY (`Drug_2_Name`) REFERENCES `ATC_Code`(`Drug_Name`);

-- ALTER TABLE `Drug_Interaction` ADD CONSTRAINT `Drug_Interaction_fk4` FOREIGN KEY (`Drug_2_Class_Name`) REFERENCES `Drug_Group`(`Class_Name`);

-- ALTER TABLE `Drug_Interaction` ADD CONSTRAINT `Drug_Interaction_fk5` FOREIGN KEY (`Drug_2_Code`) REFERENCES `Drug_Group`(`Class_Code`);

LOAD DATA LOCAL INFILE './eng_groups_tables_2015_xml_v3_v5_atc_codes.tsv' INTO TABLE `ATC_Code` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (`ATC_Code`, `Drug_Name`);

LOAD DATA LOCAL INFILE './eng_groups2015_xml_v3.tsv' INTO TABLE `Drug_Group` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (`Drug_Name`, `RxNorm`, `Source_File`, `Clinical_Source`, `Class_Name`, `Class_Code`);

LOAD DATA LOCAL INFILE './eng_tables2015-xml-v5.tsv' INTO TABLE `Drug_Interaction` FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 LINES (`Drug_Interaction_ID`, `Drug_1_Name`, `Drug_1_RxCUI`, `Drug_1_Class_Name`, `Drug_1_Code`, `Drug_2_Name`, `Drug_2_RxCUI`, `Drug_2_Class_Name`, `Drug_2_Code`, `Clinical_Source`, `Source_File`, `Description`, `Severity`, `Comment`);
