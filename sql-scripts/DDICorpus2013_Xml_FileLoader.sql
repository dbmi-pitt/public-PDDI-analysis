
	--Script to Parse XML file containing All DDI Corpus2013 files
	--Added 7/1/2014 By Serkan 
	
	 ----LOADs Test XML FILE
	 --SELECT XmlContent
	 --INTO  [PDDI_Databases].[dbo].DDICorpus2013RawXmlTest
	 --FROM (SELECT *    
		--  FROM OPENROWSET (BULK 'D:\Univ files\PhD\Research\BioInformatics\Datasets\DDICorpus2013\Abatacept_ddi.xml', SINGLE_CLOB) 
	 --AS XmlContent) AS R(XmlContent)

	 --SELECT [XmlContent]  FROM [PDDI_Databases].[dbo].DDICorpus2013RawXmlTest

	--LOADs DDI Corpus2013 XML FILE
	 SELECT XmlContent
	 INTO  [PDDI_Databases].[dbo].DDICorpus2013RawXml
	 FROM (SELECT *    
		  FROM OPENROWSET (BULK 'D:\Univ files\PhD\Research\BioInformatics\Datasets\DDICorpus2013\DDICorpus2013_AllXml.txt', SINGLE_CLOB) 
	 AS XmlContent) AS R(XmlContent)

	SELECT [XmlContent]  FROM [PDDI_Databases].[dbo].[DDICorpus2013RawXml] 
		

	-- XML Format Sample 
	--<sentence id="DDI-DrugBank.d297.s4" text="Concurrent therapy with ORENCIA and TNF antagonists is not recommended.">
		--<entity id="DDI-DrugBank.d297.s4.e0" charOffset="24-30" type="brand" text="ORENCIA"/>
		--<entity id="DDI-DrugBank.d297.s4.e1" charOffset="36-50" type="group" text="TNF antagonists"/>
		--<pair id="DDI-DrugBank.d297.s4.p0" e1="DDI-DrugBank.d297.s4.e0" e2="DDI-DrugBank.d297.s4.e1" ddi="true" type="advise"/>
	--</sentence>
	 --</document>

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xml xml
	SELECT @xml = [XmlContent] FROM [PDDI_Databases].[dbo].DDICorpus2013RawXml-- DDICorpus2013RawXmlTest
	  
	--Insert DDIs into the Table
	SELECT DISTINCT		
		   doc.col.value('@id', 'varchar(50)') DDI_ID   
		  ,doc.col.value('@e1', 'varchar(50)') e1 		
		  ,doc.col.value('@e2', 'varchar(50)') e2  
		  ,doc.col.value('@ddi', 'varchar(50)') Is_DDI  
		  ,doc.col.value('@type', 'varchar(50)') DDI_Type   
	INTO [PDDI_Databases].[dbo].DDICorpus2013_DDIs
	FROM @xml.nodes('/document/sentence/pair') doc(col)  
	
	--Set the Sentence_ID containing DDIs
	ALTER TABLE [PDDI_Databases].[dbo].DDICorpus2013_DDIs
	ADD Sentence_ID varchar(50)
	
	UPDATE [PDDI_Databases].[dbo].DDICorpus2013_DDIs
	SET Sentence_ID = SUBSTRING(DDI_ID,0,CHARINDEX('p',DDI_ID)-1) 
	
 

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xmlFile xml
	SELECT @xmlFile = [XmlContent] FROM [PDDI_Databases].[dbo].DDICorpus2013RawXml 
		
	--Insert Entities in the DDIs into the Table
	SELECT DISTINCT
		doc.col.value('@id', 'varchar(1000)') ent_id 
		,doc.col.value('@charOffset', 'varchar(1000)') charOffset
		,doc.col.value('@type', 'varchar(1000)') ent_type 
		,doc.col.value('@text', 'varchar(1000)') ent_text		
		,doc.col.value('../../@id', 'varchar(50)') Document_ID 	   
	INTO [PDDI_Databases].[dbo].DDICorpus2013_Entities
	FROM @xmlFile.nodes('/document/sentence/entity') doc(col)



--<document id="DDI-DrugBank.d353">
--<sentence id="DDI-DrugBank.d353.s0" text="Ethanol:Clinical evidence has shown that etretinate can be formed with concurrent ingestion of acitretin and ethanol.">
			
	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @Sxml xml
	SELECT @Sxml = [XmlContent] FROM [PDDI_Databases].[dbo].DDICorpus2013RawXml
	  
	--Insert Sentence into the Table
	SELECT DISTINCT 
		   doc.col.value('@id', 'varchar(50)') Sentence_ID   
		  ,doc.col.value('@text', 'varchar(1000)') Sentence_Text 
	INTO [PDDI_Databases].[dbo].DDICorpus2013_Sentences
	FROM @Sxml.nodes('/document/sentence') doc(col)  


	


/********************************************************/
--Get Mapping Results
/*******************************************************/ 
		 
	------------- Mappings using [INCHI_AND_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets,827
	DROP TABLE #PDDIs
	SELECT DISTINCT		 			   
			COALESCE(f1.FDA_Preferred_Term, sy1.[Synonym], br1.brand ) [Drug_1_Name],
			d1.ent_type as Drug_1_ent_type,
			COALESCE(f1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid] )  [Drug1_DrugbankID],
			COALESCE(f2.FDA_Preferred_Term, sy2.[Synonym], br2.brand ) [Drug_2_Name],
			COALESCE(f2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid])[Drug2_DrugbankID],
			Is_DDI,
			DDI_Type,
			d2.ent_type as Drug_2_ent_type,
			[Sentence_Text]  
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].[DDICorpus2013_DDIs] b
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2013_Entities] d1 ON d1.[ent_id] = b.[e1]  
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2013_Entities] d2 ON d2.[ent_id] = b.[e2]  			
			LEFT JOIN [PDDI_Databases].[dbo].[DDICorpus2013_Sentences] s ON s.Sentence_ID = b.Sentence_ID
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_AND_Syns_OR_Name] f1 ON f1.[FDA_preferred_term] = d1.[ent_text] 
																			OR f1.[DrugBank_name] = d1.[ent_text]
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_AND_Syns_OR_Name] f2 ON f2.[FDA_preferred_term] = d2.[ent_text] 
																			OR f2.[DrugBank_name] = d2.[ent_text]	
			LEFT JOIN (Select d.drugbankid, d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy1 ON sy1.[Synonym]= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid, d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy2 ON sy2.[Synonym]= d2.[ent_text] 
			LEFT JOIN (Select d.drugbankid, d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br1 ON br1.brand= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid, d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br2 ON br2.brand= d2.[ent_text]  
	WHERE  Is_DDI ='true'
			AND (f1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			AND (f2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		     

		 
	--Get PDDIs Mapped to Drugbank, 787 after concatination
	SELECT DISTINCT		 
			  [Drug_1_Name]  
			+'$'+ [Drug1_DrugbankID] 
			+'$'+ Drug_1_ent_type
			+'$'+ [Drug_2_Name]   
			+'$'+ [Drug2_DrugbankID] 
			+'$'+ Is_DDI
			+'$'+ DDI_Type
			+'$'+ Drug_2_ent_type
			+'$'+ (Select [Sentence_Text] +'| '
				  From #PDDIs
				  Where [Drug_1_Name]=b.[Drug_1_Name] 
						AND [Drug_2_Name]=b.[Drug_2_Name] 
				  FOR XML PATH('')
				 ) 		
	FROM #PDDIs b 
	 
 


	------------- Mappings using [INCHI_AND_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets,1897
	DROP TABLE #PDDIs
	SELECT DISTINCT		 			   
			COALESCE(f1.FDA_Preferred_Term, sy1.[Synonym], br1.brand ) [Drug_1_Name],
			d1.ent_type as Drug_1_ent_type,
			COALESCE(f1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid] )  [Drug1_DrugbankID],
			COALESCE(f2.FDA_Preferred_Term, sy2.[Synonym], br2.brand ) [Drug_2_Name],
			COALESCE(f2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid])[Drug2_DrugbankID],
			Is_DDI,
			DDI_Type,
			d2.ent_type as Drug_2_ent_type,
			[Sentence_Text]  
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].[DDICorpus2013_DDIs] b
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2013_Entities] d1 ON d1.[ent_id] = b.[e1]  
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2013_Entities] d2 ON d2.[ent_id] = b.[e2]  			
			LEFT JOIN [PDDI_Databases].[dbo].[DDICorpus2013_Sentences] s ON s.Sentence_ID = b.Sentence_ID
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_OR_Syns_OR_Name] f1 ON f1.[FDA_preferred_term] = d1.[ent_text] 
																			OR f1.[DrugBank_name] = d1.[ent_text]
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_OR_Syns_OR_Name] f2 ON f2.[FDA_preferred_term] = d2.[ent_text] 
																			OR f2.[DrugBank_name] = d2.[ent_text]	
			LEFT JOIN (Select d.drugbankid, d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy1 ON sy1.[Synonym]= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid, d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy2 ON sy2.[Synonym]= d2.[ent_text] 
			LEFT JOIN (Select d.drugbankid, d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br1 ON br1.brand= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid, d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br2 ON br2.brand= d2.[ent_text]  
	WHERE  Is_DDI ='true'
			AND (f1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			AND (f2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		 

	--Get PDDIs Mapped to Drugbank, 1780 after concatination
	SELECT DISTINCT		 
			  [Drug_1_Name]  
			+'$'+ [Drug1_DrugbankID] 
			+'$'+ Drug_1_ent_type
			+'$'+ [Drug_2_Name]   
			+'$'+ [Drug2_DrugbankID] 
			+'$'+ Is_DDI
			+'$'+ DDI_Type
			+'$'+ Drug_2_ent_type
			+'$'+ (Select [Sentence_Text] +'| '
				  From #PDDIs
				  Where [Drug_1_Name]=b.[Drug_1_Name] 
						AND [Drug_2_Name]=b.[Drug_2_Name] 
				  FOR XML PATH('')
				 ) 		
	FROM #PDDIs b 