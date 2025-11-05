BEGIN;

TRUNCATE TABLE raw.actor, raw.customer, raw.film, raw.inventory, raw.rental,
               raw.payment, raw.store, raw.staff, raw.address, raw.city,
               raw.country, raw.film_actor, raw.film_category, raw.category RESTART IDENTITY;


-- ACTOR

INSERT INTO raw.actor
SELECT DISTINCT ON (actor_id)
    actor_id,
    first_name,
    last_name,
    last_update
FROM stg.actor
WHERE actor_id IS NOT NULL
  AND first_name IS NOT NULL
  AND last_name IS NOT NULL
ORDER BY actor_id, last_update DESC;


-- CUSTOMER

INSERT INTO raw.customer
SELECT DISTINCT ON (customer_id)
    customer_id,
    store_id,
    first_name,
    last_name,
    email,
    address_id,
    active,
    create_date,
    last_update
FROM stg.customer
WHERE customer_id IS NOT NULL
  AND first_name IS NOT NULL
  AND last_name IS NOT NULL
ORDER BY customer_id, last_update DESC;


-- FILM

INSERT INTO raw.film
SELECT DISTINCT ON (film_id)
    film_id,
    title,
    description,
    release_year,
    language_id,
    rental_duration,
    rental_rate,
    length,
    replacement_cost,
    rating,
    last_update
FROM stg.film
WHERE film_id IS NOT NULL
  AND title IS NOT NULL
ORDER BY film_id, last_update DESC;


-- INVENTORY

INSERT INTO raw.inventory
SELECT DISTINCT ON (inventory_id)
    inventory_id,
    film_id,
    store_id,
    last_update
FROM stg.inventory
WHERE inventory_id IS NOT NULL
  AND film_id IS NOT NULL
  AND store_id IS NOT NULL
ORDER BY inventory_id, last_update DESC;


-- RENTAL

INSERT INTO raw.rental
SELECT DISTINCT ON (rental_id)
    rental_id,
    rental_date,
    inventory_id,
    customer_id,
    return_date,
    staff_id,
    last_update
FROM stg.rental
WHERE rental_id IS NOT NULL
  AND rental_date IS NOT NULL
  AND inventory_id IS NOT NULL
  AND customer_id IS NOT NULL
ORDER BY rental_id, last_update DESC;


-- PAYMENT

INSERT INTO raw.payment
SELECT DISTINCT ON (payment_id)
    payment_id,
    customer_id,
    staff_id,
    rental_id,
    amount,
    payment_date
FROM stg.payment
WHERE payment_id IS NOT NULL
  AND customer_id IS NOT NULL
  AND amount IS NOT NULL
  AND amount > 0
ORDER BY payment_id, payment_date DESC;


-- STORE

INSERT INTO raw.store
SELECT DISTINCT ON (store_id)
    store_id,
    manager_staff_id,
    address_id,
    last_update
FROM stg.store
WHERE store_id IS NOT NULL
ORDER BY store_id, last_update DESC;


-- STAFF

INSERT INTO raw.staff
SELECT DISTINCT ON (staff_id)
    staff_id,
    first_name,
    last_name,
    address_id,
    email,
    store_id,
    active,
    username,
    password,
    last_update
FROM stg.staff
WHERE staff_id IS NOT NULL
  AND first_name IS NOT NULL
  AND last_name IS NOT NULL
ORDER BY staff_id, last_update DESC;


-- ADDRESS

INSERT INTO raw.address
SELECT DISTINCT ON (address_id)
    address_id,
    address,
    address2,
    district,
    city_id,
    postal_code,
    phone,
    last_update
FROM stg.address
WHERE address_id IS NOT NULL
  AND address IS NOT NULL
  AND city_id IS NOT NULL
ORDER BY address_id, last_update DESC;


-- CITY

INSERT INTO raw.city
SELECT DISTINCT ON (city_id)
    city_id,
    city,
    country_id,
    last_update
FROM stg.city
WHERE city_id IS NOT NULL
  AND city IS NOT NULL
  AND country_id IS NOT NULL
ORDER BY city_id, last_update DESC;


-- COUNTRY

INSERT INTO raw.country
SELECT DISTINCT ON (country_id)
    country_id,
    country,
    last_update
FROM stg.country
WHERE country_id IS NOT NULL
  AND country IS NOT NULL
ORDER BY country_id, last_update DESC;


-- FILM_ACTOR

INSERT INTO raw.film_actor
SELECT DISTINCT ON (film_id, actor_id)
    actor_id,
    film_id,
    last_update
FROM stg.film_actor
WHERE film_id IS NOT NULL
  AND actor_id IS NOT NULL
ORDER BY film_id, actor_id, last_update DESC;


-- FILM_CATEGORY

INSERT INTO raw.film_category
SELECT DISTINCT ON (film_id, category_id)
    film_id,
    category_id,
    last_update
FROM stg.film_category
WHERE film_id IS NOT NULL
  AND category_id IS NOT NULL
ORDER BY film_id, category_id, last_update DESC;


-- CATEGORY

INSERT INTO raw.category
SELECT DISTINCT ON (category_id)
    category_id,
    name,
    last_update
FROM stg.category
WHERE category_id IS NOT NULL
  AND name IS NOT NULL
ORDER BY category_id, last_update DESC;

COMMIT;
