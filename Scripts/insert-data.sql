-- Departments
INSERT INTO departments (department_name, location) VALUES ('Executive', 'San Francisco');
INSERT INTO departments (department_name, location) VALUES ('Sales', 'New York');
INSERT INTO departments (department_name, location) VALUES ('Engineering', 'Austin');
INSERT INTO departments (department_name, location) VALUES ('Customer Support', 'Chicago');
INSERT INTO departments (department_name, location) VALUES ('Legal', 'Washington DC');

-- Employees (Hierarchical)
INSERT INTO employees (first_name, last_name, email, salary, hire_date, department_id, manager_id)
VALUES ('Arthur', 'Morgan', 'amorgan@company.com', 125000, DATE '2020-01-15', 1, NULL);

INSERT INTO employees (first_name, last_name, email, salary, hire_date, department_id, manager_id)
VALUES ('Sadie', 'Adler', 'sadler@company.com', 95000, DATE '2021-03-01', 2, 1);

INSERT INTO employees (first_name, last_name, email, salary, hire_date, department_id, manager_id)
VALUES ('John', 'Marston', 'jmarston@company.com', 88000, DATE '2021-06-15', 2, 2);

INSERT INTO employees (first_name, last_name, email, salary, hire_date, department_id, manager_id)
VALUES ('Charles', 'Smith', 'csmith@company.com', 110000, DATE '2020-08-10', 3, 1);

INSERT INTO employees (first_name, last_name, email, salary, hire_date, department_id, manager_id)
VALUES ('Lenny', 'Summers', 'lsummers@company.com', 75000, DATE '2022-02-01', 3, 4);

INSERT INTO employees (first_name, last_name, email, salary, hire_date, department_id, manager_id)
VALUES ('Micah', 'Bell', 'mbell@company.com', 52000, DATE '2023-11-20', 4, 2);

-- Unassigned Employee (Department is NULL)
INSERT INTO employees (first_name, last_name, email, salary, hire_date, department_id, manager_id)
VALUES ('Hosea', 'Matthews', 'hmatthews@company.com', 99000, DATE '2019-11-01', NULL, NULL);

-- Customers
INSERT INTO customers (first_name, last_name, email, city, country, registered_at)
VALUES ('Alice', 'Vance', 'alice@blackmesa.gov', 'Seattle', 'USA', DATE '2023-01-10');

INSERT INTO customers (first_name, last_name, email, city, country, registered_at)
VALUES ('Gordon', 'Freeman', 'gfreeman@blackmesa.gov', 'Seattle', 'USA', DATE '2023-01-15');

INSERT INTO customers (first_name, last_name, email, city, country, registered_at)
VALUES ('Barney', 'Calhoun', 'bcalhoun@mesa.com', 'Phoenix', 'USA', DATE '2023-03-22');

INSERT INTO customers (first_name, last_name, email, city, country, registered_at)
VALUES ('G-Man', 'Unknown', 'gman@interdimensional.net', NULL, 'USA', DATE '2023-05-01');

INSERT INTO customers (first_name, last_name, email, city, country, registered_at)
VALUES ('Eli', 'Vance', 'eli@resistance.org', 'Toronto', 'Canada', DATE '2023-07-19');

-- Products
INSERT INTO products (product_name, category, unit_price, stock_quantity)
VALUES ('Mechanical Keyboard', 'Electronics', 129.99, 45);

INSERT INTO products (product_name, category, unit_price, stock_quantity)
VALUES ('Wireless Mouse', 'Electronics', 59.99, 120);

INSERT INTO products (product_name, category, unit_price, stock_quantity)
VALUES ('Ultra-Wide 34in Monitor', 'Electronics', 649.00, 18);

INSERT INTO products (product_name, category, unit_price, stock_quantity)
VALUES ('Ergonomic Chair', 'Furniture', 389.50, 12);

INSERT INTO products (product_name, category, unit_price, stock_quantity)
VALUES ('Standing Desk Converter', 'Furniture', 199.00, 8);

INSERT INTO products (product_name, category, unit_price, stock_quantity)
VALUES ('USB-C Hub Multiport', 'Accessories', 34.50, 0);

-- Orders
-- Order 1: Alice Vance (Customer 1), Rep: Sadie Adler (Emp 2)
INSERT INTO orders (customer_id, order_date, order_status, sales_rep_id)
VALUES (1, DATE '2024-01-05', 'DELIVERED', 2);

-- Order 2: Gordon Freeman (Customer 2), Rep: John Marston (Emp 3)
INSERT INTO orders (customer_id, order_date, order_status, sales_rep_id)
VALUES (2, DATE '2024-01-12', 'DELIVERED', 3);

-- Order 3: Alice Vance (Customer 1), Rep: Sadie Adler (Emp 2)
INSERT INTO orders (customer_id, order_date, order_status, sales_rep_id)
VALUES (1, DATE '2024-02-01', 'SHIPPED', 2);

-- Order 4: Barney Calhoun (Customer 3), Rep: NULL
INSERT INTO orders (customer_id, order_date, order_status, sales_rep_id)
VALUES (3, DATE '2024-02-18', 'PENDING', NULL);

-- Order Items
-- Items for Order 1
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (1, 1, 1, 129.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (1, 2, 2, 59.99);

-- Items for Order 2
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (2, 3, 1, 649.00);
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (2, 4, 1, 389.50);

-- Items for Order 3
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (3, 2, 1, 59.99);
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (3, 5, 1, 199.00);

-- Items for Order 4
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES (4, 1, 2, 129.99);

COMMIT;
