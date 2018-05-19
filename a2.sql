SET search_path TO A2;

--If you define any views for a question (you are encouraged to), you must drop them
--after you have populated the answer table for that question.
--Good Luck!

--Query 1
INSERT INTO query1(
SELECT DISTINCT PLAYER.pname, CITY.cname, TOURNAMENT.tname from CHAMPION,TOURNAMENT,TEAM,PLAYER,CITY
WHERE TOURNAMENT.tid = CHAMPION.tid and CHAMPION.mid = TEAM.gid and TOURNAMENT.cid != TEAM.cid 
and CITY.cid = TEAM.cid
AND PLAYER.tid = CHAMPION.mid
ORDER BY PLAYER.pname ASC);

--Query 2
INSERT INTO query2(
SELECT distinct TEAM.gname from TEAM WHERE TEAM.gname NOT in (
SELECT DISTINCT TEAM.gname from TEAM, CHAMPION where TEAM.gid = CHAMPION.mid)
UNION
SELECT DISTINCT TEAM.gname from CHAMPION,TOURNAMENT,TEAM,PLAYER,CITY
WHERE TOURNAMENT.tid = CHAMPION.tid and CHAMPION.mid = TEAM.gid and TOURNAMENT.cid != TEAM.cid 
and CITY.cid = TEAM.cid
ORDER BY gname ASC);

--Query 3 
INSERT INTO query3(
SELECT distinct PLAYER.pid, PLAYER.pname FROM TEAM, event, PLAYER WHERE TEAM.gid = event.lossid 
AND PLAYER.tid = TEAM.gid AND TEAM.gname NOT in 
	(SELECT TEAM.gname from TEAM, PLAYER WHERE PLAYER.globalrank = 1 and TEAM.gid = PLAYER.tid)

UNION

SELECT distinct PLAYER.pid, PLAYER.pname FROM TEAM, event, PLAYER WHERE TEAM.gid = event.winid 
AND PLAYER.tid = TEAM.gid and TEAM.gname NOT in 
	(SELECT TEAM.gname from TEAM, PLAYER WHERE PLAYER.globalrank = 1 and TEAM.gid = PLAYER.tid)
ORDER BY pname ASC);

--Query 4
INSERT INTO query4(
SELECT CHAMPION.mid as tid, TEAM.gname AS tname, CITY.cname as city
FROM CHAMPION, TOURNAMENT, TEAM, CITY
WHERE CHAMPION.mid = TEAM.gid and TEAM.cid = CITY.cid
GROUP BY CHAMPION.mid HAVING COUNT(DISTINCT CHAMPION.tid) = COUNT(DISTINCT TOURNAMENT.tname)
ORDER BY TEAM.gname ASC
);

--Query 5
INSERT INTO query5(
SELECT TEAM.gid, TEAM.gname, avg(RECORD.wins) as average FROM TEAM, RECORD 
WHERE TEAM.gid=RECORD.rid and RECORD.year <= 2015 and RECORD.year >= 2011 
GROUP BY TEAM.gname ORDER BY average DESC LIMIT 10
);

--Query 6
CREATE VIEW firstseason AS (SELECT gid, gname, AVG(wins) as average FROM TEAM,RECORD 
	WHERE RECORD.rid = TEAM.gid and year <= 2013 and year >= 2012 GROUP BY TEAM.gname);
CREATE VIEW secondseason AS (SELECT gid, gname, AVG(wins) as average FROM TEAM,RECORD
	WHERE RECORD.rid = TEAM.gid and year <= 2014 and year >= 2013 GROUP BY TEAM.gname);
CREATE VIEW thirdseason AS (SELECT gid, gname, AVG(wins) as average FROM TEAM,RECORD 
	WHERE RECORD.rid = TEAM.gid and year <= 2015 and year >= 2014 GROUP BY TEAM.gname);

INSERT INTO query6(
SELECT distinct TEAM.gid as tid, TEAM.gname as tname, CITY.cname as city from TEAM,CITY 
WHERE CITY.cid = TEAM.cid AND TEAM.gid not IN
(SELECT distinct TEAM.gid from TEAM,
(
SELECT TEAM.gid, TEAM.gname, CITY.cname from TEAM, firstseason, RECORD, CITY 
where TEAM.gid = RECORD.rid and RECORD.rid = firstseason.gid and RECORD.wins > firstseason.average and
 RECORD.year =2013 AND CITY.cid = TEAM.cid) as f,
(
SELECT TEAM.gid, TEAM.gname, CITY.cname from TEAM, secondseason, RECORD, CITY 
where TEAM.gid = RECORD.rid and RECORD.rid = secondseason.gid and RECORD.wins > secondseason.average 
and RECORD.year =2014 AND CITY.cid = TEAM.cid) as s,
(
SELECT TEAM.gid, TEAM.gname, CITY.cname from TEAM, thirdseason, RECORD, CITY 
where TEAM.gid = RECORD.rid and RECORD.rid = thirdseason.gid and RECORD.wins > thirdseason.average 
and RECORD.year =2015 AND CITY.cid = TEAM.cid) as t 

WHERE TEAM.gid = f.gid AND TEAM.gid = s.gid AND TEAM.gid = t.gid)
ORDER BY TEAM.gname ASC
);
DROP VIEW firstseason CASCADE;
DROP VIEW secondseason CASCADE;
DROP VIEW thirdseason CASCADE;

--Query 7
INSERT INTO query7(
SELECT PLAYER.pname, year, TEAM.gname AS tname FROM PLAYER, TEAM,
(SELECT DISTINCT winid AS id, year FROM event 
WHERE lossid IN
(SELECT DISTINCT CHAMPION.mid 
FROM CHAMPION)

UNION

SELECT DISTINCT lossid as id, year FROM event 

WHERE winid IN
(SELECT DISTINCT CHAMPION.mid 
FROM CHAMPION)
) AS against
WHERE TEAM.gid = against.id

ORDER BY PLAYER.pname DESC, against.year  DESC
);

--Query 8
INSERT INTO query8(
SELECT DISTINCT p1.pname, p2.pname, COUNT(*)
FROM TEAM t1, TEAM t2, event e1, event e2, PLAYER p1, PLAYER p2
WHERE e1.winid = t1.gid AND e1.lossid = t2.gid
and e2.winid = t2.gid AND e2.lossid = t1.gid
and p1.tid = t1.gid and p2.tid = t2.gid
GROUP BY p1.pname
ORDER BY p1.pname  DESC
);

--Query 9
INSERT INTO query9(
select CITY.cname, COUNT(CHAMPION.tid) tournaments FROM CHAMPION, TEAM, CITY
WHERE CHAMPION.mid = TEAM.gid AND CITY.cid = TEAM.cid
GROUP BY TEAM.gname HAVING COUNT(CHAMPION.tid) < 2
ORDER BY CITY.cname ASC
);

--Query 10
CREATE view thirdpart AS
SELECT winid as id, TEAM.gname, avg(duration) FROM event, TEAM 
WHERE TEAM.gid = event.winid GROUP BY TEAM.gname HAVING avg(duration)> 200
UNION
SELECT lossid AS id, TEAM.gname, avg(duration) FROM event, TEAM 
WHERE TEAM.gid = event.lossid GROUP BY TEAM.gname HAVING avg(duration)> 200;

INSERT INTO query10(
SELECT TEAM.gname AS tname FROM TEAM, RECORD, thirdpart WHERE TEAM.gid = RECORD.rid and year= 2012 
AND RECORD.wins > RECORD.losses AND TEAM.gid = thirdpart.id GROUP BY TEAM.gname
ORDER BY TEAM.gname  DESC
);
DROP VIEW thirdpart CASCADE;


