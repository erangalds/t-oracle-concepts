DECLARE
  TYPE t_users IS TABLE OF VARCHAR2(30);
  v_users t_users := t_users(
    'dba_rachel', 'dba_victor',
    'dev_dan', 'dev_diana', 'dev_derek', 'dev_dominic', 'dev_daphne',
    'analyst_adam', 'analyst_amy', 'analyst_aaron', 'analyst_alyssa', 'analyst_alex'
  );
BEGIN
  FOR i IN 1 .. v_users.COUNT LOOP
    -- Drop if exists
    BEGIN
      EXECUTE IMMEDIATE 'DROP USER ' || v_users(i) || ' CASCADE';
    EXCEPTION
      WHEN OTHERS THEN NULL;
    END;
    -- Create user with standard password
    EXECUTE IMMEDIATE 'CREATE USER ' || v_users(i) || ' IDENTIFIED BY "Oracle123" DEFAULT TABLESPACE users';
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || v_users(i);
  END LOOP;
END;
/