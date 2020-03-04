-- Programmed by Kotama.dz
-- create trigger on table d_abc
-- py_create_trigger_abc.sql

drop trigger if exists py_exec_merge_trigger_abc on d_abc;
create trigger py_exec_merge_trigger_abc
  after insert or update or delete
  on d_abc
  execute procedure py_exec_merge_trigger('public', 'd_abc', 'd_abc_hist', 'datamart', 'dim_abc', 'id');
  
