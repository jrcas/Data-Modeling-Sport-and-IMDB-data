CREATE OR REPLACE PROCEDURE insert_actors_cumulative(IN last_year integer, IN this_year integer)
LANGUAGE plpgsql
AS $procedure$
BEGIN 
	INSERT INTO actors
	WITH yesterday AS (
	    SELECT *
	    FROM actors a
	    WHERE a.current_year = last_year
	),
	today AS (
	    SELECT *
	    FROM actor_films af 
	    WHERE af.year = this_year
	)
	SELECT 
	    COALESCE(t.actor, y.actor) AS actor,
	    COALESCE(t.actorid, y.actorid) AS actorid,
	    CASE 
	        WHEN COUNT(t.actorid) > 0 THEN TRUE
	        ELSE FALSE
	    END AS is_active,
	    CASE 
	        WHEN y.films IS NULL THEN 
	            ARRAY_AGG(ROW(
	                t.year,
	                t.film,
	                t.votes,
	                t.rating,
	                t.filmid
	            )::films)
	        WHEN t.year IS NOT NULL THEN 
	            y.films || ARRAY_AGG(ROW(
	                t.year,
	                t.film,
	                t.votes,
	                t.rating,
	                t.filmid
	            )::films)
	        ELSE y.films
	    END AS films,
	    CASE
			WHEN AVG(t.rating) IS NULL THEN y.quality_class 
	        WHEN AVG(t.rating) > 8 THEN 'star'
	        WHEN AVG(t.rating) > 7 THEN 'good'
	        WHEN AVG(t.rating) > 6 THEN 'average'
	        ELSE 'bad'
	    END::quality_class AS quality_class,
	    COALESCE(t.year, y.current_year + 1) AS current_year
	FROM today t 
	FULL OUTER JOIN yesterday y
	    ON t.actorid = y.actorid
	GROUP BY 
	    COALESCE(t.actor, y.actor),
	    COALESCE(t.actorid, y.actorid),
	    COALESCE(t.year, y.current_year + 1),
	    y.films,
		y.quality_class,
	   	t.year;
END;
$procedure$
;

DO $$
BEGIN
	for i_year IN 1969..2010 loop
		CALL insert_actors_cumulative(i_year, i_year+1);
end loop;
END;
$$;