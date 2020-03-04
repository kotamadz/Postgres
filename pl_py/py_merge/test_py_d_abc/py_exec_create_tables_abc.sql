-- Programmed by Kotama.dz
/*
function py_exec_create_tables(
        in  src_schema character varying default null::character varying,
	in  src_table  character varying default null::character varying,
        in  his_table  character varying default null::character varying,
	in  trg_schema character varying default null::character varying,
	in  trg_table  character varying default null::character varying, 
	in  is_drop    boolean default false)
*/

-- execute create tables with 5 arguments are initialize to null by default but is_drop to false by default
-- in this case the function don't drop existing tables
select * from py_exec_create_tables('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc');
or 
-- in this case the function don't drop existing tables
select * from py_exec_create_tables('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc', false);
or
-- in this case the function drop existing tables
select * from py_exec_create_tables('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc', true);
