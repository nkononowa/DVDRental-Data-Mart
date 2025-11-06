CREATE TABLE IF NOT EXISTS etl.constraint_violations (
  id serial PRIMARY KEY,
  check_time timestamptz DEFAULT now(),
  table_name text,
  check_type text,
  details text,
  sample_row jsonb -- short sample / context (may be null)
);

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.actor' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'actor_id IS NULL OR first_name IS NULL/blank OR last_name IS NULL/blank (regexp_trim)' AS details,
  to_jsonb(t) AS sample_row
FROM raw.actor t
WHERE actor_id IS NULL
  OR first_name IS NULL
  OR regexp_replace(first_name, '\s+', '', 'g') = ''
  OR last_name IS NULL
  OR regexp_replace(last_name, '\s+', '', 'g') = ''
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.customer' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'customer_id IS NULL OR first_name/last_name/email blank' AS details,
  to_jsonb(t)
FROM raw.customer t
WHERE customer_id IS NULL
   OR first_name IS NULL OR regexp_replace(first_name, '\s+', '', 'g') = ''
   OR last_name  IS NULL OR regexp_replace(last_name,  '\s+', '', 'g') = ''
   OR email IS NULL OR regexp_replace(email, '\s+', '', 'g') = ''
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.film' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'film_id IS NULL OR title/description blank' AS details,
  to_jsonb(t)
FROM raw.film t
WHERE film_id IS NULL
   OR title IS NULL OR regexp_replace(title, '\s+', '', 'g') = ''
   OR description IS NULL OR regexp_replace(description, '\s+', '', 'g') = ''
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.inventory' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'inventory_id, film_id, or store_id missing' AS details,
  to_jsonb(t)
FROM raw.inventory t
WHERE inventory_id IS NULL
   OR film_id IS NULL
   OR store_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.rental' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'rental_id, rental_date, inventory_id, or customer_id missing' AS details,
  to_jsonb(t)
FROM raw.rental t
WHERE rental_id IS NULL
   OR rental_date IS NULL
   OR inventory_id IS NULL
   OR customer_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.payment' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'payment_id, customer_id, payment_date, or amount missing/invalid' AS details,
  to_jsonb(t)
FROM raw.payment t
WHERE payment_id IS NULL
   OR customer_id IS NULL
   OR payment_date IS NULL
   OR amount IS NULL
   OR amount <= 0
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.store' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'store_id or address_id missing' AS details,
  to_jsonb(t)
FROM raw.store t
WHERE store_id IS NULL
   OR address_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.staff' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'staff_id IS NULL OR first_name/last_name blank' AS details,
  to_jsonb(t)
FROM raw.staff t
WHERE staff_id IS NULL
   OR first_name IS NULL OR regexp_replace(first_name, '\s+', '', 'g') = ''
   OR last_name  IS NULL OR regexp_replace(last_name,  '\s+', '', 'g') = ''
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.address' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'address_id, address, or city_id missing' AS details,
  to_jsonb(t)
FROM raw.address t
WHERE address_id IS NULL
   OR address IS NULL OR regexp_replace(address, '\s+', '', 'g') = ''
   OR city_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.city' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'city_id, city, or country_id missing' AS details,
  to_jsonb(t)
FROM raw.city t
WHERE city_id IS NULL
   OR city IS NULL OR regexp_replace(city, '\s+', '', 'g') = ''
   OR country_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.country' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'country_id or country name missing' AS details,
  to_jsonb(t)
FROM raw.country t
WHERE country_id IS NULL
   OR country IS NULL OR regexp_replace(country, '\s+', '', 'g') = ''
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.film_actor' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'film_id or actor_id missing' AS details,
  to_jsonb(t)
FROM raw.film_actor t
WHERE film_id IS NULL
   OR actor_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.film_category' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'film_id or category_id missing' AS details,
  to_jsonb(t)
FROM raw.film_category t
WHERE film_id IS NULL
   OR category_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT
  'raw.category' AS table_name,
  'not_null_or_blank_violation' AS check_type,
  'category_id or name missing/blank' AS details,
  to_jsonb(t)
FROM raw.category t
WHERE category_id IS NULL
   OR name IS NULL OR regexp_replace(name, '\s+', '', 'g') = ''
LIMIT 50;

-- inventory.film_id -> raw.film
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.inventory', 'fk_orphan_film', 'inventory.film_id not found in raw.film', to_jsonb(i)
FROM raw.inventory i
LEFT JOIN raw.film f ON i.film_id = f.film_id
WHERE f.film_id IS NULL
LIMIT 50;

-- inventory.store_id -> raw.store
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.inventory', 'fk_orphan_store', 'inventory.store_id not found in raw.store', to_jsonb(i)
FROM raw.inventory i
LEFT JOIN raw.store s ON i.store_id = s.store_id
WHERE s.store_id IS NULL
LIMIT 50;

-- rental.inventory_id -> raw.inventory
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.rental', 'fk_orphan_inventory', 'rental.inventory_id not found in raw.inventory', to_jsonb(r)
FROM raw.rental r
LEFT JOIN raw.inventory i ON r.inventory_id = i.inventory_id
WHERE i.inventory_id IS NULL
LIMIT 50;

-- rental.customer_id -> raw.customer
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.rental', 'fk_orphan_customer', 'rental.customer_id not found in raw.customer', to_jsonb(r)
FROM raw.rental r
LEFT JOIN raw.customer c ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL
LIMIT 50;

-- payment.customer_id -> raw.customer
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.payment', 'fk_orphan_customer', 'payment.customer_id not found in raw.customer', to_jsonb(p)
FROM raw.payment p
LEFT JOIN raw.customer c ON p.customer_id = c.customer_id
WHERE c.customer_id IS NULL
LIMIT 50;

-- payment.rental_id -> raw.rental (if not null)
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.payment', 'fk_orphan_rental', 'payment.rental_id not found in raw.rental', to_jsonb(p)
FROM raw.payment p
LEFT JOIN raw.rental r ON p.rental_id = r.rental_id
WHERE p.rental_id IS NOT NULL AND r.rental_id IS NULL
LIMIT 50;

-- film_actor film_id/actor_id -> raw.film/raw.actor
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.film_actor', 'fk_orphan_film', 'film_actor.film_id not found in raw.film', to_jsonb(fa)
FROM raw.film_actor fa
LEFT JOIN raw.film f ON fa.film_id = f.film_id
WHERE f.film_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.film_actor', 'fk_orphan_actor', 'film_actor.actor_id not found in raw.actor', to_jsonb(fa)
FROM raw.film_actor fa
LEFT JOIN raw.actor a ON fa.actor_id = a.actor_id
WHERE a.actor_id IS NULL
LIMIT 50;

-- film_category -> raw.film, raw.category
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.film_category', 'fk_orphan_film', 'film_category.film_id not found in raw.film', to_jsonb(fc)
FROM raw.film_category fc
LEFT JOIN raw.film f ON fc.film_id = f.film_id
WHERE f.film_id IS NULL
LIMIT 50;

INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.film_category', 'fk_orphan_category', 'film_category.category_id not found in raw.category', to_jsonb(fc)
FROM raw.film_category fc
LEFT JOIN raw.category c ON fc.category_id = c.category_id
WHERE c.category_id IS NULL
LIMIT 50;

-- address.city_id -> raw.city
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.address', 'fk_orphan_city', 'address.city_id not found in raw.city', to_jsonb(a)
FROM raw.address a
LEFT JOIN raw.city c ON a.city_id = c.city_id
WHERE c.city_id IS NULL
LIMIT 50;

-- city.country_id -> raw.country
INSERT INTO etl.constraint_violations (table_name, check_type, details, sample_row)
SELECT 'raw.city', 'fk_orphan_country', 'city.country_id not found in raw.country', to_jsonb(c)
FROM raw.city c
LEFT JOIN raw.country co ON c.country_id = co.country_id
WHERE co.country_id IS NULL
LIMIT 50;