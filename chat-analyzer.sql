drop table if exists theme_statistic;

create table theme_statistic as
  
SELECT 
    c.create_dttm::date
    ,consultation_rk
    ,consultation_desc
    ,trim(both from substring(split_part(consultation_desc,',',1), '"type":([ ()0-9A-zА-я"-]+)'), '"') type
    ,trim(both from substring(split_part(consultation_desc,',',2), '"brand":([ ()0-9A-zА-я"-]+)'), '"') brand
    ,trim(both from substring(split_part(consultation_desc,',',3), '"provider":([ ()0-9A-zА-я"-]+)'), '"') provider
    ,trim(both from substring(split_part(consultation_desc,',',4), '"order":([ ()0-9A-zА-я"-]+)'), '"') ord
    ,trim(both from substring(split_part(consultation_desc,',',5), '"process":([ ()0-9A-zА-я"-]+)'), '"') process
    ,trim(both from substring(split_part(consultation_desc,',',6), '"topic":([ () ()0-9A-zА-я"-]+)'), '"') topic
    ,trim(both from substring(split_part(consultation_desc,',',7), '"subTopic":([ ()0-9A-zА-я"-]+)'), '"') subTopic
    ,trim(both from substring(split_part(consultation_desc,',',8), '"subTopic2":([ ()0-9A-zА-я"-]+)'), '"') subTopic2
    ,c.communication_rk
    ,prod_v_dds.communication.communication_id
    ,prod_v_dds.communication.communication_method_cd
    ,prod_v_dds.communication.communication_direction_cd
    ,prod_v_dds.COMMUNICATION_X_CHAT_THREAD.chat_thread_rk
    ,prod_v_dds.CHAT_THREAD.chat_thread_id
FROM prod_v_dds.consultation c, prod_v_dds.communication
left outer join prod_v_dds.COMMUNICATION_X_CHAT_THREAD on prod_v_dds.communication.communication_rk=prod_v_dds.COMMUNICATION_X_CHAT_THREAD.communication_rk
left outer join prod_v_dds.CHAT_THREAD on prod_v_dds.COMMUNICATION_X_CHAT_THREAD.chat_thread_rk=prod_v_dds.CHAT_THREAD.chat_thread_rk
WHERE true
AND c.consultation_subject_dk = 'Auto.Travel.Partners'
AND c.create_dttm::date between '2024-10-01' and '2024-11-01'
AND c.communication_rk=prod_v_dds.communication.communication_rk;
drop table if exists first_chat_analiser;
create table first_chat_analiser as
SELECT chat_thread_rk, min(create_dttm)
FROM prod_v_dds.CHAT_MESSAGE
where create_dttm::date between '2024-10-01' and '2024-11-01'
GROUP BY chat_thread_rk;
