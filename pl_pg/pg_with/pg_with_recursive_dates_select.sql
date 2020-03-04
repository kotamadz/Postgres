-- with recursive
with recursive r_dates(
        skey, 
	year, 
	day_key, 
	date_ue, 
	date2_ue, 
	date_us, 
	date2_us, 
	date_julian, 
	date_long_fr, 
	date_long_nl, 
	date_full_fr, 
	date_full_nl,
	day_name_fr,
	day_name_nl,
	month_name_fr,
	month_name_nl,
	day_in_week,
	day_in_month,
	day_in_year,
	week_in_month,
	week_in_year,
	month,
	quater,
	half,
	iseasterday,
	isascensionday,
        ispentecostday
	) 
as (
  select    -- anchor member
    1::integer,                                                                    -- type integer
    1999::integer,                                                                 -- type integer
    to_char(cast('1999-12-31' as timestamp), 'yyyymmdd'),                          -- type string
    to_char(cast('1999-12-31' as timestamp), 'dd/mm/yyyy') || ' 00:00:00',         -- type string
    to_char(cast('1999-12-31' as timestamp), 'dd-mm-yyyy') || ' 00:00:00',         -- type string
    cast('1999-12-31' as timestamp),                                               -- type date 
    to_char(cast('1999-12-31' as timestamp), 'yyyy/mm/dd') || ' 00:00:00',         -- type string
	py_get_julian_date(cast('1999-12-31' as timestamp)),                       -- type integer
	(select date_long_fr  from py_get_date_long_en_fr_nl('1999-12-31')),       -- type string
	(select date_long_nl  from py_get_date_long_en_fr_nl('1999-12-31')),       -- type string
	(select date_full_fr  from py_get_date_full_en_fr_nl('1999-12-31')),       -- type string
	(select date_full_nl  from py_get_date_full_en_fr_nl('1999-12-31')),       -- type string
	(select day_name_fr   from py_get_day_name_en_fr_nl('1999-12-31')),        -- type string
	(select day_name_nl   from py_get_day_name_en_fr_nl('1999-12-31')),        -- type string
	(select month_name_fr from py_get_month_name_en_fr_nl('1999-12-31')),      -- type string
	(select month_name_nl from py_get_month_name_en_fr_nl('1999-12-31')),      -- type string
	case
	    when extract(dow from timestamp '1999-12-31') = 0 then 7               -- type integer
		else extract(dow from timestamp '1999-12-31')
	end,
    extract(day from timestamp '1999-12-31'),                                      -- type integer   
    extract(doy from timestamp '1999-12-31'),	                                   -- type integer 
	to_char(timestamp '1999-12-31', 'W')::integer,                             -- type integer
	to_char(timestamp '1999-12-31', 'WW')::integer,                            -- type integer
	extract(month from timestamp '1999-12-31')::integer,                       -- type integer
	extract(quarter from timestamp '1999-12-31')::integer,                     -- type integer
	case                                                                       -- type integer
	    when extract(quarter from timestamp '1999-12-31') in ('1','2') then 1::integer  
		else 2::integer
	end,
	case                                                                       -- type boolean
        when (select easter from py_get_easter_ascension_pentecost(1999::integer)) = cast('1999-12-31' as timestamp) then 't'::boolean
		else 'f'::boolean
	end,
	case                                                                       -- type boolean
        when (select ascension from py_get_easter_ascension_pentecost(1999::integer)) = cast('1999-12-31' as timestamp) then 't'::boolean
		else 'f'::boolean
	end,
	case                                                                       -- type boolean
        when (select pentencost from py_get_easter_ascension_pentecost(1999::integer)) = cast('1999-12-31' as timestamp) then 't'::boolean
		else 'f'::boolean
	end
  union all
  select      -- recursive member
    r_dates.skey + 1, 
	cast(extract(year from r_dates.date_us + interval '1 day' ) as integer),
	to_char(r_dates.date_us + interval '1 day', 'yyyymmdd'),
	to_char(r_dates.date_us + interval '1 day', 'dd/mm/yyyy') || ' 00:00:00',
	to_char(r_dates.date_us + interval '1 day', 'dd-mm-yyyy') || ' 00:00:00',
	r_dates.date_us + interval '1 day',
	to_char(r_dates.date_us + interval '1 day', 'yyyy/mm/dd') || ' 00:00:00',
	py_get_julian_date(r_dates.date_us + interval '1 day'),
	(select date_long_fr  from py_get_date_long_en_fr_nl(r_dates.date_us + interval '1 day')),  
	(select date_long_nl  from py_get_date_long_en_fr_nl(r_dates.date_us + interval '1 day')),
	(select date_full_fr  from py_get_date_full_en_fr_nl(r_dates.date_us + interval '1 day')),
	(select date_full_nl  from py_get_date_full_en_fr_nl(r_dates.date_us + interval '1 day')),
	(select day_name_fr   from py_get_day_name_en_fr_nl(r_dates.date_us + interval '1 day')),
	(select day_name_nl   from py_get_day_name_en_fr_nl(r_dates.date_us + interval '1 day')),
	(select month_name_fr from py_get_month_name_en_fr_nl(r_dates.date_us + interval '1 day')),
	(select month_name_nl from py_get_month_name_en_fr_nl(r_dates.date_us + interval '1 day')),
	case
	    when extract(dow from r_dates.date_us + interval '1 day') = 0 then 7
		else extract(dow from r_dates.date_us + interval '1 day')
	end,
	extract(day from r_dates.date_us + interval '1 day'),
	extract(doy from r_dates.date_us + interval '1 day'),
	to_char(r_dates.date_us + interval '1 day', 'W')::integer,
	to_char(r_dates.date_us + interval '1 day', 'WW')::integer,
    extract(month from r_dates.date_us + interval '1 day')::integer,
	extract(quarter from r_dates.date_us + interval '1 day')::integer,
	case 
	    when extract(quarter from r_dates.date_us + interval '1 day') in ('1','2') then 1::integer  -- type integer
		else 2::integer
	end,
	case
        when (select easter from py_get_easter_ascension_pentecost(cast(extract(year from r_dates.date_us + interval '1 day' ) as integer))) = cast('1999-12-31' as timestamp) then 't'::boolean
		else 'f'::boolean
	end,
	case
        when (select ascension from py_get_easter_ascension_pentecost(cast(extract(year from r_dates.date_us + interval '1 day' ) as integer)))	= cast('1999-12-31' as timestamp) then 't'::boolean
		else 'f'::boolean
	end,
	case
        when (select pentencost from py_get_easter_ascension_pentecost(cast(extract(year from r_dates.date_us + interval '1 day' ) as integer))) = cast('1999-12-31' as timestamp) then 't'::boolean
		else 'f'::boolean
	end 
 from r_dates
 where r_dates.year < 2021   -- termination condition(20 years)
)
select  
        skey, 
	year, 
	day_key, 
	date_ue, 
	date2_ue, 
	date_us, 
	date2_us, 
	date_julian, 
	date_long_fr, 
	date_long_nl, 
	date_full_fr, 
	date_full_nl,
	day_name_fr,
	day_name_nl,
	month_name_fr,
	month_name_nl,
	day_in_week,
	day_in_month,
	day_in_year,
	week_in_month,
	week_in_year,
	month,
	quater,
	half,
	iseasterday,
	isascensionday,
        ispentecostday 
from r_dates;

