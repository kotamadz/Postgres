-- Programmed by Kotama.dz
-- create trigger on table d_abc
-- pg_create_trigger_abc.sql

drop trigger if exists pg_exec_merge_trigger_abc on d_abc;
create trigger pg_exec_merge_trigger_abc
  after insert or update or delete
  on d_abc
  execute procedure pg_exec_merge_trigger('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc', 'id');
  
