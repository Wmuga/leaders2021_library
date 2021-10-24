--Загрузка и сохранение данных из CSV

--Импорт Авторов
COPY authors FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\authors.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';') ;

--Импорт Мест
COPY places FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\places.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';') ;

--Импорт издательств
COPY publishers FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\publishers.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';') ;

--Импорт Языков
COPY langlink FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\langs_1.csv' 
	WITH (FORMAT csv, DELIMITER ';') ;
COPY langlink FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\langs_2.csv' 
	WITH (FORMAT csv, DELIMITER ';') ;
COPY langlink FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\langs_3.csv' 
	WITH (FORMAT csv, DELIMITER ';') ;
	
--Импорт рубрик
COPY rubrics FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\rubrics.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';') ;

--Импорт персон
COPY persons FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\persons.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');

--Импорт Серии
COPY serials FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\series.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');	
	
--Импорт Читателей
COPY readers FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\readers.csv' 
	WITH (FORMAT csv, DELIMITER ';');

--Импорт Рубрик
COPY rubrics FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\rubrics_1.csv' 
	WITH (FORMAT csv, DELIMITER ';');

--Импорт Catalog
COPY temp_Catalog (rec_id, author_name, title, place, publ, yea, lang, rubrics, person, serial_type, material, biblevel, ager)
	FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\cat_1.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
COPY temp_Catalog (rec_id, author_name, title, place, publ, yea, lang, rubrics, person, serial_type, material, biblevel, ager)
	FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\cat_2.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
--НЕСКОЛЬКО ПЕРСОН НА 1 КНИГУ

--ФУНКЦИЯ ОБРАБОТКИ ТЕМП КАТАЛОГА
SELECT set_idbyname();
SELECT transferFromTempToCatalog();

CREATE TABLE IF NOT EXISTS temp_circulations (
	circulation_id integer NOT NULL,
	catalogue_record_id integer ,
	barcode VARCHAR(250) ,
	startdate DATE ,
	finishdate DATE ,
	reader_id integer ,
	bookpoint_id integer ,
	state VARCHAR(250) ,
	CONSTRAINT temp_circulations_pk PRIMARY KEY (circulation_id)
) WITH (
  OIDS=FALSE
);

--Импорт Circulations
COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_1.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_2.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_4.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_5.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_6.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_7.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_8.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_9.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_10.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_11.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_12.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_13.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_14.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_15.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	COPY temp_circulations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\circulaton_16.csv' 
	WITH (FORMAT csv, HEADER, DELIMITER ';');
	
DELETE FROM temp_circulations WHERE circulation_id IN (
	SELECT circulation_id
		FROM temp_circulations
		FULL JOIN main_catalog ON catalogue_record_id = rec_id
		FULL JOIN readers ON reader_id = abis_id
		WHERE rec_id ISNULL OR abis_id ISNULL OR WHERE NOT temp_circulations.state = 'На руках' 
);

INSERT INTO circulations circulation_id, catalogue_record_id, startdate, finishdate, reader_id FROM temp_circulations;

--Аннотации
--DELETE FROM annotations
COPY annotations FROM 'C:\Program Files\PostgreSQL\14\data\datasets_2\annotation.csv' 
	WITH (FORMAT csv, DELIMITER ';');
