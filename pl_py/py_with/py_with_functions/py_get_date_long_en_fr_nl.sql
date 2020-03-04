drop type if exists public.date_long_en_fr_nl cascade;
create type public.date_long_en_fr_nl as
(
    date_long_en text,
    date_long_fr text,
    date_long_nl text
);

drop function if exists public.py_get_date_long_en_fr_nl cascade;
create or replace function public.py_get_date_long_en_fr_nl(
    tms timestamp default null)
    
    returns date_long_en_fr_nl
    language 'plpython3u' 
    
    cost 100
    volatile 
    
as $BODY$

from datetime import datetime
tmsp = datetime.strptime(tms, '%Y-%m-%d %H:%M:%S')
date_long_en = None
date_long_fr = None
date_long_nl = None
if(tmsp is not None):
    yy = tmsp.strftime("%Y")
    dd = tmsp.strftime("%d")
    mm = plpy.execute("select * from py_get_month_name_en_fr_nl('{}')".format(tmsp)) 
    en = mm[0]['month_name_en']
    fr = mm[0]['month_name_fr']
    nl = mm[0]['month_name_nl']
    date_long_en = dd + ' ' + en + ' ' + yy
    date_long_fr = dd + ' ' + fr + ' ' + yy
    date_long_nl = dd + ' ' + nl + ' ' + yy
    
return[date_long_en,date_long_fr,date_long_nl]

$BODY$;

-- select * from public.py_get_date_long_en_fr_nl('2020-02-20');
