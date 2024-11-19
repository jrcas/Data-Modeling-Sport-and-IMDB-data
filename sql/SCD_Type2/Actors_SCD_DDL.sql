CREATE TABLE actors_history_scd (
	actor TEXT,
	actorid TEXT,
	quality_class quality_class,
	is_active boolean,
	current_year integer,
	start_year integer,
	end_year integer,
	PRIMARY KEY (actorid, start_year)
);