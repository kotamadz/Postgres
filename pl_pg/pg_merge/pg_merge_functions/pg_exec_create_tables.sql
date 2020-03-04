-- Programmed by Kotama.dz
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
-- pg_con        : postgres context
-- sql_req       : executed request

drop function if exists pg_exec_create_tables cascade;
create or replace function pg_exec_create_tables(
        in  src_schema character varying default null::character varying,
	in  src_table  character varying default null::character varying,
        in  his_table  character varying default null::character varying,
	in  trg_schema character varying default null::character varying,
	in  trg_table  character varying default null::character varying, 
	in  is_drop    boolean default false)
		
        returns table (pg_exec_state text, pg_exec_msg text, pg_con text, sql_req text)
		language 'plpgsql' 
		
as $BODY$
declare

  -- dimension table
  t_tdim  text;
  tdim    text;
  d_state text;
  d_msg   text;
  
  -- history table
  t_hist  text;
  hist    text;
  h_state text;
  h_msg   text;
  
  -- constant null
  s_null constant text := 'Cnull';
  m_null constant text := 'One or more argument(s) is(are) null';
  p_null constant text := null;
  r_null constant text := null;
  
  -- constant schema  or table are not exists
  s_schema constant text := '3F000';
  s_table  constant text := '42P01';
  m_schema constant text := 'schema source "' || src_schema || '" does not exist';
  t_schema constant text := 'schema target "' || trg_schema || '" does not exist';
  m_table  constant text := 'table source "'  || src_table  || '" does not exist';
  p_notexi constant text := null;
  r_notexi constant text := null;
  
  -- constant is drop table
  s_drop constant text := 'Cdrop';
  h_drop constant text := 'table "' || his_table || '" does exist';
  t_drop constant text := 'table "' || trg_table || '" does exist';
  p_drop constant text := null;
  r_drop constant text := null;
  
  -- exists table and schema
  _dim boolean := false;
  _his boolean := false;
  _exists text;
  _sche boolean;
  _scht boolean;
  
begin
    
	-- if one of arguments is null do nothing
    if $1 is null or $2 is null or 
       $3 is null or $4 is null or 
       $5 is null then
        return query 
        ( 
            select 
		 s_null as pg_exec_state,
		 m_null as pg_exec_msg,
		 p_null as pg_con,
		 r_null as sql_req
	    ); 
	else
	        -- test existing schema target
		_scht := (select exists(select 1 from pg_namespace where nspname = quote_ident(trg_schema)));
	        -- test existing schema source 
		_sche := (select exists(select 1 from pg_namespace where nspname = quote_ident(src_schema)));
		-- test existing source table
		_exists := (select to_regclass(quote_ident(src_schema) || '.' || quote_ident(src_table)));
		if _sche = false then
		    return query
			(
			    select
		                s_schema as pg_exec_state,
		                m_schema as pg_exec_msg,
			        p_notexi as pg_con,
			        r_notexi as sql_req  
			);
		elseif _exists is null then
		    return query
			(
			    select
		                s_table  as pg_exec_state,
		                m_table  as pg_exec_msg,
			        p_notexi as pg_con,
			        r_notexi as sql_req  
			);
		elseif _scht = false then
		    return query
			(
			    select
		                s_schema as pg_exec_state,
		                t_schema as pg_exec_msg,
			        p_notexi as pg_con,
			        r_notexi as sql_req  
			);		
		else
            -- dimension table sql
		    _exists := (select to_regclass(quote_ident(trg_schema) || '.' || quote_ident(trg_table)));
		    if _exists is not null and is_drop = false then
		       _dim := true;
		    else
		        begin 
		            tdim := (select pg_get_dim_table_sql(src_schema, src_table, trg_schema, trg_table));
                            execute tdim;
                            get diagnostics t_tdim = pg_context;
		            exception when others then 
                            get stacked diagnostics
                                d_state = returned_sqlstate,
                                d_msg   = message_text;
                       end;
		        if d_state is null then
 		           d_state := 'C0'; -- code 0
			   d_msg   := 'success';           		
		        end if;
		    end if;
		
            -- history table sql 
		    _exists := (select to_regclass(quote_ident(src_schema) || '.' || quote_ident(his_table)));
		    if _exists is not null and is_drop = false then
		       _his := true;
		    else		
		        begin
                            hist := (select pg_get_his_table_sql(src_schema, src_table, his_table));
                            execute hist;
                            get diagnostics t_hist = pg_context;
		            exception when others then 
                            get stacked diagnostics
                                h_state = returned_sqlstate,
                                h_msg   = message_text;
		        end;
		        if h_state is null then
 		           h_state := 'C0'; -- code 0
			   h_msg   := 'success';           		
		        end if;
		    end if;
				
		    -- return result in table
		    if _dim = false and _his = false then
                     return query 
                     ( 
                            select 
		                d_state as pg_exec_state,
		                d_msg   as pg_exec_msg,
			        t_tdim  as pg_con,
			       tdim    as sql_req
		            union
                            select 
		                h_state as pg_exec_state,
		                h_msg   as pg_exec_msg,
			        t_hist  as pg_con,
			        hist    as sql_req		
	             ); 
		    elseif _dim = true and _his = true then
                     return query 
                     ( 
                           select 
		               s_drop as pg_exec_state,
                               t_drop as pg_exec_msg,
                               p_drop as pg_con,
                               r_drop as sql_req
		           union
                           select 
		               s_drop as pg_exec_state,
                               h_drop as pg_exec_msg,
                               p_drop as pg_con,
                               r_drop as sql_req		
	            );
		    elseif _dim = false and _his = true then
                     return query 
                     ( 
                           select 
		               d_state as pg_exec_state,
		               d_msg   as pg_exec_msg,
			       t_tdim  as pg_con,
			       tdim    as sql_req
		           union
                           select 
		               s_drop as pg_exec_state,
                               h_drop as pg_exec_msg,
                               p_drop as pg_con,
                               r_drop as sql_req		
	            );	
		    elseif _dim = true and _his = false then
                     return query 
                     ( 
                           select 
		               s_drop as pg_exec_state,
                               t_drop as pg_exec_msg,
                               p_drop as pg_con,
                               r_drop as sql_req
		            union
                            select 
		                h_state as pg_exec_state,
		                h_msg   as pg_exec_msg,
			        t_hist  as pg_con,
			        hist    as sql_req		
	            );			
		    end if;
		
		end if;
		
    end if;
  
end;

$BODY$;
							 
-- select * from pg_exec_create_tables('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc');
