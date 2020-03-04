-- function function public.py_get_factorial
-- drop function
drop function if exists public.py_get_factorial cascade; 
create or replace function public.py_get_factorial(f integer default null)
    returns integer
    language 'plpython3u'

    cost 100
    volatile 
AS $BODY$    
    if f == None:
        return 0
    elif f <= 0:
        return 1
    else:
        io = f
        for i in range(f, 2, -1):
            io *= (i-1)
        return io
$BODY$;

-- select public.py_get_factorial(5);