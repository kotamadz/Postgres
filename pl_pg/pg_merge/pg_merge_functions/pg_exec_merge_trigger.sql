-- Programmed by Kotama.dz
-- exec merge trigger
-- TG_ARGV array of arguments passed by trigger

drop function if exists pg_exec_merge_trigger;
create or replace function pg_exec_merge_trigger()

        returns  trigger 		
        language 'plpgsql' 
		
as $BODY$
begin
    perform pg_exec_merge_sql(TG_ARGV[0], TG_ARGV[1], TG_ARGV[2], TG_ARGV[3], TG_ARGV[4], TG_ARGV[5]);
    return new;
end;
$BODY$;
