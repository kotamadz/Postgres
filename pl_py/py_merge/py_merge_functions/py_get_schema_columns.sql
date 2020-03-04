-- function: public.py_get_schema_columns(text, text)
-- drop function if exists public.py_get_schema_columns(text, text);
drop function if exists public.py_get_schema_columns cascade;
create or replace function public.py_get_schema_columns(
	src_schema text,
	src_table text)
	
    returns  text
    language 'plpython3u'

    cost 100
    volatile 

as $BODY$ 

    query = """
    select
        column_name,
        data_type,
        character_maximum_length,
        numeric_precision,
        numeric_scale,
        is_nullable,
        column_default
    from information_schema.columns
    where table_name   = $1
      and table_schema = $2
    """
    
    _columns_       = plpy.prepare(query, ["text", "text"])
    SD["_columns_"] = _columns_
    _rows_          = plpy.execute(SD["_columns_"], [ src_table, src_schema ])
    _count_         = _rows_.nrows()
    sql             = ''
	
    for i in range( 0, _count_ ):
        sql += ' ' + _rows_[i]['column_name'] + ' '
        if _rows_[i]['character_maximum_length'] != None:
            sql += _rows_[i]['data_type'] + '(' + str(_rows_[i]['character_maximum_length']) + ')'
        elif _rows_[i]['numeric_scale'] > 0:
            sql += _rows_[i]['data_type'] + '(' + str(_rows_[i]['numeric_precision']) + ',' + str(_rows_[i]['numeric_scale']) + ')'
        else:
            sql += _rows_[i]['data_type'] 
        if _rows_[i]['is_nullable'] == 'yes':
            sql += ' ' + 'null'
        else:
            sql += ' ' + 'not null'
        if _rows_[i]['column_default'] != None:
            sql += ' ' + _rows_[i]['column_default']
        sql += ',' + chr(10)
        
    return sql
	
$BODY$;

-- select public.py_get_schema_columns('public', 'd_abc');