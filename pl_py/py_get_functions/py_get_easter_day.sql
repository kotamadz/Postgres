-- function 
-- drop function
drop function if exists public.py_get_easter_day cascade;
create or replace function public.py_get_easter_day(yyyy integer default null)
    returns timestamp
    language 'plpython3u'

    cost 100
    volatile 
as $BODY$    
    if yyyy == None or yyyy < 1900 or yyyy > 2099:
        return None
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
        return datetime.strptime(ea, '%Y-%m-%d %H:%M:%S') + timedelta(days=p)
$BODY$;

-- select public.py_get_easter_day(2020);

/*
select 
   yyyy, 
  (select public.py_get_easter_day(yyyy)) as easter
from years;
*/
