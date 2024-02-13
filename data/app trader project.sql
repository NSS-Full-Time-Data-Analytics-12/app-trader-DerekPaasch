SELECT *
FROM app_store_apps;

SELECT *
FROM play_store_apps;


SELECT *
FROM app_store_apps INNER JOIN play_store_apps USING(name);

--a. Develop some general recommendations about the price range, genre, content rating, or any other app characteristics that the company should target.
--GENERAL RECOMMENDATIONS:
--app should be free
--should have a rating >=4
--arcade/games
--rating should be everyhone for broader audience, more users


SELECT DISTINCT(name), install_count, a1.price, p1.price, a1.rating, p1.rating
FROM app_store_apps AS a1 FULL JOIN play_store_apps AS p1 USING(name)
WHERE a1.rating >=4 AND a1.price = 0.00
GROUP BY a1.name, p1.name, install_count, a1.price, p1.price, a1.rating, p1.rating
ORDER BY install_count, a1.rating DESC
LIMIT 10;


SELECT DISTINCT name, app_store_apps.price AS app_price, app_store_apps.rating AS app_rating , app_store_apps.content_rating AS app_content_rating, play_store_apps.price AS play_price, play_store_apps.rating AS play_rating, primary_genre AS app_genre, genres AS play_genre,
play_store_apps.content_rating AS play_content_rating
FROM app_store_apps
	INNER JOIN play_store_apps USING (name)
WHERE app_store_apps.review_count::numeric >12892.91 AND play_store_apps.review_count::numeric > 444152.90 AND app_store_apps.rating > 4 AND app_store_apps.price = 0.00 AND app_store_apps.content_rating = '4+'
ORDER BY play_store_apps.rating DESC, app_store_apps.rating DESC
LIMIT 10;

-----------------------------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT name, app_store_apps.price AS app_price, app_store_apps.rating AS app_rating , app_store_apps.content_rating AS app_content_rating, play_store_apps.price AS play_price, play_store_apps.rating AS play_rating, primary_genre AS app_genre, genres AS play_genre,
play_store_apps.content_rating AS play_content_rating
FROM app_store_apps
	INNER JOIN play_store_apps USING (name)
WHERE app_store_apps.review_count::numeric >12892.91 AND play_store_apps.review_count::numeric > 444152.90 AND app_store_apps.rating > 4 AND app_store_apps.price = 0.00 AND app_store_apps.content_rating = '4+'
ORDER BY play_store_apps.rating DESC, app_store_apps.rating DESC;
--added cost and profit and subquery
SELECT DISTINCT name, app_store_apps.price AS app_price, app_store_apps.rating AS app_rating , primary_genre AS app_genre,
       app_store_apps.content_rating,
	   (4000*12) -	CASE WHEN price::numeric BETWEEN 0 AND 2.50 THEN
	   					25000
	                ELSE
						price * 10000
		            END AS yearly_total_profit
  FROM app_store_apps
 WHERE app_store_apps.review_count::numeric > (select round(avg(review_count ::numeric),2)
	                                             from app_store_apps)
   AND app_store_apps.rating > 4
   AND app_store_apps.price = 0.00
   --AND app_store_apps.content_rating = '4+'
UNION ALL
SELECT DISTINCT name, play_store_apps.price::money::numeric AS play_price, play_store_apps.rating AS play_rating, genres AS play_genre,
       play_store_apps.content_rating AS play_content_rating,
	   (4000*12) -	CASE WHEN price::money::numeric BETWEEN 0 AND 2.50 THEN
	   					25000
	                ELSE
						price::money::numeric *10000
		            END AS yearly_total_profit
  FROM play_store_apps	
 WHERE play_store_apps.review_count::numeric > (select round(avg(review_count),2)
	                                             from play_store_apps)
   AND play_store_apps.rating > 4
   AND play_store_apps.price::money::numeric = 0.00
   --AND play_store_apps.content_rating = 'Everyone'
ORDER BY yearly_total_profit DESC
LIMIT 10;
--------------------------------------------------------------------------------------

--B.
--Calculations
/*
1) Domino's Pizza USA
2) Egg Inc.
3) Bible
4) Solitare
5) Toy Blast
6) Angry Birds Blast
7) Chase Mobile
8) Fishdom
9) Geometry Dash Meltdown
10) Score! Hero */

--c. Develop a Top 4 list of the apps that App Trader should buy that are profitable but that also are thematically appropriate for the upcoming Halloween themed campaign.

SELECT name, content_rating, review_count::integer, rating, price::numeric
FROM app_store_apps
WHERE app_store_apps.name ILIKE '%Halloween%' OR app_store_apps.name ILIKE '%Haunted%' AND rating >=4
	UNION
SELECT name, content_rating, review_count, rating, price::numeric
FROM play_store_apps
WHERE play_store_apps.name ILIKE '%Halloween%' OR play_store_apps.name ILIKE '%Haunted%' AND rating >=4
ORDER BY review_count DESC, rating DESC, price::numeric
LIMIT 4;


--app should be free, no cost to consumer
--should have a rating >=4, you know the app is already popular
--rating should be everyone for broader audience, more users
--you make half of all in-app purchases

/* 
1) Haunted Halloween Escape
2) Connect'Em Halloween
3) Coin Dozer: Haunted
4) Halloween Sandbox Number Coloring-Color By Number */


WITH table_a AS (SELECT name, content_rating, rating, review_count::integer, price::numeric, (4000*12) AS min_gross_rev_year1,
	CASE WHEN price::numeric BETWEEN 0 AND 2.50 THEN 25000
	   ELSE price *10000
		 END AS total_cost_year1
FROM app_store_apps
WHERE app_store_apps.name ILIKE '%Halloween%' OR app_store_apps.name ILIKE '%HAUNTED%' AND rating >= 4.0
	UNION
SELECT name, content_rating, rating, review_count, price::numeric, (4000*12) AS min_gross_rev,
	CASE WHEN price::numeric BETWEEN 0 AND 2.50 THEN 25000
	    ELSE price::numeric *10000
		END AS total_cost_year1
FROM play_store_apps
WHERE play_store_apps.name ILIKE '%Halloween%' OR play_store_apps.name ILIKE '%HAUNTED%' and rating >= 4.0
ORDER BY review_count DESC, rating DESC, price::numeric)
SELECT name, content_rating, rating, review_count::integer, price::numeric, (4000*12) AS min_gross_rev_year1, total_cost_year1, min_gross_rev_year1 - total_cost_year1 AS profit_year1
FROM table_a;

