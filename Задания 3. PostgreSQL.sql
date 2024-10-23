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