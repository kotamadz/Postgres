create or replace function public.pg_get_month_name_en_fr_nl(
	tmsp timestamp without time zone default null::timestamp without time zone,
	out month_name_en text,
	out month_name_fr text,
	out month_name_nl text)
    returns record
    language 'plpgsql'
	
as $BODY$
declare
  dd integer;
  begin
    if tmsp is null then
	   month_name_en := null;
	   month_name_fr := null;
	   month_name_nl := null;
	else
        dd := extract(month from tmsp);
        case dd
            when 1 then
               month_name_en := 'January';
			   month_name_fr := 'Janvier';
			   month_name_nl := 'Januari';
            when 2 then
               month_name_en := 'February';
			   month_name_fr := 'Février';
			   month_name_nl := 'Februari';
            when 3 then
               month_name_en := 'March';
			   month_name_fr := 'Mars';
			   month_name_nl := 'Maart';
            when 4 then
               month_name_en := 'April';
			   month_name_fr := 'Avril';
			   month_name_nl := 'April';
            when 5 then
               month_name_en := 'May';
			   month_name_fr := 'Mai';
			   month_name_nl := 'Mei';
            when 6 then
               month_name_en := 'June';
			   month_name_fr := 'Juin';
			   month_name_nl := 'Juni';
            when 7 then
               month_name_en := 'July';
			   month_name_fr := 'Juillet';
			   month_name_nl := 'Juli';
            when 8 then
               month_name_en := 'August';
			   month_name_fr := 'Août';
			   month_name_nl := 'Augustus';
            when 9 then
               month_name_en := 'September';
			   month_name_fr := 'Septembre';
			   month_name_nl := 'September';
            when 10 then
               month_name_en := 'October';
			   month_name_fr := 'Octobre';
			   month_name_nl := 'Oktober';
            when 11 then
               month_name_en := 'November';
			   month_name_fr := 'Novembre';
			   month_name_nl := 'November';
            else
               month_name_en := 'December';
			   month_name_fr := 'Décembre';
			   month_name_nl := 'December';			   	    	
        end case;
	end if;
  end;
$BODY$;

-- select * from pg_get_month_name_en_fr_nl('2020-02-20');
