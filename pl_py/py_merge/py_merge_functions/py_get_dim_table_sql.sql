-- function: public.py_get_dim_table_sql(text, text, text, text)
-- drop function public.py_get_dim_table_sql(text, text, text, text);
drop function if exists public.py_get_dim_table_sql cascade;
create or replace function public.py_get_dim_table_sql(
    src_schema text,
    src_table text,
    trg_schema text,
    trg_table text)
    returns text
    language 'plpython3u'

    cost 100
    volatile 
as $body$ 

    dim  = plpy.execute("select py_get_schema_columns('{}', '{}')".format(src_schema, src_table))
    sql  = 'drop table if exists '+ trg_schema + '.' + trg_table + ' cascade;'  + chr(10)
    sql += 'create table ' + trg_schema + '.' + trg_table +' ( ' + chr(10)
    sql += ' skey serial primary key,' + chr(10)
    sql += dim[0]['py_get_schema_columns']
    sql += ' eff_date timestamp   not null default localtimestamp,' + chr(10)
    sql += ' end_date timestamp   null,' + chr(10);
    sql += ' cre_date timestamp   not null default localtimestamp,' + chr(10)
    sql += ' udt_date timestamp   not null default localtimestamp,' + chr(10)
    sql += ' curr_ind boolean  default true not null' + chr(10) + ');'
    
    return sql

$body$;

-- select * from py_get_dim_table_sql('public', 'd_abc', 'datamart', 'dim_abc');