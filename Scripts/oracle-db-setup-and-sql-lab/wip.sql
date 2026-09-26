SELECT
 * 
FROM products;



SELECT
product_name
FROM products;


SELECT
	product_name AS "Product Name",
	category AS "Product Category",
	unit_price AS "Unit Price",
	stock_quantity AS "Stock Quantity",
	CASE
		WHEN stock_quantity = 0 THEN 'Out of Stock'
		ELSE 'In Stock'
	END AS "Stock Status"	
FROM products; 


SELECT
	c.FIRST_NAME,
	c.LAST_NAME,
	c.FIRST_NAME || ' ' || c.LAST_NAME AS full_name, 
	c.EMAIL, 
	c.CITY 
FROM CUSTOMERS c;

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


SELECT 
    employee_id,
    first_name,
    last_name,
    salary
FROM employees
WHERE LOWER(last_name) LIKE '%a%'
  AND salary BETWEEN 70000 AND 115000
ORDER BY salary DESC;


SELECT 
    first_name,
    last_name,
    salary
FROM employees
ORDER BY salary DESC
FETCH FIRST 3 ROWS ONLY;



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


SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_employees DESC;


SELECT 
    d.department_name,
    COUNT(e.employee_id) AS total_employees
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY total_employees DESC;



SELECT 
* 
FROM EMPLOYEES e ;



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


SELECT 
    NVL2(d.department_name, d.department_name,'[Unassigned Dept]') AS department,
    NVL2(e.first_name, e.first_name || ' ' || e.last_name, '[No Employees]') AS employee_name
FROM departments d
FULL OUTER JOIN employees e ON d.department_id = e.department_id
ORDER BY department, employee_name;

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

SELECT 
    category,
    COUNT(product_id) AS total_products,
    ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category;

SELECT 
    category,
    COUNT(product_id) AS total_products,
    ROUND(AVG(unit_price), 2) AS avg_price
FROM products
GROUP BY category
HAVING AVG(unit_price) > 100
AND count(product_id) >= 2;



SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM ORDER_ITEMS oi ;
SELECT 
order_id,
product_id,
oi.UNIT_PRICE * oi.QUANTITY  AS "Total Spent"

SELECT 
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent DESC;

SELECT 
    e.first_name || ' ' || e.last_name AS sales_rep,
    COUNT(DISTINCT o.order_id) AS total_orders,
    NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_sales_volume
FROM employees e
JOIN orders o ON e.employee_id = o.sales_rep_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_sales_volume DESC;
FROM ORDER_ITEMS oi ;




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


SELECT 
        o.order_id,
        o.customer_id,
        o.order_date,
        SUM(oi.quantity * oi.unit_price) AS total_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.customer_id, o.order_date
    
    
    
    
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