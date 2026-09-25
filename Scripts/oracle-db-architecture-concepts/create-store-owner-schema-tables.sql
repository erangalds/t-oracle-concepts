-- Table: Products
CREATE TABLE products (
    product_id    NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name  VARCHAR2(100) NOT NULL,
    category      VARCHAR2(50)  NOT NULL,
    price         NUMBER(8, 2)  NOT NULL,
    stock         NUMBER        DEFAULT 0 NOT NULL
);

-- Table: Orders
CREATE TABLE orders (
    order_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    order_date    DATE          DEFAULT SYSDATE NOT NULL,
    total_amount  NUMBER(10, 2) NOT NULL
);

-- Seed Data
INSERT INTO products (product_name, category, price, stock) VALUES ('Quantum Laptop 15', 'Electronics', 1499.00, 25);
INSERT INTO products (product_name, category, price, stock) VALUES ('Ergonomic Mouse', 'Electronics', 49.99, 150);
INSERT INTO products (product_name, category, price, stock) VALUES ('Standing Desk Pad', 'Furniture', 35.00, 80);

INSERT INTO orders (customer_name, order_date, total_amount) VALUES ('Alice Cooper', DATE '2026-02-10', 1548.99);
INSERT INTO orders (customer_name, order_date, total_amount) VALUES ('Bob Dylan', DATE '2026-02-11', 49.99);

COMMIT;
EXIT;