-- Programmed by Kotama.dz
-- function function public.py_get_julian_date
-- drop function
drop function if exists public.py_get_julian_date cascade; 
create or replace function public.py_get_julian_date(tms timestamp default null)
    returns integer
    language 'plpython3u'

    cost 100
    volatile 
	
as $BODY$    
    from datetime import datetime
    tmsp = datetime.strptime(tms, '%Y-%m-%d %H:%M:%S')
    if tmsp == None:
        return None
    else:
        import math
        yy = int('{:02d}'.format(tmsp.year))
        mm = int('{:02d}'.format(tmsp.month))
        dd = int('{:02d}'.format(tmsp.day))
        if dd > 2:
            dd -= 3
        else:
            mm += 9
            yy -= 1
        a = math.floor(yy/100)
        c = yy - 100 * a
        j = math.floor( 146097 / 4 ) + math.floor( ( 1461 * c ) / 4) + math.floor( ( 153 * mm + 2) / 5) + dd + 1721119
        return j
$BODY$;

-- select public.pg_get_julian_date('2020-02-20 00:00:00');
