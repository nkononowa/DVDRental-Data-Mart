BEGIN;

TRUNCATE TABLE stg.actor, stg.customer, stg.film, stg.inventory, stg.rental,
               stg.payment, stg.store, stg.staff, stg.address, stg.city, 
               stg.country, stg.film_actor, stg.film_category, stg.category RESTART IDENTITY;

INSERT INTO stg.actor SELECT * FROM public.actor;
INSERT INTO stg.customer SELECT * FROM public.customer;
INSERT INTO stg.film SELECT * FROM public.film;
INSERT INTO stg.inventory SELECT * FROM public.inventory;
INSERT INTO stg.rental SELECT * FROM public.rental;
INSERT INTO stg.payment SELECT * FROM public.payment;
INSERT INTO stg.store SELECT * FROM public.store;
INSERT INTO stg.staff SELECT * FROM public.staff;
INSERT INTO stg.address SELECT * FROM public.address;
INSERT INTO stg.city SELECT * FROM public.city;
INSERT INTO stg.country SELECT * FROM public.country;
INSERT INTO stg.film_actor SELECT * FROM public.film_actor;
INSERT INTO stg.film_category SELECT * FROM public.film_category;
INSERT INTO stg.category SELECT * FROM public.category;

COMMIT;