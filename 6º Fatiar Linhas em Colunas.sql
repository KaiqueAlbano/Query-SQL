    

/*------------------------------------------------------------------------------------
COMO FATIAS LINHAS EM COLUNAS 
--------------------------------------------------------------------------------------*/

    if exists (select name from tempdb..sysobjects where id = OBJECT_ID('tempdb..#tbl_1_4310_final') AND type = 'U') DROP TABLE #tbl_1_4310_final  
    select distinct 
        identity (int ,1,1)                       as ID, 
        s.value                                   as NCM,
        t1.[Descrição do Produto],
        t1.Alíquotas,
        t1.Alíquotas1,
        t1.Código
    into #tbl_1_4310_final  
    from #tbl_1_4310 t1 
    CROSS APPLY STRING_SPLIT(t1.ncm, '|') s
        where s.[value] <> ''
        order by  s.value

  