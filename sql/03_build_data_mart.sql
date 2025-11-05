--dim_customer

CREATE TABLE dm.dim_customer AS
SELECT
  c.customer_id,
  c.first_name || ' ' || c.last_name AS customer_name,
  c.store_id,
  c.email,
  c.activebool,
  c.create_date,
  c.last_update
FROM raw.customer c;

ALTER TABLE dm.dim_customer ADD PRIMARY KEY (customer_id);

--dm.dim_film

CREATE TABLE dm.dim_film AS
SELECT
  f.film_id,
  f.title,
  f.description,
  f.rating,
  f.rental_rate,
  f.replacement_cost,
  f.last_update
FROM raw.film f;

ALTER TABLE dm.dim_film ADD PRIMARY KEY (film_id);

--dm.fact_rental

CREATE TABLE dm.fact_rental AS
SELECT
  r.rental_id,
  r.rental_date,
  r.inventory_id,
  i.film_id,
  r.customer_id,
  r.staff_id,
  r.return_date,
  EXTRACT(EPOCH FROM (COALESCE(r.return_date, now()) - r.rental_date))/86400 AS days_rented,
  CASE WHEN r.return_date IS NULL THEN 0 ELSE 1 END AS returned_flag, 
  r.last_update
FROM raw.rental r
JOIN raw.inventory i ON r.inventory_id = i.inventory_id;

ALTER TABLE dm.fact_rental ADD PRIMARY KEY (rental_id);

--dm.fact_paymen

CREATE TABLE dm.fact_payment AS
SELECT
  p.payment_id,
  p.customer_id,
  p.rental_id,
  p.staff_id,
  p.payment_date,
  p.amount
FROM raw.payment p;

ALTER TABLE dm.fact_payment ADD PRIMARY KEY (payment_id);