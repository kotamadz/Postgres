-- Type: del_ins_upd_sql
-- DROP TYPE public.del_ins_upd_sql;
drop type if exists public.del_ins_upd_sql cascade;
create type public.del_ins_upd_sql as
(
	del_sql text,
	ins_sql text,
	upd_sql text
);

drop function if exists public.py_get_merge_sql cascade;
create or replace function public.py_get_merge_sql(
	src_schema text,
	src_table text,
	his_table text,
	trg_schema text,
	trg_table text,
	bk text)
	
    returns  del_ins_upd_sql
    language 'plpython3u'

    cost 100
    volatile 

as $BODY$ 

    query = """
    select
        column_name
    from information_schema.columns
    where table_name   = $1
      and table_schema = $2
    """

    _columns_       = plpy.prepare(query, ["text", "text"])
    SD["_columns_"] = _columns_
    _rows_          = plpy.execute(SD["_columns_"], [ src_table, src_schema ])
    _count_         = _rows_.nrows()
    sql             = ''
    del_fil         = ''
    ins_fil         = ''
    upd_fil         = ''
    ins_upd         = ''

    for i in range( 0,_count_ ):
        del_fil+= '    trg.' + _rows_[i]['column_name'] + ',' + chr(10)
        ins_fil+= '    src.' + _rows_[i]['column_name'] + ',' + chr(10)
        ins_upd+= '    '     + _rows_[i]['column_name'] + ',' + chr(10)
        if _rows_[i]['column_name'] != bk:
            upd_fil+='         trg.' + _rows_[i]['column_name'] + ' <> src.' + _rows_[i]['column_name'] +' or' + chr(10)

    ins_fil = ins_fil[0:len(ins_fil)-2]
    ins_upd = ins_upd[0:len(ins_upd)-2]
    upd_fil = upd_fil[0:len(upd_fil)-3]

    ## del request
    del_sql = 'with del as ('  + chr(10)
    del_sql+= '  delete from ' + trg_schema + '.' + trg_table +  ' as trg   ' + chr(10)
    del_sql+= '  where trg.'   + bk + ' not in (select src.'  + bk + ' from ' + src_schema + '.' + src_table 
    del_sql+= ' as src) '      + chr(10)
    del_sql+= '  returning * ' + chr(10)     + ' ) ' + chr(10)
    del_sql+= ' insert into '  + src_schema  + '.'   + his_table + chr(10) 
    del_sql+= ' select      '  + chr(10)     + '    trg.skey, '  + chr(10)
    del_sql+= del_fil + '    localtimestamp' + chr(10) + ' from del as trg;'

    ## insert request
    ins_sql = 'with ins as ( '  + chr(10)
    ins_sql+= '   select ' + bk + ' from ' + src_schema   + '.' + src_table + ' as src where src.' + bk + ' not in (select '
    ins_sql+= 'trg.'       + bk + ' from ' + trg_schema + '.'   + trg_table + ' as trg)' + chr(10) + ' ) '    + chr(10)
    ins_sql+= ' insert into '   + trg_schema + '.' + trg_table  + ' (' + chr(10)
    ins_sql+= ins_upd   + chr(10) + ')' + chr(10)
    ins_sql+= 'select ' + chr(10)
    ins_sql+= ins_fil   + chr(10)
    ins_sql+='from '    + src_schema + '.' + src_table + ' as src where src.' + bk + ' in (select ' + bk +' from ins);'

    ## update request
    upd_sql = 'with upd as ( ' + chr(10)
    upd_sql+= '   update ' + trg_schema  + '.' + trg_table + ' as trg ' + chr(10)
    upd_sql+= '   set trg.curr_ind = false,' + chr(10)
    upd_sql+= '       trg.end_date = localtimestamp' + chr(10)
    upd_sql+= '   where trg.'   + bk + ' in '     + chr(10)
    upd_sql+= '    ( '          + chr(10)
    upd_sql+= '       select '  + chr(10)
    upd_sql+= '          src.'  + bk + chr(10)
    upd_sql+= '       from '    + src_schema + '.' + src_table + ' as src ' + chr(10)
    upd_sql+= '       where '   + chr(10)
    upd_sql+= upd_fil + chr(10) + '     ) '  + chr(10)
    upd_sql+= '     and trg.curr_ind = true' + chr(10)
    upd_sql+= '     returning * ' + chr(10)  + ')' + chr(10)
    upd_sql+= 'insert into ' + trg_schema    + '.' + trg_table + '(' + chr(10)
    upd_sql+= ins_upd   + chr(10)  + ')'     + chr(10)
    upd_sql+= 'select ' + chr(10)  + ins_fil + chr(10)
    upd_sql+= 'from ' + src_schema + '.' + src_table + ' as src where src.' + bk + ' in (select ' + bk + ' from upd);'
    
    return [del_sql, ins_sql, upd_sql]
	
$BODY$;

-- select * from public.py_get_merge_sql('public', 'd_abc', 'his_abc', 'datamart', 'dim_abc', 'id');