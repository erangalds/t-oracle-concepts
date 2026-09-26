# Seting up Sakila Database in Oracle

## Setting up a new Pluggable Database for Sakila Database

We can loginto the oracle CDB$ROOT which is `FREE` as `sys` user and `sysdba` using the **DBeaver**. Then execute the script `setup-new-pdb.sql` from DBeaver.  

```sql 
-- 1. Create the pluggable database from the seed
CREATE PLUGGABLE DATABASE sakilapdb 
  ADMIN USER pdbadmin IDENTIFIED BY Oracle123 
  ROLES = (DBA)
  FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/pdbseed/', '/opt/oracle/oradata/FREE/sakilapdb/');

-- Check for the PDBs and their open modes
SELECT name, open_mode FROM v$pdbs;

-- Changing the mode to OPEN mode
ALTER PLUGGABLE DATABASE sakilapdb OPEN;
-- Making the Open Mode the default at Start up
ALTER PLUGGABLE DATABASE sakilapdb SAVE STATE;

-- Verify the Mode 
SELECT name, open_mode FROM v$pdbs;

-- Setting the new users for the sakila db
ALTER SESSION SET CONTAINER = sakilapdb;
-- Verify 
SELECT sys_context('USERENV', 'CON_NAME') AS current_container FROM dual;


-- Create the dedicated schema
CREATE USER sakila IDENTIFIED BY Oracle123;
GRANT CONNECT, RESOURCE, DBA TO sakila;
GRANT UNLIMITED TABLESPACE TO sakila;
GRANT CREATE VIEW TO sakila;

EXIT;
```

## Creating Schema, Loading Data to Sakila Database

Open the terminal. Make use you are at the project root directory. List down the directory items and check that filder `sakila-db` is there. Now let's get the data copied to the container instance. 

```bash
# docker compose cp sakila-db/. <container_name_or_service>:/tmp/sakila-db
# According to the docker-compose settings
# Service = oracle-db
docker compose cp sakila-db/. oracle-db:/tmp/sakila-db
```

Now we need to login to the container and run the `.sql` files. 

```bash
docker compose exec <service_name> bash
# We need to move to our tmp/sakila-db directory
# Because that's where we copied the .sql files

cd /tmp/sakila-db

# Verify that the files are there
ls -lrt

# Now let's login to the database using sakila user
sqlplus sakila/Oracle123@localhost:1521/sakilapdb

# Validate the connection name
SHOW CON_NAME;
SHOW USER;
```

Once we verify that we logged into the `sakilapdb` under user `sakila' which is the schema name, let's now create the tables and load the data. 

```sql
@oracle-sakila-schema.sql
@oracle-sakila-insert-data.sql
COMMIT;
```

Now we can verify how many records got loaded. Let us login to the `sakilapdb` using the `sakila` user using the DBeaver. Then execute the script `validate-data-loading.sql`. 

```sql
-- Verify the loaded row counts
SELECT table_name, 
       TO_NUMBER(
         EXTRACTVALUE(
           XMLTYPE(
             DBMS_XMLGEN.GETXML('SELECT COUNT(*) c FROM ' || table_name)
           ), '/ROWSET/ROW/C'
         )
       ) AS row_count
FROM user_tables
ORDER BY table_name;
```



