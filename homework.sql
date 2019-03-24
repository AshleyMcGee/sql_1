-- Activate the database we want to use 
USE sakila;

-- Get the two columns of actor first and last names 
SELECT first_name, last_name FROM actor;

-- Add the new column to the table
ALTER TABLE actor DROP COLUMN Actor_Name;
ALTER TABLE actor ADD COLUMN Actor_Name VARCHAR(50);

-- Concatenate the actor's first and last name.
UPDATE actor SET Actor_Name = CONCAT(first_name, " ", last_name);
SELECT Actor_Name FROM actor;

-- Question 2a with ID, first name, last name of actor named Joe.
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = "Joe";

-- Question 2b with all actors whose lsast names contain "Gen"
SELECT * FROM actor
WHERE last_name LIKE "%gen%";

-- Question 2c find all actors whose last name contains "LI" and order them by first name, then last 
SELECT first_name, last_name FROM actor 
WHERE last_name LIKE "%li%"
ORDER BY first_name, last_name; 

-- Question 2d use 'IN' clause to pull country_id and country from the country table for Afghanistan, Bangladesh, and China. 
SELECT country_id, country FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- Question 3a create a column in the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`)
ALTER TABLE actor
ADD description BLOB;

DESC actor;

UPDATE actor
SET description = "Fought in Mortal Kombat"
WHERE Actor_Name IN ("Johnny Cage");

SELECT * FROM actor
WHERE Actor_Name = "Johnny Cage";

-- Question 3b. Like omg who does this? Delete column "description"
ALTER TABLE actor
DROP COLUMN description;

-- Question 4a List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name;

-- Question 4b List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

-- Question 4c Update `GROUCHO WILLIAMS` in the `actor` table to `HARPO WILLIAMS`. 
SELECT first_name, last_name FROM actor
WHERE last_name = "Williams";

UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO";

-- Question 4d Now change it back to Groucho because rookie mistake?
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- Question 5a You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Gives a list of the databases in my local host. Includes info and performance schemas.
SHOW DATABASES;

-- Shows the schema (logic) of the address table in the saklia db.
SHOW CREATE TABLE address;

-- I honestly don't understand the above method for displaying the schema (logic) of the table, especially in
-- Workbench. In MySQL, "database" and "schema" seem to be used interchangeably. I have seen the below query 
-- used to describe a table. What is the difference? 
DESC address;

-- Question 6a Use staff and address table. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. 
SELECT first_name, last_name, address
FROM staff s
LEFT JOIN address a 
ON a.address_id = s.address_id;

-- Question 6b Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables 
-- `staff` and `payment`.
SELECT first_name, last_name, SUM(amount)
FROM staff s
LEFT JOIN payment p
ON s.staff_id = p.staff_id
GROUP BY last_name, first_name;

-- Question 6c List each film and the number of actors who are listed for that film. Use tables `film_actor` and 
-- `film`. Use inner join.
SELECT title as "Title", COUNT(actor_id) "Actor Count"
FROM film f
INNER JOIN film_actor j
ON f.film_id = j.film_id
GROUP BY Title;

-- 6d How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title AS "Title", COUNT(i.film_id) AS "# Copies"
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
GROUP BY title
HAVING title = "Hunchback Impossible";

-- Question 6e Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer.
-- List the customers alphabetically by last name:
SELECT first_name AS "First Name", last_name AS "Last Name", SUM(amount) AS "Total"
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY last_name, first_name;

-- Question 7a 
-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
-- films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the 
-- titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title AS "Title"
FROM film
WHERE title LIKE "K%" OR title LIKE "Q%" 
AND language_id IN 
	(
	SELECT language_id
	FROM `language`
	WHERE language_id = 1
	);

-- 7b Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT Actor_Name
from actor
WHERE actor_id IN
	(
	SELECT actor_id
	FROM film_actor
	WHERE film_id IN
		(
		SELECT film_id
		FROM film
		WHERE title = "Alone Trip"
		)
	);
    
-- 7c You want to run an email marketing campaign in Canada, for which you will need the names and email 
-- addresses of all Canadian customers. Use joins to retrieve this information. 
SELECT first_name, last_name, email
FROM customer c
	INNER JOIN address a
		ON c.address_id = a.address_id
	INNER JOIN city ci
		ON a.city_id = ci.city_id
	INNER JOIN country co
		ON ci.country_id = co.country_id
WHERE country = "Canada";

-- 7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.
SELECT title
FROM film
WHERE film_id IN
	(
	SELECT film_id
	FROM film_category
	WHERE category_id IN
		(
		SELECT category_id
		FROM category
		WHERE name = "Family"
		)
	);

-- 7e Display the most frequently rented movies in descending order.
SELECT title AS "Title", COUNT(r.rental_id) AS "Frequency"
FROM film f
	INNER JOIN inventory i
		ON f.film_id = i.film_id
	INNER JOIN rental r
		ON i.inventory_id = r.inventory_id
GROUP BY title
ORDER BY Frequency DESC;

-- 7f Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id AS "Store", SUM(p.amount) AS "Gross Sales"
FROM payment p
	INNER JOIN customer c
		ON p.customer_id = c.customer_id
	INNER JOIN store s
		ON c.store_id = s.store_id
GROUP BY Store;

-- 7g Write a query to display for each store its store ID, city, and country.
SELECT s.store_id AS "Store", ci.city AS "City", co.country AS "Country"
FROM store s
	INNER JOIN address a
		ON s.address_id = a.address_id
	INNER JOIN city ci
		ON a.city_id = ci.city_id
	INNER JOIN country co
		ON ci.country_id = co.country_id;

-- 7h List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following
--  tables: category, film_category, inventory, payment, and rental.)
SELECT c.`name` AS "Genre", SUM(p.amount) AS "Gross_Revenue"
FROM category c
	INNER JOIN film_category fc
		ON c.category_id = fc.category_id
	LEFT JOIN inventory i
		ON fc.film_id = i.film_id
	LEFT JOIN rental r
		ON i.inventory_id = r.inventory_id
	LEFT JOIN payment p
		ON r.rental_id = p.rental_id
GROUP BY Genre
ORDER By Gross_Revenue DESC LIMIT 5;

-- 8a In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross 
-- revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute 
-- another query to create a view.

CREATE VIEW genre_top_5 AS
	(SELECT c.`name` AS "Genre", SUM(p.amount) AS "Gross_Revenue"
	FROM category c
	INNER JOIN film_category fc
		ON c.category_id = fc.category_id
	LEFT JOIN inventory i
		ON fc.film_id = i.film_id
	LEFT JOIN rental r
		ON i.inventory_id = r.inventory_id
	LEFT JOIN payment p
		ON r.rental_id = p.rental_id
GROUP BY Genre
ORDER By Gross_Revenue DESC LIMIT 5);

-- 8b How would you display the view that you created in 8a?
SELECT * FROM genre_top_5;

-- 8c You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW genre_top_5;











    


















