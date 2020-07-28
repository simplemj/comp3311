-- COMP3311 20T1 Exam Answer Template
--
-- * Don't change view names;
-- * Only change the SQL code for view as commented below;
-- * and follow the order of the view arguments as stated in the comments (if any);
-- * and do not remove the ending semicolon of course.
--
-- * You may create additional views, if you wish;
-- * but you are not allowed to create tables.
--


-- Q1 to Q5 --
-- SQL queries
--


drop view if exists Q1;
create view Q1
as
-- replace the SQL code for view Q1(name, total) below:
select d.name as name, ifnull(count(*),0) as total from director d
left join movie m on m.director_id = d.id
group by d.name
order by total desc,d.name asc
;

drop view if exists Q2sub;
create view Q2sub
as
select m.year as year, max(imdb_score) as grade from movie m
join rating r on r.movie_id = m.id
where m.year is not null and r.num_voted_users >= 100000 and m.lang = "English"
group by year
order by year
;

drop view if exists Q2;
create view Q2
as
-- replace the SQL code for view Q2(year, title) below:
select m.year as year, m.title as title from movie m
join rating r on r.movie_id = m.id
join Q2sub on Q2sub.year = m.year and r.imdb_score = Q2sub.grade
where m.year is not null and r.num_voted_users >= 100000 and m.lang = "English"
order by m.year asc,m.title asc
;

drop view if exists movieid;
create view movieid
as
select distinct movie_id from genre 
where genre in ('Crime', 'Horror', 'Mystery', 'Sci-Fi', 'Thriller')
;

drop view if exists allactor;
create view allactor
as
select distinct actor_id, movie_id from acting 
where movie_id in (select movie_id from movieid)
;

drop view if exists noactor;
create view noactor
as
select distinct ac.actor_id from acting ac 
join allactor aa on ac.actor_id = aa.actor_id 
where ac.movie_id not in (select movie_id from movieid)
;

drop view if exists exectactor;
create view exectactor
as
select distinct aa.actor_id from allactor aa 
where actor_id not in (select actor_id from noactor) 
order by actor_id
;

drop view if exists movienum;
create view movienum
as
select actor_id, count(movie_id) as num from acting 
group by actor_id
;

drop view if exists Q3;
create view Q3
as
-- replace the SQL code for view Q3(name) below:
select ac.name, mu.num from actor ac 
join exectactor ea on ac.id = ea.actor_id 
join movienum mu on mu.actor_id = ea.actor_id 
order by mu.num desc, ac.name asc;
;

drop view if exists Q4sub;
create view Q4sub
as
select count(distinct g.genre) as num,sum(r.movie_facebook_likes) as grade,a.name as name from actor a
join acting ac on ac.actor_id = a.id 
left join movie m on m.id = ac.movie_id
join genre g on g.movie_id = m.id
join rating r on m.id = r.movie_id
group by name
order by grade desc, name asc
;


drop view if exists Q4;
create view Q4
as
-- replace the SQL code for view Q4(name) below:
select Q4sub.name from Q4sub
where Q4sub.num >= 18
;

drop view if exists Q5;
create view Q5
as
-- replace the SQL code for view Q5(title, name) below:
select m.title, d.name from movie m join
director d on d.id = m.director_id 
join acting ac on ac.movie_id = m.id
join actor a on a.id = ac.actor_id
where d.name = a.name
order by m.title asc,d.name asc;
;



-- Q6 --
--

drop view if exists Q6a;
create view Q6a
as
-- replace "REPLACE ME" with your answer below (e.g. select "A,BC"):
select "BCD"
;

drop view if exists Q6b;
create view Q6b
as
-- replace "REPLACE ME" with your answer below (e.g. select "A,BC"):
select "A"
;

drop view if exists Q6c;
create view Q6c
as
-- replace "REPLACE ME" with your answer below (e.g. select "A,BC"):
select "ACE，CDE"
;



-- Q7 --
--

drop view if exists Q7a;
create view Q7a
as
-- replace "REPLACE ME" with your answer below (e.g. select "AB,BCD,EFG"):
select "ABCDG，CDE，EF"
;

drop view if exists Q7b;
create view Q7b
as
-- replace "REPLACE ME" with your answer below (e.g. select "AB,BCD,EFG"):
select "ABCDEFG"
;

drop view if exists Q7c;
create view Q7c
as
-- replace "REPLACE ME" with your answer below (e.g. select "AB,BCD,EFG"):
select "ABCDFG，DE"
;



-- Q8 --
--

drop view if exists Q8a;
create view Q8a
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "Y"
;

drop view if exists Q8b;
create view Q8b
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "N"
;

drop view if exists Q8c;
create view Q8c
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "Y"
;

drop view if exists Q8d;
create view Q8d
as
-- replace "REPLACE ME" with your answer below (e.g. select "Y" for serializable, select "N" otherwise):
select "N"
;



-- Q9 --
--

drop view if exists Q9;
create view Q9
as
-- replace "REPLACE ME" with your answer below (e.g. select "A" for choice A):
select "B"
;



-- 10 --
--

drop view if exists Q10;
create view Q10
as
-- replace "REPLACE ME" with your answer below (e.g. select "A" for choice A):
select "A"
;



-- END OF EXAM --
--
