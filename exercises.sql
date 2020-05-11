------------------------ SELECT, FROM, DISTINCT ------------------------ 
-- 1.1 vyberte prvnich pet zaznamu z tabulky film
-- 1.2. vyberte pet zaznamu z tabulky film s nejvyssi hodnotou film_id
-- 1.3 kolik je ruznych film_id v inventory


------------------------ WHERE a FUNKCE ------------------------ 
-- 2.1 vyberte z customer zakazniky s prijmenim zacinajicim na 'Do'
-- 2.2 vyberte z customer zakazniky s prijmenim o delce 4 znaky a kratsi
-- 2.3 vytvorte v customer sloupec s delkou prijmeni
-- 2.4 pomoci case-when rozradte jazyky filmu (tab. language) do skupin 'rozumim' (anglicky, cesky) a 'KO' (ostatni)

------------------------ CREATE TABLE a GROUP BY  ------------------------ 
-- 3.1 Za jakou castku (rental_rate) si muzeme pujcit kolik filmu? tab. film
-- odpoved: za 0.99 lze pujcit 341 filmu, za 2.99 323 filmu, za za 4.99 336 filmu

-- 3.2 Lze si drazsi filmy (rental_rate) pujcit na prumerne delsi dobu (avg z pole rental_duration)? 

-- 3.3 datum nejnovejsi a nejstarsi vypujcky kazdeho zakaznika

-- 3.4 Kolik plateb a v jakych vysich provedli zákazníci 318 a 281?
-- odpoved: zakaznik 318 zaplatil 3x 0.99, 1x 1.99, 2x 2.99 a potom 1x castky 3.99, 4.99, 5.99 a 6.99, 
-- 281 zaplatil 2x 0.99, 2x 2.99 a potom 1x castky 4.99, 5.99 a 8.99
-- napoveda: groupujte podle customer_id a amount, nezapomente je dat do select i group by a seradte podle nich vystup


------------------------  JOIN  ------------------------ 
-- 4.1 Jake filmy (film_id z tab. inventory) si pujcoval zakaznik 61 (tabulka rental)?
-- 4.2 Rozsirte vysledek ukolu 4.1 o dalsi join: pripojte tab. film a zjistete nazvy vypujcek.



-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

------------------------  ODPOVEDI  ------------------------ 

-- 1.1
select * from film limit 5;
-- 1.2
select * from film order by film_id DESC limit 5;
-- 1.3 
select distinct film_id from inventory; --958
select count(distinct film_id) from inventory; --958



-- 2.1
select *
from customer
where last_name like ('Do%');
-- 2.2
select *
from customer
where length(last_name) <= 4;
-- 2.3
select *, length(last_name) as delka_prijmeni
from customer
where length(last_name) <= 4;
-- 2.4
select *,
	case 
            when name in ('English', 'Czech') then 'rozumim'
            else 'KO'
        end as language_group
from language
;




-- 3.1
select rental_rate
		,count(*)
from film 
group by 1
order by 1
;
-- 3.2
select rental_rate, 
		avg(rental_duration) 
from film 
group by 1
;
-- 3.3 
select customer_id, min(rental_date), max(rental_date) from rental group by 1;

-- 3.4
select customer_id, 
	   amount,
       count(payment_id) as pocet_plateb, -- dopocitany sloupec
	   sum(amount) as celkova_vyse
from payment
where customer_id in (318, 281)
group by customer_id, 
	   amount
order by customer_id, 
	   amount
;



-- 4.1
select film_id, * 
from  rental r
	  inner join inventory i
       	on r.inventory_id = i.inventory_id
where r.customer_id = 61;

-- 4.2
select f.film_id, f.title, * 
from  rental r
	  inner join inventory i
       	on r.inventory_id = i.inventory_id
      inner join film f
      	on i.film_id = f.film_id
where r.customer_id = 61;

