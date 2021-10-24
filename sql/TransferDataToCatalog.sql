--Временная таблица для хранения поступившего каталога
CREATE TABLE IF NOT EXISTS temp_catalog (
	rec_id serial NOT NULL,
	author_name varchar(255),
	title text,
	place varchar(255),
	publ varchar(255),
	yea varchar(255),
	lang varchar(255),
	rubrics text,
	person text,
	serial_type varchar(255),
	material varchar(255),
	biblevel varchar(255),
	ager varchar(3),
	--поля для поиска существующих значений в других таблицах
	author_id integer,
	place_id integer,
	publ_id integer,
	--rubrics_id integer,
	person_id integer,
	serial_id integer,
	CONSTRAINT temp_catalog_pk PRIMARY KEY (rec_id)
) WITH (
  OIDS=FALSE
);

/*CREATE TABLE IF NOT EXISTS temp_langlink (
	rec_id INTEGER,
	lang_name VARCHAR
);*/

CREATE TABLE IF NOT EXISTS temp_personlink(
	rec_id INTEGER,
	person_id INTEGER
);

--Функция разбиения строки с перечислением языков на таблицу языковых значений
CREATE OR REPLACE FUNCTION break_lang_string(_str VARCHAR(250))
RETURNS TABLE(l TEXT) AS $$
	BEGIN
		return query select * from string_to_table(_str, ' , ') as l;
	END;
$$ LANGUAGE plpgsql;


--Функция разбиения строки с перечислением языков на таблицу языковых значений
CREATE OR REPLACE FUNCTION break_persons_string(_str TEXT)
RETURNS TABLE(l TEXT) AS $$
	BEGIN
		return query select * from string_to_table(_str, ' : ') as l;
	END;
$$ LANGUAGE plpgsql;

--Установить айди во временной таблице, если такие поля есть в других таблицах
--Если  нет -> Добавить и взять id

CREATE OR REPLACE FUNCTION set_idbyname()
RETURNS void AS $$
    DECLARE 
		_rec_id INTEGER;
		_author VARCHAR(255);
		_place VARCHAR(255);
		_publ VARCHAR(255);
		--_lang TEXT;
		_person TEXT;
		_serial VARCHAR(255);
		_biblevel VARCHAR(255);
		_tmplang TEXT;
		
		_author_id INTEGER;
		_place_id INTEGER;
		_publ_id INTEGER;
		--_lang_id INTEGER;
		_person_id INTEGER;
		_serial_id INTEGER;
		_curs CURSOR FOR SELECT rec_id, author_name, place, publ,
			person, serial_type
			FROM temp_catalog;
		_curs2 CURSOR FOR SELECT l FROM tmp;
			
	BEGIN
		OPEN _curs;
		CREATE TABLE tmp (l text);
		LOOP
			_author_id := NULL;
			_place_id := NULL;
			_publ_id := NULL;
			--_lang_id := NULL;
			_person_id := NULL;
			_serial_id := NULL;
	
			FETCH _curs INTO _rec_id, _author, _place, _publ, _person, _serial;
			
			EXIT WHEN _rec_id IS NULL;	--Выйти когда кончатся записи в таблице
			IF _author IS NOT NULL	--Проверка автора
			THEN
				_author_id:= findAuthorIdCoincidence(_author);
				IF _author_id = -1
				THEN
					SELECT author_id INTO _author_id FROM authors ORDER BY author_id DESC LIMIT 1 ;
					_author_id:=_author_id+1;
					INSERT INTO authors (author_id, author)
						VALUES (_author_id, _author);
				END IF;
			END IF;
			
			IF _place IS NOT NULL	--Проверка места
			THEN
				_place_id:= findPlaceIdCoincidence(_place);
				IF _place_id = -1
				THEN
					SELECT place_id INTO _place_id FROM places ORDER BY place_id DESC LIMIT 1 ;
					_place_id:=_place_id+1;
					INSERT INTO places (place_id, place)
						VALUES (_place_id, _place);
				END IF;
			END IF;
			
			IF _publ IS NOT NULL	--Проверка издательства
			THEN
				_publ_id:= findPublisherIdCoincidence(_publ);
				IF _publ_id = -1
				THEN
					SELECT publisher_id INTO _publ_id FROM publishers ORDER BY publisher_id DESC LIMIT 1 ;
					_publ_id:=_publ_id+1;
					INSERT INTO publishers (publisher_id, publisher)
						VALUES (_publ_id, _publ);
				END IF;
			END IF;
			
			DELETE FROM tmp;
			
			IF _person IS NOT NULL	--Проверка персоны
			THEN
				IF strpos(_person, ' : ') <> 0
					THEN
						INSERT INTO tmp (l) SELECT break_lang_string(_person);
						OPEN _curs2;
						LOOP
							FETCH _curs2 INTO _tmplang;
							EXIT WHEN _tmplang IS NULL;
							_person_id := findPersonIdCoincidence(_tmplang::varchar(255));
							IF _person_id = -1
								THEN
								SELECT person_id INTO _person_id FROM persons ORDER BY person_id DESC LIMIT 1 ;
								_person_id:=_person_id+1;
								INSERT INTO persons (person_id, person)
									VALUES (_person_id, _tmplang);
							END IF;
							INSERT INTO temp_personlink (rec_id, person_id)
								VALUES (_rec_id, _person_id);
						END LOOP;
						CLOSE _curs2;
					ELSE
						_person_id := findPersonIdCoincidence(_person::varchar(255));
						IF _person_id = -1
								THEN
								 SELECT person_id INTO _person_id FROM persons ORDER BY person_id DESC LIMIT 1 ;
								_person_id:=_person_id+1;
								INSERT INTO persons (person_id, person)
									VALUES (_person_id, _tmplang);
						END IF;
						INSERT INTO temp_personlink (rec_id, person_id)
								VALUES (_rec_id, _person_id);
				END IF;
			END IF;
			
			DELETE FROM tmp;
			
			/*IF _lang IS NOT NULL	--Проверка языка
			--НЕСКОЛЬКО ЯЗЫКОВ РАЗБИТЬ И ДОБАВИТЬ КАЖДЫЙ
			THEN
			
				IF strpos(_lang, ' , ') <> 0
				THEN
					INSERT INTO tmp (l) SELECT break_lang_string(_lang);
					OPEN _curs2;
					LOOP
						FETCH _curs2 INTO _tmplang;
						EXIT WHEN _tmplang IS NULL;
						_lang_id := findLangIdCoincidence(_tmplang::varchar(3));
						IF _lang_id = -1
								THEN
								SELECT lang_id INTO _lang_id FROM languages ORDER BY lang_id DESC LIMIT 1 ;
								 --SELECT COUNT (*) INTO _lang_id FROM languages;
								_lang_id:=_lang_id+1;
								INSERT INTO languages (lang_id, lang_short)
									VALUES (_lang_id, _tmplang);
						END IF;
						INSERT INTO temp_personlink (rec_id, person_id)
								VALUES (_rec_id, _person_id);
						INSERT INTO temp_langlink (rec_id, lang_id)
							VALUES (_rec_id, _lang_id);
					END LOOP;
					CLOSE _curs2;
				ELSE
					_lang_id := findLangIdCoincidence(_lang::varchar(3));
					INSERT INTO temp_langlink (rec_id, lang_id)
							VALUES (_rec_id, _lang_id);
				END IF;
			END IF;*/
			
			--Дополнить таблицу найденными id
			UPDATE temp_catalog SET 
				author_id = _author_id,
				place_id = _place_id, 
				publ_id =  _publ_id, 
				person_id =  _person_id, 
				serial_id = _serial_id
				WHERE CURRENT OF _curs;
			
		END LOOP;
		CLOSE _curs;
		DROP TABLE tmp;
	END;
$$ LANGUAGE plpgsql;

--Процедура передачи данных из временной таблицы в основную
CREATE OR REPLACE FUNCTION transferFromTempToCatalog()
RETURNS void AS $$
	BEGIN
		INSERT INTO main_catalog
			(rec_id, author_id, title, place_id, publ_id, yea, serial_id, material, biblevel, ager )
			SELECT rec_id, author_id, title, 
				place_id, publ_id, yea, 
				/*rubrics_id, person_id,*/
				serial_id, material, biblevel, 
				ager
				FROM temp_catalog;
				
		/*INSERT INTO langlink (rec_id, lang_id)
			SELECT rec_id, lang_id FROM temp_langlink;*/
			
		INSERT INTO personlink (rec_id, person_id)
			SELECT rec_id, person_id FROM temp_personlink;
	END;
$$ LANGUAGE plpgsql;
