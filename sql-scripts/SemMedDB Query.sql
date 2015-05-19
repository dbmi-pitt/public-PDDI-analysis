
SELECT TOP 1000 [PMID]
      ,[Drug1ject CUI]
      ,[Drug1ject name]
	  ,(CASE WHEN CHARINDEX('|||',[Drug1ject CUI] )>0
				   Then Drug1string([Drug1ject CUI],0,CHARINDEX('|||',[Drug1ject CUI] ))
				   Else [Drug1ject CUI]  End
			 )
		,len(Drug1string([Drug1ject name],0,CHARINDEX('|||',[Drug1ject name] )))
		,(CASE WHEN len(Drug1string([Drug1ject name],0,CHARINDEX('|||',[Drug1ject name] )))>0
				Then Drug1string([Drug1ject name],0,CHARINDEX('|||',[Drug1ject name] ))
				Else [Drug1ject name]
				End)
      ,[Drug2ect CUI]
      ,[Drug2ect Name]
      ,[Drug1_Prim_CUI]
      ,[Drug1_Prim_Name]
      ,[Drug2_Prim_CUI]
      ,[Drug2_Prim_Name]
  FROM [PDDI_Databases].[dbo].[SemMedDB]

	----CleanUp fields
	--UPDATE [PDDI_Databases].[dbo].[SemMedDB]
	--SET [PMID] = REPLACE([PMID],'"',''),
	--	[Drug1ject_CUI] = REPLACE([Drug1ject_CUI],'"',''),
	--	[Drug1ject_name] = REPLACE([Drug1ject_name],'"',''),
	--	[Drug2ect_CUI] = REPLACE([Drug2ect_CUI],'"',''),
	--	[Drug2ect_Name] = REPLACE([Drug2ect_Name],'"','')
	

	

    --CleanUp Drug1ject Cui when there are multiple items(50691), e.g. C0003241|||C0003241
	UPDATE [PDDI_Databases].[dbo].[SemMedDB]
	SET [Drug1_Prim_CUI] = (CASE WHEN CHARINDEX('|||',[Drug1ject CUI] )>0
							     Then Drug1string([Drug1ject CUI],0,CHARINDEX('|||',[Drug1ject CUI] ))
							     Else [Drug1ject CUI]  End
						   ),
		[Drug1_Prim_Name] = (CASE WHEN len(Drug1string([Drug1ject name],0,CHARINDEX('|||',[Drug1ject name] )))>0
								Then Drug1string([Drug1ject name],0,CHARINDEX('|||',[Drug1ject name] ))
								Else [Drug1ject name]	End
							),
		[Drug2_Prim_CUI] = (CASE WHEN CHARINDEX('|||',[Drug2ect CUI] )>0
							     Then Drug1string([Drug2ect CUI],0,CHARINDEX('|||',[Drug2ect CUI] ))
							     Else [Drug2ect CUI]  End
						   ),
		[Drug2_Prim_Name] = (CASE WHEN len(Drug1string([Drug2ect Name],0,CHARINDEX('|||',[Drug2ect Name] )))>0
								Then Drug1string([Drug2ect Name],0,CHARINDEX('|||',[Drug2ect Name] ))
								Else [Drug2ect Name]	End
							)

	 
	 
	SELECT DISTINCT
		   [PMID]
		  ,[Drug1ject CUI]
		  ,[Drug1ject name] 
		  ,[Drug1_Prim_CUI] 
		  ,[Drug1_Prim_Name]
		  ,[Drug2ect CUI]
		  ,[Drug2ect Name]		 
		  ,[Drug2_Prim_CUI]
		  ,[Drug2_Prim_Name]
	  FROM [PDDI_Databases].[dbo].[SemMedDB]
	  WHERE  [Drug1ject CUI]='C1366832|||51761'

	

	
	--Get Matching CUIs
	SELECT DISTINCT	
			 [PMID]
			,[Drug1ject CUI]
			,[Drug1_Prim_CUI] 			
			,[Drug1ject name]			
			,[Drug1_Prim_Name]
			,s.UMLS_CUI
			,s.Rx_CUI
			,[Drug2ect CUI]
			,[Drug2_Prim_CUI]
			,[Drug2ect Name]
			,[Drug2_Prim_Name]
			,o.UMLS_CUI
			,o.Rx_CUI
	  FROM [PDDI_Databases].[dbo].[SemMedDB] b	
		 INNER JOIN [PDDI_Databases].[dbo].[UMLS_RxNorm_Mapping] s ON s.UMLS_CUI = b.[Drug1_Prim_CUI]
		 INNER JOIN [PDDI_Databases].[dbo].[UMLS_RxNorm_Mapping] o ON o.UMLS_CUI = b.[Drug2_Prim_CUI] 
	  ORDER BY [Drug1ject CUI],[Drug2ect CUI]



	 --Insert Matching CUIs Final
	SELECT DISTINCT	
			 [PMID]
			,[Drug1_Prim_CUI] 		
			,[Drug1_Prim_Name]
			--,s.UMLS_CUI
			,s.Rx_CUI as Drug1_Rx_CUI
			,[Drug2_Prim_CUI]
			,[Drug2_Prim_Name]
			--,o.UMLS_CUI
			,o.Rx_CUI as Drug2_Rx_CUI
	  INTO [PDDI_Databases].[dbo].[SemMedDB_Mapped] 
	  FROM [PDDI_Databases].[dbo].[SemMedDB] b	
		 INNER JOIN [PDDI_Databases].[dbo].[UMLS_RxNorm_Mapping] s ON s.UMLS_CUI = b.[Drug1_Prim_CUI]
		 INNER JOIN [PDDI_Databases].[dbo].[UMLS_RxNorm_Mapping] o ON o.UMLS_CUI = b.[Drug2_Prim_CUI] 
	 ORDER BY [Drug1_Prim_CUI],[Drug2_Prim_CUI]


	 --Get Mapped Results
	 SELECT DISTINCT
			[PMID]
			,[Drug1_Prim_CUI]
			,[Drug1_Prim_Name]
			,[Drug1_Rx_CUI]
			,[Drug2_Prim_CUI]
			,[Drug2_Prim_Name]
			,[Drug2_Rx_CUI]
	  FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped]
	  ORDER BY [Drug1_Prim_CUI],[Drug2_Prim_CUI]

	 --Get Combined Results
	 SELECT DISTINCT			
			 [Drug1_Prim_CUI]
			,[Drug1_Prim_Name]
			,[Drug1_Rx_CUI]
			,[Drug2_Prim_CUI]
			,[Drug2_Prim_Name]
			,[Drug2_Rx_CUI]
			,(Select  convert(varchar,[PMID])+','
			  From [PDDI_Databases].[dbo].[SemMedDB_Mapped]
			  Where [Drug1_Prim_CUI] = b.[Drug1_Prim_CUI]
					AND [Drug2_Prim_CUI] = b.[Drug2_Prim_CUI]
			  FOR XML PATH('')
			 )as PMIDs
	  FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] b
	  ORDER BY [Drug1_Prim_CUI],[Drug2_Prim_CUI]

	
	 

	--Set Drug 1 Drugbank IDs From FDA RX-NORM, 88523
	UPDATE b
	SET Drug1_Drugbank_ID = [DrugBank_CUI]
	--Select *
	FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] b
		INNER JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f1 ON f1.[RxNorm_CUI]= b.[Drug1_RX_CuI]
	WHERE Drug1_Drugbank_ID IS NULL
		AND [DrugBank_CUI]<>'None'

	
	--Set Drug 2 Drugbank IDs From FDA RX-NORM, 89622 
	UPDATE b
	SET Drug2_Drugbank_ID = [DrugBank_CUI]
	FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] b
		INNER JOIN [PDDI_Databases].[dbo].[FDA_RXNORM_DRUGBANK] f2 ON f2.[RxNorm_CUI]= b.[Drug2_RX_CuI]
	WHERE Drug2_Drugbank_ID IS NULL
		AND [DrugBank_CUI]<>'None'



/********************************************************/
--Get Results
/*******************************************************/



	--All Mapped Dataset - 4826
	SELECT DISTINCT			
			 [Drug1_Prim_Name]
			--,[Drug1_Prim_CUI]
			--,[Drug1_Rx_CUI] 
			,Drug1_Drugbank_ID 
			--,[Drug2_Prim_CUI]
			,[Drug2_Prim_Name]
			--,[Drug2_Rx_CUI] 
			,Drug2_Drugbank_ID  
	  FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] b
	  WHERE Drug1_Drugbank_ID IS NOT NULL AND Drug2_Drugbank_ID IS NOT NULL
	  ORDER BY [Drug1_Prim_Name],[Drug2_Prim_Name]
	
		
	--All Mapped Dataset with PMIDs - 4826
	SELECT DISTINCT			
			 [Drug1_Prim_Name]
			,Drug1_Drugbank_ID  
			,[Drug2_Prim_Name] 
			,Drug2_Drugbank_ID   
			,(Select  convert(varchar,[PMID])+','
			  From [PDDI_Databases].[dbo].[SemMedDB_Mapped]
			  Where [Drug1_Prim_CUI] = b.[Drug1_Prim_CUI]
					AND [Drug2_Prim_CUI] = b.[Drug2_Prim_CUI]
			  FOR XML PATH('')
			 )as PMIDs
	  FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] b
	  WHERE Drug1_Drugbank_ID IS NOT NULL AND Drug2_Drugbank_ID IS NOT NULL
			--AND Drug1_Drugbank_ID='DB03175'
	  ORDER BY [Drug1_Prim_Name],[Drug2_Prim_Name]
	 

	--with +'$'+ All Mapped Dataset with PMIDs - 4826
	SELECT DISTINCT			
			 [Drug1_Prim_Name]
			+'$'+Drug1_Drugbank_ID  
			+'$'+[Drug2_Prim_Name] 
			+'$'+Drug2_Drugbank_ID   
			+'$'+(Select  convert(varchar,[PMID])+','
			  From [PDDI_Databases].[dbo].[SemMedDB_Mapped]
			  Where [Drug1_Prim_CUI] = b.[Drug1_Prim_CUI]
					AND [Drug2_Prim_CUI] = b.[Drug2_Prim_CUI]
			  FOR XML PATH('')
			 )as PMIDs
	  FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] b
	  WHERE Drug1_Drugbank_ID IS NOT NULL AND Drug2_Drugbank_ID IS NOT NULL
			--AND Drug1_Drugbank_ID='DB03175' 






	  -- SELECT DISTINCT			
			-- [Drug1_Prim_CUI]
			--,[Drug1_Prim_Name]
			--,[Drug1_Rx_CUI]
			--,r1.STR
			--,fd.DRUGBANK_CA
			--,[Drug2_Prim_CUI]
			--,[Drug2_Prim_Name]
			--,[Drug2_Rx_CUI]
			--,r2.STR
	  --FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] b
		 -- LEFT JOIN [PDDI_Databases].[dbo].[RXNCONSO] r1 On r1.RXCUI = b.[Drug1_Rx_CUI] AND r1.SAB= 'MTHSPL'
		 -- LEFT JOIN [PDDI_Databases].[dbo].[RXNCONSO] r2 On r2.RXCUI = b.Drug2_Rx_CUI   AND r2.SAB= 'MTHSPL'--'MTHFDA'--'RXNORM'
		 -- LEFT JOIN [PDDI_Databases].[dbo].[FdaDrug1stanceName] fd ON fd.FDADrug1stancePrefName = r1.str
	  --ORDER BY [Drug1_Prim_CUI],[Drug2_Prim_CUI]
	

	--  SELECT TOP 1000 [PMID]
	--	  --,[Drug1_Prim_CUI]
	--	  --,[Drug1_Prim_Name]
	--	  --,[Drug1_Rx_CUI]
	--	  ,[Drug2_Prim_CUI]
	--	  ,[Drug2_Prim_Name]
	--	  ,[Drug2_Rx_CUI] 
	--	  ,r.RXCUI
	--	  ,r.STR
	--	  ,r.*
	--	  ,[FDADrug1stancePrefName]
	--	  ,[DRUGBANK_CA]
	--	  ,[DRUGBANK_BIO2RDF]
 -- FROM [PDDI_Databases].[dbo].[SemMedDB_Mapped] s
	--LEFT JOIN [PDDI_Databases].[dbo].[RXNCONSO] r On r.RXCUI = s.Drug2_Rx_CUI
	--LEFT JOIN  [PDDI_Databases].[dbo].[FdaDrug1stanceName] fd ON fd.FDADrug1stancePrefName = r.STR
 --WHERE  SAB= 'MTHFDA'

 