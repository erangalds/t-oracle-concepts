-- 1. Ensure we are in CDB$ROOT
-- SHOW CON_NAME; -- This command is not a SQL command, therefore it doesn't work on DBeaver
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') FROM dual;

-- Expected output: CDB$ROOT

-- 2. Drop ENTERPRISEPDB if it already exists from a prior test run

SELECT name, open_mode FROM v$pdbs; -- Lists all pluggable databases available

BEGIN
  EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE enterprisepdb CLOSE IMMEDIATE';
  EXECUTE IMMEDIATE 'DROP PLUGGABLE DATABASE enterprisepdb INCLUDING DATAFILES';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- 3. Create the dedicated PDB from the seed template
CREATE PLUGGABLE DATABASE enterprisepdb
  ADMIN USER pdbadmin IDENTIFIED BY "Oracle123"
  ROLES = (DBA)
  -- Maps the seed template paths to your new PDB directory structure
  FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/pdbseed/', '/opt/oracle/oradata/FREE/enterprisepdb/')
  DEFAULT TABLESPACE users
    DATAFILE '/opt/oracle/oradata/FREE/enterprisepdb/users01.dbf' SIZE 100M AUTOEXTEND ON NEXT 50M MAXSIZE UNLIMITED;

SELECT name, open_mode FROM v$pdbs; -- Verify that the new ENTERPRISEPDB PDB was created. 

-- 4. Open the pluggable database in read-write mode
ALTER PLUGGABLE DATABASE enterprisepdb OPEN READ WRITE;

SELECT name, open_mode FROM v$pdbs; -- Verify that the pdb is now on read write mode

-- 5. Save the state so ENTERPRISEPDB starts automatically on container restart
ALTER PLUGGABLE DATABASE enterprisepdb SAVE STATE;

-- 6. Verify available PDBs
SELECT con_id, name, open_mode FROM v$pdbs;