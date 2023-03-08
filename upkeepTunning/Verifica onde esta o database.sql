---------------------------------------------------------------
-- Essa Query verifica em que caminho está o banco de dados..
---------------------------------------------------------------
select a.name, b.name as 'Logical filename', b.filename 
    from sys.sysdatabases a 
    inner join sys.sysaltfiles b on a.dbid = b.dbid 
    order by A.name
