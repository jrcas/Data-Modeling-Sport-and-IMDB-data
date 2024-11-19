--CREATE TABLE players_scd (
--	player_name TEXT,
--	scoring_class scoring_class,
--	is_active boolean,
--	current_season integer,
--	start_season integer,
--	end_season integer,
--	PRIMARY key(player_name, start_season)
--);

INSERT INTO players_scd 
WITH with_previous AS (
	SELECT
		player_name,
		scoring_class,
		is_active,
		current_season,
		LAG(scoring_class, 1) OVER (PARTITION BY player_name ORDER BY current_season) AS previous_scoring_class,
		LAG(is_active, 1) OVER (PARTITION BY player_name ORDER BY current_season) AS previous_is_active
	FROM players p
	WHERE current_season <= 2021
),
with_indicators AS (
	SELECT 
		*,
		CASE
			WHEN scoring_class <> previous_scoring_class THEN 1
			WHEN is_active <> previous_is_active THEN 1
			ELSE 0
		END AS change_indicator
	FROM
		with_previous		
),
with_streaks AS (
	SELECT 
		*,
		sum(change_indicator) 
			OVER (PARTITION BY player_name ORDER BY current_season) AS streak_identifier
	FROM with_indicators
)

SELECT 
	player_name,
	scoring_class,
	is_active,
	2021 AS current_season, -- Think OF this AS IF this was injected USING a orchestration tool
	min(current_season) AS start_season, 
	MAX(current_season) AS end_season
	
FROM 
	with_streaks
GROUP BY 
	player_name,
	streak_identifier, 
	is_active,scoring_class
ORDER BY player_name, streak_identifier;

SELECT * FROM players_scd ps 