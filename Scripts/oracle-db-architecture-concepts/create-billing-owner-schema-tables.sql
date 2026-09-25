-- Table: Invoices
CREATE TABLE invoices (
    invoice_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reference_no  VARCHAR2(30) UNIQUE NOT NULL,
    issued_date   DATE DEFAULT SYSDATE NOT NULL,
    amount_due    NUMBER(10, 2) NOT NULL,
    status        VARCHAR2(20) DEFAULT 'ISSUED' CHECK (status IN ('ISSUED', 'PAID', 'VOID'))
);

-- Table: Payments
CREATE TABLE payments (
    payment_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    invoice_id    NUMBER NOT NULL REFERENCES invoices(invoice_id),
    payment_date  DATE DEFAULT SYSDATE NOT NULL,
    amount_paid   NUMBER(10, 2) NOT NULL,
    method        VARCHAR2(30) CHECK (method IN ('CREDIT_CARD', 'ACH', 'WIRE'))
);

-- Seed Data
INSERT INTO invoices (reference_no, issued_date, amount_due, status) VALUES ('INV-2026-001', DATE '2026-02-01', 1548.99, 'PAID');
INSERT INTO invoices (reference_no, issued_date, amount_due, status) VALUES ('INV-2026-002', DATE '2026-02-05', 49.99, 'PAID');
INSERT INTO invoices (reference_no, issued_date, amount_due, status) VALUES ('INV-2026-003', DATE '2026-02-12', 3200.00, 'ISSUED');

INSERT INTO payments (invoice_id, payment_date, amount_paid, method) VALUES (1, DATE '2026-02-03', 1548.99, 'CREDIT_CARD');
INSERT INTO payments (invoice_id, payment_date, amount_paid, method) VALUES (2, DATE '2026-02-06', 49.99, 'ACH');

COMMIT;
EXIT;