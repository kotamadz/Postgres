-- Programmed by Kotama.dz
/*
function pg_get_merge_sql(
        in  src_schema   character varying,
	in  src_table    character varying,
        in  his_table    character varying,
	in  trg_schema   character varying,
	in  trg_table    character varying,
	in  bk           character varying,
	out row_del      text,
	out row_ins      text,
	out row_upd      text)
*/

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

drop function if exists pg_exec_merge_sql cascade;
create or replace function pg_exec_merge_sql(
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
		
	returns record 
	language 'plpgsql' 
		
as $BODY$
declare

  -- delete sql
  rdel text;
  rdel_s text;
  rdel_m text;
  
  -- insert sql 
  rins text;
  rins_s text;
  rins_m text;
  
  -- update sql
  rupd text;
  rupd_s text;
  rupd_m text;
  
  -- exists table and schema
  _t_src text;
  _s_src boolean;
  _c_src boolean;
  _t_trg text;
  _s_trg boolean;
  _c_trg boolean;
  _t_his boolean;
  
begin
    -- test if one or more arguments is(are) null
    if $1 is null or $2 is null or 
       $3 is null or $4 is null or 
       $5 is null or $6 is null then
	    deleted_row   := null;
		inserted_row  := null;
		updated_row   := null;
		pg_exec_msg   := 'One or more argument(s) is(are) null';
        pg_exec_state := 'Cnull';	-- code null	
	else
	    -- test existing schema target
		_s_trg := (select exists(select 1 from pg_namespace where nspname = quote_ident(trg_schema)));
	    -- test existing schema source 
		_s_src := (select exists(select 1 from pg_namespace where nspname = quote_ident(src_schema)));
		-- test existing source table
		_t_src := (select to_regclass(quote_ident(src_schema) || '.' || quote_ident(src_table)));
		-- test existing target table
		_t_trg := (select to_regclass(quote_ident(trg_schema) || '.' || quote_ident(trg_table)));
		-- test existing history table
		_t_his := (select to_regclass(quote_ident(src_schema) || '.' || quote_ident(his_table)));
		-- test existing column in source table
		_c_src := (select exists (select 1 from information_schema.columns where table_schema = quote_ident(src_schema) and table_name = quote_ident(src_table) and column_name = quote_ident(bk)));
		-- test existing column in target table
		_c_trg := (select exists (select 1 from information_schema.columns where table_schema = quote_ident(trg_schema) and table_name = quote_ident(trg_table) and column_name = quote_ident(bk)));		
		if _s_src = false or _t_src is null or _t_his is null or _s_trg = false or 
		   _t_trg is null or _c_src = false or _c_trg = false then
		    deleted_row  := null;
		    inserted_row := null;
		    updated_row  := null;
		    if _s_src = false then
			    pg_exec_state := '3F000';				 
			    pg_exec_msg   := 'schema source "' || src_schema || '" does not exist';
			elseif _t_src is null then 
			    pg_exec_state := '42P01';				 
			    pg_exec_msg   := 'table source "'  || src_table  || '" does not exist';
			elseif _c_src = false then
			    pg_exec_state := '42703';						
			    pg_exec_msg   := 'column "' || bk || '" of relation source"'  || src_table  || '" does not exist';	
			elseif _t_his is null then 
			    pg_exec_state := '42P01';				 
			    pg_exec_msg   := 'table history "'  || his_table  || '" does not exist';				
            elseif	_s_trg = false then
			    pg_exec_state := '3F000';				 
			    pg_exec_msg   := 'schema target "' || src_target || '" does not exist';
			elseif _t_trg is null then 
			    pg_exec_state := '42P01';				 
			    pg_exec_msg   := 'table target "'  || trg_table  || '" does not exist';	
			elseif _c_trg = false then
			    pg_exec_state := '42703';						
			    pg_exec_msg   := 'column "' || bk || '" of relation target"'  || trg_table  || '" does not exist';				
			end if;
		else
            -- delete sql
		    begin 
                rdel := (select del_sql from pg_get_merge_sql(src_schema, src_table, his_table, trg_schema, trg_table, bk));
                execute rdel;
                get diagnostics deleted_row = row_count;
		        exception when others then 
                get stacked diagnostics
                    rdel_s = returned_sqlstate,
                    rdel_m = message_text;
            end;
		
            -- insert sql 
	    begin
                rins := (select ins_sql from pg_get_merge_sql(src_schema, src_table, his_table, trg_schema, trg_table, bk));
                execute rins;
                get diagnostics inserted_row = row_count;
		exception when others then 
                get stacked diagnostics
                    rins_s = returned_sqlstate,
                    rins_m = message_text;
		    end;
  
            -- update sql
	    begin
                rupd := (select upd_sql from pg_get_merge_sql(src_schema, src_table, his_table, trg_schema, trg_table, bk));
                execute rupd;
                get diagnostics updated_row = row_count;
		exception when others then 
                get stacked diagnostics
                    rupd_s = returned_sqlstate,
                    rupd_m = message_text;
		    end;
		
	        if deleted_row is null then 
		        deleted_row := 0;
		end if;
		
		if inserted_row is null then 
		        inserted_row := 0;
		end if;

                if updated_row is null then 
		        updated_row := 0;
		end if;
		
		    pg_exec_state := 'C0'; -- code 0
		    pg_exec_msg   := 'success';	
		    if rdel_s is not null and rins_s is not null and rupd_s is not null then
		        pg_exec_state := rdel_s || ' ' || rins_s || ' ' || rupd_s;
			pg_exec_msg   := rdel_m || ' ' || rins_m || ' ' || rupd_m;
		    elseif rdel_s is null and rins_s is not null and rupd_s is not null then
		        pg_exec_state := pg_exec_state || ' ' || rins_s || ' ' || rupd_s;
			pg_exec_msg   := pg_exec_msg   || ' ' || rins_m || ' ' || rupd_m;
                    elseif rdel_s is not null and rins_s is null and rupd_s is not null then 	
		        pg_exec_state := pg_exec_state || ' ' || rdel_s || ' ' || rupd_s;
			pg_exec_msg   := pg_exec_msg   || ' ' || rdel_m || ' ' || rupd_m;
                    elseif rdel_s is not null and rins_s is not null and rupd_s is null then	
		        pg_exec_state := pg_exec_state || ' ' || rdel_s || ' ' || rins_s;
			pg_exec_msg   := pg_exec_msg   || ' ' || rdel_m || ' ' || rins_m;			
		    end if;
			
		end if;
  end if;
  
end;
$BODY$;
							      
-- select * from pg_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dim_abc','id');
-- select * from pg_exec_merge_sql('publi','d_abc','d_abc_hist','datamart','dim_abc','id');
-- select * from pg_exec_merge_sql('public','dabc','d_abc_hist','datamart','dim_abc','id');
-- select * from pg_exec_merge_sql('public','d_abc','dabc_hist','datamart','dim_abc','id');
-- select * from pg_exec_merge_sql('public','d_abc','d_abc_hist','datmart','dim_abc','id');
-- select * from pg_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dimabc','id');
-- select * from pg_exec_merge_sql('public','d_abc','d_abc_hist','datamart','dim_abc','d');
