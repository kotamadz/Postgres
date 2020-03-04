-- in arguments or input values
-- src_schema : name of source schema by default is public schema 
-- src_table  : name of source table
-- his_table  : name of history table that contains deleted row
-- trg_schema : name of target schema exemple datamart schema 
-- trg_table  : name of target table
-- bk         : business key in source table
-- out values or return values
-- deleted_row  : count rows deleted
-- inserted_row : count rows inserted
-- updated_row  : count rows updated
-- pg_exec_state   : execution state
-- pg_exec_msg     : execution message

-- Type: del_ins_upd_res
-- DROP TYPE public.del_ins_upd_res;
drop type if exists public.del_ins_upd_res cascade;
create type public.del_ins_upd_res as
(
    deleted_row  integer,
    inserted_row integer,
    updated_row  integer,
    py_exec_state   text,
    py_exec_msg     text
);

drop function if exists py_exec_merge_sql cascade;
create or replace function py_exec_merge_sql(
    src_schema text default null,
    src_table  text default null,
    his_table  text default null,
    trg_schema text default null,
    trg_table  text default null, 
    bk         text default null)
    
    returns del_ins_upd_res
    language 'plpython3u' 
    
    cost 100
    volatile 
    
as $BODY$

## variables to return
deleted_row   = None
inserted_row  = None
updated_row   = None
py_exec_state = None
py_exec_msg   = None

## constant null argurment
s_null = 'Cnull'
m_null = 'One or more argument(s) is(are) null'

## test if one ore more arguments is(are) null
if (src_schema is None) or (src_table is None) or (his_table is None) or (trg_schema is None) or (trg_table is None) or (bk is None):
    py_exec_msg   = m_null
    py_exec_state = s_null
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## constant schema  or table  or coulumn are not exists
s_schema  = '3F000'
s_table   = '42P01'
s_column  = '42703'
m_sch_src = 'schema source "' + src_schema + '" does not exist'
m_sch_trg = 'schema target "' + trg_schema + '" does not exist'
m_tbl_src = 'table source "'  + src_table  + '" does not exist'
m_tbl_trg = 'table target "'  + trg_table  + '" does not exist'
m_tbl_his = 'table history "' + his_table  + '" does not exist'
m_col_src = 'column "'   + bk + '" of relation source"'  + src_table  + '" does not exist'
m_col_trg = 'column "'   + bk + '" of relation target"'  + trg_table  + '" does not exist'

## prepare request existing schema
## $1 is schema
req_schema = "select exists(select 1 from pg_namespace where nspname = $1);"
pre_schema = plpy.prepare(req_schema, ["text"])

## test existing schema source
res_schema = plpy.execute(pre_schema, [src_schema])
if res_schema[0]['exists'] == False:
    py_exec_msg   = m_sch_src
    py_exec_state = s_schema
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## test existing schema target
res_schema = plpy.execute(pre_schema, [trg_schema])
if res_schema[0]['exists'] == False:
    py_exec_msg   = m_sch_trg
    py_exec_state = s_schema
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## prepare request of existing table
## $1 is schema, $2 is table
req_table = """
    select exists 
    (
        select 
            1
        from  information_schema.tables 
        where table_schema = $1
          and table_name   = $2
    );
 """
pre_table = plpy.prepare(req_table, ["text", "text"])

## test existing table source
res_table = plpy.execute(pre_table, [src_schema, src_table])
if res_table[0]['exists'] == False:
    py_exec_msg   = m_tbl_src
    py_exec_state = s_table
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## test existing table history
res_table = plpy.execute(pre_table, [src_schema, his_table])
if res_table[0]['exists'] == False:
    py_exec_msg   = m_tbl_his
    py_exec_state = s_table
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## test existing table target
res_table = plpy.execute(pre_table, [trg_schema, trg_table])
if res_table[0]['exists'] == False:
    py_exec_msg   = m_tbl_trg
    py_exec_state = s_table
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## prepare request of existing column
## $1 is schema, $2 is table, $3 is column 
req_column = """
    select exists 
    (
        select 
            1 
        from  information_schema.columns 
        where table_schema = $1
          and table_name   = $2
          and column_name  = $3
    );
"""
## prepare request existing table 
pre_column = plpy.prepare(req_column, ["text", "text", "text"])

## test existing column in target table 
res_table = plpy.execute(pre_column, [trg_schema, trg_table, bk])
if res_table[0]['exists'] == False:
    py_exec_msg   = m_col_trg
    py_exec_state = s_column
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## test existing column in source table 
res_table = plpy.execute(pre_column, [src_schema, src_table, bk])
if res_table[0]['exists'] == False:
    py_exec_msg   = m_col_src
    py_exec_state = s_column
    return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]

## variable to return
m_del = None
s_del = None
## delete sql
try:
    rdel = plpy.execute("select del_sql from py_get_merge_sql('{}', '{}', '{}', '{}', '{}', '{}')".format(src_schema,src_table,
                                                                                                          his_table,trg_schema,
                                                                                                          trg_table,bk))
    delex = plpy.execute(rdel[0]['del_sql'])
    deleted_row = delex.nrows()
except plpy.SPIError as e:
    s_del = e.sqlstate
    m_del = e
else:
    py_exec_state = 'C0'
    py_exec_msg   = 'success'
    
## variable to return
m_ins = None
s_ins = None
## insert sql
try:
    rins = plpy.execute("select ins_sql from py_get_merge_sql('{}', '{}', '{}', '{}', '{}', '{}')".format(src_schema,src_table,
                                                                                                          his_table,trg_schema,
                                                                                                          trg_table,bk))
    insex = plpy.execute(rins[0]['ins_sql'])
    inserted_row = insex.nrows()
except plpy.SPIError as e:
    s_ins = e.sqlstate
    m_ins = e
else:
    py_exec_state = 'C0'
    py_exec_msg   = 'success'
    
## variable to return
m_upd = None
s_upd = None
## update sql
try:
    rupd = plpy.execute("select upd_sql from py_get_merge_sql('{}', '{}', '{}', '{}', '{}', '{}')".format(src_schema,src_table,
                                                                                                          his_table,trg_schema,
                                                                                                          trg_table,bk))
    updex = plpy.execute(rupd[0]['upd_sql'])
    updated_row = insex.nrows()
except plpy.SPIError as e:
    s_upd = e.sqlstate
    m_upd = e
else:
    py_exec_state = 'C0'
    py_exec_msg   = 'success'

if (s_upd is not None) and (s_ins is not None) and (s_del is not None):
    py_exec_state = str(s_upd) + ' ' + str(s_ins) + ' ' + str(s_del)
    py_exec_msg   = str(m_upd) + ' ' + str(m_ins) + ' ' + str(m_del)
elif (s_upd is None) and (s_ins is not None) and (s_del is not None):
    py_exec_state += ' ' + str(s_ins) + ' ' + str(s_del)
    py_exec_msg   += ' ' + str(m_ins) + ' ' + str(m_del) 
elif (s_upd is not None) and (s_ins is None) and (s_del is not None):
    py_exec_state += ' ' + str(s_upd) + ' ' + str(s_del)
    py_exec_msg   += ' ' + str(m_upd) + ' ' + str(m_del) 
elif (s_upd is not None) and (s_ins is not None) and (s_del is None):
    py_exec_state += ' ' + str(s_upd) + ' ' + str(s_ins)
    py_exec_msg   += ' ' + str(m_upd) + ' ' + str(m_ins)
    
if (deleted_row is None):
    deleted_row = 0
if (inserted_row is None):
    inserted_row = 0
if (updated_row is None):
    updated_row = 0

## return result
return [deleted_row, inserted_row, updated_row, py_exec_state, py_exec_msg]
    
$BODY$;

-- select * from py_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dim_abc','id');

-- select * from py_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dim_abc','id');
-- select * from py_exec_merge_sql('publi','d_abc','d_abc_hist','datamart','dim_abc','id');
-- select * from py_exec_merge_sql('public','dabc','d_abc_hist','datamart','dim_abc','id');
-- select * from py_exec_merge_sql('public','d_abc','dabc_hist','datamart','dim_abc','id');
-- select * from py_exec_merge_sql('public','d_abc','d_abc_hist','datmart','dim_abc','id');
-- select * from py_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dimabc','id');
-- select * from py_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dim_abc','d');