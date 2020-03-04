drop type if exists public.month_name_en_fr_nl cascade;
create type public.month_name_en_fr_nl as
(
    month_name_en text,
    month_name_fr text,
    month_name_nl text
);

drop function if exists public.py_get_month_name_en_fr_nl cascade;
create or replace function public.py_get_month_name_en_fr_nl(
    tms timestamp default null)
    
    returns month_name_en_fr_nl
    language 'plpython3u' 
    
    cost 100
    volatile 
    
as $BODY$

from datetime import datetime
tmsp = datetime.strptime(tms, '%Y-%m-%d %H:%M:%S')
month_name_en = None
month_name_fr = None
month_name_nl = None
if(tmsp is not None):
    month_name_en = tmsp.strftime("%B")
    if month_name_en == 'January':
        month_name_fr = 'Janvier'
        month_name_nl = 'Januari'
    elif month_name_en == 'February':
        month_name_fr = 'Février'
        month_name_nl = 'Februari'
    elif month_name_en == 'March':
        month_name_fr = 'Mars'
        month_name_nl = 'Maart'    
    elif month_name_en == 'April':
        month_name_fr = 'Avril'
        month_name_nl = 'April'     
    elif month_name_en == 'May':
        month_name_fr = 'Mai'
        month_name_nl = 'Mei' 
    elif month_name_en == 'June':
        month_name_fr = 'Juin'
        month_name_nl = 'Juni' 
    elif month_name_en == 'July':
        month_name_fr = 'Juillet'
        month_name_nl = 'Juli' 
    elif month_name_en == 'August':
        month_name_fr = 'Août'
        month_name_nl = 'Augustus' 
    elif month_name_en == 'September':
        month_name_fr = 'Septembre'
        month_name_nl = 'September' 
    elif month_name_en == 'October':
        month_name_fr = 'Octobre'
        month_name_nl = 'Oktober' 
    elif month_name_en == 'November':
        month_name_fr = 'Novembre'
        month_name_nl = 'November' 
    elif month_name_en == 'December':
        month_name_fr = 'Décembre'
        month_name_nl = 'December' 
        
return[month_name_en,month_name_fr,month_name_nl]

$BODY$;

-- select * from public.py_get_month_name_en_fr_nl('2020-02-20');
