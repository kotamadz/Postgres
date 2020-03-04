-- Programmed by Kotama.dz
-- in arguments or input values
-- src_schema : name of source schema by default is public schema 
-- src_table  : name of source table
-- his_table  : name of history table that contains deleted row
-- trg_schema : name of target schema exemple datamart schema 
-- trg_table  : name of target table
-- bk         : business key in source table
-- out values or return values
-- row_del  : count rows deleted
-- row_ins  : count rows inserted
-- row_upd  : count rows updated

drop function if exists pg_get_merge_sql cascade;
create or replace function pg_get_merge_sql(
        in  src_schema   character varying,
	in  src_table    character varying,
        in  his_table    character varying,
	in  trg_schema   character varying,
	in  trg_table    character varying,
	in  bk           character varying,
	out del_sql    text,
	out ins_sql    text,
	out upd_sql    text)

	returns record 
	language 'plpgsql' 
		
as $BODY$
declare
    del_row  text;
    ins_row  text;
    upd_row  text;
	
    del_fil  text := '';
    ins_fil  text := '';
    upd_fil  text := '';
    ins_upd  text := '';
    rec_sche record;
    cur_sche cursor(src_schema varchar(55), src_table varchar(55)) 
    for select
    column_name
    from information_schema.columns
    where table_name   = src_table
      and table_schema = src_schema;
begin

del_row := 'with del as ( '          || chr(10)
    || '              delete from '  || trg_schema   || '.' 
    || trg_table || ' as trg '       || chr(10)
    || '              where trg.'    || bk           || ' not in (select src.'  
    || bk        || ' from '         || src_schema   || '.' 
    || src_table || ' as src) '      || chr(10)
    || '              returning * '  || chr(10)
    || ' ) '     || chr(10)
    || ' insert into '  || src_schema 
    || '.'              || his_table || chr(10)
    || ' select      '  || chr(10)
    || '   trg.skey, '  || chr(10);
	
ins_row := 'with ins as ( ' || chr(10)
    || '              select '             || bk  || ' from ' || src_schema   || '.' 
    || src_table || ' as src where src.'   || bk  || ' not in (select '  
    || 'trg.'    || bk || ' from '  || trg_schema || '.' || trg_table || ' as trg)' || chr(10)
    || ' ) '     || chr(10)
    || 'insert into ' || trg_schema || '.' || trg_table || '(' || chr(10);
	
upd_row := 'with upd as ( ' || chr(10)
    || '                  update ' || trg_schema || '.' || trg_table || ' as trg' || chr(10)
    || '                  set curr_ind = false,' ||  chr(10)
    || '                      end_date = localtimestamp' ||  chr(10)
    || '                  where trg.' || bk || ' in '   ||  chr(10)
    || '                   ( ' ||  chr(10)
    || '                     select '  ||  chr(10)
    || '                        src.'  || bk  ||  chr(10)
    || '                     from '    || src_schema || '.' || src_table || ' as src ' ||  chr(10)
    || '                     where '   ||  chr(10);
	
    -- open the cursor
    open cur_sche(src_schema, src_table);
    loop
    -- fetch row into rec_sche
        fetch cur_sche into rec_sche;
    -- exit when no more row to fetch
        exit when not found; 
	    del_fil := del_fil || '   trg.' || rec_sche.column_name || ',' || chr(10);
		ins_fil := ins_fil || '   src.' || rec_sche.column_name || ',' || chr(10);
		ins_upd := ins_upd || rec_sche.column_name  || ',' || chr(10);
		if rec_sche.column_name <> bk then
		   upd_fil := upd_fil || '   trg.'  || rec_sche.column_name || ' <> src.' || rec_sche.column_name || ' or' || chr(10);
		end if;
    end loop;
	   -- close the cursor
        close cur_sche; 
	    ins_fil := substring(ins_fil, 1, length(ins_fil)-2);
		ins_upd := substring(ins_upd, 1, length(ins_upd)-2);
		upd_fil := substring(upd_fil, 1, length(upd_fil)-3);
		
	    del_row := del_row || del_fil || '   localtimestamp' || chr(10) || ' from del as trg;';
		
	     ins_row := ins_row || ins_upd || ')' || chr(10)
		     || 'select '  || chr(10)
		     || ins_fil    || chr(10)
		     || 'from '    || src_schema        || '.' || src_table || ' as src where src.'
		     || bk         || ' in (select '    || bk  || ' from ins);';
			 
	     upd_row := upd_row ||  upd_fil ||  ') ' ||  chr(10)
	             || ' and trg.curr_ind = true'  ||  chr(10)
                     || 'returning *' ||  chr(10)
		     || ')' ||  chr(10)
		     || 'insert into ' || trg_schema || '.' || trg_table || '(' || chr(10)
                     || ins_upd || ')' || chr(10)
		     || 'select '  || chr(10)
		     || ins_fil    || chr(10)
		     || 'from '    || src_schema        || '.' || src_table || ' as src where src.'
		     || bk         || ' in (select '    || bk  || ' from upd);';
			
		del_sql := del_row;
		ins_sql := ins_row;
		upd_sql := upd_row;
end;
$BODY$;
