-- funtion public.pg_get_easter_ascension_pentecost
-- returns record contains 3 fields :
-- easter day
-- ascension day
-- pentecost day
-- year between 1900 - 2099 ( 200 years )  type integer
-- drop function if exists
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

-- Exemple to use :					       			       
/*
					       
select 
   yyyy, 
  (select easter     from public.pg_get_easter_ascension_pentecost(yyyy)) as easter,
  (select ascension  from public.pg_get_easter_ascension_pentecost(yyyy)) as ascension,
  (select pentencost from public.pg_get_easter_ascension_pentecost(yyyy)) as pentencost
from years;

create table years(yyyy integer);
insert into years (yyyy) values (2010);
insert into years (yyyy) values (2011);
insert into years (yyyy) values (2012);
insert into years (yyyy) values (2013);
insert into years (yyyy) values (2014);
insert into years (yyyy) values (2015);
insert into years (yyyy) values (2016);
insert into years (yyyy) values (2017);
insert into years (yyyy) values (2018);
insert into years (yyyy) values (2019);
insert into years (yyyy) values (2020);
insert into years (yyyy) values (2021);
insert into years (yyyy) values (2022);
insert into years (yyyy) values (2023);
insert into years (yyyy) values (2024);
insert into years (yyyy) values (2025);
					       
*/
