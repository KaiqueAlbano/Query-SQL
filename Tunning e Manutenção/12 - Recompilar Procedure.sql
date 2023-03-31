--------------------------------------------------------------
-- Recompila a PROC. Porque o primeiro plano de execucao , ele usa para todos.
--Problema!!! Vai consumir CPU para compilar a toda execução
--------------------------------------------------------------

sp_recompile stpTeste_QueryStore

-- Se metade das execuções de produção usar um parametro para scan e metade para seek, a solução é com OPTION(RECOMPILE)
CREATE procedure stpTeste_QueryStore @Cod int
AS
    select Cod,Data
    into #Temp
    from TestesIndices
    where Cod = @Cod 
OPTION(RECOMPILE)