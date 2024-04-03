
-- Q1) We will need a list of all staff members, including their first and last name, 
-- email address, an the store identification number where they work.

SELECT first_name, last_name, email, store_id
FROM staff

-- Q2) We will need seperate counts of inventory items held at each of your two stores.

SELECT store_id,
		COUNT(inventory_id)AS inventory_items
FROM inventory
GROUP BY store_id

-- Q3) We will need a count of active customers for each of your stores. saperately, please.

SELECT COUNT(customer_id) AS active_customer,
		store_id
FROM customer
WHERE active = 1
GROUP BY store_id

-- Q4) In order to assess the ability of a data breach, we will need you to provide a count of all customer email
-- address stored in the database.

SELECT COUNT(email) AS customer_email_address
FROM customer

-- Q5) We are interested in how diverse your film offering is as a mean of understanding how likely you are to keep customer enagaed
-- in the future. Please provide a count of unique film titles you have in inventory at each store and then provide a count of the 
-- unique categories of films you provided.

SELECT store_id,
		COUNT(film_id)AS unique_film_title
FROM inventory
GROUP BY store_id

SELECT COUNT(DISTINCT name) AS unique_categories
FROM category

-- Q6) We would like to understand the replacement cost of your films. Please provide the replacement cost for the film that is least
-- expensive to replace, the most expensive to replace and the average of all films you carry.

SELECT
	MIN(replacement_cost) AS least_expensive_to_replace,
    MAX(replacement_cost) AS most_expensive_to_replace,
    AVG(replacement_cost) AS average_replacement_cost
FROM film

-- Q7) We are interested in having you put payment monitoring systems and maximum payment processing restrictions in place in order 
-- to minimize the future risk of fraud by your staff. Please provide the average payment you process, as well as the maximus payment
-- you have processed.

SELECT AVG(amount) AS average_payment,
		MAX(amount) AS maximum_payment
FROM payment

-- Q8) We would like to better understand what your customer base looks like. Please provide a list of all customer identification values,
-- with a count of rentals they have made all-time, with your highest volume customers at the top of the list.

SELECT *
FROM rental

SELECT customer_id,
	COUNT(rental_id) as number_of_rentals
FROM rental
GROUP BY customer_id
ORDER BY COUNT(rental_id) DESC

-- Q9) My partner and I want to come by each of the stores in person and meet the manager. Please send over the manager’s name at 
-- each store with the full address of each property (street address, district, city and country, please).
-- (table required i.e store, staff, address, city, country.)

SELECT 
	staff.first_name AS manager_first_name,
    staff.last_name AS manager_last_name,
    address.address,
    address.district,
    city.city,
    country.country
 FROM store
	LEFT JOIN staff 
		ON store.manager_staff_id = staff.staff_id
	LEFT JOIN address
		ON store.address_id = address.address_id
	LEFT JOIN city
		ON address.city_id = city.city_id
	LEFT JOIN country
		ON city.country_id = country.country_id

-- Q10) I would like to get a better understanding of all the inventory that would come along with the business. 
-- Please pull together a list of each inventory item you have stocked, including the store_id number, The inventory_id, 
-- the name of the film, the flim’s rating, its rental rate and replacement cost.
-- (table required i.e inventory, film)

SELECT 
	inventory.store_id,
    inventory.inventory_id,
    film.title,
    film.rating,
    film.rental_rate,
    film.replacement_cost
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id

-- 	Q11) From the same list of films you have pulled, please roll that data up and provide a summary level overview of your inventory. 
-- We would like to know how many inventory item you have with each rating at each store.

SELECT 
	inventory.store_id,
    film.rating,
	COUNT(inventory_id) AS count_of_inventory_items
FROM inventory
	INNER JOIN film
		ON inventory.film_id = film.film_id
GROUP BY
	inventory.store_id,
    film.rating

-- Q12) Similarly, we want to understand how diversified the inventory is in terms of replacement cost. 
-- We want to see how big of a hit it would be if a certain category of flim became unpopular at certain store. 
-- We would like to see the number of films as well as the average replacement cost and total replacement cost. 
-- Slice by. Stored and flim category.

SELECT 
	store_id,
    category.name AS category,
    COUNT(inventory.film_id) AS film,
    AVG(film.replacement_cost) AS average_replacement_cost,
    SUM(film.replacement_cost) AS sum_replacement_cost
FROM inventory
	LEFT JOIN film
		ON inventory.film_id = film.film_id
	LEFT JOIN film_category
		ON film.film_id = film_category.film_id
	LEFT JOIN category
		ON category.category_id = film_category.category_id
GROUP BY 
	store_id,
    category.name
ORDER BY 
	SUM(film.replacement_cost) DESC

-- Q13) We want to make sure your folks have a good handle on who your customer are. 
-- Please provide a list of all customer names which store they go to, 
-- whether or not they are currently active, and their full addresses - street address, city and country.

SELECT 
	concat(customer.first_name,"  ",
    customer.last_name) AS customer_full_name,
    customer.store_id,
    customer.active,
    address.address,
    city.city,
    country.country
FROM customer
	LEFT JOIN address
		ON customer.address_id = address.address_id
	LEFT JOIN city
		ON city.city_id = address.city_id
	LEFT JOIN country
		ON country.country_id = city.country_id

-- Q14) We would like to understand how much your customers are spending with you and also to know who your most valuable customer are. 
-- Place pull together a list of customer name, the total lifetime rental and the sum of all payments you have collected from them. 
-- It would be great to see this ordered on total lifetime value with the most valuable customer at the top of the list.

SELECT
	customer.first_name,
    customer.last_name,
    COUNT(rental.rental_id) AS total_rentals,
    SUM(payment.amount) AS total_payment_amount
FROM customer
	LEFT JOIN rental
		ON customer.customer_id = rental.customer_id
	LEFT JOIN payment
		ON rental.rental_id = payment.rental_id
GROUP BY 
	customer.first_name,
    customer.last_name
ORDER BY 
	SUM(payment.amount) DESC

-- Q15) My partner and I would like to get to know your board of advisors and any current investors. 
-- Could you please provide a list of advisor and investor name in one table? 
-- Could you please note whether they are an investor or an advisor? 
-- And for the investor, it would be good to include which company they work with.

SELECT
	'investor' AS type,
    first_name,
    last_name,
    company_name
FROM investor

UNION 

SELECT
	'advisor' AS type,
    first_name,
    last_name,
    NULL
FROM advisor

-- Q16) We are interested in how well you have covered the most awarded actor. 
-- Of all the actors with three types of awards for what % of them do we carry of film? 
-- And how about for actors with two types of awards? Same question. Finally, how about actors with just one award?

SELECT
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony','Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
    END AS number_of_awards,
    AVG(CASE WHEN actor_award.actor_id IS NULL THEN 0 ELSE 1 END) AS pct_w_one_film

FROM actor_award

GROUP BY 
	CASE 
		WHEN actor_award.awards = 'Emmy, Oscar, Tony ' THEN '3 awards'
        WHEN actor_award.awards IN ('Emmy, Oscar','Emmy, Tony','Oscar, Tony') THEN '2 awards'
        ELSE '1 award'
	END
