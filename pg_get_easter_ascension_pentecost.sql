-- funtion public.pg_get_easter_ascension_pentecost
-- drop function
drop function if exists public.pg_get_easter_ascension_pentecost cascade;
create or replace function public.pg_get_easter_ascension_pentecost(
	yyyy integer default null::integer,
	out easter timestamp without time zone,
	out ascension timestamp without time zone,
	out pentencost timestamp without time zone)
    returns record
    language 'plpgsql'

    cost 100
    volatile 
as $body$
  begin
    if yyyy > 2099 or yyyy < 1900 or yyyy is null then
	   easter     := null;
	   ascension  := null;
	   pentencost := null;
	else
       easter     := (select pg_get_easter_day(yyyy));
	   ascension  := easter +  interval '39 day';
	   pentencost := easter +  interval '49 day';
	end if;
  end;
$body$;

/*
select 
   yyyy, 
  (select easter     from public.pg_get_easter_ascension_pentecost(yyyy)) as easter,
  (select ascension  from public.pg_get_easter_ascension_pentecost(yyyy)) as ascension,
  (select pentencost from public.pg_get_easter_ascension_pentecost(yyyy)) as pentencost
from years;
*/