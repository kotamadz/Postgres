-- Programmed by Kotama.dz
-- in arguments or in put values
-- src_schema : name of source schema by default is public schema 
-- src_table  : name of source table
-- return text of information schema columns

drop function if exists pg_get_schema_columns cascade;
create or replace function public.pg_get_schema_columns(
	src_table text,
	src_schema text)
    returns text   
    language 'plpgsql'
	
    cost 100
    volatile 
as $BODY$	
declare
    sql text := '';
    rec_sche record;
	cur_sche cursor(src_schema varchar(55), src_table varchar(55)) 
    for select
        column_name,
        data_type,
        character_maximum_length,
        numeric_precision,
        numeric_scale,
        is_nullable,
        column_default
    from information_schema.columns
    where table_name   = src_table
      and table_schema = src_schema;
begin	  
    -- open the cursor
    open cur_sche(src_schema, src_table);
    loop
    -- fetch row into the film
        fetch cur_sche into rec_sche;
    -- exit when no more row to fetch
        exit when not found;
        sql := sql || ' ' || rec_sche.column_name || ' '; 
	    if rec_sche.character_maximum_length is not null then
	        sql := sql || rec_sche.data_type ||'('||rec_sche.character_maximum_length||')';
	    elseif rec_sche.numeric_scale > 0 then
	        sql := sql || rec_sche.data_type || '(' || rec_sche.numeric_precision || ',' || rec_sche.numeric_scale ||')';
	    else 
	        sql := sql || rec_sche.data_type;
	    end if;
	    if rec_sche.is_nullable = 'yes' then
	        sql := sql || ' ' || 'null';
	    else
	        sql := sql || ' ' || 'not null';
	    end if;
	    if rec_sche.column_default is not null then
	        sql := sql || ' ' || rec_sche.column_default;
	    end if;
	        sql := sql || ',' || chr(10);
    end loop;
	-- close the cursor
    close cur_sche;  
    
	return sql;
	
end;
$BODY$;
