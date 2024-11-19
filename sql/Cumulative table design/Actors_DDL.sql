create type films as (
	year int,
	film text,
	votes int,
	rating real,
	filmid text
);

create type quality_class as enum('star', 'good', 'average', 'bad');

create table actors (
	actor text,
	actorid text,
	is_active boolean,
	films films[],
	quality_class quality_class,
	current_year int,
	primary key(actorid, current_year)
);
