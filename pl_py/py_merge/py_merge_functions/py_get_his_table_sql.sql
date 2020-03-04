-- in arguments or input values
-- src_schema : name of source schema by default is public schema 
-- src_table  : name of source table
-- his_table  : name of history table
-- out value
-- return sql : request create history table

drop function if exists py_get_his_table_sql cascade; 
create or replace function py_get_his_table_sql(
    src_schema text,
    src_table text,
    his_table text)
    returns text
    language 'plpython3u'

    cost 100
    volatile
as $BODY$

    his  = plpy.execute("select py_get_schema_columns('{}', '{}')".format(src_schema, src_table))
    sql  = 'drop table if exists ' + src_schema + '.' + his_table + ';'  + chr(10)
    sql += 'create table ' + src_schema + '.' + his_table +' ( ' + chr(10)
    sql += ' skey integer not null,' + chr(10)
    sql += his[0]['py_get_schema_columns']
    sql += ' delete_date timestamp null' + chr(10) + ');'

    return sql
    
$BODY$;

-- select * from py_get_his_table_sql('public', 'd_abc', 'd_abc_hist');
