-- function public.pg_get_julian_date
-- drop function
drop function if exists public.pg_get_julian_date cascade;
create or replace function public.pg_get_julian_date(
        in tmsp timestamp default null) 
returns integer as 
$$
declare
  yy integer; 
  mm integer;
  dd integer;
  a  integer;  
  c  integer;    
  jd integer;  
begin
	if tmsp is null then
        return null;
	else
        yy := extract(year  from tmsp); 
		mm := extract(month from tmsp);
        dd := extract(day   from tmsp);
        if dd > 2 then
		   dd := dd - 3;
		else
		   mm := mm + 9;
		   yy := yy - 1;
		end if;
		a  := floor( yy / 100 );
		c  := yy - 100 * a;
		jd := floor( 146097 / 4 ) + floor(( 1461 * c ) / 4 ) + floor( ( 153 * mm + 2 ) / 5 ) + dd + 1721119;
        return jd;
    end if;
end;  
$$ language 'plpgsql';

-- select public.pg_get_julian_date('2020-02-20 00:00:00'::timestamp);