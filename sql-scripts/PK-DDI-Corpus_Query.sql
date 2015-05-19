	
	--Script to Map Gold Standard Dataset
	--Added 9/17/2014 By Serkan 

	--Get Gold Standard Dataset
	SELECT DISTINCT 
		     [section#]
			,[Drug_1_type]
			,[Drug_1_mention]
			,[Drug_1_annotation_agent]
			,[Drug_1_starting_offset]
			,[Drug_1_ending_offset]
			,[Drug_2_type]
			,[Drug_2_mention]
			,[Drug_2_annotation_agent]
			,[abbreviation_translation]
			,[Drug_2_start_offset]
			,[Drug_2_end_offset]
			,[DDI_modality]
			,[DDI_statement_type]
			,[snippit_of_DDI]			
			,[snippit_of_DDI2]
			,[Unknown1_CuI]
			,[Unknown2_CuI]
			,[Drug1_RX_CuI]
			,[Drug2_RX_CuI]
	FROM [PDDI_Databases].[dbo].[PKCorpus_DDIs]



 
/********************************************************/
--Get Mapping Results
/*******************************************************/ 
 

	 
	------------- Mappings using [INCHI_AND_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets, 284
	DROP TABLE #PDDIs
	SELECT DISTINCT		 
			  (CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_Name]
					 ELSE COALESCE(i1.[DrugBank_name], sy1.[DrugName], br1.[DrugName]) 
				END ) as [Drug_1_Name] 			 
			, [Drug_1_type] 			
			,[Drug_1_annotation_agent]
			,(CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_CUI]
					 ELSE COALESCE(i1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid]) 
			   END ) AS [Drug1_Drugbank_ID]
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_Name]
					 ELSE COALESCE(i2.[DrugBank_name], sy2.[DrugName], br2.[DrugName]) 
				END ) as [Drug_2_Name] 	  
			, [Drug_2_type]  		 
			,[Drug_2_annotation_agent]
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_CUI]
					 ELSE COALESCE(i2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid]) 
			   END ) AS [Drug2_Drugbank_ID]  
			,[abbreviation_translation] 
			,[Drug1_RX_CuI]
			,[Drug2_RX_CuI] 
			,[snippit_of_DDI]   
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].[PKCorpus_DDIs] b    
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f1 ON f1.[RxNorm_CUI] = b.[Drug1_RX_CuI]  
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f2 ON f2.[RxNorm_CUI] = b.[Drug2_RX_CuI] 
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_AND_Syns_OR_Name] i1 ON i1.[FDA_preferred_term] = b.[Drug_1_mention] 
																			OR i1.[DrugBank_name] = b.[Drug_1_mention]
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_AND_Syns_OR_Name] i2 ON i2.[FDA_preferred_term] = b.[Drug_2_mention] 
																			OR i2.[DrugBank_name] = b.[Drug_2_mention] 	
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy1 ON sy1.[Synonym]= b.[Drug_1_mention] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym]
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy2 ON sy2.[Synonym]= b.[Drug_2_mention] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br1 ON br1.brand= b.[Drug_1_mention] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br2 ON br2.brand= b.[Drug_2_mention]   
	WHERE   ( f1.[DrugBank_CUI]<>'None' OR i1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			AND ( f2.[DrugBank_CUI]<>'None' OR i2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		   

			    
	--Get PDDIs Mapped to Drugbank, 232 after concatination 
	SELECT DISTINCT		 
			  [Drug_1_Name] 			 
			+'$'+ [Drug_1_type] 
			+'$'+ [Drug_1_annotation_agent]
			+'$'+ [Drug1_Drugbank_ID] 
			+'$'+ [Drug_2_Name]  
			+'$'+ [Drug_2_type]   
			+'$'+ [Drug_2_annotation_agent]
			+'$'+ [Drug2_Drugbank_ID]
			+'$'+ [abbreviation_translation]  
			+'$'+ [Drug1_RX_CuI]   
			+'$'+ [Drug2_RX_CuI]   
			+'$'+(Select [snippit_of_DDI] +'| '
				  From #PDDIs
				  Where [Drug_1_Name]=b.[Drug_1_Name] 
						AND [Drug_2_Name]=b.[Drug_2_Name] 
				  FOR XML PATH('')
				 )		
	FROM #PDDIs b 

 ------------- Mappings using [INCHI_OR_Syns_OR_Name]-------------------
	--INSERT INTO #PDDIs  to Concatinate multiple DDI Snippets, 341
	DROP TABLE #PDDIs
	SELECT DISTINCT		 
			  (CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_Name]
					 ELSE COALESCE(i1.[DrugBank_name], sy1.[DrugName], br1.[DrugName]) 
				END ) as [Drug_1_Name] 			 
			, [Drug_1_type] 			
			,[Drug_1_annotation_agent]
			,(CASE WHEN f1.[DrugBank_CUI]<>'None'
					 THEN f1.[DrugBank_CUI]
					 ELSE COALESCE(i1.drugbank_id, sy1.[drugbankid] , br1.[drugbankid]) 
			   END ) AS [Drug1_Drugbank_ID]
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_Name]
					 ELSE COALESCE(i2.[DrugBank_name], sy2.[DrugName], br2.[DrugName]) 
				END ) as [Drug_2_Name] 	  
			, [Drug_2_type]  		 
			,[Drug_2_annotation_agent]
			,(CASE WHEN f2.[DrugBank_CUI]<>'None'
					 THEN f2.[DrugBank_CUI]
					 ELSE COALESCE(i2.drugbank_id, sy2.[drugbankid] , br2.[drugbankid]) 
			   END ) AS [Drug2_Drugbank_ID]  
			,[abbreviation_translation] 
			,[Drug1_RX_CuI]
			,[Drug2_RX_CuI] 
			,[snippit_of_DDI]   
	INTO #PDDIs 		
	FROM [PDDI_Databases].[dbo].[PKCorpus_DDIs] b    
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f1 ON f1.[RxNorm_CUI] = b.[Drug1_RX_CuI]  
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f2 ON f2.[RxNorm_CUI] = b.[Drug2_RX_CuI] 
			LEFT JOIN [PDDI_Databases].[dbo].INCHI_OR_Syns_OR_Name i1 ON i1.[FDA_preferred_term] = b.[Drug_1_mention] 
																			OR i1.[DrugBank_name] = b.[Drug_1_mention]
			LEFT JOIN [PDDI_Databases].[dbo].INCHI_OR_Syns_OR_Name i2 ON i2.[FDA_preferred_term] = b.[Drug_2_mention] 
																			OR i2.[DrugBank_name] = b.[Drug_2_mention] 	
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy1 ON sy1.[Synonym]= b.[Drug_1_mention] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym]
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy2 ON sy2.[Synonym]= b.[Drug_2_mention] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br1 ON br1.brand= b.[Drug_1_mention] 
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br2 ON br2.brand= b.[Drug_2_mention]   
	WHERE   ( f1.[DrugBank_CUI]<>'None' OR i1.drugbank_id IS NOT NULL OR sy1.drugbankid IS NOT NULL OR br1.drugbankid IS NOT NULL)
			AND ( f2.[DrugBank_CUI]<>'None' OR i2.drugbank_id IS NOT NULL OR sy2.drugbankid IS NOT NULL OR br2.drugbankid IS NOT NULL)  
		    
	--Get PDDIs Mapped to Drugbank, 282 after concatination 
	SELECT DISTINCT		 
			  [Drug_1_Name] 			 
			+'$'+ [Drug_1_type] 
			+'$'+ [Drug_1_annotation_agent]
			+'$'+ [Drug1_Drugbank_ID] 
			+'$'+ [Drug_2_Name]  
			+'$'+ [Drug_2_type]   
			+'$'+ [Drug_2_annotation_agent]
			+'$'+ [Drug2_Drugbank_ID]
			+'$'+ [abbreviation_translation] 
			+'$'+ [Drug1_RX_CuI]   
			+'$'+ [Drug2_RX_CuI]   
			+'$'+(Select [snippit_of_DDI] +'| '
				  From #PDDIs
				  Where [Drug_1_Name]=b.[Drug_1_Name] 
						AND [Drug_2_Name]=b.[Drug_2_Name] 
				  FOR XML PATH('')
				 )		
	FROM #PDDIs b 


  