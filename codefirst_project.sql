CREATE DATABASE art_gallery;
USE art_gallery;

-- TABLE 1 - ARTWORK_LOCATION
CREATE TABLE artwork_location
(artist_id INTEGER NOT NULL,
artwork_id INTEGER NOT NULL,
artwork_name VARCHAR(100),
location VARCHAR(50) NOT NULL);

INSERT INTO 
artwork_location
(artist_id, artwork_id, artwork_name, location)
VALUES
(1, 5, 'The Persistence of Memory', 'Room 2'),
(2, 6, 'The Lovers', 'Room 2'),
(3, 1, 'Ophelia', 'Room 1'),
(4, 2, 'The Lady of Shalott', 'Room 1'),
(5, 7, 'Les Demoiselles d\'Avignon', 'Room 2'),
(6, 8, 'Bibemus Quarry', 'Room 2'),
(7, 3, 'The Birth of Venus', 'Room 1'),
(8, 4, 'Lamentation', 'Room 1'),
(9, 9, 'Impression, Sunrise', 'Room 3'),
(10, 10, 'Plum Brandy', 'Room 3'),
(11, 11, 'The Starry Night', 'Room 3'),
(12, 12, 'The Midday Nap', 'Room 3');

-- TABLE 2 - ARTWORK_YEAR
CREATE TABLE artwork_year
(artist_id INTEGER NOT NULL,
artwork_id INTEGER NOT NULL,
work_year INTEGER NOT NULL);

INSERT INTO 
artwork_year
(artist_id, artwork_id, work_year)
VALUES
(1, 5, 1931),
(2, 6, 1928),
(3, 1, 1851),
(4, 2, 1888),
(5, 7, 1907),
(6, 8, 1900),
(7, 3, 1485),
(8, 4, 1306),
(9, 9, 1872),
(10, 10, 1877),
(11, 11, 1889),
(12, 12, 1894);

-- TABLE 3 - ARTIST_MOVEMENT
CREATE TABLE artist_movement
(artist_id INTEGER NOT NULL, 
artist_name VARCHAR(100),
movement VARCHAR(50));

INSERT INTO 
artist_movement
(artist_id, artist_name, movement)
VALUES
(1, 'Salvador Dalí', 'Surrealism'),
(2, 'René Magritte', 'Surrealism'),
(3, 'John Everett Millais', 'Pre-Raphaelite'),
(4, 'John William Waterhouse', 'Pre-Raphaelite'),
(5, 'Pablo Picasso', 'Cubism'),
(6, 'Paul Cézanne', 'Cubism'),
(7, 'Sandro Botticelli', 'Renaissance'),
(8, 'Giotto', 'Renaissance'),
(9, 'Claude Monet', 'Impressionism'),
(10, 'Édouard Manet', 'Impressionism'),
(11, 'Vincent Van Gogh', 'Post-Impressionism'),
(12, 'Paul Gaugin', 'Post-Impressionism');

-- TABLE 4 - AUCTION_ITEMS
CREATE TABLE auction_items
(buyer_id INTEGER NOT NULL,
artwork_id INTEGER NOT NULL,
date DATE);

INSERT INTO auction_items
(buyer_id, artwork_id, date)
VALUES
(1, 5, '2002-03-12'),
(2, 7, '2010-10-24'),
(3, 12, '2020-03-01'),
(4, 2, '2015-06-30'),
(5, 10, '1998-07-15'),
(6, 1, '2019-08-14');

-- TABLE 5 - AUCTION_BUYER_DETAILS
CREATE TABLE auction_buyer_details
(buyer_id INTEGER NOT NULL, 
first_name VARCHAR(50), 
last_name VARCHAR(50), 
email_address VARCHAR(60));

INSERT INTO auction_buyer_details
(buyer_id, first_name, last_name, email_address)
VALUES
(1, 'Amanda', 'Wright', 'awright@gmail.com'),
(2, 'Roger', 'Smith', 'rs56@gmail.com'),
(3, 'Anna', 'Brown', 'anna.b@hotmail.com'),
(4, 'Quentin', 'Shepherd', 'quentin.shepherd@gmail.com'),
(5, 'George', 'Banks', 'banksg@gmail.com'),
(6, 'Linda', 'McNeil', 'lindamn@hotmail.com');

-- QUERY + SUBQUERY: FIND THE ARTISTS AND MOVEMENTS FROM THE 20TH CENTURY
SELECT artist_name, movement
FROM art_gallery.artist_movement am
WHERE am.artist_id IN (
	SELECT ay.artist_id
	FROM art_gallery.artwork_year ay
	WHERE ay.work_year >= 1900);
    
-- QUERY TO SEE ALL THE MOVEMENTS
SELECT DISTINCT movement
FROM artist_movement;

-- TWO NESTED LEFT JOINS TO SEE WHERE AUCTIONED ITEMS ARE LOCATED AND WHO OWNS THEM
SELECT
al.artwork_name, al.location,
ai.date, abd.first_name, abd.last_name
FROM auction_items ai
LEFT JOIN
artwork_location al 
ON
al.artwork_id =
ai.artwork_id
LEFT JOIN 
auction_buyer_details abd
ON
abd.buyer_id =
ai.buyer_id;

-- STORED FUNCTION THAT CALCULATES HOW MANY YEARS PASSED SINCE THE AUCTION OF THE PAINTING
DELIMITER //

CREATE FUNCTION years_since_sold (
	original_date date
) 
RETURNS INT 
DETERMINISTIC
BEGIN
 DECLARE current_date_is DATE;
  SELECT current_date()INTO current_date_is;
  RETURN year(current_date_is)-year(original_date);
END//

DELIMITER ;

-- EXECUTE FUNCTION
SELECT artwork_id, date, years_since_sold(date) 
AS 'Years since sold' 
FROM auction_items;

-- STORED PROCEDURE THAT SHOWS ALL KNOWN DETAILS ABOUT PAINTINGS IN THE GALLERY
DELIMITER //

CREATE PROCEDURE GetAllDetails()
BEGIN
	SELECT
	am.artist_id, al.artwork_id, am.artist_name, al.artwork_name,
	am.movement, ay.work_year, al.location
	FROM artist_movement am
	LEFT JOIN
	artwork_location al 
	ON
	al.artist_id =
	am.artist_id
	LEFT JOIN 
	artwork_year ay
	ON
	al.artist_id =
	ay.artist_id;
END //
DELIMITER ;

CALL GetAllDetails();

-- RECURRING EVENT THAT RECORDS VISITOR NUMBERS
CREATE TABLE recording_visitor_numbers (
	visitor_number INT NOT NULL AUTO_INCREMENT,
    last_update TIMESTAMP, PRIMARY KEY(visitor_number));

DELIMITER //
    
CREATE EVENT recorded_number_of_visitors
ON SCHEDULE EVERY 10 second
STARTS NOW()
DO BEGIN
	INSERT INTO recording_visitor_numbers(last_update) VALUE (Now());
END//

DROP EVENT recorded_number_of_visitors;