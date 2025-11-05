CREATE TABLE IF NOT EXISTS etl.control (
  name text PRIMARY KEY,          
  last_loaded timestamptz         
);

INSERT INTO etl.control (name, last_loaded)
VALUES
  ('dim_customer', '2000-01-01'::timestamptz),
  ('dim_film', '2000-01-01'::timestamptz),
  ('fact_rental', '2000-01-01'::timestamptz),
  ('fact_payment', '2000-01-01'::timestamptz)
ON CONFLICT (name) DO NOTHING;