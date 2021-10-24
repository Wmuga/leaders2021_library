/*делаем простую формочку, мне надо по переданному id пользовател
я получить список книг, которые он читал
(Название книги, автор, жанр, год, язык, краткое описание)
и таким же образом по Id получить список рекомендуемых книг (с теме же полями). 
пока всё.

Можно ещё одно представление добавить - список пользователей 
и их стата (id, кол-во взятых книг, фио(еслии такая инфа в бд есть))*/

DROP FUNCTION get_books_by_user;
CREATE OR REPLACE FUNCTION get_books_by_user(_usid integer)
RETURNS TABLE(reader_id integer, title text, author varchar(255), /*rubr varchar(255),*/ yea varchar (255), 
			  /*lan varchar(255),*/ annotation text, rec_id integer) AS $$
	BEGIN
		RETURN QUERY
		SELECT abis_id, main_catalog.title, authors.author, /*rubrics.rubric,*/ main_catalog.yea, /*langlink.lang_name,*/ annotation_text, main_catalog.rec_id
			FROM readers
			LEFT JOIN circulations ON abis_id = circulations.reader_id
			LEFT JOIN main_catalog ON main_catalog.rec_id = catalogue_record_id
			LEFT JOIN authors ON main_catalog.author_id = authors.author_id
			/*LEFT JOIN rubrics ON main_catalog.rec_id = rubrics.rec_id*/
			/*LEFT JOIN langlink ON main_catalog.rec_id = langlink.rec_id*/
			--LEFT JOIN languages ON langlink.lang_id = languages.lang_id
			LEFT JOIN annotations ON main_catalog.rec_id = annotations.rec_id
			WHERE abis_id = _usid AND circulations.state = 'На руках';--ДОБАВИТЬ условие что пользователь читал или сейчас читает
			
	END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_books_by_user(34534);

CREATE TABLE history_for_csv(
	reader_id integer, 
	title text, 
	author varchar(255),
	yea varchar (255), 
	annotation text, rec_id integer
) WITH (
  OIDS=FALSE
);

CREATE TABLE books_for_csv( 
	title text, 
	author varchar(255),
	yea varchar (255), 
	annotation text, 
	rec_id integer,
	CONSTRAINT books_pk PRIMARY KEY (rec_id)
) WITH (
  OIDS=FALSE
);

INSERT INTO books_for_csv SELECT DISTINCT ON (main_catalog.rec_id) main_catalog.title, authors.author, main_catalog.yea, annotation_text, main_catalog.rec_id
			FROM main_catalog
			LEFT JOIN authors ON main_catalog.author_id = authors.author_id
			LEFT JOIN annotations ON main_catalog.rec_id = annotations.rec_id
			;
			
			
SELECT * from books_for_csv WHERE Length(annotation) IN (
	SELECT MAX(Length(annotation)) FROM books_for_csv 
) 


SELECT * from books_for_csv WHERE Length(title) IN (
	SELECT MAX(Length(title)) FROM books_for_csv   
)

SELECT * from books_for_csv WHERE Length(author) IN (
	SELECT MAX(Length(author)) FROM books_for_csv   
)
  


INSERT INTO history_for_csv SELECT abis_id, main_catalog.title, authors.author, /*rubrics.rubric,*/ main_catalog.yea, /*langlink.lang_name,*/ annotation_text, main_catalog.rec_id
			FROM readers
			LEFT JOIN circulations ON abis_id = circulations.reader_id
			LEFT JOIN main_catalog ON main_catalog.rec_id = catalogue_record_id
			LEFT JOIN authors ON main_catalog.author_id = authors.author_id
			/*LEFT JOIN rubrics ON main_catalog.rec_id = rubrics.rec_id*/
			/*LEFT JOIN langlink ON main_catalog.rec_id = langlink.rec_id*/
			--LEFT JOIN languages ON langlink.lang_id = languages.lang_id
			LEFT JOIN annotations ON main_catalog.rec_id = annotations.rec_id
			/*WHERE abis_id = _usid AND circulations.state = 'На руках'*/;
			
COPY history_for_csv TO 'C:\Program Files\PostgreSQL\14\data\datasets_2\history.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';') ;
	
	
	

