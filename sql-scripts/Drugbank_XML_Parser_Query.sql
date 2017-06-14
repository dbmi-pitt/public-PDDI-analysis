--Script to Parse Drugbank XML file 
	--Added 7/27/2014 By Serkan 
	--Updated 6/14/2017 By Serkan Ayvaz

--NOTE: the first two lines of xml file causes problems with XQUERY 
--	    XQUERY expects xml tags and alphanumeric characters within tags. The "?xml" symbols and xmlns web link distrups the query processing.
--      therefore, the following two lines: 
--				<?xml version="1.0" encoding="UTF-8"?>
--				<drugbank xmlns="http://www.drugbank.ca" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.drugbank.ca http://www.drugbank.ca/docs/drugbank.xsd" version="5.0" exported-on="2017-01-09">
--		must be replaced with :
--				<drugbank>

/********************************************************/
--LOAD XML FILE
/*******************************************************/
 
 DROP TABLE #DrugbankRawXml
 SELECT XmlContent
 INTO #DrugbankRawXml
 FROM (SELECT *    
	  FROM OPENROWSET (BULK 'C:\Users\serkan.ayvaz\Desktop\drugbank.xml', SINGLE_CLOB) 
 AS XmlContent) AS R(XmlContent)
  

--SET ANSI_PADDING ON



----test Case
--SET @xml = '<drugbank >
--			<drug type="biotech" created="2005-06-13 07:24:05 -0600" updated="2013-05-12 21:37:25 -0600" version="4.0">
--			  <drugbank-id>DB00001</drugbank-id>
--			  <name>Lepirudin</name>
--				<drug-interaction>
--				  <drug>DB01381</drug>
--				  <name>Ginkgo biloba</name>
--				  <description>Additive anticoagulant/antiplatelet effects may increase bleed risk. Concomitant therapy should be avoided.</description>
--				</drug-interaction>
--			</drug>
--			</drugbank>'

/********************************************************/
--Parse Drugbank Interactions from XML data
/*******************************************************/

DECLARE @xml xml				
SELECT @xml = [XmlContent]  FROM #DrugbankRawXml

INSERT INTO PDDI_Databases.[dbo].[DrugbankInteractions]
SELECT
	 doc.col.value('../../drugbank-id[1]', 'nvarchar(10)') Drug_1_ID 
	,doc.col.value('../../name[1]', 'varchar(255)') Drug_1_Name  
	,doc.col.value('drugbank-id[1]', 'varchar(10)') Drug_2_ID 
    ,doc.col.value('name[1]', 'varchar(255)') Drug_2_Name 
	,doc.col.value('description[1]', 'varchar(500)') Interact_Desc  

FROM @xml.nodes('/drugbank/drug/drug-interactions/drug-interaction') doc(col)



 
 /********************************************************/
--Parse Drugbank Drugs from XML data
/*******************************************************/

DECLARE @xml xml				
SELECT @xml = [XmlContent]  FROM #DrugbankRawXml
SELECT
	 doc.col.value('drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('name[1]', 'varchar(255)') name   
	,doc.col.value('@type', 'varchar(50)') [type]  
	,doc.col.value('description[1]', 'varchar(255)') [description ]
INTO PDDI_Databases.[dbo].[DrugbankDrugs]
FROM @xml.nodes('/drugbank/drug') doc(col)




/********************************************************/
--Parse Drugbank atc-codes from XML data if need be
/*******************************************************/
--<atc-codes>
--  <atc-code>A10AB01</atc-code>
--  <category />
--  <atc-code>A10AE05</atc-code>
--  <category />
--  <atc-code>A10AB04</atc-code>
--  <category />
--  <atc-code>A10AE04</atc-code>
--  <category />
--  <atc-code>A10AD05</atc-code>
--  <category />
--  <atc-code>A10AC03</atc-code>
--  <category />
--  <atc-code>A10AC01</atc-code>
--  <category />
--  <atc-code>A10AB05</atc-code>
--  <category />
--  <atc-code>A10AB03</atc-code>
--  <category />
--</atc-codes>

DECLARE @xml xml
SELECT @xml = [XmlContent]  FROM [dbo].[DrugbankXml2] 

SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[1]', 'varchar(100)') Atc  
	,doc.col.value('atc-code[2]', 'varchar(100)') Atc2  
	,doc.col.value('atc-code[3]', 'varchar(100)') Atc3  
	,doc.col.value('atc-code[4]', 'varchar(100)') Atc4  
INTO DrugbankATC
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)


DECLARE @xml xml
SELECT @xml = [XmlContent]  FROM [dbo].[DrugbankRawXml]  
 
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[1]', 'varchar(100)') Atc   
INTO PDDI_Databases.[dbo].[DrugbankATCMapping]
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)


INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name    
	,doc.col.value('atc-code[2]', 'varchar(100)') Atc
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[2]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[3]', 'varchar(100)') Atc    
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[3]', 'varchar(100)')  is not null


INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[4]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[4]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[5]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[5]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[6]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[6]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[7]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[7]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[8]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[8]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[9]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[9]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[10]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[10]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[11]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[11]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[12]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[12]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[13]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[13]', 'varchar(100)')  is not null


INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[14]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[14]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[15]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[15]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[16]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[16]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[17]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[17]', 'varchar(100)')  is not null
 

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[18]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[18]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[19]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[19]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[20]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[20]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[21]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[21]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[22]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[22]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[23]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[23]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[24]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[24]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[25]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[25]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[26]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[26]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[27]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[27]', 'varchar(100)')  is not null



INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[28]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[28]', 'varchar(100)')  is not null

INSERT INTO PDDI_Databases.[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[29]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[29]', 'varchar(100)')  is not null

 

 

/********************************************************/
--Get Results
/*******************************************************/
 

  --Drugbank v.5 Get DDIs with Desc --558715
  SELECT DISTINCT	
	   [Subj_Drug_ID]
	  +'$'+[Subj_Name]
      +'$'+[Obj_Drug_ID]
      +'$'+[Obj_Name]
      +'$'+COALESCE([Interact_Desc],'')
  FROM [PDDI_Databases].[dbo].[DrugbankInteractions]
  WHERE LEN([Subj_Name])>1  
 -- ORDER BY [Subj_Drug_ID],[Obj_Drug_ID]

  SELECT count(*)
  FROM [PDDI_Databases].[dbo].[DrugbankInteractions]
  WHERE LEN([Subj_Name])>1  
  
  --Drugbank v.5 Get DDIs
  SELECT DISTINCT	
	   [Subj_Drug_ID]
      ,[Subj_Name]
      ,[Obj_Drug_ID]
      ,[Obj_Name] 
  FROM [PDDI_Databases].[dbo].[DrugbankInteractions]
  ORDER BY [Subj_Drug_ID],[Obj_Drug_ID]
