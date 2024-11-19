INSERT INTO actors_history_scd 
WITH with_previous AS (
	SELECT
		actor,
		actorid,
		quality_class,
		is_active,
		current_year,
		LAG(quality_class, 1) OVER (PARTITION BY actorid ORDER BY current_year) AS previous_quality_class,
		LAG(is_active, 1) OVER (PARTITION BY actorid ORDER BY current_year) AS previous_is_active
	FROM actors a 
	WHERE 
		current_year <= 2010
),
with_indicators AS (
	SELECT
		*,
		CASE 
			WHEN quality_class <> previous_quality_class THEN 1
			WHEN is_active <> previous_is_active THEN 1
			ELSE 0
		END AS change_indicator
	FROM 
		with_previous
),
with_streak AS (
	SELECT 
		*,
		SUM(change_indicator)
			OVER (PARTITION BY actorid ORDER BY current_year) AS streak_identifier
	FROM with_indicators
)


SELECT 
	actor,
	actorid,
	quality_class,
	is_active,
	2010 AS current_year,
	MIN(current_year) AS start_year,
	MAX(current_year) AS end_year
FROM
	with_streak	
GROUP BY
	actor,
	actorid,
	streak_identifier,
	is_active,
	quality_class
ORDER BY actorid, streak_identifier;