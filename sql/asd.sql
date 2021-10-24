



CREATE OR REPLACE FUNCTION recs_List(_user_id INTEGER)
RETURNS TABLE( TEXT) AS $$
	BEGIN
		
		SELECT catalogue_record_id FROM (SELECT * FROM circulations 
			WHERE circulations.reader_id = _user_id AND
			circulations.state = 'На руках';)
		
		
		
		
		
		
		
	END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION get_books_by_user(_usid integer)
RETURNS TABLE(reader_id integer, title text, author varchar(255), rubr varchar(255), yea varchar (255), 
			  lan varchar(255), annotation text) AS $$
	BEGIN
		RETURN QUERY
		SELECT abis_id, main_catalog.title, authors.author, rubrics.rubric, main_catalog.yea, main_catalog.ager, langlink.lang_name, annotation_text
			FROM readers
			LEFT JOIN circulations ON abis_id = circulations.reader_id
			LEFT JOIN main_catalog ON main_catalog.rec_id = catalogue_record_id
			LEFT JOIN authors ON main_catalog.author_id = authors.author_id
			LEFT JOIN rubrics ON main_catalog.rec_id = rubrics.rec_id
			LEFT JOIN langlink ON main_catalog.rec_id = langlink.rec_id
			--LEFT JOIN languages ON langlink.lang_id = languages.lang_id
			LEFT JOIN annotations ON main_catalog.rec_id = annotations.rec_id
			WHERE abis_id = _usid;--ДОБАВИТЬ условие что пользователь читал или сейчас читает
	END;
$$ LANGUAGE plpgsql;



SELECT * FROM readers LIMIT 1
SELECT * FROM recs_List(118736)

DROP TABLE books_by_user;
CREATE TEMP TABLE books_by_user (
 	reader_id integer,
	/*title text,*/
	author INTEGER,
	rubr varchar(255),
	/*yea varchar (255),*/
	ager varchar (3),
	lan varchar(255),
	annotation text
);



SELECT * FROM circulations 
			WHERE circulations.reader_id = 118736 AND
			circulations.state = 'На руках' ;
			
			INSERT INTO books_by_user  (
				SELECT abis_id, /*main_catalog.title,*/ authors.author_id, rubrics.rubric, 
				/*main_catalog.yea,*/ main_catalog.ager, langlink.lang_name, annotation_text
				FROM readers
				LEFT JOIN circulations ON abis_id = circulations.reader_id
				LEFT JOIN main_catalog ON main_catalog.rec_id = catalogue_record_id
				LEFT JOIN authors ON main_catalog.author_id = authors.author_id
				LEFT JOIN rubrics ON main_catalog.rec_id = rubrics.rec_id
				LEFT JOIN langlink ON main_catalog.rec_id = langlink.rec_id
				LEFT JOIN annotations ON main_catalog.rec_id = annotations.rec_id
				WHERE abis_id = 118736 AND circulations.state = 'На руках'--ДОБАВИТЬ условие что пользователь читал или сейчас читает
			)
			
			
			SELECT * FROM main_catalog
				LEFT JOIN authors ON main_catalog.author_id = authors.author_id
				LEFT JOIN rubrics ON main_catalog.rec_id = rubrics.rec_id
				LEFT JOIN langlink ON main_catalog.rec_id = langlink.rec_id
				LEFT JOIN annotations ON main_catalog.rec_id = annotations.rec_id
				WHERE authors.author IN (
					SELECT author FROM books_by_user
				)
				OR rubrics.rubric IN (
					SELECT rubr FROM books_by_user
				)
				OR main_catalog.ager IN (
					SELECT ager FROM books_by_user
				)
				OR langlink.lang_name IN (
					SELECT ager FROM books_by_user
				) LIMIT 10
			




SELECT * FROM books_by_user
			
			
			
			
			
