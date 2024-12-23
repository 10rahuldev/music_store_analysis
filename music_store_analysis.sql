/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1

/* Q2: Which countries have the most Invoices? */
SELECT billing_country,COUNT(*) FROM invoice
GROUP BY billing_country
ORDER BY COUNT(*) DESC
LIMIT 1

/* Q3: What are top 3 values of total invoice? */

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS total
FROM invoice
GROUP BY billing_city  
ORDER BY total DESC
LIMIT 1


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT first_name,last_name FROM customer
WHERE customer_id=(SELECT customer_id FROM 
					(SELECT customer_id,SUM(total) AS total FROM invoice
					GROUP BY customer_id
					ORDER BY total DESC
					LIMIT 1)
					)

/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT customer.email,customer.first_name,customer.last_name,genre.name FROM customer
				INNER JOIN invoice ON customer.customer_id=invoice.customer_id
				INNER JOIN invoice_line ON invoice.invoice_id=invoice_line.invoice_id
				INNER JOIN track ON invoice_line.track_id=track.track_id
				INNER JOIN genre ON track.genre_id=genre.genre_id
				
WHERE genre.name='Rock' AND email ILIKE 'a%'
ORDER BY customer.email	

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id,artist.name,COUNT(artist.artist_id) AS total_track FROM artist 
INNER JOIN Album ON artist.artist_id = album.artist_id
INNER JOIN track ON album.album_id=track.album_id
INNER JOIN genre ON track.genre_id=genre.genre_id
WHERE genre.name='Rock'
GROUP BY artist.artist_id,artist.name
ORDER BY total_track DESC
LIMIT 10

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT track.name,milliseconds FROM track
WHERE milliseconds > 
					(SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

SELECT customer.customer_id,
		customer.first_name,
		customer.last_name,
		artist.name,
		SUM(il.unit_price*il.quantity) AS total_spent
FROM customer 
INNER JOIN invoice ON customer.customer_id=invoice.customer_id
INNER JOIN invoice_line il ON invoice.invoice_id=il.invoice_id
INNER JOIN track ON il.track_id = track.track_id
INNER JOIN album ON track.album_id=album.album_id
INNER JOIN  artist ON album.artist_id = artist.artist_id
GROUP BY 1,4
ORDER BY 5 DESC,4

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres. */

	WITH most_popular_genre AS (
SELECT genre.name,customer.country,COUNT(*) AS purchase,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(*) DESC) AS row_num
FROM genre 
INNER JOIN track ON genre.genre_id = track.genre_id
INNER JOIN invoice_line AS il ON track.track_id = il.track_id
INNER JOIN invoice On  il.invoice_id = invoice.invoice_id
INNER JOIN customer ON invoice.customer_id = customer.customer_id
GROUP BY 1,2
ORDER BY 2,3 DESC
							
)
SELECT * FROM most_popular_genre
WHERE row_num<=1

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH top_customer AS(
SELECT customer.country,customer.first_name,SUM(il.unit_price*il.quantity) AS total_spent,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY SUM(il.unit_price*il.quantity) DESC ) AS row_num
FROM customer 
INNER JOIN invoice ON customer.customer_id = invoice.customer_id
INNER JOIN invoice_line AS il ON invoice.invoice_id=il.invoice_id
GROUP BY 1,2
ORDER BY customer.country,3 DESC
					
)
SELECT * FROM top_customer
WHERE row_num<=1
