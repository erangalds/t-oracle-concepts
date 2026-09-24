
-- 1. Departments Table
CREATE TABLE departments (
    department_id   NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    department_name VARCHAR2(100) NOT NULL,
    location        VARCHAR2(100)
);

-- 2. Employees Table (includes Self-Referencing Foreign Key for Manager)
CREATE TABLE employees (
    employee_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR2(50) NOT NULL,
    last_name       VARCHAR2(50) NOT NULL,
    email           VARCHAR2(100) UNIQUE NOT NULL,
    salary          NUMBER(10, 2) NOT NULL,
    hire_date       DATE DEFAULT SYSDATE NOT NULL,
    department_id   NUMBER REFERENCES departments(department_id),
    manager_id      NUMBER REFERENCES employees(employee_id)
);

-- 3. Customers Table
CREATE TABLE customers (
    customer_id     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name      VARCHAR2(50) NOT NULL,
    last_name       VARCHAR2(50) NOT NULL,
    email           VARCHAR2(100) UNIQUE NOT NULL,
    city            VARCHAR2(50),
    country         VARCHAR2(50) DEFAULT 'USA' NOT NULL,
    registered_at   DATE DEFAULT SYSDATE NOT NULL
);

-- 4. Products Table
CREATE TABLE products (
    product_id      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_name    VARCHAR2(150) NOT NULL,
    category        VARCHAR2(50) NOT NULL,
    unit_price      NUMBER(10, 2) NOT NULL,
    stock_quantity  NUMBER DEFAULT 0 NOT NULL
);

-- 5. Orders Table
CREATE TABLE orders (
    order_id        NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id     NUMBER NOT NULL REFERENCES customers(customer_id),
    order_date      DATE DEFAULT SYSDATE NOT NULL,
    order_status    VARCHAR2(20) DEFAULT 'PENDING' CHECK (order_status IN ('PENDING', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    sales_rep_id    NUMBER REFERENCES employees(employee_id)
);

-- 6. Order Items Table
CREATE TABLE order_items (
    item_id         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id        NUMBER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id      NUMBER NOT NULL REFERENCES products(product_id),
    quantity        NUMBER NOT NULL CHECK (quantity > 0),
    unit_price      NUMBER(10, 2) NOT NULL
);
