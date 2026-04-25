use sakila ; 
-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
SELECT count(i.inventory_id) as number_of_copies, f.title
FROM film f
JOIN inventory i 
ON f.film_id = i.film_id
WHERE f.title = 'HUNCHBACK IMPOSSIBLE';

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title, length,(Select round(avg(length), 2) FROM film) as average_length
FROM film 
WHERE length > (SELECT AVG(length) FROM film)
ORDER BY title;

-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (SELECT fa.actor_id FROM film_actor fa JOIN film f ON f.film_id = fa.film_id WHERE f.title = "ALONE TRIP");

-- 4. Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT title 
FROM film 
WHERE film_id IN (SELECT fc.film_id FROM film_category fc JOIN category c ON fc.category_id = c.category_id WHERE c.name = 'Family');
/*
-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. 
	To use joins, you will need to identify the relevant tables and their primary and foreign keys. */
SELECT first_name, last_name, email
FROM customer 
WHERE address_id IN (
SELECT a.address_id 
FROM address a
JOIN city ci
ON ci.city_id = a.city_id
JOIN country co
ON co.country_id = ci.country_id
WHERE co.country = 'Canada'
);
/*
-- 6. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. 
First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in. */
WITH prolific_actors  AS ( SELECT actor_id, count(film_id) as number_of_films FROM film_actor GROUP BY actor_id)
SELECT pa.actor_id, a.first_name, a.last_name, pa.number_of_films
FROM prolific_actors pa
JOIN actor a ON pa.actor_id = a.actor_id
ORDER BY pa.number_of_films DESC;

/*
-- 7. Find the films rented by the most profitable customer in the Sakila database. 
You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments. */
WITH customer_revenue AS (
    SELECT c.customer_id, CONCAT(c.first_name, ' ', c.last_name) AS customer_name, SUM(p.amount) AS total_paid
    FROM customer c
    JOIN payment p ON c.customer_id = p.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT cr.customer_id, cr.customer_name, ROUND(cr.total_paid, 2) AS total_paid, COUNT(DISTINCT r.rental_id) AS number_of_rentals,
    COUNT(DISTINCT f.film_id) AS different_films_rented, GROUP_CONCAT(DISTINCT f.title ORDER BY f.title SEPARATOR ', ') AS films_rented
FROM customer_revenue cr
JOIN rental r ON cr.customer_id = r.customer_id
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
GROUP BY cr.customer_id, cr.customer_name, cr.total_paid
ORDER BY cr.total_paid DESC;

-- 8. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
WITH customer_total_amount AS (
    SELECT customer_id, SUM(amount) AS total_amount_spent
    FROM payment
    GROUP BY customer_id
)
SELECT customer_id, ROUND(total_amount_spent, 2) AS total_amount_spent
FROM customer_total_amount
WHERE total_amount_spent > (SELECT AVG(total_amount_spent) FROM customer_total_amount)
ORDER BY total_amount_spent DESC;