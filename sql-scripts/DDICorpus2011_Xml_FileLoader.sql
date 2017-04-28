
	--Script to Parse XML file containing All DDI Corpus2011 files
	--Added 7/1/2014 By Serkan 
	--Last Modified 9/16/2014 

	--LOADs DDI Corpus2011 XML FILE
	 SELECT XmlContent
	 INTO [PDDI_Databases].[dbo].DDICorpus2011RawXml
	 FROM (SELECT *    
		  FROM OPENROWSET (BULK 'D:\Univ files\PhD\Research\BioInformatics\Datasets\DDICorpus2011\DDICorpus2011_AllXml.txt', SINGLE_CLOB) 
	 AS XmlContent) AS R(XmlContent)



	SELECT [XmlContent]  FROM [PDDI_Databases].[dbo].[DDICorpus2011RawXml] 


	-- XML Format Sample 
	--<document id="DrugDDI.d431" origId="Abatacept"> 
	--<sentence id="DrugDDI.d431.s3" origId="s3" text="Concurrent administration of a TNF antagonist with ORENCIA has been associated with an increased risk of serious infections and no significant additional efficacy over use of the TNF antagonists alone.">
	--	<entity id="DrugDDI.d431.s3.e0" origId="s3.p40" type="drug" text="TNF"/>
	--	<entity id="DrugDDI.d431.s3.e1" origId="s3.p41" type="drug" text="ORENCIA"/>
	--	<ddi id="DrugDDI.d431.s3.d0" e1="DrugDDI.d431.s3.e0" e2="DrugDDI.d431.s3.e1"/>
	--</sentence>
	 --</document>

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xml xml
	SELECT @xml = [XmlContent] FROM [PDDI_Databases].[dbo].DDICorpus2011RawXml 
	  
	--Insert DDIs into the Table
	SELECT DISTINCT
			doc.col.value('../../@id', 'varchar(50)') Document_ID 	  
		  ,doc.col.value('../../@origId', 'varchar(250)') Drugname 
		  ,doc.col.value('../@origId', 'varchar(50)') Sentence_ID   
		  ,doc.col.value('../@text', 'varchar(1000)') Sentence_Text 		
		  ,doc.col.value('@id', 'varchar(50)') DDI_ID   
		  ,doc.col.value('@e1', 'varchar(50)') e1 		
		  ,doc.col.value('@e2', 'varchar(50)') e2  
	INTO [PDDI_Databases].[dbo].DDICorpus2011_DDIs
	FROM @xml.nodes('/document/sentence/ddi') doc(col) 



	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xmlFile xml
	SELECT @xmlFile = [XmlContent] FROM [PDDI_Databases].[dbo].DDICorpus2011RawXml 
	 
	--Insert Entities in the DDIs into the Table
	SELECT DISTINCT
		doc.col.value('@id', 'varchar(1000)') ent_id 
		,doc.col.value('@type', 'varchar(1000)') ent_type 
		,doc.col.value('@text', 'varchar(1000)') ent_text
		,doc.col.value('../../@id', 'varchar(50)') Document_ID 	  
	    ,doc.col.value('../../@origId', 'varchar(250)') Drugname 
	INTO [PDDI_Databases].[dbo].DDICorpus2011_Entities
	FROM @xmlFile.nodes('/document/sentence/entity') doc(col)

	--drop table [PDDI_Databases].[dbo].DDICorpus2011_Entities



/********************************************************/
--Get Mapping Results
/*******************************************************/ 
		 
	------------- Mappings using [INCHI_AND_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets,366
	DROP TABLE #PDDIs
	SELECT DISTINCT		 			   
			COALESCE(f1.FDA_Preferred_Term, sy1.[Synonym], br1.brand ) [Drug_1_Name],
			COALESCE(f1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid] )  [Drug1_DrugbankID],
			COALESCE(f2.FDA_Preferred_Term, sy2.[Synonym], br2.brand ) [Drug_2_Name],
			COALESCE(f2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid])[Drug2_DrugbankID],
			[Sentence_Text]  
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].[DDICorpus2011_DDIs] b
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2011_Entities] d1 ON d1.[ent_id] = b.[e1] and d1.Drugname =b.Drugname
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2011_Entities] d2 ON d2.[ent_id] = b.[e2] and d2.Drugname =b.Drugname	
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
	WHERE  (f1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			 AND (f2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		 

	--Get PDDIs Mapped to Drugbank, 334 after concatination
	SELECT DISTINCT		 
			  [Drug_1_Name]  
			+'$'+ [Drug1_DrugbankID] 
			+'$'+  [Drug_2_Name]   
			+'$'+ [Drug2_DrugbankID] 
			+'$'+ (Select [Sentence_Text] +'| '
				  From #PDDIs
				  Where [Drug_1_Name]=b.[Drug_1_Name] 
						AND [Drug_2_Name]=b.[Drug_2_Name] 
				  FOR XML PATH('')
				 ) 		
	FROM #PDDIs b 
	 
 


	------------- Mappings using [INCHI_AND_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets,823
	DROP TABLE #PDDIs
	SELECT DISTINCT		 			   
			COALESCE(f1.FDA_Preferred_Term, sy1.[Synonym], br1.brand ) [Drug_1_Name],
			COALESCE(f1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid] )  [Drug1_DrugbankID],
			COALESCE(f2.FDA_Preferred_Term, sy2.[Synonym], br2.brand ) [Drug_2_Name],
			COALESCE(f2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid])[Drug2_DrugbankID],
			[Sentence_Text]  
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].[DDICorpus2011_DDIs] b
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2011_Entities] d1 ON d1.[ent_id] = b.[e1] and d1.Drugname =b.Drugname
			INNER JOIN [PDDI_Databases].[dbo].[DDICorpus2011_Entities] d2 ON d2.[ent_id] = b.[e2] and d2.Drugname =b.Drugname	
			LEFT JOIN [PDDI_Databases].[dbo].INCHI_OR_Syns_OR_Name f1 ON f1.[FDA_preferred_term] = d1.[ent_text] 
																			OR f1.[DrugBank_name] = d1.[ent_text]
			LEFT JOIN [PDDI_Databases].[dbo].INCHI_OR_Syns_OR_Name f2 ON f2.[FDA_preferred_term] = d2.[ent_text] 
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
	WHERE  (f1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			 AND (f2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		 

	--Get PDDIs Mapped to Drugbank, 733 after concatination
	SELECT DISTINCT		 
			  [Drug_1_Name]  
			+'$'+ [Drug1_DrugbankID] 
			+'$'+  [Drug_2_Name]   
			+'$'+ [Drug2_DrugbankID] 
			+'$'+ (Select [Sentence_Text] +'| '
				  From #PDDIs
				  Where [Drug_1_Name]=b.[Drug_1_Name] 
						AND [Drug_2_Name]=b.[Drug_2_Name] 
				  FOR XML PATH('')
				 ) 		
	FROM #PDDIs b 
	 
 
