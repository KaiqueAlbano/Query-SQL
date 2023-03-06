--  Script para criar um  Indice clustered 
create clustered index SK01_TestesIndices on TestesIndices(Cod) with(FILLFACTOR = 95)

--  Script para criar um  Indice clustered 
create nonclustered index SK01_TestesIndices on TestesIndices(Cod) with(FILLFACTOR = 95)