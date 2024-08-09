/*Sales Analysis*/
/*1.Identify Top-Selling Products*/
/*1.1.Determine which products have the highest sales quantities*/
SELECT 
    p.product_id,
    p.product_name,
    SUM(IFNULL(cp.quantity, 0)) AS total_quantity_sold
FROM 
    `farmers_market.product` p
LEFT JOIN 
    `farmers_market.customer_purchases` cp ON cp.product_id = p.product_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_quantity_sold DESC;
/*1.2.Monthly Revenue Trends*/
SELECT 
    FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP(cp.market_date)) AS months,
    SUM(cp.quantity * cp.cost_to_customer_per_qty) AS total_revenue
FROM 
    `farmers_market.customer_purchases` cp
GROUP BY months
ORDER BY months;
/*1.3.Cumilative_revenue*/
SELECT market_date,SUM(quantity * cost_to_customer_per_qty) OVER (ORDER BY market_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
AS cumulative_revenue FROM `farmers_market.customer_purchases`
ORDER BY  market_date;
/*1.4.High performing vendors*/
SELECT 
    v.vendor_id,
    v.vendor_name,
    SUM(IFNULL(cp.quantity, 0) * cp.cost_to_customer_per_qty) AS total_revenue
FROM vendor v LEFT JOIN customer_purchases cp ON cp.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY total_revenue DESC;



