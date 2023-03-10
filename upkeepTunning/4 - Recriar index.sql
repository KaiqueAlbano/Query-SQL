

/****************************************************************************************************************
TESTE PARA USAR AS PROCEDURES DE DROP E CREATE INDEX.
*****************************************************************************************************************/
BEGIN TRANSACTION

DECLARE @IndRet       int,          
	    @sIndexes     varchar(max),
        @GUID         uniqueidentifier    = null        

    --DROP INDEX 
    exec @IndRet=REG.SPR_EXE_INDEX_DROP_ALL 'dbo.teste', @sIndexes output

    insert into dbo.teste
    (
         nAging
        ,dtEntrada
        ,dtEventoStatus
        ,Aging_Execucao
        ,NmComposicaoRegua
        ,FlgObrigatorio
        ,ID_Evento
        ,Evento
        ,ID_Evento_Status
        ,Evento_Status
        ,ID_Cliente
        ,ID_ClienteTipo
        ,ID_Contrato
        ,ID_FonteOrigem
        ,FonteOrigem
        ,dtExecucao
        ,ID_Transacao
        ,DescricaoFluxo
        ,ID_Fluxo
        ,DescCritica
        ,NmArquivo
        ,dtSaida
        ,tpSaida
    )
    select 
             nAging
            ,t1.dtEntrada
            ,t1.dtEventoStatus
            ,t1.Aging_Execucao
            ,t1.NmComposicaoRegua
            ,t1.FlgObrigatorio
            ,t1.ID_Evento
            ,t1.Evento
            ,t1.ID_Evento_Status
            ,t1.Evento_Status
            ,t1.ID_Cliente
            ,t1.ID_ClienteTipo
            ,t1.ID_Contrato
            ,t1.ID_FonteOrigem
            ,t1.FonteOrigem
            ,t1.dtExecucao
            ,t1.ID_Transacao
            ,t1.DescricaoFluxo
            ,t1.ID_Fluxo
            ,t1.DescCritica
            ,t1.NmArquivo
            ,t1.dtSaida
            ,t1.tpSaida
        from #teste t1 


    --CREATE INDEX 
    exec @IndRet=REG.SPR_EXE_INDEX_CREATE_ALL 'dbo.teste', @sIndexes

COMMIT TRANSACTION



--CREATE INDEX
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
/*¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨       
' Procedure       
' Name........: [REG].[SPR_EXE_INDEX_CREATE_ALL]      
' Description.:          
'       
' AuthOR......:       
' Company.....:     
' Commentaries:        
'         
' UPDATEs        
' Date/Time  AuthOR     Description       
'  ============== ==================== ==========================================================       
'       
EXEC [REG].[SPR_EXE_INDEX_CREATE_ALL]      
     
¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨*/       
CREATE PROCEDURE [REG].[SPR_EXE_INDEX_CREATE_ALL] 
( 
    @Table_Name     varchar(256), 
    @sRetorno       varchar(4096), 
    @GUID           uniqueidentifier = null -- Número do Processo (TaskManager) 
 
) 
AS 
set nocount on   
 
    declare @cdError        int 
    declare @RowCount       int 
    declare @sExec          varchar(4096) 
    declare @sMSG           varchar(1024) 
    declare @QtdRegs        int 
    declare @iTmp           int 
    declare @iLen           int 
    declare @Index_Name     varchar(256) 
    declare @Index_Keys     varchar(256) 
    declare @dsFileGroup    varchar(256) 
    declare @tfCluster      int 
    declare @tfUnique       int 
    declare @tfPK           int 
    declare @tfIgnoreDK     int 
 
    -- Inicializa variáveis 
    select  @cdError    = 0 
    select  @iLen       = len(@sRetorno) 
    
   -- Verifica se ha algo a ser feito 
    if @sRetorno is null or @sRetorno = '' goto DropTemp 
     
    create table #tmpIndex  ( 
        Index_Name      varchar(256), 
        Index_Keys      varchar(256), 
        dsFileGroup     varchar(256), 
        tfCluster       int, 
        tfUnique        int, 
        tfPK            int, 
        tfIgnoreDK      int) 
 
 
cLoop: 
    select @iTmp = charindex('|', @sRetorno) 
    if @iTmp > 0 begin 
        select @sExec = 'insert into #tmpIndex values (' + substring(@sRetorno, 1, @iTmp-1) + ')' 
        select @sRetorno = substring(@sRetorno, @iTmp+1, @iLen-@iTmp) 
        exec (@sExec) 
        select @cdError=@@Error, @RowCount=@@RowCount 
        if @cdError<>0 begin 
            select @sMSG = '   Erro ao inserir na temporaria: '+cast(@cdError as varchar(10)) 
            goto Erro 
        end 
        goto cLoop 
    end 
    select @sExec = 'insert into #tmpIndex values (' + @sRetorno + ')' 
    exec (@sExec) 
    select @cdError=@@Error, @RowCount=@@RowCount 
    if @cdError<>0 begin 
        select @sMSG = '   Erro ao inserir na temporaria: '+cast(@cdError as varchar(10)) 
        goto Erro 
    end 
 
    select  @QtdRegs = count(*) from #tmpIndex 
    while @QtdRegs>0 begin 
        select top 1    @Index_Name     = Index_Name, 
                            @Index_Keys     = Index_Keys, 
                            @dsFileGroup    = dsFileGroup, 
                            @tfCluster      = tfCluster, 
                            @tfUnique       = tfUnique, 
                            @tfPK               = tfPK, 
                            @tfIgnoreDK     = tfIgnoreDK 
        from                #tmpIndex 
        order   by          tfCluster desc 
     
        if @tfPK = 1 begin 
            select  @sExec = 'ALTER TABLE ' + @Table_Name + ' WITH NOCHECK ADD CONSTRAINT ' + @Index_Name + ' ' 
            select  @sExec = @sExec + 'PRIMARY KEY '  
            if @tfCluster = 1       select @sExec = @sExec + 'CLUSTERED '  
            select  @sExec = @sExec + '(' + @Index_Keys + ') ' 
            select  @sExec = @sExec + 'ON [' + @dsFileGroup + ']' 
        end else begin 
            select @sExec = 'CREATE ' 
            if @tfUnique = 1        select @sExec = @sExec + 'UNIQUE '  
            if @tfCluster = 1       select @sExec = @sExec + 'CLUSTERED '  
            select @sExec = @sExec + 'INDEX ' + @Index_Name + ' on ' + @Table_Name + ' (' + @Index_Keys + ') ' 
            if @tfIgnoreDK = 1  select @sExec = @sExec + 'WITH IGNORE_DUP_KEY '  
            select @sExec = @sExec + 'ON [' + @dsFileGroup + ']' 
        end 
        exec (@sExec) 
        select @cdError=@@Error, @RowCount=@@RowCount 
        if @cdError<>0 begin 
            select @sMSG = '   Erro ao criar index: '+cast(@cdError as varchar(10)) 
            goto Erro 
        end 
        select  @sMSG = '   Index "' + @Index_Name + '" criado' 
 
        delete from #tmpIndex where Index_Name = @Index_Name 
        select @QtdRegs = @QtdRegs-1 
    end 
     
    goto DropTemp 
 
Erro: 

DropTemp: 
 
    return @cdError 



-- DROP INDEX
--------------------------------------------------------------------------------------------------
 
/*¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨       
' Procedure       
' Name........: [REG].[SPR_EXE_INDEX_CREATE_ALL]      
' Description.:          
'       
' AuthOR......:       
' Company.....:     
' Commentaries:        
'         
' UPDATEs        
' Date/Time  AuthOR     Description       
'  ============== ==================== ==========================================================       
'       
EXEC [REG].[SPR_EXE_INDEX_CREATE_ALL]      
     
¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨¨*/        
CREATE PROCEDURE [REG].[SPR_EXE_INDEX_DROP_ALL] 
( 
   @Table_Name    varchar(256),   
   @sRetorno      varchar(4096) output,   
   @GUID          uniqueidentifier = null, -- Número do Processo (TaskManager)   
   @sIndex        varchar(256) = null   
) 
as     
set nocount on    
   
   declare @cdError        int   
   declare @RowCount       int   
   declare @ASPAS          varchar(1)   
   declare @sMSG           varchar(1024)   
   declare @sExec          varchar(4096)   
   declare @QtdRegs        int   
   declare @Index_Name     varchar(256)   
   declare @Index_Keys     varchar(256)   
   declare @tfCluster      int   
   declare @tfUnique       int   
   declare @tfPK           int   
   declare @tfIgnoreDK     int   
   declare @dsFileGroup    varchar(256)   
 
------------------------------------------------------------------------------------------------------------------------------------------------- 
  -- REGRAS DE NEGOCIO 
--------------------------------------------------------------------------------------------------------------------------------------------------   
   -- Inicializa variáveis   
   select @cdError  = 0   
   select @sRetorno = ''   
   select @ASPAS  = ''''   
   
   -- Cria 1ª tabela temporaria   
   create table #tmpIndex1 (   
      Index_Name        varchar(256),   
      Index_Description varchar(1024),   
      Index_Keys        varchar(1024))   
   
   -- Recupera informações de todos os indexes   
   insert into #tmpIndex1 execute sp_helpindex @Table_Name   
   select @cdError=@@Error, @RowCount=@@RowCount   
   if @cdError<>0 begin   
      select @sMSG = '   Erro ao inserir na temporaria: '+cast(@cdError as varchar(10))   
      goto Erro   
   end   
   if @RowCount=0 begin   
      select @sRetorno=null   
      goto DropTemp   
   end   
   -- Seleciona apenas um indice especifico (quando determinal)   
   if @sIndex is not null begin   
      delete from #tmpIndex1 where Index_Name<>@sIndex   
   end   
   
   -- Cria 2ª temporaria com detalhes   
   select   Index_Name,   
            Index_Keys,   
                'PRIMARY' dsFileGroup,   
            --substring(Index_Description, patindex('%located on%', Index_Description)+11, len(Index_Description)) dsFileGroup,   
            (case charindex('nonclustered', Index_Description)    when 0 then 1 else 0 end) tfCluster,   
            (case charindex('unique', Index_Description)      when 0 then 0 else 1 end) tfUnique,   
            (case charindex('primary key', Index_Description)    when 0 then 0 else 1 end) tfPK,   
            (case charindex('ignore duplicate keys', Index_Description) when 0 then 0 else 1 end) tfIgnoreDK   
   into     #tmpIndex2   
   from     #tmpIndex1   
   order by tfCluster   
   select @cdError=@@Error, @RowCount=@@RowCount   
   if @cdError<>0 begin   
      select @sMSG = '   Erro ao inserir na temporaria: '+cast(@cdError as varchar(10))   
      goto Erro   
   end   
    -- 
   select @QtdRegs = count(*) from #tmpIndex2   
   while @QtdRegs>0 begin   
      select   top 1  
               @Index_Name    = Index_Name,   
               @Index_Keys    = Index_Keys,   
               @tfCluster     = tfCluster,   
               @tfUnique      = tfUnique,   
               @tfPK          = tfPK,   
               @tfIgnoreDK    = tfIgnoreDK,   
               @dsFileGroup   = dsFileGroup   
      from     #tmpIndex2   
 
      if @tfPK = 0 or (@tfPK = 1 and not exists( select rkeyid from sysforeignkeys where rkeyid=object_id(@Table_Name))) begin    
         if @tfPK = 1 begin   
            select @sExec = 'ALTER TABLE ' + @Table_Name + ' DROP CONSTRAINT ' + @Index_Name   
         end else begin   
            select @sExec = 'DROP INDEX ' + @Table_Name + '.' + @Index_Name   
         end   
         exec (@sExec)   
         select @cdError=@@Error, @RowCount=@@RowCount   
         if @cdError<>0 begin   
            select @sMSG = '   Erro ao excluir o index: '+cast(@cdError as varchar(10))   
            goto Erro   
         end   
 
         select @sMSG = '   Index "' + @Index_Name + '" excluido'   

         select @sRetorno = @sRetorno + @ASPAS + @Index_Name + @ASPAS + ',' +   
                              @ASPAS + @Index_Keys + @ASPAS + ',' +   
                              @ASPAS + @dsFileGroup + @ASPAS + ',' +   
                              cast(@tfCluster as varchar(1)) + ',' +   
                              cast(@tfUnique as varchar(1)) + ',' +   
                              cast(@tfPK as varchar(1)) + ',' +   
                              cast(@tfIgnoreDK as varchar(1)) + '|'   
      end   
      delete from #tmpIndex2 where Index_Name = @Index_Name   
      select @QtdRegs = @QtdRegs-1   
   end   
   if len(@sRetorno)>=2 begin   
      select @sRetorno = substring(@sRetorno,1, len(@sRetorno)-1)   
   end else begin   
      select @sRetorno = ''   
   end   
   goto DropTemp   
   
Erro:   
     
   
DropTemp:   
 
   if exists (select name from tempdb..sysobjects where id = OBJECT_ID('tempdb..#tmpIndex1') AND type = 'U') drop table #tmpIndex1   
   if exists (select name from tempdb..sysobjects where id = OBJECT_ID('tempdb..#tmpIndex2') AND type = 'U') drop table #tmpIndex2   
   
   return @cdError  

