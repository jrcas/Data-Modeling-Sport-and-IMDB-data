CREATE TYPE scd_actor AS (
	quality_class quality_class,
	is_active boolean,
	start_year integer,
	end_year integer
)


WITH last_year_scd AS (
	SELECT *
	FROM actors_history_scd
	WHERE current_year = 2009
	AND end_year = 2009
),
historical_scd AS (
	SELECT
		actor,
		actorid,
		quality_class,
		is_active,
		start_year,
		end_year
	FROM actors_history_scd
	WHERE current_year = 2009
	AND end_year < 2009
),
this_year_data AS (
	SELECT * FROM actors
	WHERE current_year = 2010
),
unchanged_records AS (
	SELECT
		ty.actor,
		ty.actorid,
		ty.quality_class,
		ty.is_active,
		ly.start_year,
		ty.current_year AS end_year
	FROM this_year_data ty
	JOIN last_year_scd ly
		ON ty.actorid = ly.actorid
	WHERE 
		ty.quality_class = ly.quality_class
		AND ty.is_active = ly.is_active
),
new_records AS (
	SELECT
		ty.actor,
		ty.actorid,
		ty.quality_class,
		ty.is_active,
		ty.current_year AS start_year,
		ty.current_year AS end_year
	FROM this_year_data ty
	LEFT JOIN last_year_scd ly
		ON ty.actorid = ly.actorid
	WHERE 
		ly.actorid IS NULL 
),
changed_records AS (
	SELECT
		ty.actor,
		ty.actorid,
		UNNEST(ARRAY[
			ROW (
				ly.quality_class,
				ly.is_active,
				ly.start_year,
				ly.end_year
			)::scd_actor,
			ROW(
				ty.quality_class,
				ty.is_active,
				ty.current_year,
				ty.current_year
			)::scd_actor
		]) AS unnested
	FROM this_year_data ty
	LEFT JOIN last_year_scd ly
		ON ty.actorid = ly.actorid
	WHERE 
		ty.quality_class <> ly.quality_class
		OR ty.is_active <> ly.is_active
),
unnested_changed_records AS (
	SELECT
		actor,
		actorid,
		(unnested::scd_actor).quality_class,
		(unnested::scd_actor).is_active,
		(unnested::scd_actor).start_year,
		(unnested::scd_actor).end_year
	FROM
		changed_records
),
combined_records AS(
	SELECT * FROM historical_scd
	
	UNION ALL
	
	SELECT * FROM unchanged_records
	
	UNION ALL
	
	SELECT * FROM unnested_changed_records

	UNION ALL
	
	SELECT * FROM new_records
)

SELECT * FROM combined_records

