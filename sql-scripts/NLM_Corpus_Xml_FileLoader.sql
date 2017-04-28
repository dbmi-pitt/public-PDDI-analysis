
	--Script to Parse XML file containing All NLM Corpus files
	--Added 9/17/2014 By Serkan 
	
	

	--LOADs DDI Corpus2013 XML FILE
	 SELECT XmlContent
	 INTO  [PDDI_Databases].[dbo].NLMCorpusRawXml
	 FROM (SELECT *    
		  FROM OPENROWSET (BULK 'D:\Univ files\PhD\Research\BioInformatics\Datasets\NLMCorpus\NLMCorpus_AllXml.txt', SINGLE_CLOB) 
	 AS XmlContent) AS R(XmlContent)

	SELECT [XmlContent]  FROM [PDDI_Databases].[dbo].NLMCorpusRawXml 
		

	-- XML Format Sample 
	--<sentence id="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1" text="Drug Label for drug brand ADCIRCA, containing Tadalafil." type="negative">
		--<entity charOffset="46:55" id="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.0" text="tadalafil" type="Biomedical_Entity">
			--<Normalization>
				--<mmtx cui="C1176316" phraseText="Tadalafil." preferredWord="tadalafil" semType="phsu, orch"/>
				--<RxNorm RxCui="358263"/>
			--</Normalization>
		--</entity>
		--<entity charOffset="26:33" id="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.1" text="adcirca" type="Biomedical_Entity">...</entity>
		--<entity charOffset="0:19" id="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.2" text="drug drug" type="Biomedical_Entity">...</entity>
		--<pair ddi="false" e1="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.1" e2="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.0"/>
		--<pair ddi="false" e1="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.2" e2="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.0"/>
		--<pair ddi="false" e1="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.2" e2="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.1"/>
	--</sentence>

	--drop table [PDDI_Databases].[dbo].NLMCorpus_DDIs

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xml xml
	SELECT @xml = [XmlContent] FROM [PDDI_Databases].[dbo].NLMCorpusRawXml-- NLMCorpusRawXmlTest
	  
	--Insert DDIs into the Table
	SELECT DISTINCT		 
		   doc.col.value('@e1', 'varchar(100)') e1 		
		   --,doc.col.value('@id', 'varchar(50)') DDI_ID  
		  ,doc.col.value('@e2', 'varchar(100)') e2  
		  ,doc.col.value('@ddi', 'varchar(50)') Is_DDI  
		  ,doc.col.value('@type', 'varchar(50)') DDI_Type   
		  ,doc.col.value('@trigger', 'varchar(100)') DDI_Trigger    
	INTO [PDDI_Databases].[dbo].NLMCorpus_DDIs
	FROM @xml.nodes('/document/sentence/pair') doc(col)  
 
	--Set the Sentence_ID containing DDIs
	ALTER TABLE [PDDI_Databases].[dbo].NLMCorpus_DDIs
	ADD Sentence_ID varchar(100)
	
	UPDATE [PDDI_Databases].[dbo].NLMCorpus_DDIs
	SET Sentence_ID = SUBSTRING(e2,0,CHARINDEX('.e.',e2)-1)
	WHere Is_DDI = 'true'
	  


--<entity charOffset="26:33" id="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.1" text="adcirca" type="Biomedical_Entity">...</entity>
		
	--drop table [PDDI_Databases].[dbo].NLMCorpus_Entities

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xmlFile xml
	SELECT @xmlFile = [XmlContent] FROM [PDDI_Databases].[dbo].NLMCorpusRawXml 
		
	--Insert Entities in the DDIs into the Table
	SELECT DISTINCT
		doc.col.value('@id', 'varchar(1000)') ent_id 
		,doc.col.value('@charOffset', 'varchar(1000)') charOffset
		,doc.col.value('@type', 'varchar(1000)') ent_type 
		,doc.col.value('@text', 'varchar(1000)') ent_text		
		,doc.col.value('../../@id', 'varchar(50)') Document_ID 	
		--,doc.col.value('../@id', 'varchar(50)') Sentence_ID 	   
	INTO [PDDI_Databases].[dbo].NLMCorpus_Entities
	FROM @xmlFile.nodes('/document/sentence/entity') doc(col)



--<entity charOffset="46:55" id="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.0" text="tadalafil" type="Biomedical_Entity">
	--<Normalization>
		--<mmtx cui="C1176316" phraseText="Tadalafil." preferredWord="tadalafil" semType="phsu, orch"/>
		--<RxNorm RxCui="358263"/>
	--</Normalization>
--</entity>

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xmlFile xml
	SELECT @xmlFile = [XmlContent] FROM [PDDI_Databases].[dbo].NLMCorpusRawXml 
		
	--Insert Entities in the DDIs into the Table
	SELECT DISTINCT
		doc.col.value('@cui', 'varchar(50)') cui
		,doc.col.value('@phraseText', 'varchar(100)') phraseText
		,doc.col.value('@preferredWord', 'varchar(50)') preferredWord 
		,doc.col.value('@semType', 'varchar(100)') semType		
		,doc.col.value('../../@id', 'varchar(100)') entityID		   
	INTO [PDDI_Databases].[dbo].NLMCorpus_Entities_mmtx
	FROM @xmlFile.nodes('/document/sentence/entity/Normalization/mmtx') doc(col)

--<entity charOffset="46:55" id="Dailymed.ff61b237-be8e-461b-8114-78c52a8ad0ae.s.1.e.0" text="tadalafil" type="Biomedical_Entity">
	--<Normalization>
		--<mmtx cui="C1176316" phraseText="Tadalafil." preferredWord="tadalafil" semType="phsu, orch"/>
		--<RxNorm RxCui="358263"/>
	--</Normalization>
--</entity>

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xmlFile xml
	SELECT @xmlFile = [XmlContent] FROM [PDDI_Databases].[dbo].NLMCorpusRawXml 
		
	--Insert Entities in the DDIs into the Table
	SELECT DISTINCT
		 doc.col.value('@RxCui', 'varchar(50)') RxCui 
		,doc.col.value('../../@id', 'varchar(100)') entityID		   
	INTO [PDDI_Databases].[dbo].NLMCorpus_Entities_RxNorm
	FROM @xmlFile.nodes('/document/sentence/entity/Normalization/RxNorm') doc(col)

--<document id="DDI-DrugBank.d353">
--<sentence biomedicalEntities="3" id="Dailymed.01b14603-8f29-4fa3-8d7e-9d523f802e0b.s.36" lineNumber="49" text="Avoid concomitant use of Plavix with omeprazole or esomeprazole. " type="regular">
	
	--drop table [PDDI_Databases].[dbo].NLMCorpus_Sentences

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @Sxml xml
	SELECT @Sxml = [XmlContent] FROM [PDDI_Databases].[dbo].NLMCorpusRawXml
	  
	--Insert Sentence into the Table
	SELECT DISTINCT 
		   doc.col.value('@id', 'varchar(50)') Sentence_ID   
		  ,doc.col.value('@biomedicalEntities', 'varchar(1000)') biomedicalEntities 
		  ,doc.col.value('@lineNumber', 'varchar(10)') lineNumber 
		  ,doc.col.value('@type', 'varchar(50)') Sentence_Type 
		  ,doc.col.value('@text', 'varchar(1000)') Sentence_Text 
	INTO [PDDI_Databases].[dbo].NLMCorpus_Sentences
	FROM @Sxml.nodes('/document/sentence') doc(col)  


--<drugInteraction id="Dailymed.01b14603-8f29-4fa3-8d7e-9d523f802e0b.s.11.ddi.1">
	--<interaction trigger="Dailymed.01b14603-8f29-4fa3-8d7e-9d523f802e0b.s.11.e.1">
		--<relations>
			--<relation type="hasObject">
				--<entity id="Dailymed.01b14603-8f29-4fa3-8d7e-9d523f802e0b.s.11.e.3"/>
			--</relation>
			--<relation type="hasPrecipitant">
				--<entity id="Dailymed.01b14603-8f29-4fa3-8d7e-9d523f802e0b.s.11.e.0"/>
			--</relation>
		--</relations>
	--</interaction>
--</drugInteraction>
	
	--drop table [PDDI_Databases].[dbo].NLMCorpus_Interaction_Trigger

	--Extracts the Fields values in the DDIs from the document formatted like sample above
	DECLARE @xmlFile xml
	SELECT @xmlFile = [XmlContent] FROM [PDDI_Databases].[dbo].NLMCorpusRawXml
		
	--Insert Entities in the DDIs into the Table
	SELECT DISTINCT
		doc.col.value('@id', 'varchar(100)') ent_id
		,doc.col.value('../@type', 'varchar(100)') relation_type
		,doc.col.value('../../../@trigger', 'varchar(100)') DDI_trigger  
		,doc.col.value('../../../../@id', 'varchar(100)') interactionID		   
	INTO [PDDI_Databases].[dbo].NLMCorpus_Interaction_Trigger
	FROM @xmlFile.nodes('/document/sentence/drugInteraction/interaction/relations/relation/entity') doc(col)
	 


/********************************************************/
--Get Mapping Results
/*******************************************************/ 

		 
	------------- Mappings using [INCHI_AND_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets, 932
	DROP TABLE #PDDIs
	SELECT DISTINCT		 
			  (CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_Name]
					 ELSE COALESCE(i1.[DrugBank_name], sy1.[DrugName], br1.[DrugName]) 
				END ) as [Drug_1_Name] 			 
			, d1.ent_type as  Drug1_type  
			,(CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_CUI]
					 ELSE COALESCE(i1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid]) 
			   END ) AS [Drug1_DrugbankID]
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_Name]
					 ELSE COALESCE(i2.[DrugBank_name], sy2.[DrugName], br2.[DrugName]) 
				END ) as [Drug_2_Name] 	  
			, d2.ent_type as Drug2_type  
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_CUI]
					 ELSE COALESCE(i2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid]) 
			   END ) AS [Drug2_DrugbankID]  
			, Is_DDI 
			, DDI_Type   
			, s.[Sentence_Text]   
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].NLMCorpus_DDIs b
			INNER JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities] d1 ON d1.[ent_id] = b.[e1]  
			INNER JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities] d2 ON d2.[ent_id] = b.[e2]  
			LEFT JOIN [PDDI_Databases].[dbo].[NLMCorpus_Sentences] s ON s.Sentence_ID = b.Sentence_ID
			LEFT JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities_RxNorm] rx1 ON rx1.entityID = b.[e1]
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f1 ON f1.[RxNorm_CUI] = rx1.RxCui 						
			LEFT JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities_RxNorm] rx2 ON rx2.entityID = b.[e2]
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f2 ON f2.[RxNorm_CUI] = rx2.RxCui 
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_AND_Syns_OR_Name] i1 ON i1.[FDA_preferred_term] = d1.[ent_text] 
																			OR i1.[DrugBank_name] = d1.[ent_text]
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_AND_Syns_OR_Name] i2 ON i2.[FDA_preferred_term] = d2.[ent_text] 
																			OR i2.[DrugBank_name] = d2.[ent_text]	
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy1 ON sy1.[Synonym]= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym]
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy2 ON sy2.[Synonym]= d2.[ent_text] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br1 ON br1.brand= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br2 ON br2.brand= d2.[ent_text]  
	WHERE  Is_DDI ='true'
			AND b.[e1] like '%Dailymed%' AND b.[e2] like '%Dailymed%'    
			AND ( f1.[DrugBank_CUI]<>'None' OR i1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			AND ( f2.[DrugBank_CUI]<>'None' OR i2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		   
		 

	--Get PDDIs Mapped to Drugbank, 238 after concatination 
	SELECT DISTINCT		 
			  [Drug_1_Name] 			 
			+'$'+ Drug1_type 
			+'$'+ [Drug1_DrugbankID] 
			+'$'+ [Drug_2_Name]  
			+'$'+ Drug2_type   
			+'$'+ [Drug2_DrugbankID]
			+'$'+ Is_DDI 
			+'$'+ DDI_Type    
			+'$'+(Select [Sentence_Text] +'; '
			  From #PDDIs
			  Where [Drug_1_Name]=b.[Drug_1_Name] 
					AND [Drug_2_Name]=b.[Drug_2_Name] 
			  FOR XML PATH('')
			 )		
	FROM #PDDIs b 

 

 	------------- Mappings using [INCHI_OR_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets, 1335
	DROP TABLE #PDDIs
	SELECT DISTINCT		 
			  (CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_Name]
					 ELSE COALESCE(i1.[DrugBank_name], sy1.[DrugName], br1.[DrugName]) 
				END ) as [Drug_1_Name] 			 
			, d1.ent_type as  Drug1_type  
			,(CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_CUI]
					 ELSE COALESCE(i1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid]) 
			   END ) AS [Drug1_DrugbankID]
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_Name]
					 ELSE COALESCE(i2.[DrugBank_name], sy2.[DrugName], br2.[DrugName]) 
				END ) as [Drug_2_Name] 	  
			, d2.ent_type as Drug2_type  
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_CUI]
					 ELSE COALESCE(i2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid]) 
			   END ) AS [Drug2_DrugbankID]  
			, Is_DDI 
			, DDI_Type   
			, s.[Sentence_Text]   
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].NLMCorpus_DDIs b
			INNER JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities] d1 ON d1.[ent_id] = b.[e1]  
			INNER JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities] d2 ON d2.[ent_id] = b.[e2]  
			LEFT JOIN [PDDI_Databases].[dbo].[NLMCorpus_Sentences] s ON s.Sentence_ID = b.Sentence_ID
			LEFT JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities_RxNorm] rx1 ON rx1.entityID = b.[e1]
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f1 ON f1.[RxNorm_CUI] = rx1.RxCui 						
			LEFT JOIN [PDDI_Databases].[dbo].[NLMCorpus_Entities_RxNorm] rx2 ON rx2.entityID = b.[e2]
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f2 ON f2.[RxNorm_CUI] = rx2.RxCui 
			LEFT JOIN [PDDI_Databases].[dbo].INCHI_OR_Syns_OR_Name i1 ON i1.[FDA_preferred_term] = d1.[ent_text] 
																			OR i1.[DrugBank_name] = d1.[ent_text]
			LEFT JOIN [PDDI_Databases].[dbo].INCHI_OR_Syns_OR_Name i2 ON i2.[FDA_preferred_term] = d2.[ent_text] 
																			OR i2.[DrugBank_name] = d2.[ent_text]	
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy1 ON sy1.[Synonym]= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym]
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy2 ON sy2.[Synonym]= d2.[ent_text] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br1 ON br1.brand= d1.[ent_text] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br2 ON br2.brand= d2.[ent_text]  
	WHERE  Is_DDI ='true'
			AND b.[e1] like '%Dailymed%' AND b.[e2] like '%Dailymed%'    
			AND ( f1.[DrugBank_CUI]<>'None' OR i1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			AND ( f2.[DrugBank_CUI]<>'None' OR i2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		   
		 

	--Get PDDIs Mapped to Drugbank, 328 after concatination 
	SELECT DISTINCT		 
			  [Drug_1_Name] 			 
			+'$'+ Drug1_type 
			+'$'+ [Drug1_DrugbankID] 
			+'$'+ [Drug_2_Name]  
			+'$'+ Drug2_type   
			+'$'+ [Drug2_DrugbankID]
			+'$'+ Is_DDI 
			+'$'+ DDI_Type    
			+'$'+(Select [Sentence_Text] +'; '
			  From #PDDIs
			  Where [Drug_1_Name]=b.[Drug_1_Name] 
					AND [Drug_2_Name]=b.[Drug_2_Name] 
			  FOR XML PATH('')
			 )		
	FROM #PDDIs b 