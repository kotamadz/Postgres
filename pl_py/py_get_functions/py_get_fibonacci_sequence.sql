-- Programmed by Kotama.dz
-- type like record :: fibonacci_sequence
-- drop type fibonacci_sequence
drop type if exists fibonacci_sequence cascade;
create type public.fibonacci_sequence as (
  io  integer,
  sq  text 
);

-- function function public.py_get_fibonacci_sequence
-- drop function
drop function if exists public.py_get_fibonacci_sequence cascade; 
create or replace function public.py_get_fibonacci_sequence(fi integer default null)
    returns fibonacci_sequence
    language 'plpython3u'

    cost 100
    volatile 
AS $BODY$    
    if fi == None or fi < 0:
        io = None
        sq = None
    elif fi == 0:
        io = 1
        sq = '(f0 = 1)'
    elif fi == 1:
        io = 1
        sq = '(f0 = 1, f1 = 1)'
    else:
        io = 0
        sq = '(f0 = 1, f1 = 1'
        cn = 1
        iz = 1
        iu = 1
        while (cn != fi):
            cn += 1
            io = iz + iu
            iz = iu
            iu = io
            sq +=', f' + str(cn) + ' = ' + str(io)
        sq += ')'
    return[io, sq]
	
$BODY$;

-- select * from public.py_get_fibonacci_sequence(5);
