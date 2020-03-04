-- public.d_abc table
drop table if exists public.d_abc cascade;
create table if not exists public.d_abc (
   id              integer     not null,
   val_important   varchar(10) not null,
   val_unimportant varchar(10) not null
);

-- execute create tables with null 5 arguments is initialize to false by default
-- in this case the function drop not existing tables
-- py_exec_create_tables_abc.sql
select * from py_exec_create_tables('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc');

-- create trigger on table d_abc
-- py_create_trigger_abc.sql
drop trigger if exists py_exec_merge_trigger_abc on d_abc;
create trigger py_exec_merge_trigger_abc
  after insert or update or delete
  on d_abc
  execute procedure py_exec_merge_trigger('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc', 'id');
  
-- insert values in public.d_abc table
insert into public.d_abc values (1, 'one'  , 'foo');
insert into public.d_abc values (2, 'two'  , 'bar');
insert into public.d_abc values (3, 'three', 'baz');
insert into public.d_abc values (4, 'four' , 'bla');
