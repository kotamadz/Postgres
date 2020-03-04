-- in arguments or input values
-- src_schema : name of source schema by default is public schema 
-- src_table  : name of source table
-- his_table  : name of history table that contains deleted row
-- trg_schema : name of target schema exemple datamart schema 
-- trg_table  : name of target table
-- is_drop    : boolean value by default is false, 
--              if is true drop tables if are exist
-- out values or return values is a table
-- pg_exec_state : execution state
-- pg_exec_msg   : execution message
-- sql_req       : executed request

drop function if exists py_exec_create_tables cascade;
create or replace function py_exec_create_tables(
    src_schema text default null,
    src_table  text default null,
    his_table  text default null,
    trg_schema text default null,
    trg_table  text default null, 
    is_drop boolean default false)
    
    returns table(py_exec_state text, py_exec_msg text, sql_req text)
    language 'plpython3u' 
    
    cost 100
    volatile 
    
as $BODY$

## variables to return
dim_s = None
dim_m = None
dim_r = None
his_s = None
his_m = None
his_r = None

## constant schema  or table are not exists
s_schema = '3F000'
s_table  = '42P01'
m_schema = 'schema source "' + src_schema + '" does not exist'
t_schema = 'schema target "' + trg_schema + '" does not exist'
m_table  = 'table source "'  + src_table  + '" does not exist'
r_notexi = None

## constant is drop table
s_drop = 'Cdrop'
h_drop = 'table "' + his_table + '" does  exist'
t_drop = 'table "' + trg_table + '" does  exist'
r_drop = None

## exists table
_dim = False
_his = False

## test existing schema source
req_schema = "select exists(select 1 from pg_namespace where nspname = $1);"
pre_schema = plpy.prepare(req_schema, ["text"])
res_schema = plpy.execute(pre_schema, [src_schema])
if res_schema[0]['exists'] == False:
    dim_s, his_s = s_schema, s_schema
    dim_m, his_m = m_schema, m_schema
    dim_r, his_r = r_notexi, r_notexi
    return ( [ dim_s, dim_m, dim_r ], [ his_s, his_m, his_r ] )

## test existing table source
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
res_table = plpy.execute(pre_table, [src_schema, src_table])
if res_table[0]['exists'] == False:
    dim_s, his_s = s_table, s_table
    dim_m, his_m = m_table, m_table
    dim_r, his_r = r_notexi, r_notexi
    return ( [ dim_s, dim_m, dim_r ], [ his_s, his_m, his_r ] )

## test existing schema target
req_schema = "select exists(select 1 from pg_namespace where nspname = $1);"
pre_schema = plpy.prepare(req_schema, ["text"])
res_schema = plpy.execute(pre_schema, [trg_schema])
if res_schema[0]['exists'] == False:
    dim_s, his_s = s_schema, s_schema
    dim_m, his_m = t_schema, t_schema
    dim_r, his_r = r_notexi, r_notexi
    return ( [ dim_s, dim_m, dim_r ], [ his_s, his_m, his_r ] )

## try create dimension table
req_dim = """
    select exists 
    (
        select 
            1
        from  information_schema.tables 
        where table_schema = $1
          and table_name   = $2
    );
 """
pre_dim = plpy.prepare(req_dim, ["text", "text"])
res_dim = plpy.execute(pre_dim, [trg_schema, trg_table])

if res_dim[0]['exists'] == True and is_drop == False:
    _dim = True
else:
    try:
        dim = plpy.execute("select py_get_dim_table_sql('{}', '{}', '{}', '{}')".format(src_schema,
                                                                                        src_table,
                                                                                        trg_schema,
                                                                                        trg_table))
        dim_r = dim[0]['py_get_dim_table_sql']
        plpy.execute(dim[0]['py_get_dim_table_sql'])
    except plpy.SPIError as e:
        dim_s = e.sqlstate
        dim_m = e
    else:
        dim_s = 'C0'
        dim_m = 'success'

# try create history table
req_his = """
    select exists 
    (
        select 
            1
        from  information_schema.tables 
        where table_schema = $1
          and table_name   = $2
    );
 """
pre_his = plpy.prepare(req_dim, ["text", "text"])
res_his = plpy.execute(pre_dim, [src_schema, his_table])

if res_his[0]['exists'] == True and is_drop == False:
    _his = True
else:
    try:
        his = plpy.execute("select py_get_his_table_sql('{}', '{}', '{}')".format(src_schema,
                                                                                  src_table,
                                                                                  his_table))
        his_r = his[0]['py_get_his_table_sql']
        plpy.execute(his[0]['py_get_his_table_sql'])
    except plpy.SPIError as e:
        his_s = e.sqlstate
        his_m = e
    else:
        his_s = 'C0'
        his_m = 'success'

## return table       
if _dim == False and _his == False:
    return ( [ dim_s, dim_m, dim_r ], [ his_s, his_m, his_r ] )
elif _dim == True and _his == True:
    return ( [ s_drop, t_drop, r_drop ], [ s_drop, h_drop, r_drop ] )
elif _dim == False and _his == True:
    return ( [ dim_s, dim_m, dim_r ], [ s_drop, h_drop, r_drop ] )
elif _dim == True and _his == False: 
    return ( [ s_drop, t_drop, r_drop ], [ his_s, his_m, his_r ] )
    
$BODY$;

-- select * from py_exec_create_tables('public', 'd_abc_hist', 'dim_abc');
-- select * from py_exec_create_tables('public','d_abc','d_abc_hist','damart',  'dim_abc');
-- select * from py_exec_create_tables('pub',   'd_abc','d_abc_hist','datamart','dim_abc');
-- select * from py_exec_create_tables('public','dabc', 'd_abc_hist','datamart','dim_abc');
-- select * from py_exec_create_tables('public','d_abc', 'd_abc_hist','datamart','dim_abc');