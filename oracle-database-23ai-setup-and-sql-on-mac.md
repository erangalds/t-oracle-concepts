# Oracle Database 23ai on Mac (Docker) & SQL Mastery Guide

A complete, hands-on workbook designed to take you from a blank terminal on macOS to running Oracle Database locally in Docker, connecting via the command line and VS Code, understanding Oracle schema architecture, and mastering SQL querying and table operations.

## Table of Contents
+ Architecture & Core Concepts
+ Prerequisites & Docker Compose Setup
+ Connecting to Oracle Database
    + Method A: Terminal via Docker Exec
    + Method B: VS Code Oracle Extension
+ Setting Up the Practice User and Schema
+ E-Commerce Schema DDL & Seed Data
+ SQL Practice Exercises & Complete Solutions
    + Part 1: Filtering, Sorting & Null Handling (Q1–Q4)
    + Part 2: Joins (Inner, Left, Self, Full Outer) (Q5–Q8)
    + Part 3: Aggregations & Grouping (Q9–Q12)
    + Part 4: Subqueries & CTEs (Q13–Q16)
    + Part 5: DML Operations (Insert, Update, Delete, Merge) (Q17–Q19)
+ Common Oracle Errors & Troubleshooting1. 

## 1. Oracle Architecture & Core Concepts
Before writing queries, it helps to understand how Oracle differs from databases like PostgreSQL or MySQL:

1. CDB vs. PDB (Multitenant Architecture):
    + CDB (Container Database): The root database (e.g., `FREE` or `CDB$ROOT`). Used for system administration.
    + PDB (Pluggable Database): An isolated database instance inside the CDB (default in Docker: `FREEPDB1`). Always create your tables and run application queries inside the PDB, never in `CDB$ROOT`.
2. User = Schema:
    + In Oracle, a User and a Schema are the same thing. When you create a user named dev_user, an empty schema called dev_user is automatically created.
3. Case Sensitivity:
    + Oracle identifiers (table names, column names) are stored in uppercase by default. Writing `SELECT name FROM customers;` is processed as `SELECT NAME FROM CUSTOMERS;`.

## 2. Prerequisites & Docker Compose Setup

### Step 2.1: Prerequisites

+ macOS: Apple Silicon (M1/M2/M3/M4) or Intel.
+ Docker Desktop: Installed and running with at least 4 GB of RAM allocated (Docker Desktop -> Settings -> Resources -> Memory: 4 GB+).

### Step 2.2: Create Project Directory & Compose File 

Create a new directory on your Mac and navigate into it:

```bash 
mkdir -p ~/oracle-docker && cd ~/oracle-docker
```

Create a file named `docker-compose.yml`:

```yml
services:
  oracle-db:
    image: gvenzl/oracle-free:latest
    container_name: oracle23ai
    restart: unless-stopped
    ports:
      - "1521:1521"
    environment:
      # Master password for SYS and SYSTEM administrative accounts
      - ORACLE_PASSWORD=Oracle123
      # Name of the pluggable database
      - ORACLE_DATABASE=FREEPDB1
      # Optional: automatically provision an application developer user
      - APP_USER=dev_user
      - APP_USER_PASSWORD=Oracle123
    volumes:
      # Retains all database files across container rebuilds
      - oracle_data:/opt/oracle/oradata
    healthcheck:
      test: ["CMD-SHELL", "healthcheck.sh"]
      interval: 15s
      timeout: 10s
      retries: 20
      start_period: 40s

volumes:
  oracle_data:
    driver: local
```

Note for Apple Silicon (M-series Macs): The image `gvenzl/oracle-free:latest` contains native `linux/arm64` images for Oracle 23ai, so it runs at full native speed without Rosetta emulation.

### Step 2.3: Start the ContainerStart the container in the background:

```bash
docker compose up -d
```

Monitor initialization logs:

```bash
docker compose logs -f oracle-db
```

Wait until you see:
`DATABASE IS READY TO USE!`

Press `Ctrl + C` to exit log streaming.

## 3. Connecting to Oracle Database

### Method A: Terminal via Docker Exec

1. Connect as Administrative User (SYSTEM) to the PDB:

```bash
docker exec -it oracle23ai sqlplus system/Oracle#123@//localhost:1521/FREEPDB1
```

2. Connect as the Application User (dev_user):

```bash
docker exec -it oracle23ai sqlplus dev_user/DevPass2026#@//localhost:1521/FREEPDB1
```
Basic **SQL*Plus** Navigation Commands:

+ Exit SQL*Plus: `exit`; or `quit`;

+ Clear formatting / set page width:

```sql
SET LINESIZE 200;
SET PAGESIZE 50;
```

Run a quick health check:

```sql
SELECT sys_context('USERENV', 'CON_NAME') AS current_container, USER FROM dual;
```

### Method B: VS Code Oracle Extension

1. Open VS Code.
2. Go to Extensions (`Cmd + Shift + X`) and search for:
    + Oracle Developer Tools for VS Code (SQL and PL/SQL) by Oracle.
3. Click Install.
4. In the left activity bar, click the new Database / Oracle icon.
5. In the connections pane, click the + (New Connection) button and enter the following settings:
    + Connection Type: `Basic`
    + Role: `Default`
    + User Name: `dev_user`
    + Password: `DevPass2026#` (check Save Password)
    + Host Name: `localhost`
    + Port: `1521`
    + Type: `Service Name`
    + Service Name: `FREEPDB1`
6. Click Test Connection. Once successful, click Save Connection.
7. Open a new SQL file (practice.sql), right-click inside the editor, select Change Connection, and select your `dev_user` profile. Run queries using `Ctrl + Enter` or `Cmd + Enter`.

## 4. Setting Up the Practice User and Schema
If you ever need to manually recreate or configure permissions for a practice user, connect as SYSTEM:

```bash
docker exec -it oracle23ai sqlplus system/Oracle123@//localhost:1521/FREEPDB1
```

Run the following administrative SQL statements:

```sql
-- Ensure we are in the pluggable database
ALTER SESSION SET CONTAINER = FREEPDB1;

-- Create the developer user (if not created via compose)
CREATE USER dev_user IDENTIFIED BY "Oracle123";

-- Grant basic connection, resource management, and view creation permissions
GRANT CONNECT, RESOURCE, CREATE VIEW, CREATE SEQUENCE TO dev_user;

-- Grant unlimited storage space in the users tablespace
ALTER USER dev_user QUOTA UNLIMITED ON USERS;

EXIT;
```


## 5. E-Commerce Schema DDL & Seed Data

Connect as `dev_user` in `dbeaver` or `SQL*Plus` before executing the scripts below. Open the script below. 

Open the script `clean-existing-environment.sql` and run the entire script. This will delete if these tables are already in the schema. 

### 5.1 DDL (Table Definitions)-- Clean up previous tables if re-running

```sql
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE order_items CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE orders CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE products CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE customers CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE employees CASCADE CONSTRAINTS';
  EXECUTE IMMEDIATE 'DROP TABLE departments CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/
```

Next, we need to create the tables required for the lab. For that open the script, `create-tables.sql`. Run the entire script at once or else you can run one by one to see how it works. 


```sql
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
```


### 5.2 DML (Sample Data)-- Departments

Now we have created the tables, the next step is to load some data into those tables. You can run either run the entire script at once or run section by section. 

```sql
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
```


## 6. SQL Practice Exercises & Complete Solutions

Work through the questions first, then review the query and explanation provided below each problem.

### Part 1: Filtering, Sorting & Null Handling

#### Exercise 1: Basic Filtering and Column Aliasing

**Task:** Find the product name, unit price, and stock status for all products. If a product has a stock quantity of 0, show the status as 'Out of Stock', otherwise 'In Stock'. Sort by unit price descending.

```sql
SELECT 
    product_name,
    unit_price,
    stock_quantity,
    CASE 
        WHEN stock_quantity = 0 THEN 'Out of Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM products
ORDER BY unit_price DESC;
```

**Explanation:** Uses Oracle's standard `CASE` expression for conditional logic and aliases the result column as `stock_status`.

#### Exercise 2: Null Checks and String Substitution

**Task:** List all customers. Show their full name (first and last name combined), email, and city. If the city is null, display 'Unknown Location'.

```sql
-- Option 1: Using NVL
SELECT 
    first_name || ' ' || last_name AS full_name,
    email,
    NVL(city, 'Unknown Location') AS city
FROM customers
ORDER BY full_name;

-- Option 2: using COALESCE
SELECT 
    first_name || ' ' || last_name AS full_name,
    email,
    COALESCE(city, 'Unknown Location') AS city
FROM customers
ORDER BY full_name;
```

**Explanation:** `||` is Oracle's string concatenation operator.`NVL(expr1, expr2)` returns `expr2` if `expr1` is `NULL`. You can also use standard `COALESCE(city, 'Unknown Location')`.

#### Exercise 3: Pattern Matching and Salary Range

**Task:** Find all employees whose last name contains the letter 'a' (case-insensitive) and whose salary is between $70,000 and $115,000.

```sql
SELECT 
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE LOWER(last_name) LIKE '%a%'
  AND salary BETWEEN 70000 AND 115000
ORDER BY salary DESC;
```

**Explanation:** `LOWER()` normalizes the column to guarantee case-insensitive matching regardless of database collation settings.

#### Exercise 4: Oracle Pagination (Row Limiting)

**Task:** Retrieve the top 3 highest-earning `employees` using Oracle's native `FETCH FIRST` syntax.

```sql
SELECT 
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 3 ROWS ONLY;
```

**Explanation:** Oracle 12c+ supports the ANSI-standard `OFFSET` ... `FETCH FIRST` ... `ROWS ONLY` syntax, avoiding older nested `ROWNUM` subqueries.Part 2: Joins (Inner, Left, Self, Full Outer)

#### Exercise 5: Multi-table Inner Join

**Task:** Produce a breakdown of all orders showing: Order ID, Order Date, Customer Full Name, Product Name, Quantity Ordered, and Item Total (Quantity $\times$ Unit Price).

```sql
SELECT 
    o.order_id,
    o.order_date,
    c.first_name || ' ' || c.last_name AS customer_name,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price) AS item_total
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
ORDER BY o.order_id, item_total DESC;
```

**Explanation:** Connects four tables: `orders` to `customers` via `customer_id`, to `order_items` via `order_id`, and to `products` via `product_id`.

#### Exercise 6: Left Join to Find Inactive Entities

**Task:** List all departments along with the total count of employees in each department. Departments with zero employees must still appear in the list with a count of 0.

```sql
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_employees DESC;
```

**Explanation:** A LEFT JOIN keeps all departments even if there is no match in `employees`.`COUNT(e.employee_id)` counts non-null employee IDs, accurately showing 0 for empty departments (using `COUNT(*)` would incorrectly return 1).

#### Exercise 7: Self Join (Employee Hierarchy)

**Task:** Write a query displaying each employee's full name, their `salary`, and their direct manager's full name. If an employee has no manager, display 'No Manager'.

```sql
-- Option 1 : with CASE
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.salary,
    CASE 
        WHEN mgr.employee_id IS NULL THEN 'No Manager'
        ELSE mgr.first_name || ' ' || mgr.last_name
    END AS manager_name
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY emp.salary DESC;

-- Option 2: with NVL2
SELECT 
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.salary,
    NVL2(mgr.employee_id, mgr.first_name || ' ' || mgr.last_name, 'No Manager') AS manager_name
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY emp.salary DESC;
```

**Explanation:** Joins the employees table back onto itself. An outer join ensures top-level executives (where `manager_id IS NULL`) are not excluded.

#### Exercise 8: Full Outer Join

**Task:** Retrieve all departments and all employees, ensuring you see:

+ Employees assigned to departments.
+ Employees with no department.
+ Departments with no employees.

```sql
SELECT 
    NVL2(d.department_name, d.department_name,'[Unassigned Dept]') AS department,
    NVL2(e.first_name, e.first_name || ' ' || e.last_name, '[No Employees]') AS employee_name
FROM departments d
FULL OUTER JOIN employees e ON d.department_id = e.department_id
ORDER BY department, employee_name;
```

**Explanation:** A `FULL OUTER JOIN` preserves unmatched rows from both sides of the join condition.

### Part 3: Aggregations & Grouping


#### Exercise 9: Department Salary Statistics

**Task:** For each department, calculate the number of employees, the average `salary` (rounded to 2 decimal places), the minimum `salary`, and the maximum `salary`. Include only departments with at least 1 employee.

```sql
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS num_employees,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    MIN(e.salary) AS min_salary,
    MAX(e.salary) AS max_salary
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY avg_salary DESC;
```

#### Exercise 10: Filtering Aggregates with HAVING

**Task:** Find the categories of products that have an average unit price greater than $100 and contain at least 2 distinct products in inventory.

```sql
SELECT 
    category,
    COUNT(product_id) AS total_products,
    ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(unit_price) > 100
   AND COUNT(product_id) >= 2;
```

**Explanation:** `WHERE` filters individual rows before grouping; `HAVING` filters aggregated buckets after the `GROUP BY` calculation.

#### Exercise 11: Total Revenue per Customer

**Task:** Calculate the total amount spent across all completed or active orders (DELIVERED, SHIPPED, or PENDING) by each customer. Include customers who haven't placed any orders yet (showing $0.00 spent).

```sql
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;
```

**Explanation:** Successive `LEFT JOIN`s preserve customers who have no orders or order items. `NVL(..., 0)` handles `null` sums.

#### Exercise 12: Sales Representative Performance

**Task:** Show each sales representative's full name and the total dollar value of the orders they managed.

```sql
SELECT 
    e.first_name || ' ' || e.last_name AS sales_rep,
    COUNT(DISTINCT o.order_id) AS total_orders,
    NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_sales_volume
FROM employees e
JOIN orders o ON e.employee_id = o.sales_rep_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_sales_volume DESC;
```

### Part 4: Subqueries & CTEs

#### Exercise 13: Scalar Subquery in WHERE Clause

**Task:** Find all employees whose salary is strictly greater than the average salary of the entire company.

```sql
SELECT 
    first_name,
    last_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary) 
    FROM employees
)
ORDER BY salary DESC;
```

#### Exercise 14: Correlated Subquery

**Task:** Find all employees who earn more than the average salary of their specific department.

```sql
SELECT 
    e.first_name,
    e.last_name,
    e.salary,
    e.department_id
FROM employees e
WHERE e.salary > (
    SELECT AVG(sub.salary)
    FROM employees sub
    WHERE sub.department_id = e.department_id
)
ORDER BY e.department_id, e.salary DESC;
```

**Explanation:** The inner query references e.department_id from the outer row. The database executes the subquery dynamically for each candidate row in employees.

#### Exercise 15: Subquery with NOT EXISTS

**Task:** Find all customers who have never placed an order.

```sql
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
FROM customers c
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders o 
    WHERE o.customer_id = c.customer_id
);
```

**Explanation:** `NOT EXISTS` is null-safe and generally more performant than `NOT IN (SELECT customer_id FROM orders)` when customer_id contains or allows nulls.

#### Exercise 16: Common Table Expressions (CTE / WITH Clause)

**Task:** Using a `CTE`, calculate the total spending per order, then retrieve only the orders whose total value is greater than $500.

```sql
-- First Creating the Temporary Virtual Table as a CTE
WITH order_totals AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS total_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id, o.order_date
)
-- Then Using that in the later SELECT Query
SELECT 
    ot.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    ot.order_date,
    ot.total_value
FROM order_totals ot
JOIN customers c ON ot.customer_id = c.customer_id
WHERE ot.total_value > 500
ORDER BY ot.total_value DESC;
```

**Explanation:** `CTE`s make complex queries modular, reusable, and readable by establishing temporary named result sets.


### Part 5: DML Operations

#### Exercise 17: Insert with Subquery

**Task:** Create a table called `high_earners` (with columns `emp_id,` `full_name`, `salary`) and populate it directly with `employees` earning more than $90,000 using an `INSERT INTO ... SELECT` statement.

```sql
CREATE TABLE high_earners (
    emp_id    NUMBER PRIMARY KEY,
    full_name VARCHAR2(100),
    salary    NUMBER(10, 2)
);

INSERT INTO high_earners (emp_id, full_name, salary)
SELECT 
    employee_id,
    first_name || ' ' || last_name,
    salary
FROM employees
WHERE salary > 90000;

COMMIT;

-- Verify results:
SELECT * FROM high_earners;
Exercise 18: Correlated UPDATETask: Give a 10% salary raise to all employees who work in the 'Sales' department.UPDATE employees
SET salary = salary * 1.10
WHERE department_id = (
    SELECT department_id 
    FROM departments 
    WHERE department_name = 'Sales'
);

COMMIT;

-- Verify the update:
SELECT first_name, last_name, salary 
FROM employees 
WHERE department_id = (SELECT department_id FROM departments WHERE department_name = 'Sales');
```

#### Exercise 19: The Oracle MERGE Statement (Upsert)

**Task:** Write an Oracle `MERGE` statement to update the product inventory. If the product 'Mechanical Keyboard' exists, increase its stock by 10. If it does not exist, insert it with price $129.99 and stock 10.

```sql
MERGE INTO products target
USING (
    SELECT 'Mechanical Keyboard' AS product_name,
           'Electronics'         AS category,
           129.99                AS unit_price,
           10                    AS added_quantity
    FROM dual
) source
ON (target.product_name = source.product_name)
WHEN MATCHED THEN
    UPDATE SET target.stock_quantity = target.stock_quantity + source.added_quantity
WHEN NOT MATCHED THEN
    INSERT (product_name, category, unit_price, stock_quantity)
    VALUES (source.product_name, source.category, source.unit_price, source.added_quantity);

COMMIT;

-- Verify the stock change:
SELECT product_name, stock_quantity FROM products WHERE product_name = 'Mechanical Keyboard';
```

**Explanation:** The `MERGE` statement is Oracle's native `UPSERT` mechanism. It cleanly executes conditional inserts or updates in a single atomic transaction.