-- Programmed by Kotama.dz
-- in arguments or input values
-- src_schema : name of source schema by default is public schema 
-- src_table  : name of source table
-- his_table  : name of history table
-- out value
-- return sql : request to create history table

drop function if exists pg_get_his_table_sql cascade; 
create or replace function pg_get_his_table_sql(
        in  src_schema character varying,
	in  src_table  character varying,
        in  his_table  character varying)
		
		returns text 
		language 'plpgsql' 
		
as $BODY$
declare
sql text;
begin

    sql := 'drop table if exists '|| src_schema || '.' || his_table || ';'  || chr(10);
    sql := sql || 'create table ' || src_schema || '.' || his_table ||' ( ' || chr(10);
    sql := sql || ' skey integer not null,' || chr(10);
    sql := sql || (select pg_get_schema_columns(src_schema, src_table));
    sql := sql || ' delete_date timestamp null' || chr(10) || ');';
		
    return sql;
	
end;
$BODY$;

-- select pg_get_his_table_sql('public', 'd_abc', 'd_abc_hist');
						
