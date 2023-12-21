-- PERSON table
CREATE TABLE PERSON (
    driver_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(50),
    address VARCHAR(50)
);

INSERT INTO PERSON (driver_id, name, address)
VALUES
    ('D001', 'John Doe', '123 Main St'),
    ('D002', 'Jane Smith', '456 Oak St'),
    ('D003', 'Bob Johnson', '789 Pine St'),
    ('D004', 'Alice Brown', '101 Elm St'),
    ('D005', 'Charlie Wilson', '202 Cedar St');

-- CAR table
CREATE TABLE CAR (
    regno VARCHAR(50) PRIMARY KEY,
    model VARCHAR(50),
    year INT
);

INSERT INTO CAR (regno, model, year)
VALUES
    ('KA09MA1234', 'Toyota', 2020),
    ('KA10BM5678', 'Ford', 2019),
    ('KA11TA9876', 'Honda', 2021),
    ('KA12RE5432', 'Mazda', 2018),
    ('KA13SC1122', 'Chevrolet', 2017);

-- ACCIDENT table
CREATE TABLE ACCIDENT (
    report_number INT PRIMARY KEY,
    acc_date DATE,
    location VARCHAR(50)
);

INSERT INTO ACCIDENT (report_number, acc_date, location)
VALUES
    (101, '2021-03-15', 'Intersection A'),
    (102, '2021-05-20', 'Highway B'),
    (103, '2021-07-10', 'Street C'),
    (104, '2021-09-05', 'Junction D'),
    (105, '2021-12-01', 'Avenue E');

-- OWNS table
CREATE TABLE OWNS (
    driver_id VARCHAR(50),
    regno VARCHAR(50),
    PRIMARY KEY (driver_id, regno),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
    FOREIGN KEY (regno) REFERENCES CAR(regno)
);

INSERT INTO OWNS (driver_id, regno)
VALUES
    ('D001', 'KA09MA1234'),
    ('D002', 'KA10BM5678'),
    ('D003', 'KA11TA9876'),
    ('D004', 'KA12RE5432'),
    ('D005', 'KA13SC1122');

-- PARTICIPATED table
CREATE TABLE PARTICIPATED (
    driver_id VARCHAR(50),
    regno VARCHAR(50),
    report_number INT,
    damage_amount INT,
    PRIMARY KEY (driver_id, regno, report_number),
    FOREIGN KEY (driver_id) REFERENCES PERSON(driver_id),
    FOREIGN KEY (regno) REFERENCES CAR(regno),
    FOREIGN KEY (report_number) REFERENCES ACCIDENT(report_number)
);

INSERT INTO PARTICIPATED (driver_id, regno, report_number, damage_amount)
VALUES
    ('D001', 'KA09MA1234', 101, 5000),
    ('D002', 'KA10BM5678', 102, 7000),
    ('D003', 'KA11TA9876', 103, 3000),
    ('D004', 'KA12RE5432', 104, 6000),
    ('D005', 'KA13SC1122', 105, 8000);



----QUERIES----


SELECT COUNT(DISTINCT P.driver_id) AS total_people
FROM PERSON P
JOIN OWNS O ON P.driver_id = O.driver_id
JOIN PARTICIPATED PA ON O.driver_id = PA.driver_id
JOIN ACCIDENT A ON PA.report_number = A.report_number
WHERE YEAR(A.acc_date) = 2021;

SELECT COUNT(A.report_number) AS accidents_involving_smith
FROM PERSON P
JOIN OWNS O ON P.driver_id = O.driver_id
JOIN PARTICIPATED PA ON O.driver_id = PA.driver_id
JOIN ACCIDENT A ON PA.report_number = A.report_number
WHERE P.name = 'Smith';

INSERT INTO ACCIDENT (report_number, acc_date, location)
VALUES (106, '2022-02-18', 'Roundabout F');

DELETE FROM CAR
WHERE regno IN (SELECT regno FROM OWNS WHERE driver_id IN (SELECT driver_id FROM PERSON WHERE name = 'Smith'));

UPDATE PARTICIPATED
SET damage_amount = 6000
WHERE regno = 'KA09MA1234' AND report_number = 101;

CREATE VIEW AccidentCarsView AS
SELECT DISTINCT C.model, C.year
FROM CAR C
JOIN PARTICIPATED PA ON C.regno = PA.regno;

DELIMITER //

CREATE TRIGGER PreventExcessiveAccidents
BEFORE INSERT ON PARTICIPATED
FOR EACH ROW
BEGIN
    DECLARE accidents_count INT;

    SELECT COUNT(*) INTO accidents_count
    FROM PARTICIPATED
    WHERE driver_id = NEW.driver_id AND YEAR(acc_date) = YEAR(NOW());

    IF accidents_count >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Too many accidents in a year for this driver.';
    END IF;
END //

DELIMITER ;
