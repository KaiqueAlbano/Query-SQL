-- BEGIN TRAN

DECLARE @Resumo TABLE (Raiz NVARCHAR(255), 
                       Raiz_Grupo NVARCHAR(255),
					   nome_grupo NVARCHAR(255),
					   Segmento_valor NVARCHAR(255),
					   Fornecedor NVARCHAR(255),
					   Analista_Responsavel NVARCHAR(255),
					   Analista_Email NVARCHAR(255),
					   Telefone_Analista NVARCHAR(255),
					   Lider NVARCHAR(255),
					   Email_Lider NVARCHAR(255),
					   old_nome_grupo NVARCHAR(255),
					   old_segmento_valor NVARCHAR(255),
					   old_fornecedor NVARCHAR(255),
					   old_Analista_Responsavel NVARCHAR(255),
					   old_Analista_Email NVARCHAR(255),
					   old_Telefone_Analista NVARCHAR(255),
					   old_Lider NVARCHAR(255),
					   old_Email_Lider NVARCHAR(255),
					   Acao NVARCHAR(20)
					   );

CREATE TABLE tmp.Resumo_ReguaCarteira_Cobranca
(
	Raiz NVARCHAR(255), 
	Raiz_Grupo NVARCHAR(255),
	nome_grupo NVARCHAR(255),
	Segmento_valor NVARCHAR(255),
	Fornecedor NVARCHAR(255),
	Analista_Responsavel NVARCHAR(255),
	Analista_Email NVARCHAR(255),
	Telefone_Analista NVARCHAR(255),
	Lider NVARCHAR(255),
	Email_Lider NVARCHAR(255),
	old_nome_grupo NVARCHAR(255),
	old_segmento_valor NVARCHAR(255),
	old_fornecedor NVARCHAR(255),
	old_Analista_Responsavel NVARCHAR(255),
	old_Analista_Email NVARCHAR(255),
	old_Telefone_Analista NVARCHAR(255),
	old_Lider NVARCHAR(255),
	old_Email_Lider NVARCHAR(255),
	Acao NVARCHAR(20)
);
/*--------------------------
MERGE
----------------------------*/
MERGE INTO reg.tblRegua_Carteira_Cobranca AS tgt  
USING (SELECT * FROM [tmp].[tblRegua_Carteira_Cobranca_23064]) as src  ON tgt.RAIZ = src.RAIZ AND tgt.RAIZ_GRUPO = src.RAIZ_GRUPO
/*--------------------------
QUANDO EXISTE NOS DOIS COM BASE NO JOIN (FAZ UPDATE.)
----------------------------*/
WHEN MATCHED THEN  
UPDATE 
   SET Nome_Grupo 	  		= iif(src.Nome_Grupo 			is not null 	, src.Nome_Grupo 			, tgt.Nome_Grupo 		   )
      ,Segmento_Valor 		= iif(src.Segmento_Valor 		is not null 	, src.Segmento_Valor 		, tgt.Segmento_Valor 	   )
	  ,Fornecedor     		= iif(src.Fornecedor 			is not null  	, src.Fornecedor 			, tgt.Fornecedor 		   )
	  ,Analista_Responsavel = iif(src.Analista_Responsavel 	is not null  	, src.Analista_Responsavel 	, tgt.Analista_Responsavel )
	  ,Analista_Email 		= iif(src.Analista_Email 		is not null  	, src.Analista_Email 		, tgt.Analista_Email 	   )
	  ,Lider 				= iif(src.Lider 			    is not null  	, src.Lider 			    , tgt.Lider 			   )
	  ,Email_Lider 			= iif(src.Email_Lider 			is not null  	, src.Email_Lider 			, tgt.Email_Lider 		   )
	  ,Telefone_Analista	= iif(src.Telefone_Analista 	is not null  	, src.Telefone_Analista 	, tgt.Telefone_Analista    )

/*--------------------------
SE NÃO EXISTIR NO DESTINO FAZO INSERT.
----------------------------*/
WHEN NOT MATCHED BY TARGET THEN  
INSERT (Raiz, Raiz_Grupo, Nome_Grupo, Segmento_Valor, Fornecedor, Analista_Responsavel, Analista_Email, Lider, Email_Lider,Telefone_Analista) 
VALUES (src.Raiz, src.Raiz_Grupo, src.Nome_Grupo, src.Segmento_Valor, src.Fornecedor, src.Analista_Responsavel, src.Analista_Email, src.Lider, src.Email_Lider,src.Telefone_Analista)  
OUTPUT inserted.Raiz, 
       inserted.Raiz_Grupo, 
	   inserted.Nome_Grupo, 
	   inserted.segmento_valor, 
	   inserted.Fornecedor, 
	   inserted.analista_responsavel, 
	   inserted.analista_email,
	   inserted.lider,
	   inserted.email_lider,
	   inserted.Telefone_Analista,
	   deleted.Nome_Grupo, 
	   deleted.segmento_valor, 
	   deleted.Fornecedor, 
	   deleted.analista_responsavel, 
	   deleted.analista_email,
	   deleted.lider,
	   deleted.email_lider,
	   deleted.Telefone_Analista,
	   $action  
	   INTO @Resumo;  

INSERT INTO tmp.Resumo_ReguaCarteira_Cobranca 
SELECT * FROM @Resumo

-- SELECT count(*) FROM tmp.Resumo_ReguaCarteira_Cobranca where acao = 'insert'

-- SELECT * FROM tmp.Resumo_ReguaCarteira_Cobranca where acao = 'update' and raiz = '08724915'

-- select * from reg.tblRegua_Carteira_Cobranca where raiz = '08724915'

-- DROP TABLE tmp.Resumo_ReguaCarteira_Cobranca

-- ROLLBACK TRAN