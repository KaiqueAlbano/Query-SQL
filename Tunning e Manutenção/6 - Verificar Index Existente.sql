if (not exists (select null from  sys.indexes  where name = 'IDX_MVL_PRODUTO_CAR'))
 begin 
    CREATE INDEX [IDX_MVL_PRODUTO_CAR] ON db_GlobalOne_Telefonica.dbo.tblSTAGE_MVL_PRODUTO_CAR (ID_Contrato asc,ID_FonteOrigem asc) 
end