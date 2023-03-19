--------------------------------------------------------------
-- Diferença de Reorganize e Rebuild 
-- Rebuild - Reconstrui - Mais extremo (Destrui e Recontrui) Usar Acima de 30% de fragmentação
-- Reorganize - Reorganiza  - Mais tranquilo (Reogarniza)   Usar entre 10% e 30% de fragmentação
--------------------------------------------------------------

ALTER INDEX SK01_TESTE_Fragmentacao ON dbo.TESTE_Fragmentacao REORGANIZE --SCRIPT REORGANIZE

ALTER INDEX SK01_TESTE_Fragmentacao ON dbo.TESTE_Fragmentacao REBUILD --SCRIPT REBUILD
