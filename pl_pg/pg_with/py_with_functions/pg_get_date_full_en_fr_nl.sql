-- Programmed by Kotama.dz(ETL Developper/ BI Cognos)
-- in tsmp :: type timestamp or date
-- returns record with 3 fields :
-- date_full_en :: full date in English
-- date_full_fr :: full date in French
-- date_full_nl :: full date in Dutch

drop function if exists public.pg_get_date_full_en_fr_nl cascade;
create or replace function public.pg_get_date_full_en_fr_nl(
	tmsp timestamp without time zone default null::timestamp without time zone,
	out date_full_en text,
	out date_full_fr text,
	out date_full_nl text)
    returns record
    language 'plpgsql'
	
as $BODY$
declare
  df text;
  fl text;
  dn text;
  nl text;
  de text;
  el text;
  begin
    if tmsp is null then
	   date_full_en := null;
	   date_full_fr := null;
	   date_full_nl := null;
    else
	   fl := (select date_full_fr from pg_get_date_full_en_fr_nl(tmsp));
	   df := (select day_name_fr  from pg_get_day_name_en_fr_nl(tmsp));
		
	   nl := (select date_full_nl from pg_get_date_full_en_fr_nl(tmsp));
	   dn := (select day_name_nl  from pg_get_day_name_en_fr_nl(tmsp));
		
	   el := (select date_full_en from pg_get_date_full_en_fr_nl(tmsp));
	   de := (select day_name_en  from pg_get_day_name_en_fr_nl(tmsp));
		
	   date_full_en := de || ' ' || el;
	   date_full_fr := df || ' ' || fl;
	   date_full_nl := dn || ' ' || nl;  
		
    end if;
  end;
$BODY$;

-- select * from public.pg_get_date_full_en_fr_nl('2020-02-20');
