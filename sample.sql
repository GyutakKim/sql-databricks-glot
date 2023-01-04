-- Semi Device ID 기준
merge into bi_dw.ck_fds_user_first_funnel_info as t1
using (
    select user_id
         , os_code
         , country_code
         , log_datetime
         , log_date
         , user_id_type_code
      from (
            select 'semi_device_id' as user_id_type_code
                 , semi_device_id as user_id
                 , os_code
                 , country_code
                 , log_datetime
                 , date(log_datetime) as log_date
                 , row_number() over (partition by semi_device_id order by log_datetime) as rn
              from bi_ods.ck_log_d_sdk_funnel_view
             where base_date = '2022-12-30'
               and funnel_name = 'tutorial'
               and funnel_sequence = 1
--                and funnel_status = 'begin' -- (킹덤에서) cdn_download begin이 안남는 경우가 있어서 조건 제거함
               and semi_device_id <> ''
               and semi_device_id is not null
          ) t
     where rn = 1
     ) as t2
   on t1.user_id_type_code = t2.user_id_type_code
  and t1.user_id = t2.user_id
 when matched and t2.log_datetime < t1.log_datetime then
        update set os_code = t2.os_code, country_code = t2.country_code, log_datetime = t2.log_datetime, log_date = t2.log_date
 when not matched then
        insert (user_id, os_code, country_code, log_datetime, log_date, user_id_type_code)
        values (t2.user_id, t2.os_code, t2.country_code, t2.log_datetime, t2.log_date, t2.user_id_type_code)
;
