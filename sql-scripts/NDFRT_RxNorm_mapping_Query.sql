 
 	--Script to Map NDFRT to Drugbank
	--Added 9/15/2014 By Serkan 
	
	 
	
	 
	--Map NDF-RT to From FDA RX-NORM to Drugbank IDs using Rx_Cuis ,1708
	SELECT DISTINCT 
			--NUI,
			'http://purl.bioontology.org/ontology/NDFRT/'+NUI as NUI,
			Drugname,
			[FDA_PreferredTerm],
			--Replace(Drugname,' [Chemical/Ingredient]','') as Drugname,
			[DrugBank_CUI] as Drugbank_ID,
			'http://bio2rdf.org/drugbank:'+[DrugBank_CUI] Drugbank_Bio2rdf 
	FROM [PDDI_Databases].[dbo].[NDFRT_RxNorm_mappings] b 
		INNER JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f ON f.[RxNorm_CUI] = b.RxCUI 
 	WHERE  [DrugBank_CUI]<>'None' 

 
--------------- Mappings using [INCHI_AND_Syns_OR_Name]-------------------
	
	--Mapped, 1911
	SELECT DISTINCT  
			'http://purl.bioontology.org/ontology/NDFRT/'+NUI  
			+'$'+b.Drugname  
			+'$'+(CASE WHEN f.[DrugBank_CUI]<>'None'
					 THEN f.[DrugBank_CUI]
					 ELSE COALESCE(i.drugbank_id, sy.[drugbankid] , br.[drugbankid]) 
				   END )   
			+'$'+(CASE WHEN f.[DrugBank_CUI]<>'None'
					 THEN f.[DrugBank_Name]
					 ELSE COALESCE(i.[DrugBank_name], sy.[DrugName], br.[DrugName]) 
					 END )   
			+'$'	  	
	FROM [PDDI_Databases].[dbo].[NDFRT_RxNorm_mappings] b 
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f ON f.[RxNorm_CUI] = b.RxCUI 
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_AND_Syns_OR_Name] i ON i.[FDA_preferred_term] = b.[drugname]
																			OR i.[DrugBank_name] = b.[drugname]
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy ON sy.[Synonym]= b.[drugname]
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br ON br.brand= b.[drugname]
	WHERE   ( f.[DrugBank_CUI]<>'None' OR i.drugbank_id IS NOT NULL OR sy.drugbankid IS NOT NULL OR br.drugbankid IS NOT NULL) 



--------------- Mappings using [INCHI_OR_Syns_OR_Name]-------------------
	
	--Mapped, 2103
	SELECT DISTINCT  
			'http://purl.bioontology.org/ontology/NDFRT/'+NUI  
			+'$'+b.Drugname  
			+'$'+(CASE WHEN f.[DrugBank_CUI]<>'None'
					 THEN f.[DrugBank_CUI]
					 ELSE COALESCE(i.drugbank_id, sy.[drugbankid] , br.[drugbankid]) 
				   END )   
			+'$'+(CASE WHEN f.[DrugBank_CUI]<>'None'
					 THEN f.[DrugBank_Name]
					 ELSE COALESCE(i.[DrugBank_name], sy.[DrugName], br.[DrugName]) 
					 END )  
			+'$'  
	FROM [PDDI_Databases].[dbo].[NDFRT_RxNorm_mappings] b 
			LEFT JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f ON f.[RxNorm_CUI] = b.RxCUI 
			LEFT JOIN [PDDI_Databases].[dbo].[INCHI_OR_Syns_OR_Name] i ON i.[FDA_preferred_term] = b.[drugname]
																			OR i.[DrugBank_name] = b.[drugname]
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.[Synonym] 
					   From [PDDI_Databases].[dbo].[DrugbankSynonyms] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleSynonyms] m ON m.Common_Synonym = d.[Synonym]
						Where Common_Synonym IS NULL
					   ) sy ON sy.[Synonym]= b.[drugname]
			LEFT JOIN (Select d.drugbankid,d.[DrugName],d.brand 
					   From [PDDI_Databases].[dbo].[DrugbankBrands] d
							LEFT JOIN [PDDI_Databases].[dbo].[MultipleBrandNames] m ON m.Common_BrandName = d.brand
						Where Common_BrandName IS NULL
					   ) br ON br.brand= b.[drugname]
	WHERE   ( f.[DrugBank_CUI]<>'None' OR i.drugbank_id IS NOT NULL OR sy.drugbankid IS NOT NULL OR br.drugbankid IS NOT NULL) 
