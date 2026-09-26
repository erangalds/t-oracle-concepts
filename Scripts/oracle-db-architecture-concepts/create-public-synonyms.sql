-- Create PUBLIC Synonyms
CREATE OR REPLACE PUBLIC SYNONYM products FOR store_owner.products;
CREATE OR REPLACE PUBLIC SYNONYM orders   FOR store_owner.orders;
CREATE OR REPLACE PUBLIC SYNONYM invoices FOR billing_owner.invoices;
CREATE OR REPLACE PUBLIC SYNONYM payments FOR billing_owner.payments;