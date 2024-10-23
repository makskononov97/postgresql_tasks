--Задание 1. Выведите уникальные названия городов из таблицы городов
select distinct city 
  from city 
  order by city;

/*Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, названия которых начинаются на “L” 
             и заканчиваются на “a”, и названия не содержат пробелов. */
select distinct city 
  from city 
 where city like 'L%a' and city !~ '[[:space:]]' 
 order by city;

/*Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 17 июня 2005 года 
             по 19 июня 2005 года включительно и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.*/

select * 
 from payment 
 where payment_date::date between '2005-06-17' and '2005-06-19' 
   and amount > 1.00 
 order by payment_date;

--Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.

select * 
  from payment 
 order by payment_date desc 
 limit 10;

/*Задание 5. Выведите следующую информацию по покупателям:
•	Фамилия и имя (в одной колонке через пробел)
•	Электронная почта
•	Длину значения поля email
•	Дату последнего обновления записи о покупателе (без времени)

 Каждой колонке задайте наименование на русском языке.*/

select concat_ws(' ', last_name, first_name) as "Фамилия и имя", 
       email as "Электронная почта", 
       length(trim(email)) as "Длина значения поля email", 
       last_update::date as "Дата последнего обновления записи о покупателе"
  from public.customer;

/*Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. 
             Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.*/
 
 select lower(first_name) as first_name, lower(last_name) as last_name
   from customer
  where activebool
    and (first_name = 'KELLY' or first_name = 'WILLIE');
 
/*Задание 7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, 
             а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.*/

 select title, rating, rental_rate
   from film
  where (rating = 'R' and rental_rate between 0.00 and 3.00 )
     or (rating = 'PG-13' and rental_rate >= 4.00);
  
--Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.
select *
  from film 
 order by length(title) desc
 limit 3;
    
/*Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
•	в первой колонке должно быть значение, указанное до @,
•	во второй колонке должно быть значение, указанное после @.*/

select split_part(email, '@', 1) as email_part1, split_part(email, '@', 2) as email_part2
  from public.customer;

/*Задание 10. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква должна быть заглавной, 
              остальные строчными.*/
 
 select concat(upper(substring (split_part(email, '@', 1) for 1)), lower(substring (split_part(email, '@', 1) from 2))) as email_part1, 
        concat(upper(substring (split_part(email, '@', 2) for 1)), lower(substring (split_part(email, '@', 2) from 2))) as email_part1
  from public.customer; 