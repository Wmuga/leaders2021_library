--Найти айди автора в таблице авторов по имение, если такого нет, то -1
CREATE OR REPLACE FUNCTION findAuthorIdCoincidence(_str VARCHAR(250)) 
RETURNS integer AS $$
    DECLARE 
		_found_id integer DEFAULT -1;
	BEGIN
		SELECT INTO _found_id author_id FROM authors WHERE _str = author;	
		IF _found_id IS NULL
		THEN 
			RETURN -1;
		ELSE 
			RETURN _found_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--Найти айди места в таблице мест по имени, если такого нет, то -1

CREATE OR REPLACE FUNCTION findPlaceIdCoincidence(_str VARCHAR(250)) 
RETURNS integer AS $$
    DECLARE 
		_found_id integer DEFAULT -1;
	BEGIN
		SELECT INTO _found_id place_id FROM places WHERE _str = place;	
		IF _found_id IS NULL
		THEN 
			RETURN -1;
		ELSE 
			RETURN _found_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--Найти айди издательства в таблице издательств по имени, если такого нет, то -1

CREATE OR REPLACE FUNCTION findPublisherIdCoincidence(_str VARCHAR(250)) 
RETURNS integer AS $$
    DECLARE 
		_found_id integer DEFAULT -1;
	BEGIN
		SELECT INTO _found_id publisher_id FROM publishers WHERE _str = publisher;	
		IF _found_id IS NULL
		THEN 
			RETURN -1;
		ELSE 
			RETURN _found_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--Найти айди языка в таблице языков по названию, если такого нет, то -1

CREATE OR REPLACE FUNCTION findLangIdCoincidence(_str VARCHAR(3)) 
RETURNS integer AS $$
    DECLARE 
		_found_id integer DEFAULT -1;
	BEGIN
		SELECT INTO _found_id lang_id FROM languages WHERE _str = lang_short;	
		IF _found_id IS NULL
		THEN 
			RETURN -1;
		ELSE 
			RETURN _found_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--Найти айди рубрику в таблице рубрик по имени, если такого нет, то -1

CREATE OR REPLACE FUNCTION findRubricIdCoincidence(_str VARCHAR(250)) 
RETURNS integer AS $$
    DECLARE 
		_found_id integer DEFAULT -1;
	BEGIN
		SELECT INTO _found_id rubric_id FROM rubrics WHERE _str = rubric;	
		IF _found_id IS NULL
		THEN 
			RETURN -1;
		ELSE 
			RETURN _found_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--Найти айди персоны в таблице персон по имени, если такого нет, то -1

CREATE OR REPLACE FUNCTION findPersonIdCoincidence(_str VARCHAR(250)) 
RETURNS integer AS $$
    DECLARE 
		_found_id integer DEFAULT -1;
	BEGIN
		SELECT INTO _found_id person_id FROM persons WHERE _str = person;	
		IF _found_id IS NULL
		THEN 
			RETURN -1;
		ELSE 
			RETURN _found_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;

--Найти айди серии в таблице серий по имени, если такого нет, то -1

CREATE OR REPLACE FUNCTION findSerialIdCoincidence(_str VARCHAR(250)) 
RETURNS integer AS $$
    DECLARE 
		_found_id integer DEFAULT -1;
	BEGIN
		SELECT INTO _found_id serial_id FROM serials WHERE _str = serial_type;	
		IF _found_id IS NULL
		THEN 
			RETURN -1;
		ELSE 
			RETURN _found_id;
		END IF;
	END;
$$ LANGUAGE plpgsql;