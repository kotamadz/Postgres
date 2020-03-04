# Postgres
PL/Python - PL/Pgsql
In this post, i write some stored procedures in PL/Python and PL/Pgsql

# How to do like sql server merge in postgres:
 in this tutorial, you will learn how to use the MERGE statement to update data in a table based on values matched from another table in postgres.
     1. The source table has some rows that do not exist in the target table. In this case, 
     you need to insert rows that are in the source table into the target table.
    2. The target table has some rows that do not exist in the source table. In this case, 
    you need to delete rows from the target table.
    3. The source table has some rows with the same keys as the rows in the target table. 
    However, these rows have different values in the non-key columns. In this case, 
    you need to update the rows in the target table with the values coming from the source table.

# Postgres/pl_pg/pg_get_functions :: 
This folder contains stored procedures(code pl/pgsql) used to calculate easter day, pentcost day, factorial integer...
# Postgres/pl_pg/pg_merge :: 
This folder contains stored procedures(code pl/pgsql) used merge sql in postgres, to populate dimension table in datamart 
# Postgres/pl_pg/pg_with :: 
This folder contains stored procedures(code pl/pgsql) used with recusive to populate dimension table of dates in datamart
# Postgres/pl_py/py_get_functions :: 
This folder contains stored procedures(code pl/python) used to calculate easter day, pentcost day, factorial integer...
# Postgres/pl_py/py_merge :: 
This folder contains stored procedures(code pl/python) used merge sql in postgres, to populate dimension table in datamart 
# Postgres/pl_py/py_with :: 
This folder contains stored procedures(code pl/python) used with recusive to populate dimension table of dates in datamart
