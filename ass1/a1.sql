--Q1
create or replace view Q1(pid, firstname, lastname) as
select Person.pid,firstname,lastname 
from Person 
join client on person.pid = client.pid
join staff on person.pid = staff.pid 
order by person.pid;


--Q2
create or replace view Q2v1(brand,rate) as
select ii.brand, max(rr.rate)
from Insured_Item ii
join policy po on ii.id = po.id
join Coverage c on po.pno = c.pno
join Rating_record rr on c.coid = rr.coid
group by brand;

create or replace view Q2v2(brand,car_id,pno,rate) as
select ii.brand, ii.id, po.pno, rr.rate
from Insured_Item ii
join policy po on ii.id = po.id
join Coverage c on po.pno = c.pno
join Rating_record rr on c.coid = rr.coid;

create or replace view Q2(brand, car_id, pno, premium) as
select brand, car_id, pno, rate
from Q2v2
where rate = (select rate from Q2v1 where brand = Q2v2.brand)
order by brand, car_id, pno;


--Q3

create or replace view Q3(pid,firstname, lastname) as
select p.pid, p.firstname, p.lastname 
from person p 
join staff s on p.pid = s.pid
where s.sid not in 
(select po.sid
from policy po
join underwriting_record ur on po.pno = ur.pno
join underwritten_by ub on ub.urid = ur.urid
where (select current_date - ub.wdate) < 365)
order by pid;





--Q4
create or replace view Q4v1(suburb, npolicies) as
select person.suburb,count(*) as npolicies
from person
join client on person.pid = client.pid
join insured_by on client.cid= insured_by.cid
join policy on insured_by.pno = policy.pno
where person.state = 'NSW'
group by suburb
order by npolicies,suburb;

create or replace view Q4(suburb, npolicies) as
select upper(suburb), npolicies
from Q4v1;

--Q5
create or replace view Q5(pno, pname, pid, firstname, lastname) as
select distinct po.pno, po.pname,p.pid,p.firstname,p.lastname
from person p
join staff s on s.pid = p.pid
join rated_by rb on rb.sid = s.sid
join rating_record rr on rr.rid = rb.rid
join coverage c on c.coid = rr.coid
join policy po on c.pno = po.pno and po.sid = s.sid
join underwriting_record ur on po.pno = ur.pno
join underwritten_by ub on ur.urid = ub.urid and ub.sid = rb.sid
order by po.pno;



--Q6
create or replace view Q6v1(pid, number) as 
select p.pid, count(ii.brand)
from person p
join staff s on p.pid = s.pid
join policy po on s.sid = po.sid
join insured_item ii on po.id = ii.id
group by p.pid
order by p.pid;

create or replace view Q6(pid, name, brand) as 
select person.pid, concat(concat(firstname,' '),lastname) as name, insured_item.brand
from person
join staff on person.pid = staff.pid
join policy on staff.sid = policy.sid
join insured_item on policy.id = insured_item.id
join Q6v1 on Q6v1.pid = person.pid
where Q6v1.number = 1
order by person.pid;

--Q7
create or replace view Q7v2(pid,brand) as 
select p.pid, count(distinct(ii.brand))
from person p 
join client c on c.pid = p.pid
join insured_by ib on ib.cid = c.cid
join policy po on ib.pno = po.pno
join insured_item ii on po.id = ii.id
group by p.pid
order by p.pid;

create or replace view Q7(pid,name) as 
select distinct person.pid, concat(concat(firstname,' '),lastname) as name
from person 
join client on client.pid = person.pid
join insured_by on insured_by.cid = client.cid
join policy on insured_by.pno = policy.pno
join insured_item on policy.id = insured_item.id
join Q7v2 on Q7v2.pid = person.pid
where Q7v2.brand = (select count(distinct(brand)) 
from insured_item)
order by person.pid;


--Q8
create or replace view Q8v1(pno,num_cname) as
select po.pno, count(distinct(c.cname)) from
policy po join coverage c on po.pno = c.pno
group by po.pno;

create or replace view Q8v2(pno,cname,num_cname) as
select po.pno, c.cname, Q8v1.num_cname from
policy po join coverage c on po.pno = c.pno
join Q8v1 on Q8v1.pno = po.pno;

create or replace view Q8v3(pno,total) as 
select tmp1.pno, count(tmp1.cname) 
from Q8v2 tmp1 join Q8v2 tmp2 on tmp1.cname = tmp2.cname
where tmp1.num_cname >= tmp2.num_cname and tmp1.cname = tmp2.cname 
group by tmp1.pno;

create or replace view Q8(pno,npolicies) as
select distinct(Q8v3.pno), Q8v3.total-Q8v2.num_cname
from Q8v2 join Q8v3 on Q8v2.pno = Q8v3.pno
order by pno;



--Q9

create or replace view Q9(pno) as
select po.pno from policy po
where po.status = 'E' and (current_date - po.effectivedate >= 0 ) and (current_date - po.expirydate <= 0)
order by po.pno;

create or replace view Q9v1(num) as
select count(*) from Q9;

create or replace function ratechange(Adj integer) returns integer 
as $$
begin
	if (Adj = 0 or Adj > 99 or Adj < -99) then
		return 0;
	else  
	update rating_record 
	set rate = rate + (rate * Adj/100)
	where coid in (select c.coid from coverage c join Q9 on Q9.pno = c.pno order by Q9.pno);
	return (select num from Q9v1);
	end if;
end;
$$ language plpgsql;
	
