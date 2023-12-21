-- Disable foreign key checks temporarily
SET foreign_key_checks = 0;

-- DLOCATION table
CREATE TABLE DLOCATION (
    DNo INT PRIMARY KEY,
    DLoc VARCHAR(255)
);

INSERT INTO DLOCATION (DNo, DLoc)
VALUES
    (1, 'New York'),
    (2, 'Chicago'),
    (3, 'Los Angeles'),
    (4, 'San Francisco'),
    (5, 'Miami');

-- DEPARTMENT table
CREATE TABLE DEPARTMENT (
    DNo INT PRIMARY KEY,
    DName VARCHAR(255),
    MgrSSN VARCHAR(11),
    MgrStartDate DATE,
    FOREIGN KEY (MgrSSN) REFERENCES EMPLOYEE(SSN)
);

INSERT INTO DEPARTMENT (DNo, DName, MgrSSN, MgrStartDate)
VALUES
    (1, 'HR', '123-45-6789', '2021-01-01'),
    (2, 'IT', '345-67-8901', '2022-02-15'),
    (3, 'Accounts', '345-67-8901', '2023-03-20'),
    (4, 'Marketing', '123-45-6789', '2021-04-01'),
    (5, 'Operations', '456-78-9012', '2022-05-15');

-- Enable foreign key checks
SET foreign_key_checks = 1;

-- EMPLOYEE table
CREATE TABLE EMPLOYEE (
    SSN VARCHAR(11) PRIMARY KEY,
    Name VARCHAR(255),
    Address VARCHAR(255),
    Sex CHAR,
    Salary DECIMAL,
    SuperSSN VARCHAR(11),
    DNo INT,
    FOREIGN KEY (SuperSSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

INSERT INTO EMPLOYEE (SSN, Name, Address, Sex, Salary, SuperSSN, DNo)
VALUES
    ('123-45-6789', 'John Doe', '123 Main St', 'M', 80000, NULL, 1),
    ('234-56-7890', 'Alice Smith', '456 Oak St', 'F', 70000, '123-45-6789', 1),
    ('345-67-8901', 'Bob Johnson', '789 Pine St', 'M', 60000, '123-45-6789', 2),
    ('456-78-9012', 'Eve Wilson', '101 Elm St', 'F', 85000, '345-67-8901', 2),
    ('567-89-0123', 'Charlie Brown', '202 Cedar St', 'M', 75000, '345-67-8901', 3);

-- PROJECT table
CREATE TABLE PROJECT (
    PNo INT PRIMARY KEY,
    PName VARCHAR(255),
    PLocation VARCHAR(255),
    DNo INT,
    FOREIGN KEY (DNo) REFERENCES DEPARTMENT(DNo)
);

INSERT INTO PROJECT (PNo, PName, PLocation, DNo)
VALUES
    (101, 'HR Management', 'New York', 1),
    (102, 'Software Development', 'Chicago', 2),
    (103, 'Financial Analysis', 'Los Angeles', 3),
    (104, 'Employee Training', 'New York', 1),
    (105, 'Database Optimization', 'Chicago', 2);

-- WORKS_ON table
CREATE TABLE WORKS_ON (
    SSN VARCHAR(11),
    PNo INT,
    Hours INT,
    PRIMARY KEY (SSN, PNo),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (PNo) REFERENCES PROJECT(PNo)
);

INSERT INTO WORKS_ON (SSN, PNo, Hours)
VALUES
    ('123-45-6789', 101, 40),
    ('234-56-7890', 102, 30),
    ('345-67-8901', 103, 35),
    ('456-78-9012', 104, 25),
    ('567-89-0123', 105, 20);


-- 1. List of Project Numbers for Projects Involving Employee 'Scott'
SELECT DISTINCT P.PNo
FROM PROJECT P
JOIN WORKS_ON W ON P.PNo = W.PNo
JOIN EMPLOYEE E ON W.SSN = E.SSN
WHERE E.Name LIKE '%Scott%'
   OR E.SSN IN (SELECT MgrSSN FROM DEPARTMENT WHERE DNo = P.DNo);

-- 2. Salaries After 10% Raise for Employees Working on 'IoT' Project
UPDATE EMPLOYEE
SET Salary = Salary * 1.10
WHERE SSN IN (SELECT SSN FROM WORKS_ON WHERE PNo = (SELECT PNo FROM PROJECT WHERE PName = 'IoT'));

-- 3. Sum, Maximum, Minimum, and Average Salaries in 'Accounts' Department
SELECT
    SUM(Salary) AS TotalSalaries,
    MAX(Salary) AS MaxSalary,
    MIN(Salary) AS MinSalary,
    AVG(Salary) AS AvgSalary
FROM EMPLOYEE
WHERE DNo = (SELECT DNo FROM DEPARTMENT WHERE DName = 'Accounts');

-- 4. Employees Working on All Projects of Department 5 (Using NOT EXISTS)
SELECT E.Name
FROM EMPLOYEE E
WHERE NOT EXISTS (
    SELECT PNo
    FROM PROJECT P
    WHERE P.DNo = 5
    AND NOT EXISTS (
        SELECT SSN
        FROM WORKS_ON W
        WHERE W.PNo = P.PNo AND W.SSN = E.SSN
    )
);

-- 5. Departments with More Than Five Employees Making Over Rs. 6,00,000
SELECT D.DNo, COUNT(*) AS NumEmployees
FROM DEPARTMENT D
JOIN EMPLOYEE E ON D.DNo = E.DNo
WHERE E.Salary > 600000
GROUP BY D.DNo
HAVING COUNT(*) > 5;

-- 6. Create a View Showing Employee Name, Department Name, and Location
CREATE VIEW EmployeeDetails AS
SELECT E.Name AS EmployeeName, D.DName AS DepartmentName, DL.DLoc AS DepartmentLocation
FROM EMPLOYEE E
JOIN DEPARTMENT D ON E.DNo = D.DNo
JOIN DLOCATION DL ON D.DNo = DL.DNo;

-- 7. Create a Trigger to Prevent Project Deletion If Currently Worked On
DELIMITER //

CREATE TRIGGER prevent_project_deletion
BEFORE DELETE ON PROJECT
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM WORKS_ON WHERE PNo = OLD.PNo) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete project currently being worked on.';
    END IF;
END //

DELIMITER ;
