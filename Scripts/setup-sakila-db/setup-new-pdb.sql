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