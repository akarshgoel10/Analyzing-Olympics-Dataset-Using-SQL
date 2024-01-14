# Q1. How many olympics games have been held?

select count(distinct games) as no_of_games from olympics

# Q2.  List down all Olympics games held so far.

select distinct games from olympics

# Q3. Mention the total no of nations who participated in each olympics game?

select games,count(distinct noc) as no_of_nations from olympics group by games

# Q4. Which year saw the highest and lowest no of countries participating in olympics

with  tab as (
select year,count(distinct noc) as no_of_nations from olympics group by year) 

select concat(first_value(year) over(order by no_of_nations),' - ',
first_value(no_of_nations) over(order by no_of_nations)) as lowest,
concat(first_value(year) over(order by no_of_nations desc),' - ',
first_value(no_of_nations) over(order by no_of_nations desc)) as highest
from tab limit 1

# Q5 SQL query to return the list of countries who have been part of every Olympics games.

with counting as(
select  count(distinct a.games) as tot,b.region from olympics a join noc b on a.noc = b.noc
group by b.region)

select * from counting where tot = 
(select count(distinct games) as no_of_games from olympics)

# Q6. Identify the sport which was played in all summer olympics.



with gam as (
select sport,count(distinct games) as no_of_times_part from olympics
where season = 'Summer' group by sport)

select sport,no_of_times_part from 
gam where no_of_times_part = (select count(distinct games) as total from olympics where season = 'Summer')

# Q7. Which Sports were just played only once in the olympics

with hg as (select sport,count(distinct games) as counting from olympics group by sport 
having count(distinct games) = 1)

select distinct a.games,b.sport,counting
from olympics a join hg b on a.sport = b.sport

# Q8. Fetch the total no of sports played in each olympic games

select games,count(distinct sport) from olympics group by games order by count(distinct sport) desc

#Q9. Fetch oldest athletes to win a gold medal

with old as(
select name,cast(case when age = 'NA' then '0' else age end as int) as age
	,medal
from olympics where medal = 'Gold')

select * from( 
select *,dense_rank() over(order by age desc) as rnk from old)g where rnk = 1

# Q10. Find the Ratio of male and female athletes participated in all olympic games.

with counting as(
select count(case when sex = 'M' then 1 end) as male,
count(case when sex = 'F' then 1 end) as female
	from olympics)

select concat('1: ',round((male::float/female::float)::numeric,2)) as ratio from counting

# Q11. Fetch the top 5 athletes who have won the most gold medals.

with top as (
select name,count(medal) as tot from olympics where medal = 'Gold' 
group by name)

select * from(
select *,dense_rank() over(order by tot desc) as rnk from top)v where rnk<= 5

# Q12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze)

with top as(
select name,count(medal) as tot from olympics where medal in('Gold','Silver','Bronze') group by name)
select * from(
select *,dense_rank() over(order by tot desc) as rnk from top)h where rnk <= 5

# Q13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

with top as(
select b.region,count(medal) as cnt from olympics a join noc b 
on a.noc = b.noc where medal in ('Gold','Silver','Bronze') group by b.region)
select * from(
select *,dense_rank() over(order by cnt desc) as rnk from top) a where rnk <= 5

# Q14.  List down total gold, silver and bronze medals won by each country.
	
SELECT
    nr.region AS country,
    COALESCE(SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END), 0) AS gold,
    COALESCE(SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END), 0) AS silver,
    COALESCE(SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END), 0) AS bronze
FROM
    olympics oh
JOIN
    noc nr ON nr.noc = oh.noc
WHERE
    medal <> 'NA'
GROUP BY
    nr.region
ORDER BY
    gold DESC, silver DESC, bronze DESC;


# Q15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

select a.games,b.region,
coalesce(sum(case when medal = 'Gold' then 1 else 0 end),0) as total_gold,
coalesce(sum(case when medal = 'Silver' then 1 else 0 end),0) as total_silver,
coalesce(sum(case when medal = 'Bronze' then 1 else 0 end),0) as total_bronze
from olympics a join noc b
on b.noc = a.noc where medal <> 'NA' 
group by games,region order by games

# Q16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

with coll as (
select a.games,b.region,
coalesce(sum(case when medal = 'Gold' then 1 else 0 end),0) as total_gold,
coalesce(sum(case when medal = 'Silver' then 1 else 0 end),0) as total_silver,
coalesce(sum(case when medal = 'Bronze' then 1 else 0 end),0) as total_bronze
from olympics a join noc b
on b.noc = a.noc where medal <> 'NA' 
group by games,region order by games)

select distinct games,
concat(
first_value(region) over(partition by games order by total_gold desc),' - ',
first_value(total_gold) over(partition by games order by total_gold desc)) as most_golds,
concat(
first_value(region) over(partition by games order by total_silver desc),' - ',
first_value(total_silver) over(partition by games order by total_silver desc)) as most_silver,
concat(
first_value(region) over(partition by games order by total_bronze desc),' - ',
first_value(total_bronze) over(partition by games order by total_bronze desc)) as most_bronze
from coll order by games

# Q17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

with coll as (
select a.games,b.region,
coalesce(sum(case when medal = 'Gold' then 1 else 0 end),0) as total_gold,
coalesce(sum(case when medal = 'Silver' then 1 else 0 end),0) as total_silver,
coalesce(sum(case when medal = 'Bronze' then 1 else 0 end),0) as total_bronze
from olympics a join noc b
on b.noc = a.noc where medal <> 'NA' 
group by games,region order by games),

total as (
select games,region,
sum(total_gold + total_silver + total_bronze) as tot
from coll group by games,region order by games)

select distinct coll.games,
concat(
first_value(coll.region) over(partition by coll.games order by total_gold desc),' - ',
first_value(total_gold) over(partition by coll.games order by total_gold desc)) as most_golds,
concat(
first_value(coll.region) over(partition by coll.games order by total_silver desc),' - ',
first_value(total_silver) over(partition by coll.games order by total_silver desc)) as most_silver,
concat(
first_value(coll.region) over(partition by coll.games order by total_bronze desc),' - ',
first_value(total_bronze) over(partition by coll.games order by total_bronze desc)) as most_bronze,
concat(first_value(coll.region) over(partition by coll.games order by tot desc),' - ',
first_value(tot) over(partition by total.games order by tot desc)) as most_medals
from coll join total on coll.games = total.games and coll.region = total.region
order by coll.games

# Q18.  Which countries have never won gold medal but have won silver/bronze medals?

with total as(
select b.region,
coalesce(sum(case when medal = 'Gold' then 1 else 0 end),0) as total_gold,
coalesce(sum(case when medal = 'Silver' then 1 else 0 end),0) as total_silver,
coalesce(sum(case when medal = 'Bronze' then 1 else 0 end),0) as total_bronze
from olympics a join noc b
on b.noc = a.noc where medal <> 'NA'
group by region)

SELECT *
FROM total
WHERE total_gold = 0 AND (total_silver > 0 OR total_bronze > 0) 
order by  total_silver desc,total_bronze desc ;

# Q19.  In which Sport/event, India has won highest medals.

select sport,total_medals from(
select sport,count(medal) as total_medals,
dense_rank() over(order by count(medal) desc) as rnk
 from olympics a join noc b
on a.noc = b.noc where region = 'India' and medal <> 'NA' group by sport)k where rnk = 1 

# Q20.  Break down all olympic games where India won medal for Hockey and how many medals in each olympic games

select games,count(medal) as tot from olympics a join noc b
on a.noc = b.noc where medal <> 'NA' and b.region = 'India' and sport = 'Hockey'
group by games order by tot desc