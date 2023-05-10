    

/*------------------------------------------------------------------------------------
QUANDO DER ERRO DE COLLATE, PODEMOS AJUSTAR NA PROPRIA BASE OU SIMPLISMTE COLOCAR NA QUERY.. 
!IMPORTANTE , NÃO FUNCION O COLLATE PARA O TIPO  INT
--------------------------------------------------------------------------------------*/

    select (t0.Qtde)                                        COLLATE Latin1_General_CI_AS as 'QtContrato',               
        ISNULL(sum(t1.DebitosVencido),0)                    COLLATE Latin1_General_CI_AS as DebitosVencido,               
        ISNULL(sum(t1.DebitosVencer),0)                     COLLATE Latin1_General_CI_AS as DebitosVencer,               
        isnull(max(CONVERT(VARCHAR(10),t1.FotoCar,103)      COLLATE Latin1_General_CI_AS),            
         max(CONVERT(VARCHAR(10),t3.data,103)))             COLLATE Latin1_General_CI_AS as FotoCar,               
        isnull(sum(t1.AgingVencido),0)                      COLLATE Latin1_General_CI_AS as AgingVencido,               
        isnull(sum(t1.AgingVencer),0)                       COLLATE Latin1_General_CI_AS as AgingVencer,               
        t0.ID_FonteOrigem                                   COLLATE Latin1_General_CI_AS as IdFonteOrigem,               
        min(convert(varchar(10),t1.PrimeiroVencido,103))    COLLATE Latin1_General_CI_AS as 'PrimeiroVencimentoVencido',               
        max(convert(varchar(10),t1.PrimentoVencer,103))     COLLATE Latin1_General_CI_AS as 'PrimeiroVencimentoVencer',               
        isnull(t1.Filtros,0)                                COLLATE Latin1_General_CI_AS as 'QtTotalEmFiltros',               
        isnull(t1.QtTotalReguaAtiva,0)                      COLLATE Latin1_General_CI_AS as QtTotalReguaAtiva,               
        isnull(t1.QtTotalReguaHistorica,0)                  COLLATE Latin1_General_CI_AS as QtTotalReguaHistorica,               
        isnull(t1.QtTotalMailAtiva,0)                       COLLATE Latin1_General_CI_AS as QtTotalMailAtiva,                       
        isnull(t1.QtTotalMailHistorica,0)                   COLLATE Latin1_General_CI_AS as QtTotalMailHistorica,               
        isnull(t1.QtTotalEntradaMail,0)                     COLLATE Latin1_General_CI_AS as QtTotalEntradaMail,               
        isnull(sum(t1.SumValorCorrigido),0)                 COLLATE Latin1_General_CI_AS as SumValorCorrigido,               
        t2.FonteOrigem                                      COLLATE Latin1_General_CI_AS as FonteOrigem,               
        isnull(min(t1.Nome),null)                           COLLATE Latin1_General_CI_AS as Nome,               
        @ID_Cliente                                         COLLATE Latin1_General_CI_AS as 'IdCliente',               
        @ID_ClienteTipo                                     COLLATE Latin1_General_CI_AS as 'IdClienteTipo'               
    from #tmp_chave t0               
    left join #tmp_resultado t1               
        on t1.ID_FonteOrigem = t0.ID_FonteOrigem               
    inner join REG.vw_FonteOrigem t2               
        on t0.ID_FonteOrigem = t2.ID_FonteOrigem               
    left join GSDB001.db_GlobalOne.dbo.TblBilling_DataCorte t3          
    /*--------------------------
    COLLATE NO JOIN
    ----------------------------*/     
        on t3.BILLING COLLATE Latin1_General_CI_AS = t2.FonteOrigem                   
    group by t0.ID_FonteOrigem,               
             t1.Filtros,               
             t1.QtTotalReguaAtiva,               
             t1.QtTotalReguaHistorica,               
             t1.QtTotalMailAtiva,                   
             t1.QtTotalMailHistorica,               
             t1.QtTotalEntradaMail,               
             t2.FonteOrigem,               
             t0.Qtde               
    order by QtContrato desc        