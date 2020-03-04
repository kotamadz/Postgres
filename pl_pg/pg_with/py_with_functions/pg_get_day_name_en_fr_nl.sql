-- Programmed by Kotama.dz(ETL Developper/ BI Cognos)
-- in tsmp :: type timestamp or date
-- returns record with 3 fields :
-- day_name_en :: name of day in English
-- day_name_fr :: name of day in French
-- day_name_nl :: name of day in Dutch

drop function if exists public.pg_get_day_name_en_fr_nl cascade;
create or replace function public.pg_get_day_name_en_fr_nl(
	tmsp timestamp without time zone default null::timestamp without time zone,
	out day_name_en text,
	out day_name_fr text,
	out day_name_nl text)
    returns record
    language 'plpgsql'
	
as $BODY$
declare
  dd integer;
  begin
    if tmsp is null then
	   day_name_en := null;
	   day_name_fr := null;
	   day_name_nl := null;
	else
       dd := extract(dow from tmsp);
       case dd
           when 0 then
               day_name_en := 'Sunday';
	       day_name_fr := 'Dimanche';
	       day_name_nl := 'Zondag';
           when 1 then
               day_name_en := 'Monday';
	       day_name_fr := 'Lundi';
	       day_name_nl := 'Maandag';
           when 2 then
               day_name_en := 'Tuesday';
	       day_name_fr := 'Mardi';
	       day_name_nl := 'Dinsdag';
           when 3 then
               day_name_en := 'Wednesday';
	       day_name_fr := 'Mercredi';
	       day_name_nl := 'Woensdag';
           when 4 then
               day_name_en := 'Thursday';
	       day_name_fr := 'Jeudi';
	       day_name_nl := 'Donderdag';
           when 5 then
               day_name_en := 'Friday';
	       day_name_fr := 'Vendredi';
	       day_name_nl := 'Vrijdag';
           else
               day_name_en := 'Saturday';
	       day_name_fr := 'Samedi';
	      day_name_nl := 'Zaterdag';			   	    	
          end case;
	end if;
  end;
$BODY$;

-- select * from public.pg_get_day_name_en_fr_nl('2020-02-20');
