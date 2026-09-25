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