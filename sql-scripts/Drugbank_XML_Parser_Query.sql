
	--Script to Parse Drugbank XML file 
	--Added 7/27/2014 By Serkan 



--LOAD XML FILE
-- SELECT XmlContent
-- INTO DrugbankXml2
--FROM (SELECT *    
--	  FROM OPENROWSET (BULK 'D:\Source\Drugref2\drugbankxml\drug.txt', SINGLE_CLOB) 
-- AS XmlContent) AS R(XmlContent)



--SELECT [XmlContent]  FROM [dbo].[DrugbankXml] 


--test Case
--SET @xml = N'<drugs xmlns="http://drugbank.ca" xmlns:xs="http://www.w3.org/2001/XMLSchema-instance" schemaVersion="2.0" xs:schemaLocation="http://www.drugbank.ca/docs/drugbank.xsd">
--			<drug type="biotech" created="2005-06-13 07:24:05 -0600" updated="2013-05-12 21:37:25 -0600" version="4.0">
--			  <drugbank-id>DB00001</drugbank-id>
--			  <name>Lepirudin</name>

--			  <drug-interactions>
--				<drug-interaction>
--				  <drug>DB01381</drug>
--				  <name>Ginkgo biloba</name>
--				  <description>Additive anticoagulant/antiplatelet effects may increase bleed risk. Concomitant therapy should be avoided.</description>
--				</drug-interaction>
--				</drug-interactions>  
--			</drug>
--			</drugs>


	
	 
 
DECLARE @xml xml

SELECT @xml = [XmlContent]  FROM [Drugref].[dbo].[DrugbankRawXml]  
 
SELECT
	 doc.col.value('../../drugbank-id[1]', 'nvarchar(10)') Subj_Drug_ID 
	,doc.col.value('../../name[1]', 'varchar(255)') Subj_Name  
	,doc.col.value('drug[1]', 'varchar(10)') Obj_Drug_ID 
	,doc.col.value('name[1]', 'varchar(255)') Obj_Name 
	,doc.col.value('description[1]', 'varchar(500)') Interact_Desc  
INTO [Drugref].[dbo].[DrugbankInteractions]
FROM @xml.nodes('/drugs/drug/drug-interactions/drug-interaction') doc(col)


 

  --<drug-interactions>
  --  <drug-interaction>
  --    <drug>DB06372</drug>
  --    <name>Rilonacept</name>
  --    <description>decreases effects of toxoids by pharmacodynamic antagonism. </description>
  --  </drug-interaction>
  
DECLARE @xml xml

SELECT @xml = [XmlContent]  FROM [dbo].[DrugbankRawXml] 
 
 
SELECT
	 doc.col.value('drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('name[1]', 'varchar(255)') name   
	,doc.col.value('@type', 'varchar(50)') [type]  
	,doc.col.value('description[1]', 'varchar(255)') [description ]
INTO [Drugref].[dbo].[DrugbankDrugs]
FROM @xml.nodes('/drugs/drug') doc(col)


 

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

	--,doc.col.value('../atc-code[1]', 'varchar(100)') Atc  
--INTO DrugbankATC
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)



DECLARE @xml xml

SELECT @xml = [XmlContent]  FROM [dbo].[DrugbankRawXml] 
 
 
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[1]', 'varchar(100)') Atc   
INTO [Drugref].[dbo].[DrugbankATCMapping]
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)


INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name    
	,doc.col.value('atc-code[2]', 'varchar(100)') Atc
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[2]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[3]', 'varchar(100)') Atc    
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[3]', 'varchar(100)')  is not null


INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[4]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[4]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[5]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[5]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[6]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[6]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[7]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[7]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[8]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[8]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[9]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[9]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[10]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[10]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[11]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[11]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[12]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[12]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[13]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[13]', 'varchar(100)')  is not null


INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[14]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[14]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[15]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[15]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[16]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[16]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[17]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[17]', 'varchar(100)')  is not null
 

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[18]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[18]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[19]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[19]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[20]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[20]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[21]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[21]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[22]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[22]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[23]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[23]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[24]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[24]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[25]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[25]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[26]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[26]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[27]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[27]', 'varchar(100)')  is not null



INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[28]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[28]', 'varchar(100)')  is not null

INSERT INTO [Drugref].[dbo].[DrugbankATCMapping]([drugbankid],[name],[Atc])  
SELECT
	 doc.col.value('../drugbank-id[1]', 'nvarchar(10)') [drugbankid]
	,doc.col.value('../name[1]', 'varchar(255)') name  
	,doc.col.value('atc-code[29]', 'varchar(100)') Atc   
FROM @xml.nodes('/drugs/drug/atc-codes') doc(col)
where doc.col.value('atc-code[29]', 'varchar(100)')  is not null

 





/********************************************************/
--Get Results
/*******************************************************/
 


  --Drugbank 4 Get DDIs with Desc
  SELECT DISTINCT	
	   [Subj_Drug_ID]
	  +'$'+[Subj_Name]
      +'$'+[Obj_Drug_ID]
      +'$'+[Obj_Name]
      --+'$'+[Interact_Desc]
  FROM [PDDI_Databases].[dbo].[DrugbankInteractions]
  WHERE LEN([Subj_Name])>1  
 -- ORDER BY [Subj_Drug_ID],[Obj_Drug_ID]


  
  --Drugbank 4 Get DDIs
  SELECT DISTINCT	
	   [Subj_Drug_ID]
      ,[Subj_Name]
      ,[Obj_Drug_ID]
      ,[Obj_Name] 
  FROM [PDDI_Databases].[dbo].[DrugbankInteractions]
  ORDER BY [Subj_Drug_ID],[Obj_Drug_ID]