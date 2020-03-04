create or replace function public.pg_get_date_long_en_fr_nl(
	tmsp timestamp without time zone default null::timestamp without time zone,
	out date_long_en text,
	out date_long_fr text,
	out date_long_nl text)
    returns record
    language 'plpgsql'
	
as $BODY$
declare
  dd integer;
  yy integer;
  mf text;
  mn text;
  me text;
  begin
    if tmsp is null then
	   date_long_en := null;
	   date_long_fr := null;
	   date_long_nl := null;
	else
        dd := extract(day  from tmsp);
		yy := extract(year from tmsp);
		mf := (select month_name_fr from pg_get_month_name_en_fr_nl(tmsp));
		mn := (select month_name_nl from pg_get_month_name_en_fr_nl(tmsp));
		me := (select month_name_en from pg_get_month_name_en_fr_nl(tmsp));
	    date_long_en := dd || ' ' || me || ' ' || yy;
	    date_long_fr := dd || ' ' || mf || ' ' || yy;
	    date_long_nl := dd || ' ' || mn || ' ' || yy;      
	end if;
  end;
$BODY$;

-- select * from public.pg_get_date_long_en_fr_nl('2020-02-20');