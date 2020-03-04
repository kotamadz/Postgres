-- Programmed by Kotama.dz
-- in arguments or input values
-- src_schema : name of source schema by default is public schema 
-- src_table  : name of source table
-- trg_schema : name of target schema exemple datamart schema 
-- trg_table  : name of target table
-- out value
-- return sql : request to create dimention table 

drop function if exists pg_get_dim_table_sql cascade;
create or replace function pg_get_dim_table_sql(
        in  src_schema character varying,
		in  src_table  character varying,
		in  trg_schema character varying,
		in  trg_table  character varying)
		
		returns text 
		language 'plpgsql' 
		
as $body$
declare
    sql text;
begin 

    sql := 'drop table if exists '|| trg_schema || '.' || trg_table || ' cascade;'  || chr(10);
    sql := sql || 'create table ' || trg_schema || '.' || trg_table ||' ( ' || chr(10);
    sql := sql || ' skey serial primary key,' || chr(10);
    sql := sql || (select pg_get_schema_columns(src_schema, src_table));
    sql := sql || ' eff_date timestamp   not null default localtimestamp,' || chr(10);
    sql := sql || ' end_date timestamp   null,' || chr(10);
    sql := sql || ' cre_date timestamp   not null default localtimestamp,' || chr(10);
    sql := sql || ' udt_date timestamp   not null default localtimestamp,' || chr(10);
    sql := sql || ' curr_ind boolean  default true not null' || chr(10);
    sql := sql ||  ');'; 
		
    return sql;
	
end;
$body$;

-- select * from pg_get_dim_table_sql('public', 'd_abc', 'datamart', 'dim_abc');
