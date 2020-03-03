/*
function pg_exec_merge_sql(
        in  src_schema   character varying default null::character varying,
		in  src_table    character varying default null::character varying,
        in  his_table    character varying default null::character varying,
		in  trg_schema   character varying default null::character varying,
		in  trg_table    character varying default null::character varying,
		in  bk           character varying default null::character varying,
		out deleted_row  integer,
		out inserted_row integer,
		out updated_row  integer,
	    out pg_exec_state   text,
		out pg_exec_msg     text)
*/

select * from pg_exec_merge_sql('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc', 'id');
