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
/*2.Customer Segmentation*/
/*2.1.Segment customers based on purchasing behavior and demographics*/
SELECT 
    c.customer_zip,
    COUNT(c.customer_id) AS num_customers,
    AVG(cp.total_spent) AS avg_spent_per_customer,
    SUM(cp.total_spent) AS total_spent
FROM 
    `farmers_market.customer` c
JOIN 
    (SELECT 
         customer_id, 
         SUM(quantity * cost_to_customer_per_qty) AS total_spent
     FROM 
         `farmers_market.customer_purchases`
     GROUP BY 
         customer_id) cp
ON 
    c.customer_id = cp.customer_id
GROUP BY 
    c.customer_zip
ORDER BY 
    total_spent DESC;
/*2.2.Identifying Customer Segments Based on Spending Patterns*/
SELECT 
    c.customer_id,
    c.customer_zip,
    CASE 
        WHEN cp.total_spent > 1000 THEN 'High Spender'
        WHEN cp.total_spent BETWEEN 500 AND 1000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS spending_segment
FROM 
    `farmers_market.customer` c
JOIN 
    (SELECT 
         customer_id, 
         SUM(quantity * cost_to_customer_per_qty) AS total_spent
     FROM 
         `farmers_market.customer_purchases`
     GROUP BY 
         customer_id) cp
ON 
    c.customer_id = cp.customer_id
ORDER BY 
    spending_segment;
/*3.Product Performance*/
SELECT 
    p.product_id,
    p.product_name,
    pc.product_category_name,
    SUM(cp.quantity) AS total_quantity_sold,
    SUM(cp.quantity * cp.cost_to_customer_per_qty) AS total_revenue
FROM 
    `farmers_market.product` p
JOIN 
    `farmers_market.customer_purchases` cp ON cp.product_id = p.product_id
JOIN 
    `farmers_market.product_category` pc ON p.product_category_id = pc.product_category_id
GROUP BY 
    p.product_id, p.product_name, pc.product_category_name
HAVING 
    SUM(cp.quantity * cp.cost_to_customer_per_qty) > 100  -- Threshold for high performance
ORDER BY 
    total_revenue DESC;
/*4.Booth analysis*/
/*4.1.Analyzing Booth Occupancy Rates*/
SELECT 
    b.booth_number,
    b.booth_price_level,
    COUNT(vba.vendor_id) AS occupancy_count,
FROM 
    `farmers_market.booth` b
LEFT JOIN 
    `farmers_market.vendor_booth_assignments` vba ON b.booth_number = vba.booth_number
LEFT JOIN
    `farmers_market.market_date_info` mdi ON vba.market_date = mdi.market_date
GROUP BY 
    b.booth_number, b.booth_price_level

/*5.Impact of weather on market sales and attendance*/
SELECT 
    m.market_date,
    SUM(cp.quantity * cp.cost_to_customer_per_qty) AS total_sales,
    m.market_min_temp,
    m.market_max_temp,
    m.market_rain_flag,
    m.market_snow_flag
FROM 
    `farmers_market.market_date_info` m
LEFT JOIN 
    `farmers_market.customer_purchases` cp ON m.market_date = cp.market_date
GROUP BY 
    m.market_date, m.market_min_temp, m.market_max_temp, m.market_rain_flag, m.market_snow_flag
ORDER BY 
    m.market_date;
/*6.Vendor analysis*/
/*6.1.High performing vendors*/
SELECT 
    v.vendor_id,
    v.vendor_name,
    SUM(IFNULL(cp.quantity, 0) * cp.cost_to_customer_per_qty) AS total_revenue
FROM vendor v LEFT JOIN customer_purchases cp ON cp.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.vendor_name
ORDER BY total_revenue DESC;



