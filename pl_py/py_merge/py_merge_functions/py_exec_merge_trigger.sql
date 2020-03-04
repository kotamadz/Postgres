-- exec merge trigger 
-- TD["args"][n-1] array of arguments passed by trigger
drop function if exists py_exec_merge_trigger;
create or replace function py_exec_merge_trigger()
        returns trigger 
		language 'plpython3u' 
as $BODY$

    plpy.execute("select py_exec_merge_sql('{}', '{}', '{}', '{}', '{}', '{}')".format(TD["args"][0], TD["args"][1], TD["args"][2], TD["args"][3], TD["args"][4], TD["args"][5]))
    ##return "MODIFY"

$BODY$;

-- select * from py_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dim_abc','id');
