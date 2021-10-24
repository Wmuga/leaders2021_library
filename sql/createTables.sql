/*
DROP TABLE personlink;
DROP TABLE langlink;
DROP TABLE circulations;
DROP TABLE main_catalog;
DROP TABLE authors;
DROP TABLE siglaslink;
DROP TABLE siglstore;
DROP TABLE bookpoints;
DROP TABLE organisation;
DROP TABLE persons;
DROP TABLE places;
DROP TABLE publishers;
DROP TABLE serials;
DROP TABLE readers;*/



--ALTER TABLE main_catalog ALTER COLUMN title TYPE text;
CREATE TABLE IF NOT EXISTS main_catalog (
	rec_id integer NOT NULL,
	author_id integer,
	title TEXT,
	place_id integer,
	publ_id integer,
	yea VARCHAR(250) ,
	serial_id integer ,
	material varchar(255) ,
	biblevel VARCHAR(255) ,
	ager varchar(3) ,
	CONSTRAINT catalog_p PRIMARY KEY (rec_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS readers (
	abis_id integer NOT NULL,
	date_of_birth DATE ,
	address varchar(255) ,
	CONSTRAINT readers_pk PRIMARY KEY (abis_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS circulations (
	circulation_id integer NOT NULL,
	catalogue_record_id integer ,
	barcode VARCHAR(250) ,
	startdate DATE ,
	finishdate DATE ,
	reader_id integer ,
	bookpoint_id integer ,
	state VARCHAR(250) ,
	CONSTRAINT circulations_pk PRIMARY KEY (circulation_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS authors (
	author_id integer NOT NULL,
	author varchar(255) ,
	CONSTRAINT authors_pk PRIMARY KEY (author_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS persons (
	person_id integer NOT NULL,
	person varchar(255) ,
	CONSTRAINT persons_pk PRIMARY KEY (person_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS serials (
	serial_id integer NOT NULL,
	serial_type varchar(255) ,
	CONSTRAINT serials_pk PRIMARY KEY (serial_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS organisation (
	organisation_id integer NOT NULL,
	organisation varchar(255) ,
	CONSTRAINT organisation_pk PRIMARY KEY (organisation_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS places (
	place_id integer NOT NULL,
	place varchar(255) ,
	CONSTRAINT places_pk PRIMARY KEY (place_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS publishers (
	publisher_id integer NOT NULL,
	publisher varchar(255) ,
	CONSTRAINT publishers_pk PRIMARY KEY (publisher_id)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS langlink (
	rec_id integer,
	lang_name VARCHAR(255)
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS personlink (
	rec_id integer,
	person_id integer
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS annotations(
	rec_id integer,
	annotation_text TEXT
) WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS recomendations(
	user_id integer,
	rec_id integer
)WITH (
  OIDS=FALSE
);

CREATE INDEX ON recomendations (user_id);

CREATE TABLE IF NOT EXISTS key_words(
	rec_id integer,
	keyword varchar(255)
)WITH (
  OIDS=FALSE
);

CREATE TABLE IF NOT EXISTS reader_history(
	user_id integer,
	rec_id integer
)WITH (
  OIDS=FALSE
);

CREATE INDEX ON recomendations (user_id);
CREATE INDEX ON key_words (rec_id);
CREATE INDEX ON key_words (keyword);

ALTER TABLE main_catalog ADD CONSTRAINT catalog_fk0 FOREIGN KEY (author_id) REFERENCES authors(author_id);
ALTER TABLE main_catalog ADD CONSTRAINT catalog_fk1 FOREIGN KEY (place_id) REFERENCES places(place_id);
ALTER TABLE main_catalog ADD CONSTRAINT catalog_fk2 FOREIGN KEY (publ_id) REFERENCES publishers(publisher_id);
ALTER TABLE main_catalog ADD CONSTRAINT catalog_fk5 FOREIGN KEY (serial_id) REFERENCES serials(serial_id);

ALTER TABLE circulations ADD CONSTRAINT circulations_fk0 FOREIGN KEY (catalogue_record_id) REFERENCES main_catalog(rec_id);
ALTER TABLE circulations ADD CONSTRAINT circulations_fk2 FOREIGN KEY (reader_id) REFERENCES readers(abis_id);
ALTER TABLE circulations ADD CONSTRAINT circulations_fk3 FOREIGN KEY (bookpoint_id) REFERENCES bookpoints(bookpoint_id);

ALTER TABLE bookpoints ADD CONSTRAINT bookpoints_fk0 FOREIGN KEY (bookpoint_cbs) REFERENCES organisation(organisation_id);

ALTER TABLE personlink ADD CONSTRAINT personlink_fk0 FOREIGN KEY (rec_id) REFERENCES main_catalog(rec_id);
ALTER TABLE personlink ADD CONSTRAINT personlink_fk1 FOREIGN KEY (person_id) REFERENCES persons(person_id);

CREATE INDEX ON rubrics (rec_id);
CREATE INDEX ON langlink (rec_id);
CREATE INDEX ON persons (lower(person));
CREATE INDEX ON organisation (lower(organisation));
CREATE INDEX ON places (lower(place));
CREATE INDEX ON publishers (lower(publisher));
CREATE INDEX ON serials (lower(serial_type));

