-- STUDENT table
CREATE TABLE STUDENT (
    regno VARCHAR(20) PRIMARY KEY,
    name VARCHAR(255),
    major VARCHAR(50),
    bdate DATE
);

INSERT INTO STUDENT (regno, name, major, bdate)
VALUES
    ('S001', 'John Doe', 'CS', '2000-01-10'),
    ('S002', 'Alice Smith', 'EE', '1999-05-15'),
    ('S003', 'Bob Johnson', 'CS', '2001-03-20'),
    ('S004', 'Eve Wilson', 'ME', '1998-08-25'),
    ('S005', 'Charlie Brown', 'IT', '2002-02-28');

-- COURSE table
CREATE TABLE COURSE (
    course_id INT PRIMARY KEY,
    cname VARCHAR(255),
    dept VARCHAR(50)
);

INSERT INTO COURSE (course_id, cname, dept)
VALUES
    (101, 'Database Management System', 'CS'),
    (102, 'Algorithm Design', 'CS'),
    (103, 'Digital Electronics', 'EE'),
    (104, 'Thermodynamics', 'ME'),
    (105, 'Web Development', 'IT');

-- ENROLL table
CREATE TABLE ENROLL (
    regno VARCHAR(20),
    course_id INT,
    sem INT,
    marks INT,
    PRIMARY KEY (regno, course_id, sem),
    FOREIGN KEY (regno) REFERENCES STUDENT(regno),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id)
);

INSERT INTO ENROLL (regno, course_id, sem, marks)
VALUES
    ('S001', 101, 2, 85),
    ('S002', 101, 2, 75),
    ('S003', 102, 2, 92),
    ('S004', 102, 2, 68),
    ('S005', 101, 2, 78);

-- TEXT table
CREATE TABLE TEXT (
    book_ISBN INT PRIMARY KEY,
    book_title VARCHAR(255),
    publisher VARCHAR(50),
    author VARCHAR(255)
);

INSERT INTO TEXT (book_ISBN, book_title, publisher, author)
VALUES
    (1001, 'Database Systems', 'Pearson', 'Ramez Elmasri'),
    (1002, 'Introduction to Algorithms', 'MIT Press', 'Thomas H. Cormen'),
    (1003, 'Digital Fundamentals', 'Pearson', 'Floyd Thomas'),
    (1004, 'Engineering Thermodynamics', 'Wiley', 'Yunus A. Cengel'),
    (1005, 'HTML and CSS: Design and Build Websites', 'Wiley', 'Jon Duckett');

-- BOOK_ADOPTION table
CREATE TABLE BOOK_ADOPTION (
    course_id INT,
    sem INT,
    book_ISBN INT,
    PRIMARY KEY (course_id, sem, book_ISBN),
    FOREIGN KEY (course_id) REFERENCES COURSE(course_id),
    FOREIGN KEY (book_ISBN) REFERENCES TEXT(book_ISBN)
);

INSERT INTO BOOK_ADOPTION (course_id, sem, book_ISBN)
VALUES
    (101, 2, 1001),
    (101, 2, 1003),
    (102, 2, 1002),
    (103, 2, 1003),
    (105, 2, 1005);
---QUERIES-----
-- Add a new text book and make it adopted by a department
INSERT INTO TEXT (book_ISBN, book_title, publisher, author)
VALUES (1006, 'New Database Book', 'New Publisher', 'New Author');

INSERT INTO BOOK_ADOPTION (course_id, sem, book_ISBN)
VALUES (101, 3, 1006);

-- List text books in alphabetical order for CS courses with more than two books
SELECT BA.course_id, BA.sem, BA.book_ISBN, T.book_title
FROM BOOK_ADOPTION BA
JOIN TEXT T ON BA.book_ISBN = T.book_ISBN
JOIN COURSE C ON BA.course_id = C.course_id
WHERE C.dept = 'CS'
GROUP BY BA.book_ISBN
HAVING COUNT(*) > 2
ORDER BY T.book_title;

-- List departments with all adopted books published by a specific publisher
SET @target_publisher = 'Pearson';

SELECT C.dept
FROM COURSE C
WHERE NOT EXISTS (
    SELECT 1
    FROM BOOK_ADOPTION BA
    JOIN TEXT T ON BA.book_ISBN = T.book_ISBN
    WHERE BA.course_id = C.course_id
    AND T.publisher != @target_publisher
);

-- List students with maximum marks in 'DBMS' course
SELECT E.regno, E.marks
FROM ENROLL E
WHERE E.course_id = 101
ORDER BY E.marks DESC
LIMIT 1;

-- Create a view to display courses opted by a student with marks
CREATE VIEW StudentCourses AS
SELECT E.regno, E.course_id, E.sem, E.marks, C.cname
FROM ENROLL E
JOIN COURSE C ON E.course_id = C.course_id;

-- Create a trigger to prevent enrollment with marks less than 40
DELIMITER //
CREATE TRIGGER CheckMarksTrigger
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN
    IF NEW.marks < 40 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot enroll with marks less than 40';
    END IF;
END //
DELIMITER ;


