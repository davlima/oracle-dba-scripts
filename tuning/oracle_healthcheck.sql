-- ============================================================================
-- ORACLE HEALTH CHECK
-- File    : oracle_healthcheck.sql
-- Purpose : Diagnostic health check for Oracle Database 19c+
-- Run as  : SYSDBA
-- Usage   : SQL> @oracle_healthcheck.sql
--
-- Notes:
--   * Read-only: this script does NOT change database configuration.
--   * Does not require AWR/ASH/ADDM.
--   * Thresholds are intentionally conservative and should be adapted to
--     the workload/baseline of each environment.
--   * Alert log is queried through V$DIAG_ALERT_EXT (ADR).
-- ============================================================================

set echo off
set feedback on
set heading on
set pagesize 100
set linesize 220
set trimspool on
set tab off
set verify off
set serveroutput on size unlimited
set long 200000
set longchunksize 200000
set sqlprompt "SQL> "
set timing off
set termout on

whenever sqlerror continue

column report_file new_value report_file noprint
column db_name new_value db_name noprint
column instance_name new_value instance_name noprint

select lower(
         sys_context('USERENV','DB_NAME') || '_' ||
         sys_context('USERENV','INSTANCE_NAME') || '_' ||
         to_char(sysdate,'YYYYMMDD_HH24MISS') || '_healthcheck.log'
       ) report_file
from dual;

select sys_context('USERENV','DB_NAME') db_name,
       sys_context('USERENV','INSTANCE_NAME') instance_name
from dual;

spool &report_file

prompt
prompt ============================================================================
prompt                     ORACLE DATABASE HEALTH CHECK
prompt ============================================================================
prompt

select 'Database' parameter, sys_context('USERENV','DB_NAME') value from dual
union all
select 'Instance', sys_context('USERENV','INSTANCE_NAME') from dual
union all
select 'Host', host_name from v$instance
union all
select 'Version', version from v$instance
union all
select 'Startup', to_char(startup_time,'YYYY-MM-DD HH24:MI:SS') from v$instance
union all
select 'Instance status', status from v$instance
union all
select 'Database role', database_role from v$database
union all
select 'Open mode', open_mode from v$database
union all
select 'Log mode', log_mode from v$database;

prompt
prompt ============================================================================
prompt [1] DATABASE / INSTANCE STATUS
prompt ============================================================================

select instance_name,
       status,
       database_status,
       active_state,
       archiver,
       logins
from v$instance;

select name,
       db_unique_name,
       open_mode,
       database_role,
       log_mode,
       flashback_on
from v$database;

prompt
prompt ============================================================================
prompt [2] TABLESPACE CAPACITY
prompt ============================================================================

column status format a10
column tablespace_name format a35
column used_pct format 990.00

select df.tablespace_name,
       round((df.bytes - nvl(fs.free_bytes,0)) / df.bytes * 100,2) used_pct,
       round(df.bytes/1024/1024) total_mb,
       round(nvl(fs.free_bytes,0)/1024/1024) free_mb,
       case
         when (df.bytes - nvl(fs.free_bytes,0))/df.bytes*100 >= 95 then 'CRITICAL'
         when (df.bytes - nvl(fs.free_bytes,0))/df.bytes*100 >= 85 then 'WARNING'
         else 'OK'
       end status
from
(
  select tablespace_name, sum(bytes) bytes
  from dba_data_files
  group by tablespace_name
) df
left join
(
  select tablespace_name, sum(bytes) free_bytes
  from dba_free_space
  group by tablespace_name
) fs
on fs.tablespace_name = df.tablespace_name
order by used_pct desc;

prompt
prompt --- TEMP TABLESPACE ---

select tablespace_name,
       round(tablespace_size/1024/1024) total_mb,
       round(free_space/1024/1024) free_mb,
       round((tablespace_size-free_space)/tablespace_size*100,2) used_pct,
       case
         when (tablespace_size-free_space)/tablespace_size*100 >= 95 then 'CRITICAL'
         when (tablespace_size-free_space)/tablespace_size*100 >= 85 then 'WARNING'
         else 'OK'
       end status
from dba_temp_free_space
order by used_pct desc;

prompt
prompt ============================================================================
prompt [3] MEMORY - SGA
prompt ============================================================================

select name,
       round(value/1024/1024,2) mb
from v$sga
order by value desc;

select component,
       current_size/1024/1024 current_mb,
       min_size/1024/1024 min_mb,
       max_size/1024/1024 max_mb,
       oper_count,
       last_oper_type,
       last_oper_mode
from v$sga_dynamic_components
where current_size > 0
order by current_size desc;

prompt
prompt --- SGA TARGET / MEMORY PARAMETERS ---

select name,
       display_value,
       isdefault,
       issys_modifiable
from v$system_parameter
where name in (
  'memory_target',
  'memory_max_target',
  'sga_target',
  'sga_max_size',
  'pga_aggregate_target',
  'pga_aggregate_limit',
  'shared_pool_size',
  'db_cache_size',
  'large_pool_size',
  'java_pool_size'
)
order by name;

prompt
prompt ============================================================================
prompt [4] MEMORY - PGA
prompt ============================================================================

select name,
       case
         when unit = 'bytes' then round(value/1024/1024,2)
         else value
       end value,
       unit
from v$pgastat
where name in (
  'aggregate PGA target parameter',
  'aggregate PGA auto target',
  'total PGA allocated',
  'total PGA inuse',
  'maximum PGA allocated',
  'over allocation count',
  'cache hit percentage'
)
order by name;

prompt
prompt --- PGA STATUS ---

select case
         when max(case when name='over allocation count' then value end) > 0
           then 'WARNING'
         else 'OK'
       end status,
       max(case when name='over allocation count' then value end) over_allocation_count,
       max(case when name='cache hit percentage' then value end) cache_hit_pct
from v$pgastat;

prompt
prompt ============================================================================
prompt [5] CPU / DB TIME
prompt ============================================================================

select metric_name,
       round(value,2) value,
       metric_unit,
       begin_time,
       end_time
from v$sysmetric
where metric_name in (
  'Host CPU Utilization (%)',
  'Database CPU Time Ratio',
  'Database Wait Time Ratio'
)
order by metric_name;

prompt
prompt --- CPU / DB TIME CUMULATIVE ---

select stat_name,
       round(value/1000000,2) seconds
from v$sys_time_model
where stat_name in (
  'DB time',
  'DB CPU'
)
order by stat_name;

prompt
prompt ============================================================================
prompt [6] WAIT EVENTS
prompt ============================================================================

column event format a55
column avg_wait_ms format 990.00

select event,
       total_waits,
       round(time_waited/100,2) total_wait_seconds,
       case when total_waits > 0
            then round((time_waited*10)/total_waits,2)
       end avg_wait_ms,
       wait_class
from v$system_event
where wait_class <> 'Idle'
order by time_waited desc
fetch first 20 rows only;

prompt
prompt --- USER I/O LATENCY SUMMARY ---

select round(sum(time_waited)*10/nullif(sum(total_waits),0),2) avg_user_io_ms,
       case
         when sum(total_waits) = 0 then 'NO DATA'
         when sum(time_waited)*10/nullif(sum(total_waits),0) >= 20 then 'CRITICAL'
         when sum(time_waited)*10/nullif(sum(total_waits),0) >= 10 then 'WARNING'
         else 'OK'
       end status
from v$system_event
where wait_class = 'User I/O';

prompt
prompt ============================================================================
prompt [7] FILE I/O
prompt ============================================================================

column file_name format a90

select f.file_name,
       round(i.phyrds) physical_reads,
       round(i.phywrts) physical_writes,
       round(i.readtim*10/nullif(i.phyrds,0),2) read_ms,
       round(i.writetim*10/nullif(i.phywrts,0),2) write_ms
from v$iostat_file i
join dba_data_files f
  on f.file_id = i.file_no
where i.filetype_name = 'Data File'
order by (i.phyrds + i.phywrts) desc
fetch first 20 rows only;

prompt
prompt --- TEMP I/O ---

select file_name,
       round(phyrds) physical_reads,
       round(phywrts) physical_writes,
       round(readtim*10/nullif(phyrds,0),2) read_ms,
       round(writetim*10/nullif(phywrts,0),2) write_ms
from v$tempstat
order by (phyrds + phywrts) desc;

prompt
prompt ============================================================================
prompt [8] TOP SQL - BUFFER GETS
prompt ============================================================================

column sql_id format a13
column sql_text format a100

select sql_id,
       executions,
       buffer_gets,
       round(buffer_gets/nullif(executions,0),2) avg_buffer_gets,
       round(elapsed_time/1000000,2) elapsed_sec,
       round(cpu_time/1000000,2) cpu_sec,
       substr(replace(replace(sql_text,chr(10),' '),chr(13),' '),1,100) sql_text
from v$sql
where executions > 0
order by buffer_gets desc
fetch first 20 rows only;

prompt
prompt ============================================================================
prompt [9] TOP SQL - ELAPSED TIME
prompt ============================================================================

select sql_id,
       executions,
       round(elapsed_time/1000000,2) elapsed_sec,
       round(elapsed_time/1000/nullif(executions,0),2) avg_elapsed_ms,
       round(cpu_time/1000000,2) cpu_sec,
       buffer_gets,
       substr(replace(replace(sql_text,chr(10),' '),chr(13),' '),1,100) sql_text
from v$sql
where executions > 0
order by elapsed_time desc
fetch first 20 rows only;

prompt
prompt ============================================================================
prompt [10] TOP SQL - CPU
prompt ============================================================================

select sql_id,
       executions,
       round(cpu_time/1000000,2) cpu_sec,
       round(cpu_time/1000/nullif(executions,0),2) avg_cpu_ms,
       round(elapsed_time/1000000,2) elapsed_sec,
       buffer_gets,
       substr(replace(replace(sql_text,chr(10),' '),chr(13),' '),1,100) sql_text
from v$sql
where executions > 0
order by cpu_time desc
fetch first 20 rows only;

prompt
prompt ============================================================================
prompt [11] LOCKS / BLOCKING SESSIONS
prompt ============================================================================

column username format a20
column machine format a30
column program format a35
column blocking_session format 999999

select s.sid,
       s.serial#,
       s.username,
       s.status,
       s.event,
       s.seconds_in_wait,
       s.blocking_session,
       s.blocking_session_status,
       substr(s.machine,1,30) machine,
       substr(s.program,1,35) program,
       s.sql_id
from v$session s
where s.blocking_session is not null
order by s.seconds_in_wait desc;

prompt
prompt --- BLOCKING SESSION SUMMARY ---

select count(*) blocked_sessions,
       count(distinct blocking_session) blocking_sessions,
       case
         when count(*) >= 10 then 'CRITICAL'
         when count(*) > 0 then 'WARNING'
         else 'OK'
       end status
from v$session
where blocking_session is not null;

prompt
prompt --- ACTIVE TRANSACTIONS ---

select s.sid,
       s.serial#,
       s.username,
       t.start_time,
       round((sysdate - to_date(t.start_time,'MM/DD/YY HH24:MI:SS'))*86400) elapsed_seconds,
       s.sql_id
from v$transaction t
join v$session s on s.taddr = t.addr
order by t.start_time;

prompt
prompt ============================================================================
prompt [12] OPTIMIZER STATISTICS
prompt ============================================================================

prompt --- TABLES WITH STALE STATISTICS ---

select owner,
       table_name,
       stale_stats,
       last_analyzed
from dba_tab_statistics
where owner not in ('SYS','SYSTEM','OUTLN','XDB','CTXSYS','MDSYS','ORDSYS','WMSYS')
  and stale_stats = 'YES'
order by owner, table_name
fetch first 100 rows only;

select count(*) stale_table_stats
from dba_tab_statistics
where owner not in ('SYS','SYSTEM','OUTLN','XDB','CTXSYS','MDSYS','ORDSYS','WMSYS')
  and stale_stats = 'YES';

prompt
prompt --- INDEXES WITH STALE STATISTICS ---

select owner,
       index_name,
       table_name,
       stale_stats,
       last_analyzed
from dba_ind_statistics
where owner not in ('SYS','SYSTEM','OUTLN','XDB','CTXSYS','MDSYS','ORDSYS','WMSYS')
  and stale_stats = 'YES'
order by owner, table_name, index_name
fetch first 100 rows only;

select count(*) stale_index_stats
from dba_ind_statistics
where owner not in ('SYS','SYSTEM','OUTLN','XDB','CTXSYS','MDSYS','ORDSYS','WMSYS')
  and stale_stats = 'YES';

prompt
prompt ============================================================================
prompt [13] OBJECTS / SPACE PRESSURE
prompt ============================================================================

select owner,
       segment_type,
       count(*) objects,
       round(sum(bytes)/1024/1024/1024,2) gb
from dba_segments
where owner not in ('SYS','SYSTEM','OUTLN','XDB','CTXSYS','MDSYS','ORDSYS','WMSYS')
group by owner, segment_type
order by gb desc
fetch first 30 rows only;

prompt
prompt ============================================================================
prompt [14] REDO / COMMIT PROFILE
prompt ============================================================================

select name,
       value
from v$sysstat
where name in (
  'user commits',
  'user rollbacks',
  'redo size',
  'redo writes',
  'redo synch writes',
  'redo synch time'
)
order by name;

prompt
prompt --- REDO SYNC DIAGNOSTIC ---

select case
         when max(case when name='redo synch writes' then value end) = 0
           then 'NO DATA'
         when (
           max(case when name='redo synch time' then value end) * 10
           / nullif(max(case when name='redo synch writes' then value end),0)
         ) >= 10
           then 'WARNING'
         else 'OK'
       end status,
       max(case when name='redo synch writes' then value end) redo_synch_writes,
       round(
         max(case when name='redo synch time' then value end) * 10
         / nullif(max(case when name='redo synch writes' then value end),0),
         2
       ) avg_redo_sync_ms
from v$sysstat;

prompt
prompt ============================================================================
prompt [15] CACHE / LIBRARY CACHE - INFORMATIONAL ONLY
prompt ============================================================================

prompt NOTE: Hit ratios are not used as primary health criteria.
prompt Investigate SQL, DB Time, waits, CPU, I/O and contention first.

select namespace,
       gets,
       gethits,
       round(gethits/nullif(gets,0)*100,2) get_hit_pct,
       pins,
       pinhits,
       round(pinhits/nullif(pins,0)*100,2) pin_hit_pct,
       reloads,
       invalidations
from v$librarycache
order by namespace;

prompt
prompt --- ROW CACHE ---

select parameter,
       gets,
       getmisses,
       round(getmisses/nullif(gets,0)*100,2) miss_pct
from v$rowcache
where gets > 0
order by getmisses desc
fetch first 30 rows only;

prompt
prompt ============================================================================
prompt [16] IMPORTANT INSTANCE PARAMETERS
prompt ============================================================================

select name,
       display_value,
       isdefault,
       issys_modifiable
from v$system_parameter
where name in (
  'optimizer_mode',
  'optimizer_adaptive_plans',
  'optimizer_adaptive_statistics',
  'statistics_level',
  'cursor_sharing',
  'open_cursors',
  'processes',
  'sessions',
  'parallel_degree_policy',
  'parallel_max_servers',
  'filesystemio_options',
  'disk_asynch_io',
  'db_writer_processes',
  'log_buffer',
  'result_cache_max_size'
)
order by name;

prompt
prompt --- NON-DEFAULT INITIALIZATION PARAMETERS ---

select name,
       display_value,
       isdefault,
       issys_modifiable
from v$system_parameter
where isdefault = 'FALSE'
order by name;

prompt
prompt ============================================================================
prompt [17] PROCESS / SESSION PRESSURE
prompt ============================================================================

select resource_name,
       current_utilization,
       max_utilization,
       initial_allocation,
       limit_value,
       round(current_utilization/nullif(
         case
           when regexp_like(limit_value,'^[0-9]+$') then to_number(limit_value)
         end,0)*100,2) utilization_pct
from v$resource_limit
where resource_name in ('processes','sessions')
order by resource_name;

prompt
prompt ============================================================================
prompt [18] ARCHIVE / RECOVERY PRESSURE
prompt ============================================================================

select dest_id,
       status,
       target,
       destination,
       error,
       fail_sequence,
       applied_seq#
from v$archive_dest
where status <> 'INACTIVE'
order by dest_id;

prompt
prompt --- ARCHIVE GAP ---

select *
from v$archive_gap;

prompt
prompt ============================================================================
prompt [19] ADR / ALERT LOG - LAST 24 HOURS
prompt ============================================================================

prompt ADR diagnostic data is stored outside the database under DIAGNOSTIC_DEST.
prompt V$DIAG_ALERT_EXT exposes alert-log messages to the database.

select originating_timestamp,
       message_type,
       message_level,
       substr(message_text,1,180) message_text
from v$diag_alert_ext
where originating_timestamp >= systimestamp - interval '24' hour
  and (
       upper(message_text) like '%ORA-%'
       or upper(message_text) like '%ERROR%'
       or upper(message_text) like '%WARNING%'
       or upper(message_text) like '%INCIDENT%'
      )
order by originating_timestamp desc
fetch first 100 rows only;

prompt
prompt --- CRITICAL ORACLE ERRORS IN LAST 24 HOURS ---

select count(*) critical_alert_messages,
       case
         when count(*) > 0 then 'WARNING'
         else 'OK'
       end status
from v$diag_alert_ext
where originating_timestamp >= systimestamp - interval '24' hour
  and (
       upper(message_text) like '%ORA-00600%'
       or upper(message_text) like '%ORA-07445%'
       or upper(message_text) like '%ORA-04031%'
       or upper(message_text) like '%ORA-04036%'
       or upper(message_text) like '%ORA-01578%'
       or upper(message_text) like '%ORA-01652%'
       or upper(message_text) like '%ORA-01653%'
       or upper(message_text) like '%ORA-01654%'
      );

prompt
prompt ============================================================================
prompt [20] CONTAINER INFORMATION
prompt ============================================================================

select con_id,
       name,
       open_mode,
       restricted
from v$containers
order by con_id;

prompt
prompt ============================================================================
prompt [21] FINAL AUTOMATED DIAGNOSIS
prompt ============================================================================

set serveroutput on

declare
  l_host_cpu       number := 0;
  l_pga_over       number := 0;
  l_io_ms          number := 0;
  l_blocked        number := 0;
  l_stale_tables   number := 0;
  l_stale_indexes  number := 0;
  l_alerts         number := 0;
  l_redo_ms        number := 0;
  l_process_pct    number := 0;
  l_session_pct    number := 0;
  l_critical       number := 0;
  l_warning        number := 0;
begin
  begin
    select value into l_host_cpu
    from v$sysmetric
    where metric_name = 'Host CPU Utilization (%)'
      and rownum = 1;
  exception when others then l_host_cpu := 0;
  end;

  begin
    select nvl(max(value),0)
    into l_pga_over
    from v$pgastat
    where name = 'over allocation count';
  exception when others then l_pga_over := 0;
  end;

  begin
    select nvl(sum(time_waited)*10/nullif(sum(total_waits),0),0)
    into l_io_ms
    from v$system_event
    where wait_class = 'User I/O';
  exception when others then l_io_ms := 0;
  end;

  begin
    select count(*)
    into l_blocked
    from v$session
    where blocking_session is not null;
  exception when others then l_blocked := 0;
  end;

  begin
    select count(*)
    into l_stale_tables
    from dba_tab_statistics
    where owner not in ('SYS','SYSTEM','OUTLN','XDB','CTXSYS','MDSYS','ORDSYS','WMSYS')
      and stale_stats = 'YES';
  exception when others then l_stale_tables := 0;
  end;

  begin
    select count(*)
    into l_stale_indexes
    from dba_ind_statistics
    where owner not in ('SYS','SYSTEM','OUTLN','XDB','CTXSYS','MDSYS','ORDSYS','WMSYS')
      and stale_stats = 'YES';
  exception when others then l_stale_indexes := 0;
  end;

  begin
    select count(*)
    into l_alerts
    from v$diag_alert_ext
    where originating_timestamp >= systimestamp - interval '24' hour
      and (
        upper(message_text) like '%ORA-00600%'
        or upper(message_text) like '%ORA-07445%'
        or upper(message_text) like '%ORA-04031%'
        or upper(message_text) like '%ORA-04036%'
        or upper(message_text) like '%ORA-01578%'
        or upper(message_text) like '%ORA-01652%'
        or upper(message_text) like '%ORA-01653%'
        or upper(message_text) like '%ORA-01654%'
      );
  exception when others then l_alerts := 0;
  end;

  begin
    select
      nvl(
        max(case when name='redo synch time' then value end) * 10
        / nullif(max(case when name='redo synch writes' then value end),0),
        0
      )
    into l_redo_ms
    from v$sysstat;
  exception when others then l_redo_ms := 0;
  end;

  begin
    select nvl(max(
      case
        when resource_name='processes'
        then current_utilization /
             nullif(to_number(regexp_substr(limit_value,'^[0-9]+')),0)*100
        else 0
      end),0)
    into l_process_pct
    from v$resource_limit;
  exception when others then l_process_pct := 0;
  end;

  begin
    select nvl(max(
      case
        when resource_name='sessions'
        then current_utilization /
             nullif(to_number(regexp_substr(limit_value,'^[0-9]+')),0)*100
        else 0
      end),0)
    into l_session_pct
    from v$resource_limit;
  exception when others then l_session_pct := 0;
  end;

  dbms_output.put_line(chr(10));
  dbms_output.put_line('============================================================');
  dbms_output.put_line(' FINAL HEALTH CHECK');
  dbms_output.put_line('============================================================');

  dbms_output.put_line('Host CPU                : '||round(l_host_cpu,2)||'%');
  dbms_output.put_line('PGA over allocation     : '||l_pga_over);
  dbms_output.put_line('User I/O avg latency    : '||round(l_io_ms,2)||' ms');
  dbms_output.put_line('Blocked sessions        : '||l_blocked);
  dbms_output.put_line('Stale table statistics  : '||l_stale_tables);
  dbms_output.put_line('Stale index statistics  : '||l_stale_indexes);
  dbms_output.put_line('Critical ADR alerts/24h : '||l_alerts);
  dbms_output.put_line('Avg redo sync time      : '||round(l_redo_ms,2)||' ms');
  dbms_output.put_line('Processes utilization   : '||round(l_process_pct,2)||'%');
  dbms_output.put_line('Sessions utilization    : '||round(l_session_pct,2)||'%');

  dbms_output.put_line(chr(10)||'--- FINDINGS ---');

  if l_alerts > 0 then
    dbms_output.put_line('[CRITICAL] Critical ORA errors/incidents found in ADR in the last 24 hours.');
    l_critical := l_critical + 1;
  end if;

  if l_blocked >= 10 then
    dbms_output.put_line('[CRITICAL] 10 or more blocked sessions detected.');
    l_critical := l_critical + 1;
  elsif l_blocked > 0 then
    dbms_output.put_line('[WARNING ] Blocking/blocked sessions detected.');
    l_warning := l_warning + 1;
  end if;

  if l_host_cpu >= 90 then
    dbms_output.put_line('[CRITICAL] Host CPU >= 90%. Investigate CPU consumers and DB CPU.');
    l_critical := l_critical + 1;
  elsif l_host_cpu >= 80 then
    dbms_output.put_line('[WARNING ] Host CPU >= 80%. Correlate with DB CPU and wait classes.');
    l_warning := l_warning + 1;
  end if;

  if l_pga_over > 0 then
    dbms_output.put_line('[WARNING ] PGA over-allocation detected. Review PGA sizing/workarea demand.');
    l_warning := l_warning + 1;
  end if;

  if l_io_ms >= 20 then
    dbms_output.put_line('[CRITICAL] User I/O average latency >= 20 ms.');
    l_critical := l_critical + 1;
  elsif l_io_ms >= 10 then
    dbms_output.put_line('[WARNING ] User I/O average latency >= 10 ms.');
    l_warning := l_warning + 1;
  end if;

  if l_redo_ms >= 10 then
    dbms_output.put_line('[WARNING ] Average redo synchronization time >= 10 ms.');
    l_warning := l_warning + 1;
  end if;

  if l_stale_tables > 0 then
    dbms_output.put_line('[WARNING ] Stale table statistics detected: '||l_stale_tables);
    l_warning := l_warning + 1;
  end if;

  if l_stale_indexes > 0 then
    dbms_output.put_line('[WARNING ] Stale index statistics detected: '||l_stale_indexes);
    l_warning := l_warning + 1;
  end if;

  if l_process_pct >= 90 then
    dbms_output.put_line('[CRITICAL] Processes utilization >= 90%.');
    l_critical := l_critical + 1;
  elsif l_process_pct >= 80 then
    dbms_output.put_line('[WARNING ] Processes utilization >= 80%.');
    l_warning := l_warning + 1;
  end if;

  if l_session_pct >= 90 then
    dbms_output.put_line('[CRITICAL] Sessions utilization >= 90%.');
    l_critical := l_critical + 1;
  elsif l_session_pct >= 80 then
    dbms_output.put_line('[WARNING ] Sessions utilization >= 80%.');
    l_warning := l_warning + 1;
  end if;

  if l_critical = 0 and l_warning = 0 then
    dbms_output.put_line('[OK      ] No configured critical/warning thresholds were triggered.');
  end if;

  dbms_output.put_line(chr(10)||'--- PRIORITY ---');

  if l_critical > 0 then
    dbms_output.put_line('1. Resolve CRITICAL findings before performance tuning.');
    dbms_output.put_line('2. Correlate affected sessions, SQL_IDs, waits and ADR evidence.');
  end if;

  if l_warning > 0 then
    dbms_output.put_line('3. Investigate WARNING findings using workload evidence.');
  end if;

  dbms_output.put_line('4. Prioritize SQL and contention before blind parameter changes.');
  dbms_output.put_line('5. Establish a workload baseline before changing memory/I/O parameters.');

  dbms_output.put_line(chr(10)||'Totals: CRITICAL='||l_critical||' WARNING='||l_warning);
  dbms_output.put_line('============================================================');
end;
/

prompt
prompt ============================================================================
prompt END OF HEALTH CHECK
prompt ============================================================================
prompt Output file: &report_file
prompt ============================================================================

spool off

exit
