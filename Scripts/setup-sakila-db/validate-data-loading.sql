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