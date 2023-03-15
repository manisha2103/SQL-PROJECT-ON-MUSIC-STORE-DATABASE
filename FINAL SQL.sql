create database musicdata;
use musicdata;


#1. Employee table.

create table employee(employee_id int primary key,last_name varchar(50),first_name varchar(100),title varchar(100),reports_to int ,
levels varchar(10) ,birthdate datetime ,hire_date datetime, address varchar(100),city varchar(100),state varchar(100),
country varchar(50),postal_code varchar(20),phone varchar(50),
fax varchar(50),email varchar(50));

select * from employee;

#2.      Customers Table.

create table customer(customer_id int primary key,first_name varchar(50),last_name varchar(50),company varchar(100),
address varchar(100),city varchar(100), state varchar(10),country varchar(50),postal_code varchar(50),phone varchar(20) ,
fax varchar(20) ,email varchar(100),support_rep_id int not null ,
constraint fk_sup foreign key (support_rep_id) references employee(employee_id) on update cascade on delete cascade );
select * from customer;

#3. invoice table

create table invoice(invoice_id int primary key,customer_id int not null,invoice_date datetime,billing_address varchar(100),
billing_city varchar(50),billing_state varchar(10),billing_country varchar(10),billing_postal_code varchar(50),total float4 ,
 constraint fk_cust foreign key (customer_id) references customer(customer_id) on update cascade on delete cascade);
select * from invoice;

#4. invoice line table

create table invoice_line(invoice_line_id int primary key ,invoice_id int not null ,track_id int ,unit_price float,quantity bigint, 
constraint fk_in foreign key(invoice_id) references invoice(invoice_id) on update cascade on delete cascade,
constraint fk_track  foreign key(track_id) references track(track_id) on update cascade on delete cascade);
select * from invoice_line;

#5. track table
 
create table track(track_id int primary key,name varchar(150),album_id int not null,
media_type_id int not null,genre_id int not null,composer varchar(150),milliseconds int,bytes int,unit_price float4,
constraint fk_media_type_id foreign key(media_type_id) references media_type(media_type_id) on update cascade on delete cascade,
constraint fk_genre_id foreign key(genre_id) references genre(genre_id) on update cascade on delete cascade,
constraint fk_album_id foreign key(album_id) references album(album_id) on update cascade on delete cascade);

select * from track;

#6. playlist table

create table playlist(playlist_id int primary key,name varchar(50));
select * from playlist;

#7. playlist track table

create table playlist_track(playlist_id int not null ,track_id int not null,
constraint fk_playlistid foreign key (playlist_id) references playlist(playlist_id) on update cascade on delete cascade,
constraint fk_track_id foreign key(track_id) references track(track_id) on update cascade on delete cascade);

select * from playlist_track;

#8. media type table

create table media_type(media_type_id int primary key ,name varchar(50));
select * from media_type;

#9. genre table

create table genre(genre_id int primary key ,name varchar(50));
select * from genre;

#10. album table

create table album(album_id int primary key ,title varchar(200),artist_id int not null,
constraint fk_artist_id foreign key(artist_id) references artist(artist_id) on update cascade on delete cascade);
select * from album;

#11. artist table 

create table artist(artist_id int primary key,name varchar(50));
select * from artist;
 


#QUESTIONS
# 1. Who is the senior most employee based on job title?
desc employee;
select * from employee order by levels desc limit 1 ;

# 2. Which countries have the most Invoices?
select * from invoice;
select billing_country,count(invoice_id) as count  from invoice  group by billing_country order by count(invoice_id) desc;

# 3. What are top 3 values of total invoice?
desc invoice;
select total from invoice order by total desc limit 3;

# 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, 
sum(total) as total from invoice
group by billing_city
order by total desc limit 1;

# 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money
select * from invoice;
select * from customer;

select c.first_name as customername,sum(total) as total_spend from customer c join invoice i on c.customer_id=i.customer_id
group by customername order by total_spend desc limit 1;

# 6. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select * from customer;
select * from invoice;
select * from genre;
select * from track;

select distinct c.email as email, c.first_name as first_name, c.last_name as last_name
from customer c join invoice i on c.customer_id = i.customer_id 
join invoice_line inl on i.invoice_id = inl.invoice_id 
join track t on inl.track_id = t.track_id 
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock' order by c.email;

# 7. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
select * from artist;
select * from genre;
select * from album;
select * from track;

select ar.artist_id as artist_id, ar.name as name, count(t.name) as song
from artist ar join album al on al.artist_id = ar.artist_id
join track t on al.album_id = t.album_id
join genre g on t.genre_id = g.genre_id
where g.name = 'Rock' group by ar.artist_id, ar.name, g.name
order by song desc limit 10;


# 8. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select * from track;

select t.name , t.milliseconds from track t where t.milliseconds > 
(select avg(milliseconds) from track) order by t.milliseconds desc;

# 9. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent
select * from customer;
select * from artist;

select a.name as name, sum(il.unit_price) as spent_amount, sum(il.quantity) as quantity, 
c.customer_id as customer_id, c.first_name as first_name, c. last_name as last_name
from artist a join album al on a.artist_id =al.artist_id
join track t on t.album_id = al.album_id
join invoice_line il on il.track_id = il.track_id
join invoice i on il.invoice_id = i.invoice_id
join customer c on c.customer_id = i.customer_id
where a.name = 'Iron Maiden' group by customer_id order by spent_amount desc;

# 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
WITH CountryGenPopularityList AS
(SELECT count(*) as Popularity, gen.name as GenreName, i.billing_country as Country
FROM 	invoice_line il
		JOIN track trk ON trk.track_id=il.track_id
		JOIN genre gen ON gen.genre_id=trk.genre_id
		JOIN invoice i ON il.invoice_id = i.invoice_id
GROUP BY Country, gen.genre_id)

SELECT cgpl.Country, cgpl.GenreName, cgpl.Popularity 
FROM CountryGenPopularityList cgpl
WHERE 	cgpl.Popularity = (SELECT 	max(Popularity) FROM CountryGenPopularityList 
									WHERE cgpl.Country=Country
									GROUP BY Country
									)
ORDER BY Country;

# 11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount
WITH TotalsPerCountry as
(
SELECT i.billing_country, cust.first_name || ' ' || cust.last_name as CustomerId, sum(i.total) as TotalSpent
FROM invoice i
JOIN customer cust ON cust.customer_id=i.customer_id
GROUP BY i.billing_country, cust.customer_id
ORDER BY i.billing_country
)               

SELECT a.billing_country, a.CustomerId, a.TotalSpent
FROM  TotalsPerCountry a
WHERE a.TotalSpent = (	SELECT max(TotalSpent) 
FROM TotalsPerCountry
WHERE a.billing_country=billing_country
GROUP BY billing_country 
);



