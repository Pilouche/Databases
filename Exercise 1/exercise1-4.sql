SELECT * FROM thattable
GROUP BY Name, Section
HAVING count(*) > 1