-- Exercise 1
-- FInd the product name, unit price, and stock status for all products. If a product has a stock quantity of 0, show the status as 'Out of Stock' otherwise 'In Stock'.
SELECT * 
FROM products;

SELECT 
product_name, 
unit_price,
stock_quantity,
CASE
    WHEN stock_quantity = 0 THEN 'Out of Stock'
    ELSE 'In Stock'
END
FROM products
ORDER BY unit_price DESC;

-- Exercise 2
-- List all customers. Show their full name (first and last name combined), email and city. If the city is null, display 'Unknown Location' 
SELECT 
    first_name || ' ' || last_name AS full_name,
    email,
    NVL(city, 'Unknown Location') AS city
FROM customers
ORDER BY full_name;

SELECT 
    first_name || ' ' || last_name AS full_name,
    email,
    COALESCE(city, 'Unknown Location') AS city
FROM customers
ORDER BY full_name;


-- Exercise 3: Pattern Matching and Salary Range
-- Find all employees whose last name contains the letter 'a' (case-insensitive) and whose salary is between $70,000 and $115,000.
SELECT 
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE LOWER(last_name) LIKE '%a%'
  AND salary BETWEEN 70000 AND 115000
ORDER BY salary DESC;

-- Exercise 4: Oracle Pagination
-- Retrieve the top 3 highest-earning employees using Oracle's native FETCH FIRST syntax.
SELECT 
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 3 ROWS ONLY;


-- JOINS
-- Exercise 5: Multi Table Inner Join
-- Produce a breakdown of all orders showing: Order ID, Order Date, Customer Full Name, Product Name, Quantity Ordered, and Item Total (Quantity x Unit Price).
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

-- Exercise 6: Left Join to Find Inactive Entities
-- List all departments along with the total count of employees in each department. Departments with zero employees must still appear in the list with a count of 0.
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_employees DESC;

-- Exercise 7: Self JOIN (Employee Hierarchy)
-- Write a query displaying each employee's full name, their salary, and their direct manager's full name. If an employee has no manager, display 'No Manager'.
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

SELECT 
    emp.first_name || ' ' || emp.last_name AS employee_name,
    emp.salary,
    NVL2(mgr.employee_id, mgr.first_name || ' ' || mgr.last_name, 'No Manager') AS manager_name
FROM employees emp
LEFT JOIN employees mgr ON emp.manager_id = mgr.employee_id
ORDER BY emp.salary DESC;

-- Exercise 8: Full Outer JOIN
-- Task: Retrieve all departments and all employees, ensuring you see:
-- Employees assigned to departments.
-- Employees with no department.
-- Departments with no employees.
SELECT 
    NVL2(d.department_name, d.department_name,'[Unassigned Dept]') AS department,
    NVL2(e.first_name, e.first_name || ' ' || e.last_name, '[No Employees]') AS employee_name
FROM departments d
FULL OUTER JOIN employees e ON d.department_id = e.department_id
ORDER BY department, employee_name;

-- Part 3: Aggregating & Grouping

-- Exercise 9: Department Salary Statistics
-- For each department, calculate the number of employees, the average salary (rounded to 2 decimal places), 
-- the minimum salary, and the maximum salary. Include only departments with at least 1 employee.
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

-- Exercise 10: Filtering Aggregates with HAVING
-- Find the categories of products that have an average unit price greater than $100 and contain at least 2 distinct products in inventory.
SELECT 
    category,
    COUNT(product_id) AS total_products,
    ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(unit_price) > 100
   AND COUNT(product_id) >= 2;


-- Exercise 11: Total Revenue per Customer
-- Calculate the total amount spent across all completed or active orders (DELIVERED, SHIPPED, or PENDING) by each customer. 
-- Include customers who haven't placed any orders yet (showing $0.00 spent).
SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

-- Exercise 12: Sales Representative Performance
-- Show each sales representative's full name and the total dollar value of the orders they managed.
SELECT 
    e.first_name || ' ' || e.last_name AS sales_rep,
    COUNT(DISTINCT o.order_id) AS total_orders,
    NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_sales_volume
FROM employees e
JOIN orders o ON e.employee_id = o.sales_rep_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_sales_volume DESC;

-- Part 4: Subqueries and CTEs

-- Exercise 13: Scalar Subquery in WHERE Clause
-- Find all employees whose salary is strictly greater than the average salary of the entire company.
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

-- Exercise 14: Correlated Subquery
-- Find all employees who earn more than the average salary of their specific department.
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


-- Exercise 15: Subquery with NOT EXISTS
-- Find all customers who have never placed an order.
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

-- Exercise 16: Common Table Expressions (CTE / WITH Clause)
-- Using a CTE, calculate the total spending per order, then retrieve only the orders whose total value is greater than $500.
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
SELECT 
    ot.order_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    ot.order_date,
    ot.total_value
FROM order_totals ot
JOIN customers c ON ot.customer_id = c.customer_id
WHERE ot.total_value > 500
ORDER BY ot.total_value DESC;


-- PART 5: DML Operations

-- Exercise 17: Insert with Subquery
-- Create a table called high_earners (with columns emp_id, full_name, salary) and populate it directly with employees earning more than $90,000 using an INSERT INTO ... SELECT statement.
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

 -- Exercise 18: Correlated UPDATE
-- Give a 10% salary raise to all employees who work in the 'Sales' department.
UPDATE employees
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

-- The Oracle MERGE Statement (UPSERT)
-- Write an Oracle MERGE statement to update the product inventory. If the product 'Mechanical Keyboard' exists, increase its stock by 10. If it does not exist, insert it with price $129.99 and stock 10.
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

















