-- 1. Create Roles
CREATE ROLE role_store_dev;
CREATE ROLE role_store_analyst;
CREATE ROLE role_billing_dev;
CREATE ROLE role_billing_analyst;

-- 2. Grant Permissions to Store Roles
GRANT SELECT, INSERT, UPDATE, DELETE ON store_owner.products TO role_store_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON store_owner.orders   TO role_store_dev;

GRANT SELECT ON store_owner.products TO role_store_analyst;
GRANT SELECT ON store_owner.orders   TO role_store_analyst;

-- 3. Grant Permissions to Billing Roles
GRANT SELECT, INSERT, UPDATE, DELETE ON billing_owner.invoices TO role_billing_dev;
GRANT SELECT, INSERT, UPDATE, DELETE ON billing_owner.payments TO role_billing_dev;

GRANT SELECT ON billing_owner.invoices TO role_billing_analyst;
GRANT SELECT ON billing_owner.payments TO role_billing_analyst;