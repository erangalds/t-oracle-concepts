-- Grant DBA Roles to dbas
GRANT DBA TO dba_rachel;
GRANT DBA TO dba_victor;

-- Grant Roles to Developers
-- Dan and Diana (Stores Only
GRANT role_store_dev TO dev_dan;
GRANT role_store_dev TO dev_diana;

-- Derek (Billing Only)
GRANT role_billing_dev TO dev_derek;


-- Dominic and Daphne (Both Apps)
GRANT role_store_dev, role_billing_dev TO dev_dominic;
GRANT role_store_dev, role_billing_dev TO dev_daphne;

-- Adam and Amy (Store Only Read)
GRANT role_store_analyst TO analyst_adam;
GRANT role_store_analyst TO analyst_amy;

-- Aaron (Billing Only Read)
GRANT role_billing_analyst TO analyst_aaron;

-- Alyssa and Alex (Both Apps Read)
GRANT role_store_analyst, role_billing_analyst TO analyst_alyssa;
GRANT role_store_analyst, role_billing_analyst TO analyst_alex;

