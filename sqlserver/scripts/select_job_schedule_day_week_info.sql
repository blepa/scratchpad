-- list jobs and schedule info with daily and weekly schedules
-- jobs with a daily schedule
select
 sysjobs.name job_name
,sysjobs.enabled job_enabled
,sysschedules.name schedule_name
,sysschedules.freq_recurrence_factor
,case
 when freq_type = 4 then 'Daily'
end frequency
,
'every ' + cast (freq_interval as varchar(3)) + ' day(s)'  Days
,
case
 when freq_subday_type = 2 then ' every ' + cast(freq_subday_interval as varchar(7)) 
 + ' seconds' + ' starting at '
 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
 when freq_subday_type = 4 then ' every ' + cast(freq_subday_interval as varchar(7)) 
 + ' minutes' + ' starting at '
 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
 when freq_subday_type = 8 then ' every ' + cast(freq_subday_interval as varchar(7)) 
 + ' hours'   + ' starting at '
 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
 else ' starting at ' 
 +stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
end time
from msdb.dbo.sysjobs
inner join msdb.dbo.sysjobschedules on sysjobs.job_id = sysjobschedules.job_id
inner join msdb.dbo.sysschedules on sysjobschedules.schedule_id = sysschedules.schedule_id
where freq_type = 4

union

-- jobs with a weekly schedule
select
 sysjobs.name job_name
,sysjobs.enabled job_enabled
,sysschedules.name schedule_name
,sysschedules.freq_recurrence_factor
,case
 when freq_type = 8 then 'Weekly'
end frequency
,
replace
(
 case when freq_interval&1 = 1 then 'Sunday, ' else '' end
+case when freq_interval&2 = 2 then 'Monday, ' else '' end
+case when freq_interval&4 = 4 then 'Tuesday, ' else '' end
+case when freq_interval&8 = 8 then 'Wednesday, ' else '' end
+case when freq_interval&16 = 16 then 'Thursday, ' else '' end
+case when freq_interval&32 = 32 then 'Friday, ' else '' end
+case when freq_interval&64 = 64 then 'Saturday, ' else '' end
,', '
,''
) Days
,
case
 when freq_subday_type = 2 then ' every ' + cast(freq_subday_interval as varchar(7)) 
 + ' seconds' + ' starting at '
 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':') 
 when freq_subday_type = 4 then ' every ' + cast(freq_subday_interval as varchar(7)) 
 + ' minutes' + ' starting at '
 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
 when freq_subday_type = 8 then ' every ' + cast(freq_subday_interval as varchar(7)) 
 + ' hours'   + ' starting at '
 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
 else ' starting at ' 
 + stuff(stuff(RIGHT(replicate('0', 6) +  cast(active_start_time as varchar(6)), 6), 3, 0, ':'), 6, 0, ':')
end time
from msdb.dbo.sysjobs
inner join msdb.dbo.sysjobschedules on sysjobs.job_id = sysjobschedules.job_id
inner join msdb.dbo.sysschedules on sysjobschedules.schedule_id = sysschedules.schedule_id
where freq_type = 8
order by job_enabled desc
