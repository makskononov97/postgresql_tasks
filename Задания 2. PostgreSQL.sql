/*Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.*/
 
select c.first_name, c.last_name, a.address, ct.city, cn.country
  from public.customer c
  join public.address a on c.address_id = a.address_id 
  join public.city ct on ct.city_id = a.city_id
  join public.country cn on cn.country_id = ct.country_id;
 
 
/*Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
•	Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с функцией агрегации. 
•	Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём. */
 
 select c.store_id, c2.city, s2.last_name, s2.first_name, count(c.customer_id)
   from customer c 
   join store s on s.store_id = c.store_id 
   join address a on a.address_id = s.address_id 
   join city c2 on c2.city_id = a.city_id 
   join staff s2 on s2.staff_id = s.manager_staff_id 
  group by c.store_id, c2.city, s2.last_name, s2.first_name
  having count(customer_id) > 300;


/*Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.*/

  select customer_id--, count(rental_id)
    from rental
   group by customer_id
   order by count(rental_id) desc
   limit 5;

/*Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
•	количество взятых в аренду фильмов;
•	общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
•	минимальное значение платежа за аренду фильма;
•	максимальное значение платежа за аренду фильма.*/
   
  select r.customer_id, count(r.rental_id), round(sum(p.amount), 0), min(p.amount), max(p.amount)
    from rental r
    join payment p on r.rental_id = p.rental_id 
   group by r.customer_id;  

/*Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, 
чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение.*/

   select c1.city, c2.city 
     from city c1
    cross join city c2 
    where c1.city_id != c2.city_id; 
   
/*Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), 
вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.*/
    
  select customer_id, round (avg(days_return)) as days_return_avg 
    from (select r.customer_id, extract(day from age (return_date, rental_date)) as days_return
            from rental r) t
   group by customer_id;     

--Дополнительная часть
--Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
  
  select f.film_id, f.title, count(*) as count_rental, sum(rental_rate)
    from rental r
    join inventory i on i.inventory_id = r.inventory_id 
    join film f on f.film_id = i.film_id 
   group by f.film_id, f.title
   order by f.film_id;
    
--Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
  
  select distinct f.film_id, f.title
    from rental r
    join inventory i on i.inventory_id = r.inventory_id 
    left join film f on f.film_id = i.film_id 
   where f.film_id is null
   order by f.film_id;
  

/*Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». 
             Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».*/
  
 select s.staff_id, s.first_name, s.last_name, coalesce (sum (p.amount), 0) as sum_amount, 
        case when sum (p.amount) > 7300 then 'Да' else 'Нет' end as "Премия"
   from staff s 
   left join payment p on s.staff_id = p.staff_id  
  where s.active 
  group by s.staff_id, s.first_name, s.last_name
  order by s.staff_id;