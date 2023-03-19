BEGIN TRY


--------------------------------------------------------------------------------------------------------------------------------------------------      
-- RODAPÉ DA PROC
--------------------------------------------------------------------------------------------------------------------------------------------------      
    
END TRY       
BEGIN CATCH       
       
   IF @@TRANCOUNT>0 ROLLBACK TRANSACTION       
         
   EXEC ECAC.SPR_ERRO_XML_ADD '', @xmlERRO OUTPUT      
   DECLARE @msg  NVARCHAR(MAX) = CAST(@xmlERRO AS NVARCHAR(MAX))      
       
   RAISERROR (@msg,17,1)      
       
END CATCH;       
SET NOCOUNT OFF 
GO



/*------------------------------------------------------------------------------------
PROC RESPONSAVEL PELO TRATAMENTO DE ERRO...
--------------------------------------------------------------------------------------*/
CREATE PROCEDURE [ECAC].[SPR_ERRO_XML_ADD]
( 
    @Mensagem  varchar(500) = NULL, 
    @xmlLog    XML output
)  
AS   
BEGIN TRY    
 
DECLARE @NovoNos xml, 
        @id_ErroProcedure int  
 
DECLARE  @tb table (   
         ID bigint NOT NULL) 
 
--BEGIN TRANSACTION 
 
   --CRIA O XML PELA PRIMEIRA VEZ 
   if @xmlLog is null 
      BEGIN 
         SET @NovoNos = N'<ERRO> '                                         +  
                        '<ID_ERRO_LogProcedure>0</ID_ERRO_LogProcedure>'   + 
                        '<ERROR_NUMBER>0</ERROR_NUMBER>'                   + 
                        '<ERROR_SEVERITY>0</ERROR_SEVERITY>'               + 
                        '<ERROR_STATE>0</ERROR_STATE>'                     + 
                        '<ERROR_PROCEDURE>""</ERROR_PROCEDURE>'            +  
                        '<ERROR_LINE>0</ERROR_LINE>'                       + 
                        '<ERROR_MESSAGE></ERROR_MESSAGE>'                + 
                        '</ERRO>'; 
 
         SET @xmlLog = cast(@NovoNos as XML) 
      END 
 
   -- Limpa a mensagem 
   select @Mensagem = substring(@Mensagem,1,4000)   
   select @Mensagem = replace(replace(@Mensagem,'\',' '),'/',' ')   
   select @Mensagem = replace(@Mensagem,'''','')   
   select @Mensagem = replace(@Mensagem,'<','')   
   select @Mensagem = replace(@Mensagem,'>','')   
   select @Mensagem = replace(@Mensagem,'&','')   
 
   --CASO TENHA MENSAGEM ADICIONA AO XML /ERRO/ERROR_MESSAGE 
   IF @Mensagem <> '' AND @Mensagem <> ' ' AND @Mensagem IS NOT NULL    
      BEGIN 
         SET @NovoNos = N'<Descricao Negocio="1">' 
                        + CAST(@Mensagem AS VARCHAR(300)) + 
                        '</Descricao>';            
            
         SET @xmlLog.modify('      
                           insert sql:variable("@NovoNos")              
                           into (/ERRO/ERROR_MESSAGE)[1] ')  
      END 
 
    IF ERROR_NUMBER() IS NOT NULL and ERROR_NUMBER() <> 50000 
    BEGIN 
            insert into [ECAC].[tblErrorLogProcedure]
            ( 
		       iidHistorico, 
		       E_Data_Erro, 
		       E_ERROR_NUMBER, 
		       E_ERROR_SEVERITY, 
		       E_ERROR_STATE, 
		       E_ERROR_PROCEDURE, 
		       E_ERROR_LINE, 
		       E_ERROR_MESSAGE 
            ) output inserted.ID_ErroProcedure into @tb 
            SELECT 
		         null 
		         ,GETDATE() 
		         ,ERROR_NUMBER()    AS ErrorNumber 
		         ,ERROR_SEVERITY()  AS ErrorSeverity 
		         ,ERROR_STATE()     AS ErrorState 
		         ,ERROR_PROCEDURE() AS ErrorProcedure 
		         ,ERROR_LINE()      AS ErrorLine 
		         ,ERROR_MESSAGE()   AS ErrorMessage; 
 
        -- Retorna o id do erro que foi gravado na tabela tblErrorLogProcedure 
            select @id_ErroProcedure = ID from @tb 
 
        -- ERROR_PROCEDURE 
        SET @NovoNos = N'<ID_ERRO_LogProcedure>'+ cast(isnull(@id_ErroProcedure,0) as varchar(100)) +'</ID_ERRO_LogProcedure>';      
        set @xmlLog.modify('delete /ERRO/ID_ERRO_LogProcedure') 
        SET @xmlLog.modify('insert (sql:variable("@NovoNos")) before (/ERRO/ERROR_NUMBER)[1] ') 
 
    END 
 
    IF ERROR_NUMBER() IS NOT null 
    BEGIN 
        -- ERROR_NUMBER 
        SET @NovoNos = N'<ERROR_NUMBER>'+ cast(isnull(ERROR_NUMBER(),0) as varchar(100)) +'</ERROR_NUMBER>';      
        set @xmlLog.modify('delete /ERRO/ERROR_NUMBER') 
        SET @xmlLog.modify('insert (sql:variable("@NovoNos")) before (/ERRO/ERROR_SEVERITY)[1] ') 
 
        -- ERROR_SEVERITY 
        SET @NovoNos = N'<ERROR_SEVERITY>'+ cast(isnull(ERROR_SEVERITY(),0) as varchar(100)) +'</ERROR_SEVERITY>';      
        set @xmlLog.modify('delete /ERRO/ERROR_SEVERITY') 
        SET @xmlLog.modify('insert (sql:variable("@NovoNos")) before (/ERRO/ERROR_STATE)[1] ') 
 
        -- ERROR_STATE 
        SET @NovoNos = N'<ERROR_STATE>'+ cast(isnull(ERROR_STATE(),0) as varchar(100)) +'</ERROR_STATE>';      
        set @xmlLog.modify('delete /ERRO/ERROR_STATE') 
        SET @xmlLog.modify('insert (sql:variable("@NovoNos")) before (/ERRO/ERROR_PROCEDURE)[1] ') 
 
        -- ERROR_PROCEDURE 
        SET @NovoNos = N'<ERROR_PROCEDURE>'+ cast(isnull(ERROR_PROCEDURE(),'""') as varchar(128)) +'</ERROR_PROCEDURE>';      
        set @xmlLog.modify('delete /ERRO/ERROR_PROCEDURE') 
        SET @xmlLog.modify('insert (sql:variable("@NovoNos")) before (/ERRO/ERROR_LINE)[1] ') 
 
        -- ERROR_PROCEDURE 
        SET @NovoNos = N'<ERROR_LINE>'+ cast(isnull(ERROR_LINE(),0) as varchar(100)) +'</ERROR_LINE>';      
        set @xmlLog.modify('delete /ERRO/ERROR_LINE') 
        SET @xmlLog.modify('insert (sql:variable("@NovoNos")) before (/ERRO/ERROR_MESSAGE)[1] ') 
 
        --Descricao DO ERRO 
        SET @NovoNos = N'<Descricao Negocio="0">' 
                    + cast(isnull(ERROR_MESSAGE(),'""') as varchar(4000)) + 
                    '</Descricao>';            
        
        SET @xmlLog.modify('      
                        insert sql:variable("@NovoNos")              
                        into (/ERRO/ERROR_MESSAGE)[1] ')  
    END 
       

END TRY BEGIN CATCH    

   return 1   
   
END CATCH;    
set nocount off   
return 0   
   
   
GO
