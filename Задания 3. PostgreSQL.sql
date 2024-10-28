/* Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
•	Пронумеруйте все платежи от 1 до N по дате
•	Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
•	Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, 
    а затем по сумме платежа от наименьшей к большей
•	Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым
    значением имели одинаковое значение номера.
Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.*/
 
 select *, 
        row_number() over(order by payment_date asc) as rn_date, 
        row_number() over(partition by customer_id order by payment_date asc) as rn_customer_date,
        sum(amount) over (partition by customer_id order by payment_date asc, amount asc) as step_sum,
        dense_rank() over(partition by customer_id order by amount asc) as dense_rank
  from payment p
 order by payment_id;

/*Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки 
со значением по умолчанию 0.0 с сортировкой по дате.*/

 select *,
        lag(amount,1,0.0) over(partition by customer_id order by payment_date)
  from payment p
 order by customer_id, payment_date;       

/*Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.*/

 select payment_id, customer_id, amount, payment_date, lead_amount - amount as difference_amount
   from (
		 select payment_id, customer_id, amount, payment_date,
		        lead(amount,1,0.0) over(partition by customer_id order by payment_date) as lead_amount
		  from payment p ) t
   order by customer_id, payment_date; 		  

/*Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.*/

select customer_id, payment_date, amount  
  from (
		 select c.customer_id, p.payment_date, p.amount,
		        row_number() over(partition by c.customer_id order by payment_date desc, p.payment_id) as rn
		   from customer c 
		   left join rental r on r.customer_id = c.customer_id 
		   left join payment p on p.rental_id = r.rental_id ) t
 where rn = 1
 order by customer_id;

/*Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому 
             сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.*/
select * from (
select s.staff_id, p.payment_date::date,
       sum(amount) over (partition by p.staff_id order by payment_date::date asc) as step_sum
  from public.staff s 
  join payment p on p.staff_id = s.staff_id 
 where extract ( year from p.payment_date) = 2005 
   and extract ( month from p.payment_date) = 8) t
 group by staff_id, payment_date, step_sum
 order by staff_id, payment_date;
 

/*Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку 
             на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.*/
select customer_id from (
select c.customer_id, p.payment_date, row_number () over (order by  payment_id) as rn 
  from customer c 
  join payment p on c.customer_id = p.customer_id 
 where p.payment_date::date = '2005-08-20') t 
where rn % 100 = 0;


/*Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
•  покупатель, арендовавший наибольшее количество фильмов;
•  покупатель, арендовавший фильмов на самую большую сумму;
•  покупатель, который последним арендовал фильм.*/

select * from ( 
select c.country_id, c.country,
       first_value (c3.customer_id) over (partition by c.country_id, country order by count(*) desc) as customer_rent_max_films, 
       first_value (c3.customer_id) over (partition by c.country_id, country order by sum(f.rental_rate) desc) as customer_rent_max_sum, 
       first_value (c3.customer_id) over (partition by c.country_id, country order by max (r.rental_date) desc) as customer_last_rent
  from country c 
  join city c2 on c2.country_id = c.country_id 
  join address a on a.city_id = c2.city_id 
  join customer c3 on c3.address_id = a.address_id 
  join rental r on r.customer_id = c3.customer_id 
  join inventory i on i.inventory_id = r.inventory_id
  join film f on f.film_id = i.film_id
group by c.country_id, c.country, c3.customer_id
) t
group by country_id, country, customer_rent_max_films, customer_rent_max_sum, customer_last_rent
order by country_id;
