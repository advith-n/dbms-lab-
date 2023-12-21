-- Customer table
CREATE TABLE Customer (
    CustNo INT PRIMARY KEY,
    cname VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO Customer (CustNo, cname, city)
VALUES
    (1, 'John', 'New York'),
    (2, 'Kumar', 'Chicago'),
    (3, 'Alice', 'Los Angeles'),
    (4, 'Bob', 'Houston'),
    (5, 'Eve', 'San Francisco');

-- Order table
CREATE TABLE OrderTable (
    orderNo INT PRIMARY KEY,
    odate DATE,
    custNo INT,
    order_amt INT,
    FOREIGN KEY (custNo) REFERENCES Customer(CustNo)
);

INSERT INTO OrderTable (orderNo, odate, custNo, order_amt)
VALUES
    (101, '2022-01-10', 2, 500),
    (102, '2022-02-15', 1, 700),
    (103, '2022-03-20', 3, 600),
    (104, '2022-04-25', 4, 800),
    (105, '2022-05-30', 2, 900);

-- Order-Item table
CREATE TABLE Order_Item (
    orderNo INT,
    itemNo INT,
    qty INT,
    PRIMARY KEY (orderNo, itemNo),
    FOREIGN KEY (orderNo) REFERENCES OrderTable(orderNo),
    FOREIGN KEY (itemNo) REFERENCES Item(itemNo)
);

INSERT INTO Order_Item (orderNo, itemNo, qty)
VALUES
    (101, 1, 2),
    (102, 2, 3),
    (103, 3, 1),
    (104, 1, 4),
    (105, 2, 2);

-- Item table
CREATE TABLE Item (
    itemNo INT PRIMARY KEY,
    unitprice INT
);

INSERT INTO Item (itemNo, unitprice)
VALUES
    (1, 100),
    (2, 150),
    (3, 120),
    (4, 180),
    (5, 200);

-- Shipment table
CREATE TABLE Shipment (
    orderNo INT,
    warehouseNo INT,
    ship_date DATE,
    PRIMARY KEY (orderNo, warehouseNo),
    FOREIGN KEY (orderNo) REFERENCES OrderTable(orderNo),
    FOREIGN KEY (warehouseNo) REFERENCES Warehouse(warehouseNo)
);

INSERT INTO Shipment (orderNo, warehouseNo, ship_date)
VALUES
    (101, 1, '2022-02-01'),
    (102, 2, '2022-03-10'),
    (103, 3, '2022-04-15'),
    (104, 1, '2022-05-20'),
    (105, 2, '2022-06-25');

-- Warehouse table
CREATE TABLE Warehouse (
    warehouseNo INT PRIMARY KEY,
    city VARCHAR(50)
);

INSERT INTO Warehouse (warehouseNo, city)
VALUES
    (1, 'New York'),
    (2, 'Chicago'),
    (3, 'Los Angeles'),
    (4, 'Houston'),
    (5, 'San Francisco');


----QUERIES----
-- SELECT S.order#, S.ship_date
SELECT S.orderNo, S.ship_date
FROM Shipment S
WHERE S.warehouseNo = 2;

-- SELECT O.order#, S.warehouse#
SELECT O.orderNo, S.warehouseNo
FROM OrderTable O
JOIN Shipment S ON O.orderNo = S.orderNo
JOIN Warehouse W ON S.warehouseNo = W.warehouseNo
JOIN Customer C ON O.custNo = C.CustNo
WHERE C.cname = 'Kumar';

-- SELECT C.cname, COUNT(O.order#) AS "#ofOrders", AVG(O.order_amt) AS Avg_Order_Amt
SELECT C.cname, COUNT(O.orderNo) AS NumberOfOrders, AVG(O.order_amt) AS Avg_Order_Amt
FROM Customer C
LEFT JOIN OrderTable O ON C.CustNo = O.custNo
GROUP BY C.cname;

-- DELETE FROM Order
DELETE FROM OrderTable
WHERE custNo IN (SELECT CustNo FROM Customer WHERE cname = 'Kumar');

-- SELECT * FROM Item
SELECT * FROM Item
WHERE unitprice = (SELECT MAX(unitprice) FROM Item);

-- CREATE TRIGGER UpdateOrderAmount
DELIMITER //
CREATE TRIGGER UpdateOrderAmount
BEFORE INSERT ON Order_Item
FOR EACH ROW
BEGIN
    DECLARE total_price INT;
    SELECT SUM(I.unitprice * NEW.qty) INTO total_price
    FROM Item I
    WHERE I.itemNo = NEW.itemNo;

    SET NEW.order_amt = total_price;
END;
//
DELIMITER ;

-- CREATE VIEW ShippedOrdersView
CREATE VIEW ShippedOrdersView AS
SELECT S.orderNo, S.ship_date
FROM Shipment S;

