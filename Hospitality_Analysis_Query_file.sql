use hospitality;
# 1 Total revenue 
SELECT 
    CONCAT(ROUND(SUM(revenue_realized) / 1000000000,
                    2),
            ' B') AS totalrevenue
FROM
    fact_bookings;

# 2 Country wise revenue generated

SELECT 
    country,
    CONCAT(ROUND(SUM(revenue_realized) / 1000000, 1),
            ' M') AS revenue,sum(no_guests) Guest_Count,count(booking_id) Bookings_Count
FROM
    fact_bookings
GROUP BY country;

-- 3 Average rating given by customers 
SELECT 
    ROUND(AVG(nullif(ratings_given,"")), 2) AS average_rating
FROM
    fact_bookings;

-- 4 Booking platform 
SELECT 
    booking_platform,
    CONCAT(ROUND(SUM(revenue_realized) / 1000000, 2),
            ' M') AS revenue
FROM
    fact_bookings
GROUP BY booking_platform;

-- 5 City, property wise revenue 
SELECT 
    dh.city,
    dh.property_name,
    CONCAT(ROUND(SUM(fb.revenue_realized) / 1000000, 2),
            ' M') AS total_revenue
FROM
    fact_bookings fb
        JOIN
    dim_hotels dh ON fb.property_id = dh.property_id
GROUP BY dh.city , dh.property_name
ORDER BY total_revenue DESC;

-- 6 Stored procedure: Bookings and revenue by customer age

DELIMITER $$

CREATE PROCEDURE spending(IN age INT)
BEGIN
    SELECT 
        customer_age,
        COUNT(booking_id) AS total_bookings,
        CONCAT(ROUND(SUM(revenue_realized) / 1000000, 1),
            ' M') AS total_revenue
    FROM 
        fact_bookings
    WHERE 
        customer_age = age
    GROUP BY 
        customer_age;
END$$

DELIMITER ;

CALL spending(20);

-- 7 Index

create index Property on fact_bookings(property_id);
select
	property_id, room_category, sum(no_guests) as Guest_count 
from 
	fact_bookings where property_id = 16558 
group by 
	property_id, room_category;
    
-- 8 Month-wise Revenue
SELECT 
    monthname(str_to_date(booking_date,"%d-%m-%Y")) as Month,
    CONCAT(ROUND(SUM(revenue_realized) / 1000000, 2), ' M') AS monthly_revenue
FROM 
	fact_bookings
GROUP BY month; 

desc fact_bookings;

-- 9 Guests by City
SELECT 
    dh.city,
    SUM(fb.no_guests) AS total_guests
FROM fact_bookings fb
JOIN 
	dim_hotels dh 
ON fb.property_id = dh.property_id
GROUP BY dh.city
ORDER BY total_guests desc;

-- 10 Most popular room category
SELECT 
    room_category,
    COUNT(booking_id) AS total_bookings
FROM 
	fact_bookings
GROUP BY room_category
ORDER BY total_bookings DESC
LIMIT 1;

-- 11 Revenue contribution% by country
SELECT 
    country,
    CONCAT(ROUND(100 * SUM(revenue_realized) / (SELECT SUM(revenue_realized) FROM fact_bookings), 2), '%') AS revenue_share
FROM 
	fact_bookings
GROUP BY country
ORDER BY revenue_share DESC;

-- 12 Customer age group analysis
SELECT 
    CASE 
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '50+'
    END AS age_group,
    COUNT(booking_id) AS total_bookings,
    CONCAT(ROUND(SUM(revenue_realized)/1000000,2),' M') AS total_revenue
FROM 
	fact_bookings
GROUP BY age_group
ORDER BY total_revenue DESC;



