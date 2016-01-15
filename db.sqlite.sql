-- delete all the data
DELETE FROM Sale;
DELETE FROM Automobile;
DELETE FROM AutomobileType;
DELETE FROM Customer;
DELETE FROM EmployeeInDealership;
DELETE FROM Employee;
DELETE FROM JobTitle;
DELETE FROM Dealership;
DELETE FROM Address;

DROP TABLE Sale;
DROP TABLE Automobile;
DROP TABLE AutomobileType;
DROP TABLE Customer;
DROP TABLE EmployeeInDealership;
DROP TABLE Employee;
DROP TABLE JobTitle;
DROP TABLE Dealership;
DROP TABLE Address;

-- foreign key relationships are disabled by default
PRAGMA foreign_keys = ON;

-- http://stackoverflow.com/questions/7739444/declare-variable-in-sqlite-and-use-it#answer-14574227
PRAGMA temp_store = 2;

CREATE TABLE Address(
	ID      INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	Street  TEXT,
	City    TEXT,
	State   TEXT,
	Zip     TEXT,
	Country TEXT
);

CREATE TABLE Dealership(
	ID          INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
	AddressID   INTEGER,
	FOREIGN KEY(AddressID) REFERENCES Address(ID)
);

ALTER TABLE Dealership
ADD COLUMN Owner TEXT;

ALTER TABLE Dealership
ADD COLUMN Label TEXT;

CREATE TABLE JobTitle(
	Title             VARCHAR(24) PRIMARY KEY NOT NULL,
	StartingSalary    INTEGER -- MONEY IS STORED IN LOWEST COMMON UNIT, SO 100 = $1.00
);

CREATE TABLE Employee(
	ID          TEXT PRIMARY KEY NOT NULL,
	FirstName   TEXT NOT NULL,
	MiddleName  TEXT,
	LastName    TEXT NOT NULL,
	AddressID   INTEGER NOT NULL,
	Phone       TEXT,
	SSN         TEXT NOT NULL,
	JobTitle    TEXT NOT NULL,
	FOREIGN KEY(AddressID) REFERENCES Address(ID),
	FOREIGN KEY(JobTitle) REFERENCES JobTitle(Title)
);

CREATE TABLE EmployeeInDealership(
	DealershipID      INTEGER NOT NULL,
	EmployeeID        TEXT NOT NULL,
	FOREIGN KEY(DealershipID) REFERENCES Dealership(ID),
	FOREIGN KEY(EmployeeID) REFERENCES Employee(ID),
	PRIMARY KEY(DealershipID, EmployeeID)
);

CREATE TABLE Customer(
	ID          INTEGER PRIMARY KEY NOT NULL,
	FirstName   TEXT NOT NULL,
	MiddleName  TEXT,
	LastName    TEXT NOT NULL,
	Email       TEXT,
	Phone       TEXT,
	AddressID   INTEGER, -- FOREIGN KEY NOT NULL ?!??!
	FOREIGN KEY(AddressID) REFERENCES Address(ID)
);

CREATE TABLE AutomobileType(
	Type     VARCHAR(16) PRIMARY KEY NOT NULL
);

CREATE TABLE Automobile(
	VIN      INTEGER PRIMARY KEY NOT NULL,
	Type     VARCHAR(16) NOT NULL,
	Year     INTEGER NOT NULL,
	Make     TEXT NOT NULL,
	Model    TEXT NOT NULL,
	Color    TEXT NOT NULL,
	Mileage  INTEGER NOT NULL,
	FOREIGN KEY(Type) REFERENCES AutomobileType(Type)
);

CREATE TABLE Sale(
	ID             INTEGER PRIMARY KEY NOT NULL,
	EmployeeID     VARCHAR(8) NOT NULL,
	CustomerID     INTEGER NOT NULL,
	AutomobileVIN  INTEGER NOT NULL,
	Price          INTEGER NOT NULL,
	TaxRate        REAL NOT NULL,
	Date           TEXT,
	FOREIGN KEY(EmployeeID) REFERENCES Employee(ID),
	FOREIGN KEY(CustomerID) REFERENCES Customer(ID),
	FOREIGN KEY(AutomobileVIN) REFERENCES Automobile(VIN)
);

INSERT INTO JobTitle(Title, StartingSalary) VALUES('Sales',10000);
INSERT INTO JobTitle(Title, StartingSalary) VALUES('Mechanic',42000);

INSERT INTO AutomobileType(Type) VALUES('Sedan');
INSERT INTO AutomobileType(Type) VALUES('Truck');
INSERT INTO AutomobileType(Type) VALUES('Motorcycle');
INSERT INTO AutomobileType(Type) VALUES('Boat');


BEGIN TRANSACTION;

-- create an in-memory variables table
CREATE TEMP TABLE _IDs(Key TEXT, Value INTEGER);

INSERT INTO Address(Street, City, State, Zip, Country)
VALUES('9301 State Line Road','Kansas City','MO','64114','USA');

INSERT INTO Dealership(AddressID, Owner, Label)
VALUES(last_insert_rowid(),'Jimmy Hoffa','Gangster Chevrolet of Olathe');

INSERT INTO _IDs(Key, Value)
VALUES("DealershipID", last_insert_rowid());

INSERT INTO Address(Street, City, State, Zip, Country)
VALUES('123 Somewhere','Leawood','KS','66213','USA');

INSERT INTO Employee(ID, FirstName, LastName, AddressID, SSN, JobTitle)
VALUES('ASDF1234','John','Smith',last_insert_rowid(),'123-45-6789','Mechanic');

INSERT INTO EmployeeInDealership(DealershipID, EmployeeID)
VALUES(
  (SELECT Value FROM _IDs WHERE Key = 'DealershipID'),
  'ASDF1234'
);

INSERT INTO Customer(FirstName, LastName)
VALUES('Jane','Doe');

INSERT INTO _IDs(Key, Value)
VALUES('CustomerID', last_insert_rowid());

INSERT INTO Automobile(VIN, Type, Year, Make, Model, Color, Mileage)
VALUES(1234,'Truck',2012,'Ford','F-150','Blue',20000);

INSERT INTO Sale(EmployeeID, CustomerID, AutomobileVIN, Price, TaxRate, Date)
VALUES(
  'ASDF1234',
  (SELECT Value FROM _IDs WHERE Key = 'CustomerID'),
  1234, 2500000, 0.08, '08-Jan-2016'
);

DROP TABLE _IDs;

END TRANSACTION;
