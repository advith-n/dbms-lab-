-- SAILORS table
CREATE TABLE SAILORS (
    sid INT PRIMARY KEY,
    sname VARCHAR(50),
    rating INT,
    age INT
);

INSERT INTO SAILORS (sid, sname, rating, age)
VALUES
    (1, 'John', 8, 30),
    (2, 'Albert', 9, 35),
    (3, 'Eve', 7, 28),
    (4, 'Bob', 8, 32),
    (5, 'Alice', 7, 29);

-- BOAT table
CREATE TABLE BOAT (
    bid INT PRIMARY KEY,
    bname VARCHAR(50),
    color VARCHAR(20)
);

INSERT INTO BOAT (bid, bname, color)
VALUES
    (101, 'Boat1', 'Red'),
    (102, 'Boat2', 'Blue'),
    (103, 'Boat3', 'Green'),
    (104, 'Boat4', 'Yellow'),
    (105, 'Boat5', 'White');

-- RESERVERS table
CREATE TABLE RESERVERS (
    sid INT,
    bid INT,
    date DATE,
    PRIMARY KEY (sid, bid),
    FOREIGN KEY (sid) REFERENCES SAILORS(sid),
    FOREIGN KEY (bid) REFERENCES BOAT(bid)
);

INSERT INTO RESERVERS (sid, bid, date)
VALUES
    (1, 101, '2023-01-01'),
    (2, 103, '2023-02-15'),
    (3, 104, '2023-03-20'),
    (4, 101, '2023-04-10'),
    (5, 102, '2023-05-05');

-- COLORS table
CREATE TABLE COLORS (
    color VARCHAR(20) PRIMARY KEY
);

INSERT INTO COLORS (color)
VALUES
    ('Red'),
    ('Blue'),
    ('Green'),
    ('Yellow'),
    ('White');
---queries
-----Find the colors of boats reserved by Albert:
SELECT DISTINCT B.color
FROM BOAT B
JOIN RESERVERS R ON B.bid = R.bid
JOIN SAILORS S ON R.sid = S.sid
WHERE S.sname = 'Albert';

---

SELECT DISTINCT S.sid
FROM SAILORS S
LEFT JOIN RESERVERS R ON S.sid = R.sid
WHERE S.rating >= 8 OR R.bid = 103;

SELECT sname
FROM SAILORS
WHERE sid NOT IN (
    SELECT DISTINCT R.sid
    FROM RESERVERS R
    JOIN BOAT B ON R.bid = B.bid
    WHERE B.bname LIKE '%storm%'
)
ORDER BY sname ASC;


SELECT S.sname
FROM SAILORS S
WHERE NOT EXISTS (
    SELECT B.bid
    FROM BOAT B
    WHERE NOT EXISTS (
        SELECT R.bid
        FROM RESERVERS R
        WHERE R.sid = S.sid AND R.bid = B.bid
    )
);


    SELECT sname, age
FROM SAILORS
ORDER BY age DESC
LIMIT 1;

SELECT R.bid, AVG(S.age) AS avg_age
FROM RESERVERS R
JOIN SAILORS S ON R.sid = S.sid
WHERE S.age >= 40
GROUP BY R.bid
HAVING COUNT(DISTINCT R.sid) >= 5;

CREATE VIEW BoatReservations AS
SELECT S.sname, B.color
FROM SAILORS S
JOIN RESERVERS R ON S.sid = R.sid
JOIN BOAT B ON R.bid = B.bid;

DELIMITER //
CREATE TRIGGER PreventDeleteBoat
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
    DECLARE reservation_count INT;
    SELECT COUNT(*) INTO reservation_count
    FROM RESERVERS
    WHERE bid = OLD.bid;

    IF reservation_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete boat with active reservations';
    END IF;
END;
//
DELIMITER ;

