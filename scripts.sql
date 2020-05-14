------------------------ SELECT a FROM ------------------------ 
select film_id, title, rental_rate
from film ;

select * 
from film;

select rental_duration, *
from film ;

select *
from inventory;

------------------------ DISTINCT, LIMIT, ORDER BY ------------------------
select distinct film_id
from inventory; 
--958 zaznamu

select distinct film_id
from film; 
--1000 zaznamu

select distinct film_id
from inventory
limit 10;

select distinct film_id
from inventory
order by film_id
limit 10;

select distinct film_id
from inventory
order by film_id DESC
limit 10;
-- zaznamy s nejvyssim film_id








------------------------  WHERE ------------------------ 
select *
from customer;

select *
from customer
where first_name = 'Jamie';

select *
from customer
where first_name = 'Jamie' and last_name = 'Rice';

select *
from customer
where first_name = 'Ann' or first_name = 'Anne' or first_name = 'Annie';

select *
from customer
where first_name in ('Ann','Anne','Annie');

select *
from customer
where first_name like 'Ann%';

-- LENGTH: delka textu
select *
from film 
where length(description) <= 70;

select address2, length(address2) as delka_adresy, *
from address 
where address2 = '';  -- 599 rows




-- funkce v SELECT --
select *, 
       length(country) as delka_jmena
from country
limit 10;

select *, 
       length(country) as delka_jmena,
	   country like 'An%' as jmeno_na_An
from country
limit 10;

select *
from film;

select *
       ,length(title)          as delka_nazvu
	   ,replacement_cost >= 15 as cena_nad_15
	   ,rating in ('G','PG')   as rating_G_nebo_PG
from film
limit 10;

select *
       ,length(title)          as delka_nazvu
	   ,replacement_cost >= 15 as cena_nad_15
	   ,rating in ('G','PG')   as rating_G_nebo_PG
from film
order by length(title)
limit 10;
-- minimalni delka nazvu je 8




-- CASE-WHEN
SELECT title, 
	   rating,
         CASE WHEN rating = 'G' THEN 1
           WHEN rating = 'PG-13' THEN 2
               ELSE 3
          END as rating_group
FROM film
;




------------------------   CREATE  ------------------------ 
drop table if exists my_film;
create table my_film as 
select *
from film
where length(title) <= 8;
-- Nevidite tabulku? Kliknete pravym mysitkem na "Tables" -> Refresh...

drop table if exists my_filmy_s_kratkym_nazvem;
create table my_filmy_s_kratkym_nazvem as 
select film_id,
		title,
       	length(title) as delka_nazvu,
		replacement_cost >= 15 as cena_nad_15,
	   	rating in ('G','PG')   as rating_G_nebo_PG
from film 
where length(title) <= 8;



------------------------  GROUP BY  ------------------------ 
-- Kolik plateb provedli zákazníci 318 a 281?
select * 
from payment 
where customer_id in (318, 281); -- 17 radku

select customer_id
from payment
where customer_id in (318, 281)
group by customer_id;

select customer_id, 
       count(payment_id) as pocet_plateb -- dopocitany sloupec
from payment
where customer_id in (318, 281)
group by customer_id;

select customer_id, 
       count(payment_id) as pocet_plateb, -- dopocitany sloupec
	   sum(amount) as celkova_vyse
from payment
where customer_id in (318, 281)
group by customer_id;



-- vsichni zakaznici
select customer_id, 
       count(payment_id) as pocet_plateb, -- dopocitany sloupec
	   sum(amount) as celkova_vyse
from payment
--where customer_id in (318, 281)
group by customer_id
order by sum(amount);

-- samostatna tabulka
drop table if exists my_platby;
create table my_platby as 
select customer_id, 
       count(payment_id) as pocet_plateb,
	   sum(amount) as celkova_vyse
from payment
group by customer_id
order by sum(amount);

select * from my_platby;

-- tip pro strucny zapis:
-- plny zapis...
select customer_id, 
       count(payment_id) as pocet_plateb
from payment
group by customer_id
;
-- ...je ekvivalentni zkracene forme group by:
select customer_id, 
       count(payment_id) as pocet_plateb
from payment
group by 1 --"prvni sloupec uvedeny v select"
;


------------------------  domaci prace: DATUM a CAS  ------------------------ 
-- Prectete si SQL dotazy nize a pomoci techto odkazu pochopte, jak se 
-- jednotlive funkce pro datum a cas presne pouzivaji.

-- funkce: https://www.postgresql.org/docs/12/functions-datetime.html
-- datove typy (jen pro doplneni): https://www.postgresql.org/docs/12/datatype-datetime.html

-- Jak dlouho trvala jednotliva vypujcka a ktery den v tydnu probehla?
select rental_id, 
		customer_id,
        rental_date,
        return_date,
        return_date - rental_date  as delka_vypucky,
        extract('dow' from rental_date) as den_v_tydnu, 
        now() - return_date as vraceno_pred        
from rental
;

-- Ktery den v tydnu je nejvice vypujcek?
select extract('dow' from rental_date) as den_v_tydnu, 
       count(*) as pocet_vypujcek
from rental
group by extract('dow' from rental_date)
order by count(*) DESC
;

-- Kolik vypujcek probehlo v jednotlivych mesicich?
select date_trunc('month', rental_date) as mesic_vypujcky,
		count(*)
from rental
group by date_trunc('month', rental_date)
order by date_trunc('month', rental_date)
;
-- strucna forma:
select date_trunc('month', rental_date) as mesic_vypujcky,
		count(*)
from rental
group by 1
order by 1
;
-- komentar: data jsou fiktivni, a proto vidime tak malo mesicu


-- Podle rental_date bez uprav nelze groupovat, nebot hodnoty obsahuji i cas:
select rental_date, count(*)
from rental 
group by rental_date
;



------------------------  domaci prace: HAVING  ------------------------ 

SELECT customer_id,
       count(payment_id) as pocet_plateb,
      sum(amount) as celkova_vyse
FROM payment
--WHERE sum(amount) > 60 --sem podminka se sum() nepatri - vyzkousejte, ze to nefunguje
GROUP BY customer_id
HAVING sum(amount) > 60
;

-- ukol: pomoci HAVING upravte dotaz uvedeny vyse tak, abychom dostali jen mesice, kdy bylo provedeno mene nez 1500 vypujcek
-- dotaz k upraveni: Kolik vypujcek probehlo v jednotlivych mesicich?
select date_trunc('month', rental_date) as mesic_vypujcky,
		count(*)
from rental
group by date_trunc('month', rental_date)
order by date_trunc('month', rental_date)
;
-- napoveda: vlozte HAVING na spravne misto
-- filtrujte pomoci count(*)




------------------------  JOIN  ------------------------ 
-- Nejprve priprava dat:
-- krok 1: rozdelte si tabulku s inventarem na dve podle store_id
drop table if exists inventory_store_1;
drop table if exists inventory_store_2;
create table inventory_store_1 as 
select *
from inventory 
where inventory_id in (496, 1553, 1563)
;
create table inventory_store_2 as 
select *
from inventory 
where inventory_id in (861, 971, 1264)
;
-- presvedcete se, zda jsou to skutecne polozky ze store_id = 1 a store_id = 2
select store_id, count(*) from inventory_store_1 group by store_id;
select store_id, count(*) from inventory_store_2 group by store_id;

-- mala cast tabulky filmu
drop table if exists film_8;
create table film_8 as 
select * 
from film 
where film_id in (110, 341, 343, 
                  189, 216, 280,
                  1, 4)
;                  
select * from film_8;


-- Jak se jmenuji filmy v inventory_store_1?
SELECT is1.store_id, 
       is1.inventory_id,
       f8.film_id,
       f8.title
FROM inventory_store_1 as is1
    JOIN film_8 as f8
       ON is1.film_id = f8.film_id
;







-- nespecifikovany JOIN = INNER JOIN 
SELECT is1.store_id, 
       is1.inventory_id,
       f8.film_id,
       f8.title
FROM inventory_store_1 as is1
     INNER JOIN film_8 as f8
       ON is1.film_id = f8.film_id
;

-- LEFT OUTER JOIN 
select * from film_8;

SELECT f8.film_id,
       f8.title,
       is1.store_id, 
       is1.inventory_id       
FROM film_8 as f8 
     LEFT JOIN inventory_store_1 as is1
       ON is1.film_id = f8.film_id
;
SELECT f8.film_id,
       f8.title,
       is1.store_id, 
       is1.inventory_id       
FROM inventory_store_1 as  is1
     RIGHT JOIN film_8 as f8
       ON is1.film_id = f8.film_id
;




-- vazba 1:1 vs 1:many
-- pripravime si dve tabulky:
drop table if exists five_films;
create table five_films as 
select  inventory_id, film_id, store_id
from inventory
where inventory_id in (496, 493, 494, 495, 497)
;
select * from five_films
;
drop table if exists film_3;
create table film_3 as 
select film_id, title
from film 
where film_id in (110,111,343)
;
select * from film_3;

-- inner join s 1:many
select f3.*,
		ff.inventory_id,
        ff.store_id
from film_3   f3
	 inner join five_films ff
       on f3.film_id = ff.film_id 
;

-- outer join s 1:many
select f3.*,
		ff.inventory_id,
        ff.store_id
from film_3   f3
	 left outer join five_films ff
       on f3.film_id = ff.film_id 
;



-- NULL
SELECT f8.film_id,
       f8.title,
       is1.store_id, 
       is1.inventory_id
FROM inventory_store_1 as is1
     RIGHT JOIN film_8 as f8
       ON is1.film_id = f8.film_id
;
SELECT f8.film_id,
       f8.title,
       --is1.store_id,
	   coalesce(is1.store_id, 9),
       is1.inventory_id
FROM inventory_store_1 as is1
     RIGHT JOIN film_8 as f8
       ON is1.film_id = f8.film_id
WHERE store_id is null       
;

-- NULL neni prazdna hodnota
select *
from address 
where address2 is null; 
-- 4 rows

select *
from address 
where address2 ='' and address2 is not null;  -- 599 rows




------------------------  UNION  ------------------------ 


select * 
from inventory_store_1
UNION 
select *
from inventory_store_2
;

drop table if exists inventory_both_stores;
create table inventory_both_stores as 
select * 
from inventory_store_1
UNION 
select *
from inventory_store_2
;

-- UNION vylucuje duplicity:
select * 
from inventory_store_1
UNION 
select *
from inventory_store_1
;

-- UNION ALL nevylucuje duplicity
select * 
from inventory_store_1
UNION ALL 
select *
from inventory_store_1
;

select * , 'horni tabulka' as zdroj 
from inventory_store_1
UNION ALL 
select *, 'dolni tabulka' as zdroj 
from inventory_store_1
;




------------------------  SUB-QUERY a EXIST  ------------------------ 
-- Ktere filmy nejsou v inventari?
select * 
from film
where film_id not in 
  (select film_id from inventory) -- subquery
; --42 filmu