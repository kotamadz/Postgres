drop type if exists public.date_full_en_fr_nl cascade;
create type public.date_full_en_fr_nl as
(
    date_full_en text,
    date_full_fr text,
    date_full_nl text
);

drop function if exists public.py_get_date_full_en_fr_nl cascade;
create or replace function public.py_get_date_full_en_fr_nl(
    tms timestamp default null)
    
    returns date_full_en_fr_nl
    language 'plpython3u' 
    
    cost 100
    volatile 
    
as $BODY$

from datetime import datetime
tmsp = datetime.strptime(tms, '%Y-%m-%d %H:%M:%S')
date_full_en = None
date_full_fr = None
date_full_nl = None
if(tmsp is not None):
    dl    = plpy.execute("select * from py_get_date_long_en_fr_nl('{}')".format(tmsp)) 
    dl_en = dl[0]['date_long_en']
    dl_fr = dl[0]['date_long_fr']
    dl_nl = dl[0]['date_long_nl']
    
    dy    = plpy.execute("select * from py_get_day_name_en_fr_nl('{}')".format(tmsp))
    dy_en = dy[0]['day_name_en']
    dy_fr = dy[0]['day_name_fr']
    dy_nl = dy[0]['day_name_nl']
    
    date_full_en = dy_en + ' ' + dl_en
    date_full_fr = dy_fr + ' ' + dl_fr
    date_full_nl = dy_nl + ' ' + dl_nl
    
return[date_full_en,date_full_fr,date_full_nl]

$BODY$;

-- select * from public.py_get_date_full_en_fr_nl('2020-02-20');
