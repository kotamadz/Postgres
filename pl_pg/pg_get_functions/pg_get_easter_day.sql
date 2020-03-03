-- Programmed by Kotama.dz
-- function public.pg_get_easter_day
-- returns easter day
-- year between 1900-2099 (200 years) type integer
-- drop function if exists
drop function if exists public.pg_get_easter_day cascade;
create or replace function public.pg_get_easter_day(
        in yyyy integer default null) 
returns timestamp as 
$$
declare
  yy varchar(4);
  dd varchar(10);
  ea varchar(19);
  n  integer;    
  a  integer;    
  b  integer;   
  c  integer;    
  d  integer;
  e  integer;
  p  integer; 
begin
	if yyyy > 2099 or yyyy < 1900 or yyyy is null then
           return null;
	else
           yy := cast(yyyy as varchar(4));
           ea := yy || '-03-31';
           n  := yyyy - 1900;
           a  := n % 19;
           b  := floor( ( a * 7 + 1 ) / 19 );
           c  := ( 11 * a - b + 4 ) % 29;
           d  := floor( n / 4 );
           e  := ( n - c + d + 31 ) % 7;
           p  := 25 - c - e;
	   ea := to_char(to_date(ea, 'yyyy-mm-dd')  + p, 'yyyy-mm-dd') || ' 00:00:00';
        return cast(ea as timestamp);
    end if;
end;  
$$ language 'plpgsql';

-- Exemple to use
-- select pg_get_easter_day(2020);
