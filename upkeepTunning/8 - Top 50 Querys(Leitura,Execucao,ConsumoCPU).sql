--------------------------------------------------------------
--TOP 50 queries executadas mais vezes (A.execution_count)
--------------------------------------------------------------

if object_id('tempdb..#Temp_Trace') is not null drop table #Temp_Trace
SELECT TOP 50  execution_count, sql_handle,last_execution_time,last_worker_time,total_worker_time
into #Temp_Trace
FROM sys.dm_exec_query_stats A
where last_elapsed_time > 20
ORDER BY A.execution_count DESC

select distinct *
from #Temp_Trace A
cross apply sys.dm_exec_sql_text (sql_handle)
order by 1 DESC

--------------------------------------------------------------
--TOP 50 queries com mais leituras (total_physical_reads + total_logical_reads + total_logical_writes)
--------------------------------------------------------------

if object_id('tempdb..#Temp_Trace') is not null drop table #Temp_Trace
SELECT TOP 50  total_physical_reads + total_logical_reads + total_logical_writes IO,
 sql_handle,execution_count,last_execution_time,last_worker_time,total_worker_time
into #Temp_Trace
FROM sys.dm_exec_query_stats A
where last_elapsed_time > 20    
ORDER BY A.total_physical_reads + A.total_logical_reads + A.total_logical_writes DESC

select distinct *
from #Temp_Trace A
cross apply sys.dm_exec_sql_text (sql_handle)
order by 1 desc

--------------------------------------------------------------
--TOP 50 queries com maior consumo de CPU (A.total_worker_time)
--------------------------------------------------------------

if object_id('tempdb..#Temp_Trace') is not null drop table #Temp_Trace
SELECT TOP 50 total_worker_time ,  sql_handle,execution_count,last_execution_time,last_worker_time
into #Temp_Trace
FROM sys.dm_exec_query_stats A
--where last_elapsed_time > 20
    --and last_execution_time > dateadd(ss,-600,getdate()) --ultimos 5 min
order by A.total_worker_time desc

select distinct *
from #Temp_Trace A
cross apply sys.dm_exec_sql_text (sql_handle)
order by 1 DESC
