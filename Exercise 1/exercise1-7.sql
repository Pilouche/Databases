-- CREATE TABLE Planets (
--     star text not null, 
--     name text not null,
--     distance float not null check( distance>0 ), 
--     mass float not null check( mass>0 ), 
--     atmosphere boolean not null, 
--     oxygen float not null 
--     check( (oxygen=0 and not atmosphere) or 
--         (atmosphere and oxygen>=0 )), 
--     water float not null, 
--     primary key(star,name), 
--     UNIQUE (star,distance)
-- ) ;
--------------------------------------------
-- SELECT count(*) 
-- FROM  Planets
-- WHERE distance > (
--     SELECT distance FROM Planets
--     where star = 'Kerbol' and name='Duna'
-- );
--------------------------------------------
( SELECT star, name, 'habitable'
FROM Planets
WHERE distance>=100 AND distance<=200 AND
atmosphere AND oxygen >= 15 AND oxygen <= 25 AND
water>0 )
UNION
( 
SELECT star, name, 'uninhabitable' 
FROM planets 
WHERE NOT ( distance>=100 AND distance<=200 AND
atmosphere AND oxygen >= 15 AND oxygen <= 25 AND
water > 0 ) 
);