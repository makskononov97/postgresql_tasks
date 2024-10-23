/*Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) 
             равным “Behind the Scenes”.*/

select * from public.film where special_features && array['Behind the Scenes']; 


/*Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL 
             для поиска значения в массиве.*/

select * 
  from (select f.*, generate_subscripts(special_features, 1) as s
          from public.film f) t
 where special_features[s] = 'Behind the Scenes';

select * from public.film where 'Behind the Scenes' = any (special_features);


/*Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.*/

with films as (select film_id from public.film where special_features && array['Behind the Scenes'])
select c.customer_id, first_name, last_name, count(*) as count_rental 
  from public.customer c
  join public.rental p on c.customer_id = p.customer_id 
  join public.inventory i on i.inventory_id = p.inventory_id 
 where exists (select 1 from films where films.film_id = i.film_id)
 group by c.customer_id, first_name, last_name
 order by c.customer_id;

/*--если предположить что есть покупатель, который не брал в аренду фильмы
with films as (select film_id from public.film where special_features && array['Behind the Scenes'])
select c.customer_id, first_name, last_name, count(*) filter (where films.film_id is not null) as count_rental 
  from public.customer c
  left join public.rental p on c.customer_id = p.customer_id 
  left join public.inventory i on i.inventory_id = p.inventory_id 
  left join films on films.film_id = i.film_id
 group by c.customer_id, first_name, last_name
 order by c.customer_id;*/
  
/*Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать 
для решения задания.*/

select c.customer_id, first_name, last_name, count(*) as count_rental 
  from public.customer c
  join public.rental p on c.customer_id = p.customer_id 
  join public.inventory i on i.inventory_id = p.inventory_id 
 where exists (select 1 from public.film where film.film_id = i.film_id and special_features && array['Behind the Scenes'])
 group by c.customer_id, first_name, last_name
 order by c.customer_id;

/*Задание 5. Создайте материализованное представление с запросом из предыдущего задания и 
напишите запрос для обновления материализованного представления.*/
--создание 
create materialized view if not exists mv_film_rental_statistics
as
select c.customer_id, first_name, last_name, count(*) as count_rental 
  from public.customer c
  join public.rental p on c.customer_id = p.customer_id 
  join public.inventory i on i.inventory_id = p.inventory_id 
 where exists (select 1 from public.film where film.film_id = i.film_id and special_features && array['Behind the Scenes'])
 group by c.customer_id, first_name, last_name
 order by c.customer_id;

--обновление
refresh materialized view mv_film_rental_statistics;


/*Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;
какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.*/

--Ответ: Немного быстрее работает с cte, но для лучшего анализа необходимо добавить данных в таблицы.

--Execution Time: 22 ms в среднем
explain (analyze, buffers)
with films as (select film_id from public.film where special_features && array['Behind the Scenes'])
select c.customer_id, first_name, last_name, count(*) as count_rental 
  from public.customer c
  join public.rental p on c.customer_id = p.customer_id 
  join public.inventory i on i.inventory_id = p.inventory_id 
 where exists (select 1 from films where films.film_id = i.film_id)
 group by c.customer_id, first_name, last_name
 order by c.customer_id;

--Execution Time: 23 ms в среднем
explain (analyze, buffers)
select c.customer_id, first_name, last_name, count(*) as count_rental 
  from public.customer c
  join public.rental p on c.customer_id = p.customer_id 
  join public.inventory i on i.inventory_id = p.inventory_id 
 where exists (select 1 from public.film where film.film_id = i.film_id and special_features && array['Behind the Scenes'])
 group by c.customer_id, first_name, last_name
 order by c.customer_id;
 

--Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.

 select staff_id, first_name, last_name, payment_id, customer_id, rental_id, amount, payment_date
   from (select s.staff_id, s.first_name, s.last_name, p.payment_id, customer_id, rental_id, amount, payment_date, 
                row_number() over(partition by s.staff_id order by p.payment_date desc) as rn
           from staff s 
           left join payment p on s.staff_id = p.staff_id) t
  where t.rn = 1;
 

/*Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
•	день, в который арендовали больше всего фильмов (в формате год-месяц-день);
•	количество фильмов, взятых в аренду в этот день;
•	день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
•	сумму продажи в этот день.*/
 
 with rental_info 
 as (
 select rental_date, store_id, cnt,
        row_number() over(partition by store_id order by cnt desc) as rn
   from (select r.rental_date::date, s.store_id, count(*) as cnt 
           from rental r 
           join customer c on r.customer_id  = c.customer_id 
           join store s on s.store_id = c.store_id 
          group by rental_date ::date, s.store_id) t ), 
payment_info 
as (
  select payment_date, store_id, sum_amound,
         row_number() over(partition by store_id order by sum_amound asc) as rn
    from (select p.payment_date::date, s.store_id, sum(p.amount) as sum_amound 
            from payment p 
            join rental r on r.rental_id = p.rental_id 
            join customer c on r.customer_id  = c.customer_id 
            join store s on s.store_id = c.store_id 
           group by s.store_id, p.payment_date::date) t
 )
 select ri.store_id as "идентификатор магазина", 
        ri.rental_date as "день, в который арендовали больше всего фильмов", 
        ri.cnt as "количество фильмов, взятых в аренду", 
        pin.payment_date as "день, в который продали фильмов на наименьшую сумму", 
        pin.sum_amound "сумма продажи в этот день"
   from rental_info ri join payment_info pin on ri.store_id = pin.store_id and ri.rn = 1 and pin.rn = 1;