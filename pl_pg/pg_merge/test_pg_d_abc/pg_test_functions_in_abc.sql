-- Programmed by Kotama.dz

-- exemple to test functions

-- insert one record
insert into public.d_abc values (5, 'five' , 'zza');

-- delete one record
delete from public.d_abc where id = 4;

-- update two record
update public.d_abc 
set val_important = 'toz'
where id = 3;
update public.d_abc 
set val_unimportant = 'bas'
where id = 1;
