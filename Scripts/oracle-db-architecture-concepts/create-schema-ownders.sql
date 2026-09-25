-- List down all the users in the ENTERPRISEPDB PDB
SELECT username FROM all_users;

-- Clean up previous runs if necessary
BEGIN
  FOR u IN (SELECT username FROM all_users WHERE username IN ('STORE_OWNER', 'BILLING_OWNER')) LOOP
    EXECUTE IMMEDIATE 'DROP USER ' || u.username || ' CASCADE';
  END LOOP;
END;
/

-- 1. Create Store Application Owner
CREATE USER store_owner IDENTIFIED BY "Oracle123"
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO store_owner;

-- 2. Create Billing Application Owner
CREATE USER billing_owner IDENTIFIED BY "Oracle123"
  DEFAULT TABLESPACE users
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO billing_owner;

EXIT;


