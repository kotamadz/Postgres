-- function public.public.pg_get_factorial
-- drop function
drop function if exists public.public.pg_get_factorial cascade;
create or replace function public.pg_get_factorial(f integer default null) 
returns integer as 
$$
declare
   io integer;
    begin
        case 
	        when f is null then
		         io := 0;
            when f <= 0 then
	             io := 1;
	        else
		         io := f;
	            for i in reverse f..2 loop
                    io := io * (i - 1);
                end loop;
        end case;
        return io;
    end;
$$ language 'plpgsql';

-- select public.pg_get_factorial(5);