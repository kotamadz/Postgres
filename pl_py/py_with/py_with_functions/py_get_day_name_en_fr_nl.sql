drop type if exists public.day_name_en_fr_nl cascade;
create type public.day_name_en_fr_nl as
(
    day_name_en text,
    day_name_fr text,
    day_name_nl text
);

drop function if exists public.py_get_day_name_en_fr_nl cascade;
create or replace function public.py_get_day_name_en_fr_nl(
    tms timestamp default null)
    
    returns day_name_en_fr_nl
    language 'plpython3u' 
    
    cost 100
    volatile 
    
as $BODY$

from datetime import datetime
tmsp = datetime.strptime(tms, '%Y-%m-%d %H:%M:%S')
day_name_en = None
day_name_fr = None
day_name_nl = None
if(tmsp is not None):
    day_name_en = tmsp.strftime("%A")
    if day_name_en == 'Sunday':
        day_name_fr = 'Dimanche'
        day_name_nl = 'Zondag'
    elif day_name_en == 'Monday':
        day_name_fr = 'Lundi'
        day_name_nl = 'Maandag'
    elif day_name_en == 'Tuesday':
        day_name_fr = 'Mardi'
        day_name_nl = 'Dinsdag' 
    elif day_name_en == 'Wednesday':
        day_name_fr = 'Mercredi'
        day_name_nl = 'Woensdag'    
    elif day_name_en == 'Thursday':
        day_name_fr = 'Jeudi'
        day_name_nl = 'Donderdag'     
    elif day_name_en == 'Friday':
        day_name_fr = 'Vendredi'
        day_name_nl = 'Vrijdag' 
    elif day_name_en == 'Saturday':
        day_name_fr = 'Samedi'
        day_name_nl = 'Zaterdag' 

return[day_name_en,day_name_fr,day_name_nl]

$BODY$;

-- select * from public.py_get_day_name_en_fr_nl('2020-02-20');

