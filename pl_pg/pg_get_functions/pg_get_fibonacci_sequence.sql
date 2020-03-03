-- function public.public.pg_get_fibonacci_sequence
-- drop function
drop function if exists public.public.pg_get_fibonacci_sequence cascade;
create or replace function public.pg_get_fibonacci_sequence(
   in  fi integer default null,
   out io integer,
   out sq text) 
   returns record as $$ 
declare
   cn integer := 1; 
   iz integer := 1;
   iu integer := 1;
begin
    if fi is null then
	   io := null;
	   sq := null;
    elseif fi < 0 then
        io := null;
		sq := null;
    elseif fi = 0 then
        io := 1;
		sq := '(f0 = 1)';
    elseif fi = 1 then
        io := 1;
		sq := '(f0 = 1, f1 = 1)';
    else
	    io := 0;
		sq := '(f0 = 1, f1 = 1';
        loop
            exit when cn = fi;
            cn := cn + 1;	
            io := iz + iu;
            iz := iu;
            iu := io;
            sq := sq || ', f' ||  cast(cn as text) || ' = ' || cast(io as text);				
        end loop;
		sq := sq || ')';
    end if;
end; 
$$ language plpgsql;

-- select io, sq from public.pg_get_fibonacci_sequence(11);