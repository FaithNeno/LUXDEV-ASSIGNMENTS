



ADVANCED ANALYTICAL QUESTIONS
-- =====================================================

-- 81. Which customers bought products in more than one category?
select*from assignment.sales;

SELECT c.customer_id, c.first_name, c.last_name
FROM assignment.customers c
JOIN assignment.sales s 
    ON c.customer_id = s.customer_id
JOIN assignment.products p 
    ON s.product_id = p.product_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT p.category) > 1;

-- 82. Which customers purchased products within 7 days of registering?

SELECT DISTINCT c.customer_id, c.first_name, c.last_name
FROM assignment.customers c
JOIN assignment.sales s 
    ON c.customer_id = s.customer_id
WHERE s.sale_date <= c.registration_date + INTERVAL '7 days';

-- 83. Which products have lower stock remaining than the average stock quantity?

SELECT *
FROM assignment.products
WHERE stock_quantity < (
    SELECT AVG(stock_quantity) FROM assignment.products
);


-- 84. Which customers purchased the same product more than once?


SELECT customer_id, product_id, COUNT(*) AS purchase_count
FROM assignment.sales
GROUP BY customer_id, product_id
HAVING COUNT(*) > 1;

-- 85. Which product categories generated the highest total revenue?
SELECT p.category, SUM(s.total_amount) AS total_revenue
FROM assignment.sales s
JOIN assignment.products p 
    ON s.product_id = p.product_id
GROUP BY p.category
ORDER BY total_revenue DESC;

-- 86. Which products are among the top 3 most sold products?
SELECT product_id, SUM(quantity_sold) AS total_quantity
FROM assignment.sales
GROUP BY product_id
ORDER BY total_quantity DESC
LIMIT 3;


-- 87. Which customers purchased the most expensive product?

SELECT c.customer_id, c.first_name, c.last_name,
       p.product_name, p.price
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
JOIN assignment.products p ON s.product_id = p.product_id
WHERE p.price = (
    SELECT MAX(price)
    FROM assignment.products
);

-- 88. Which products were purchased by the highest number of unique customers?
SELECT product_id, COUNT(DISTINCT customer_id) AS customer_count
FROM assignment.sales
GROUP BY product_id
ORDER BY customer_count DESC;

-- 89. Which customers made purchases above the average sale amount?
SELECT DISTINCT c.customer_id, c.first_name, c.last_name,
       s.total_amount
FROM assignment.customers c
JOIN assignment.sales s ON c.customer_id = s.customer_id
WHERE s.total_amount > (
    SELECT AVG(total_amount)
    FROM assignment.sales
)
ORDER BY s.total_amount DESC
-- 90. Which customers purchased more products than the average quantity purchased per customer?
WITH customer_qty AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(s.quantity_sold) AS total_qty
    FROM assignment.customers c
    JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT *
FROM customer_qty
WHERE total_qty > (
    SELECT AVG(total_qty) FROM customer_qty
);


-- =====================================================
-- ADVANCED WINDOW + ANALYTICAL PROBLEMS
-- =====================================================

-- 91. Which customers rank in the top 10% of spending?

WITH customer_spending AS (
    SELECT c.customer_id, c.first_name, c.last_name,
           SUM(s.total_amount) AS total_spent,
           NTILE(10) OVER (ORDER BY SUM(s.total_amount) DESC) AS percentile_group
    FROM assignment.customers c
    JOIN assignment.sales s ON c.customer_id = s.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT customer_id, first_name, last_name, total_spent
FROM customer_spending
WHERE percentile_group = 1; 



-- 92. Which products contribute to the top 50% of total revenue?

SELECT *
FROM (
    SELECT product_id,
           SUM(total_amount) AS total_revenue,
           SUM(SUM(total_amount)) OVER (ORDER BY SUM(total_amount) DESC) AS running_total,
           SUM(SUM(total_amount)) OVER () AS overall_total
    FROM assignment.sales
    GROUP BY product_id
) 
WHERE running_total <= 0.5 * overall_total;

-- 93. Which customers made purchases in consecutive months?
SELECT DISTINCT customer_id
FROM (
    SELECT customer_id,
           TO_CHAR(sale_date, 'YYYY-MM') AS sale_month,
           LAG(TO_CHAR(sale_date, 'YYYY-MM')) 
               OVER (PARTITION BY customer_id ORDER BY sale_date) AS prev_month
    FROM assignment.sales
) t
WHERE prev_month IS NOT NULL
  AND sale_month = TO_CHAR(
        TO_DATE(prev_month, 'YYYY-MM') + INTERVAL '1 month',
        'YYYY-MM'
  );

-- 94. Which products experienced the largest difference between stock quantity and total quantity sold?

-- 95. Which customers have spending above the average spending of their membership tier?

-- 96. Which products have higher sales than the average sales within their category?

-- 97. Which customer made the largest single purchase relative to their total spending?

-- 98. Which products rank among the top 3 most sold products within each category?

-- 99. Which customers are tied for the highest total spending?

-- 100. Which products generated sales every year present in the dataset?