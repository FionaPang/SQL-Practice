/*

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT *
FROM Facilities
WHERE membercost !=0;


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) FROM Facilities WHERE membercost = 0;

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name as Facility, membercost 
FROM Facilities
WHERE membercost > 0 AND membercost < monthlymaintenance*0.2;

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * FROM Facilities WHERE facid in (1,5);

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance, 
CASE WHEN monthlymaintenance > 100 THEN 'expensive'
	 WHEN monthlymaintenance <= 100 THEN 'cheap'
END AS Class
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname, joindate 
FROM Members 
WHERE joindate = (SELECT MAX(joindate) FROM Members);

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT
	CONCAT_WS(m.firstname, ' ',m.surname) as Book_tennis
FROM Bookings as b 
LEFT JOIN Members as m ON b.memid=m.memid
LEFT JOIN Facilities as f ON b.facid = f.facid 
WHERE f.name LIKE 'Tennis%'
Group by Book_tennis
ORDER BY Book_tennis;

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name,CONCAT_WS(firstname,' ',surname) as book_name,
	 CASE WHEN b.memid = 0 THEN guestcost*slots
		  WHEN  b.memid != 0 THEN membercost*slots
	 END AS cost
FROM Facilities as f
RIGHT JOIN Bookings as b ON f.facid=b.facid 
LEFT JOIN Members as m ON b.memid=m.memid
WHERE (starttime LIKE '2012-09-14%') AND 
	 ((m.memid = 0 AND b.slots * f.guestcost > 30) OR
     (m.memid > 0 AND b.slots * f.membercost > 30))
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT * FROM

(SELECT f.name,CONCAT_WS(firstname,' ',surname) as book_name,
	 CASE WHEN b.memid = 0 THEN guestcost*slots
		  WHEN  b.memid != 0 THEN membercost*slots
	 END AS cost
FROM Facilities as f
RIGHT JOIN Bookings as b ON f.facid=b.facid 
LEFT JOIN Members as m ON b.memid=m.memid
WHERE starttime LIKE '2012-09-14%')
sub
WHERE cost > 30
ORDER BY sub.cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT * from (
SELECT sub.Facility, sum(sub.cost) AS income FROM

(SELECT f.name as Facility,
	 CASE WHEN b.memid = 0 THEN guestcost*slots
		  WHEN  b.memid != 0 THEN membercost*slots
	 END AS cost
FROM Facilities as f
RIGHT JOIN Bookings as b ON f.facid=b.facid 
LEFT JOIN Members as m ON b.memid=m.memid)
sub
GROUP BY Facility)
total
WHERE total.income <1000;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT e.firstname, e.surname, m.firstname AS recby_firstname, m.surname AS recby_surname
From Members AS e
LEFT JOIN Members AS m ON e.recommendedby = m.memid
WHERE e.recommendedby > 0
ORDER BY e.surname DESC, e.firstname DESC;

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name, COUNT(*) 
FROM Bookings AS b
LEFT JOIN Facilities AS f ON b.facid = f.facid
WHERE memid !=0
GROUP BY f.name;

/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name,count(*),Month(starttime) as month 
from Bookings as b 
left join Facilities as f On b.facid=f.facid
where memid!=0
group by Month(starttime);
