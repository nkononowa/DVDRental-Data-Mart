BEGIN;


--DIM_CUSTOMER

WITH ctrl AS (
  SELECT COALESCE(last_loaded, '2000-01-01'::timestamptz) AS last_loaded
  FROM etl.control WHERE name = 'dim_customer'
)
INSERT INTO dm.dim_customer AS t
SELECT
  c.customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.store_id,
  c.email,
  c.activebool,
  c.create_date,
  c.last_update
FROM raw.customer c, ctrl
WHERE c.last_update > ctrl.last_loaded
ON CONFLICT (customer_id)
DO UPDATE
  SET
    customer_name = EXCLUDED.customer_name,
    store_id = EXCLUDED.store_id,
    email = EXCLUDED.email,
    activebool = EXCLUDED.activebool,
    create_date = EXCLUDED.create_date,
    last_update = EXCLUDED.last_update
  WHERE t.last_update < EXCLUDED.last_update;

UPDATE etl.control
SET last_loaded = (SELECT MAX(last_update) FROM raw.customer)
WHERE name = 'dim_customer';


--DIM_FILM

WITH ctrl AS (
  SELECT COALESCE(last_loaded, '2000-01-01'::timestamptz) AS last_loaded
  FROM etl.control WHERE name = 'dim_film'
)
INSERT INTO dm.dim_film AS t
SELECT
  f.film_id,
  f.title,
  f.description,
  f.rating,
  f.rental_rate,
  f.replacement_cost,
  f.last_update
FROM raw.film f, ctrl
WHERE f.last_update > ctrl.last_loaded
ON CONFLICT (film_id)
DO UPDATE
  SET
    title = EXCLUDED.title,
    description = EXCLUDED.description,
    rating = EXCLUDED.rating,
    rental_rate = EXCLUDED.rental_rate,
    replacement_cost = EXCLUDED.replacement_cost,
    last_update = EXCLUDED.last_update
  WHERE t.last_update < EXCLUDED.last_update;

UPDATE etl.control
SET last_loaded = (SELECT MAX(last_update) FROM raw.film)
WHERE name = 'dim_film';


--FACT_RENTAL

WITH ctrl AS (
  SELECT COALESCE(last_loaded, '2000-01-01'::timestamptz) AS last_loaded
  FROM etl.control WHERE name = 'fact_rental'
)
INSERT INTO dm.fact_rental AS t
SELECT
  r.rental_id,
  r.rental_date,
  r.inventory_id,
  i.film_id,
  r.customer_id,
  r.staff_id,
  r.return_date,
  EXTRACT(EPOCH FROM (COALESCE(r.return_date, now()) - r.rental_date)) / 86400 AS days_rented,
  CASE WHEN r.return_date IS NULL THEN 0 ELSE 1 END AS returned_flag,
  r.last_update
FROM raw.rental r
JOIN raw.inventory i ON r.inventory_id = i.inventory_id,
     ctrl
WHERE r.last_update > ctrl.last_loaded
ON CONFLICT (rental_id)
DO UPDATE
  SET
    rental_date = EXCLUDED.rental_date,
    inventory_id = EXCLUDED.inventory_id,
    film_id = EXCLUDED.film_id,
    customer_id = EXCLUDED.customer_id,
    staff_id = EXCLUDED.staff_id,
    return_date = EXCLUDED.return_date,
    days_rented = EXCLUDED.days_rented,
    returned_flag = EXCLUDED.returned_flag,
    last_update = EXCLUDED.last_update
  WHERE t.last_update < EXCLUDED.last_update;

UPDATE etl.control
SET last_loaded = (SELECT MAX(last_update) FROM raw.rental)
WHERE name = 'fact_rental';


--FACT_PAYMENT

WITH ctrl AS (
  SELECT COALESCE(last_loaded, '2000-01-01'::timestamptz) AS last_loaded
  FROM etl.control WHERE name = 'fact_payment'
)
INSERT INTO dm.fact_payment AS t
SELECT
  p.payment_id,
  p.customer_id,
  p.rental_id,
  p.staff_id,
  p.payment_date,
  p.amount
FROM raw.payment p, ctrl
WHERE p.payment_date > ctrl.last_loaded
ON CONFLICT (payment_id)
DO UPDATE
  SET
    customer_id = EXCLUDED.customer_id,
    rental_id = EXCLUDED.rental_id,
    staff_id = EXCLUDED.staff_id,
    payment_date = EXCLUDED.payment_date,
    amount = EXCLUDED.amount
  WHERE t.payment_date < EXCLUDED.payment_date;

UPDATE etl.control
SET last_loaded = (SELECT MAX(payment_date) FROM raw.payment)
WHERE name = 'fact_payment';

COMMIT;
