-- type like record :: easter_ascension_pentecost
-- drop type easter_ascension_pentecost
drop type if exists easter_ascension_pentecost cascade;
create type public.easter_ascension_pentecost as (
  easter     timestamp,
  ascension  timestamp,
  pentencost timestamp
);

-- function public.py_get_easter_ascension_pentecost
-- drop function
drop function if exists public.py_get_easter_ascension_pentecost cascade;
create or replace function public.py_get_easter_ascension_pentecost(
      in yyyy  integer default null) 
    returns easter_ascension_pentecost
    language 'plpython3u'

    cost 100
    volatile 
as $BODY$    
    if yyyy == None or yyyy < 1900 or yyyy > 2099:
        easter     = None
        ascension  = None
        pentencost = None
    else:
        import math
        from datetime import timedelta, datetime
        ea = str(yyyy) + '-03-31 00:00:00'
        n  = yyyy - 1900
        a  = n % 19
        b  = math.floor( ( a * 7 + 1 ) / 19 )
        c  = ( 11 * a - b + 4 ) % 29
        d  = math.floor( n / 4 )
        e  = ( n - c + d + 31 ) % 7
        p  = 25 - c - e
        easter     = datetime.strptime(ea, '%Y-%m-%d %H:%M:%S') + timedelta(days=p)
        ascension  = easter + timedelta(days=39)
        pentencost = easter + timedelta(days=49)
    return [easter, ascension, pentencost]
	
$BODY$;

/*
select 
   yyyy, 
  (select easter     from public.py_get_easter_ascension_pentecost(yyyy)) as easter,
  (select ascension  from public.py_get_easter_ascension_pentecost(yyyy)) as ascension,
  (select pentencost from public.py_get_easter_ascension_pentecost(yyyy)) as pentencost
from years;
*/