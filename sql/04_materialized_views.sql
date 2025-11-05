--mv_payments_by_day_film

CREATE MATERIALIZED VIEW dm.mv_payments_by_day_film AS
SELECT
  date_trunc('day', p.payment_date)::date AS day,
  i.film_id,
  df.title,
  SUM(p.amount) AS total_amount,
  COUNT(*) AS payments_count
FROM raw.payment p
JOIN raw.rental r ON p.rental_id = r.rental_id
JOIN raw.inventory i ON r.inventory_id = i.inventory_id
JOIN dm.dim_film df ON i.film_id = df.film_id
GROUP BY day, i.film_id, df.title;

CREATE INDEX idx_mv_payments_day_film ON dm.mv_payments_by_day_film (day, film_id);

--mv_rentals_summary

CREATE MATERIALIZED VIEW dm.mv_rentals_summary AS
SELECT
    DATE(r.rental_date) AS rental_day,
    r.inventory_id,
    f.film_id,
    f.title,
    c.customer_id,
    s.store_id,
    COUNT(*) AS rentals_count,
    COUNT(DISTINCT c.customer_id) AS unique_customers,
    ROUND(AVG(EXTRACT(EPOCH FROM (r.return_date - r.rental_date)) / 3600), 2) AS avg_rental_duration_hours
FROM public.rental r
JOIN public.inventory i ON r.inventory_id = i.inventory_id
JOIN public.film f ON i.film_id = f.film_id
JOIN public.customer c ON r.customer_id = c.customer_id
JOIN public.store s ON i.store_id = s.store_id
GROUP BY rental_day, f.film_id, f.title, c.customer_id, s.store_id;

