-------------------------------------------------------------------------------------------------------------------------------------------------
---------------Code to create database, tables, relationships, indexes, views and roles to implement a travel databsae -------------------
------------This is a centralized database to allow seamless web access for the staff for booking package as per customer requirements.--- 
--------------------------------------Created by: UP2200902, UP2200918, UP2200923---------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
/*
Steps:
1. Open a terminal or command prompt.
2. Navigate to the directory where you saved the .sql file.
3. Log in to the PostgreSQL database using the psql command:
	psql -h hostname -d dbname -U username
    
	Replace hostname, dbname, and username with your actual database connection details.

4. Once you are connected to the database, you can execute the SQL file using the \i command followed by the file path:
	\i path/to/ALL_CODE.sql

	Replace path/to/create_indexes.sql with the actual path to your SQL file.

5. The SQL statements in the file will be executed, and you will see the output indicating the success of each statement.

*/

--Please excute the first part of the code first--------

--Create roles to facilitate creation of employee table.
CREATE ROLE employee_role;
CREATE ROLE accountant_role;
CREATE ROLE manager_role;
CREATE ROLE sys_admin_role;

-- Drop the database if it exists
DROP DATABASE IF EXISTS travel_booking;

--Create Database. This will be used for our test case. 

CREATE DATABASE travel_booking;
-- Connect to Database
\c travel_booking;

BEGIN;
-- Drop all tables in the correct order to avoid foreign key constraints
DROP TABLE IF EXISTS Booking CASCADE;
DROP TABLE IF EXISTS Package CASCADE;
DROP TABLE IF EXISTS Flight CASCADE;
DROP TABLE IF EXISTS Hotel_facility CASCADE;
DROP TABLE IF EXISTS hotel_amenity CASCADE;
DROP TABLE IF EXISTS hotel CASCADE;
DROP TABLE IF EXISTS facility CASCADE;
DROP TABLE IF EXISTS amenity CASCADE;
DROP TABLE IF EXISTS Employee CASCADE;
DROP TABLE IF EXISTS Customer CASCADE;
DROP TABLE IF EXISTS Payment CASCADE;
DROP TABLE IF EXISTS Payment_Installment CASCADE;


-- Create table for AMENITY
CREATE TABLE AMENITY (
    amenity_id SERIAL PRIMARY KEY,
    amenity_description TEXT NOT NULL,
    CONSTRAINT unique_amenity_id UNIQUE (amenity_id)
);

-- Create table for FACILITY
CREATE TABLE FACILITY (
    fac_id SERIAL PRIMARY KEY,
    fac_description TEXT NOT NULL
);

--- Create table for HOTEL
CREATE TABLE HOTEL (
    hotel_id SERIAL PRIMARY KEY,
    hotel_rating SMALLINT CHECK (hotel_rating BETWEEN 3 AND 5),
    hotel_name VARCHAR(100) NOT NULL,
    hotel_location VARCHAR(100)
);

-- Create table for HOTEL_AMENITY (junction table)
CREATE TABLE HOTEL_AMENITY (
    hotel_id INT,
    amenity_id INT,
    CONSTRAINT fk_hotelamenity_hotel_id FOREIGN KEY (hotel_id) REFERENCES HOTEL(hotel_id),
    CONSTRAINT fk_hotelamenity_amenity_id FOREIGN KEY (amenity_id) REFERENCES AMENITY(amenity_id),
    PRIMARY KEY (hotel_id, amenity_id)
);

-- Create table for HOTEL_FACILITY (junction table)
CREATE TABLE HOTEL_FACILITY (
    hotel_id INT,
    fac_id INT,
    CONSTRAINT fk_hotelfacility_hotel_id FOREIGN KEY (hotel_id) REFERENCES HOTEL(hotel_id),
    CONSTRAINT fk_hotelfacility_fac_id FOREIGN KEY (fac_id) REFERENCES FACILITY(fac_id),
    PRIMARY KEY (hotel_id, fac_id)
);


-- Create table for EMPLOYEE
CREATE TABLE EMPLOYEE (
    emp_id SERIAL PRIMARY KEY,
    emp_username VARCHAR(100) UNIQUE NOT NULL,
    emp_firstname VARCHAR(50) NOT NULL,
    emp_lastname VARCHAR(50),
    emp_role VARCHAR(50) NOT NULL CHECK (emp_role IN ('manager_role', 'employee_role', 'accountant_role')),
    emp_branch VARCHAR(50),
    emp_contact VARCHAR(15) UNIQUE NOT NULL,
    emp_active_login BOOLEAN);

-- Create table for CUSTOMER
CREATE TABLE CUSTOMER (
    cust_id SERIAL PRIMARY KEY,
    cust_fname VARCHAR(50) NOT NULL,
    cust_lname VARCHAR(50) NOT NULL,
    cust_email VARCHAR(255) UNIQUE NOT NULL,
    cust_phone VARCHAR(15) UNIQUE NOT NULL,
    cust_street_address VARCHAR(255),
    cust_city VARCHAR(50) NOT NULL,
    cust_postcode VARCHAR(10),
    cust_dob DATE
);

-- Create table for FLIGHT
CREATE TABLE FLIGHT (
    flight_id SERIAL PRIMARY KEY,
    out_flight_no VARCHAR(50) NOT NULL,
    out_destination VARCHAR(100),
    out_location VARCHAR(20),
    out_depart_date TIMESTAMP,
    out_arrival_date TIMESTAMP CHECK (out_arrival_date > out_depart_date),
    ret_flight_no VARCHAR(50) NOT NULL,
    ret_destination VARCHAR(100),
    ret_location VARCHAR(20),
    ret_depart_date TIMESTAMP,
    ret_arrival_date TIMESTAMP CHECK (ret_arrival_date > ret_depart_date)
);

-- Create table for PACKAGE
CREATE TABLE PACKAGE (
    pack_id SERIAL PRIMARY KEY,
    hotel_id INT,
    flight_id INT,
    pack_name VARCHAR(255) NOT NULL,
    pack_pricePP DECIMAL(10,2) CHECK (pack_pricePP > 0),
    pack_duration SMALLINT CHECK (pack_duration > 0),
    pack_location VARCHAR(20),
    CONSTRAINT fk_package_hotel_id FOREIGN KEY (hotel_id) REFERENCES HOTEL(hotel_id),
    CONSTRAINT fk_package_flight_id FOREIGN KEY (flight_id) REFERENCES FLIGHT(flight_id)
);

-- Create table for BOOKING
CREATE TABLE Booking (
    book_id SERIAL PRIMARY KEY,
    cust_id INT,
    pack_id INT,
    emp_id INT,
    book_depart_date DATE,
    book_adult_no SMALLINT CHECK (book_adult_no > 0),
    book_child_no SMALLINT CHECK (book_child_no >= 0),
    book_discount DECIMAL(5, 2) CHECK (book_discount BETWEEN 0 AND 50),
    book_total_amt DECIMAL(10, 2),
    book_install BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_booking_cust_id FOREIGN KEY (cust_id) REFERENCES Customer(cust_id),
    CONSTRAINT fk_booking_pack_id FOREIGN KEY (pack_id) REFERENCES PACKAGE(pack_id),
    CONSTRAINT fk_booking_emp_id FOREIGN KEY (emp_id) REFERENCES EMPLOYEE(emp_id)
);

-- Create table for PAYMENT
CREATE TABLE Payment (
    pay_id SERIAL PRIMARY KEY,
    book_id INT,
    pay_amt_paid DECIMAL(10, 2) CHECK (pay_amt_paid >= 0),
    pay_install_no SMALLINT CHECK (pay_install_no IN (1, 3)),
    pay_status VARCHAR(20) DEFAULT 'Unpaid' CHECK (pay_status IN ('Unpaid', 'Partially Paid', 'Fully Paid')),
    CONSTRAINT fk_payment_book_id FOREIGN KEY (book_id) REFERENCES Booking(book_id)
);

-- Create table for PAYMENT_INSTALLMENT
CREATE TABLE Payment_Installment (
    pay_install_id SERIAL PRIMARY KEY,
    pay_id INT,
    pay_install_amt DECIMAL(10, 2) CHECK (pay_install_amt>=0),
    pay_install_date DATE,
    pay_install_status VARCHAR(20) CHECK (pay_install_status IN ('Fully Paid', 'Partially Paid', 'Unpaid')),
    CONSTRAINT fk_payment_installment_pay_id FOREIGN KEY (pay_id) REFERENCES Payment(pay_id)
);


-- Trigger function to update Package attributes
CREATE OR REPLACE FUNCTION update_package_attributes()
RETURNS TRIGGER AS $$
BEGIN
    -- Example: UPDATE Package SET pack_pricePP = NEW.pack_pricePP WHERE hotel_id = NEW.hotel_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach triggers to Hotel and Flight tables

CREATE TRIGGER update_package_on_hotel_change
AFTER INSERT OR UPDATE ON HOTEL
FOR EACH ROW EXECUTE FUNCTION update_package_attributes();

-- Attach trigger to Flight
CREATE TRIGGER update_package_on_flight_change
AFTER INSERT OR UPDATE ON FLIGHT
FOR EACH ROW EXECUTE FUNCTION update_package_attributes();

-- Create a trigger to calculate total_amount
CREATE OR REPLACE FUNCTION update_total_amount()
RETURNS TRIGGER AS $$
BEGIN
    NEW.book_total_amt := (
        SELECT
            CASE
                WHEN p.pack_id IS NOT NULL THEN
                    p.pack_pricePP * (NEW.book_adult_no + NEW.book_child_no) * (1 - NEW.book_discount)
                ELSE
                    0
            END
        FROM
            PACKAGE p
        WHERE
            p.pack_id = NEW.pack_id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER update_total_amount_trigger
BEFORE INSERT OR UPDATE ON Booking
FOR EACH ROW EXECUTE FUNCTION update_total_amount();

-------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_installment_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pay_status IN ('Partially Paid', 'Fully Paid') AND NOT EXISTS (
        SELECT 1
        FROM payment_installment pi
        WHERE pi.pay_id = NEW.pay_id
    ) THEN
        INSERT INTO payment_installment (pay_id, pay_install_amt, pay_install_date, pay_install_status)
        VALUES (NEW.pay_id, NEW.pay_amt_paid, CURRENT_DATE, NEW.pay_status);
    ELSEIF NEW.pay_status IN ('Partially Paid', 'Fully Paid') THEN
        UPDATE payment_installment
        SET pay_install_status = NEW.pay_status,
            pay_install_amt = NEW.pay_amt_paid
        WHERE pay_id = NEW.pay_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Drop the existing trigger if it exists
--DROP TRIGGER IF EXISTS update_installment_trigger ON payment;

-- Create the trigger to update installment table post the payment
CREATE TRIGGER update_installment_trigger
AFTER UPDATE ON payment
FOR EACH ROW
WHEN (OLD.pay_status = 'Unpaid' AND (NEW.pay_status = 'Partially Paid' OR NEW.pay_status = 'Fully Paid'))
EXECUTE FUNCTION update_installment_trigger_function();

---------------------------------------------------------

-- Create or replace the trigger function for inserting payment
CREATE OR REPLACE FUNCTION insert_payment_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.book_install THEN
        INSERT INTO Payment (book_id, pay_amt_paid, pay_install_no, pay_status)
        VALUES (NEW.book_id, 0, 3, 'Unpaid');
    ELSE
        INSERT INTO Payment (book_id, pay_amt_paid, pay_install_no, pay_status)
        VALUES (NEW.book_id, 0, 1, 'Unpaid');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


--DROP TRIGGER IF EXISTS insert_payment_trigger ON Booking;
-- Create the trigger
CREATE TRIGGER insert_payment_trigger
AFTER INSERT ON Booking
FOR EACH ROW
EXECUTE FUNCTION insert_payment_trigger_function();

-- Create the trigger function
CREATE OR REPLACE FUNCTION insert_payment_trigger_function()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO Payment (book_id, pay_amt_paid, pay_install_no, pay_status)
    VALUES (NEW.book_id, 0, CASE WHEN NEW.book_install THEN 3 ELSE 1 END, 'Unpaid');
   
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- Drop the existing trigger if it exists
DROP TRIGGER IF EXISTS insert_payment_trigger ON Booking;
-- Create the trigger
CREATE TRIGGER insert_payment_trigger
AFTER INSERT OR UPDATE ON Booking
FOR EACH ROW
EXECUTE FUNCTION insert_payment_trigger_function();


---------------INSERT VIEWS---------------------------------


CREATE VIEW TotalRevenuePerPackage AS
SELECT p.pack_name AS package_description,
       SUM(py.pay_amt_paid) AS total_revenue
FROM package p
JOIN booking b ON p.pack_id = b.pack_id
JOIN payment py ON b.book_id = py.book_id
GROUP BY p.pack_name;

CREATE VIEW MostPopularPackage AS
SELECT p.pack_name AS most_popular_package,
       COUNT(b.book_id) AS total_bookings
FROM package p
LEFT JOIN booking b ON p.pack_id = b.pack_id
GROUP BY p.pack_name
ORDER BY total_bookings DESC
LIMIT 1;


CREATE VIEW BookingDetailsByCustomer AS
SELECT b.book_id,
       p.pack_name AS package_description,
       b.book_depart_date AS departure_date,
       b.book_adult_no AS number_of_adults,
       b.book_child_no AS number_of_children
FROM booking b
JOIN package p ON b.pack_id = p.pack_id;


CREATE VIEW PackageDetailsWithFlightAndHotel AS
SELECT p.pack_name AS package_description,
       f.out_flight_no AS flight_no,
       f.out_destination AS flight_destination,
       f.out_depart_date AS departure_date,
       f.out_arrival_date AS arrival_date,
       h.hotel_name,
       h.hotel_location
FROM package p
JOIN flight f ON p.flight_id = f.flight_id
JOIN hotel h ON p.hotel_id = h.hotel_id;

CREATE VIEW EmployeePerformance AS
SELECT e.emp_id,
       e.emp_username,
       COUNT(b.book_id) AS total_successful_bookings
FROM employee e
LEFT JOIN booking b ON e.emp_id = b.emp_id
JOIN payment py ON b.book_id = py.book_id
GROUP BY e.emp_id, e.emp_username
ORDER BY total_successful_bookings DESC;


CREATE OR REPLACE VIEW Installment_Details_With_Customers AS
SELECT
    p.pay_id,
    p.book_id,
    c.cust_id,
    c.cust_fname,
    pi.pay_install_id,
    pi.pay_install_amt,
    pi.pay_install_date,
    pi.pay_install_status
FROM
    Payment p
JOIN
    Payment_Installment pi ON p.pay_id = pi.pay_id
JOIN
    Booking b ON p.book_id = b.book_id
JOIN
    Customer c ON b.cust_id = c.cust_id;


----------------------------Creation of roles -----------------------------------------------------------------

-- Restrict View Creation
-- Revoke the CREATE privilege for views from all roles except the sys admin role
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
-- Grant the CREATE privilege on schema to the sys admin role
GRANT CREATE ON SCHEMA public TO sys_admin_role;

-- TotalRevenuePerPackage view (accessible by manager_role and accountant_role)
GRANT SELECT ON TotalRevenuePerPackage TO manager_role;
GRANT SELECT ON TotalRevenuePerPackage TO accountant_role;

-- MostPopularPackage view (accessible by all roles)
GRANT SELECT ON MostPopularPackage TO PUBLIC;

-- BookingDetailsByCustomer view (accessible by all roles)
GRANT SELECT ON BookingDetailsByCustomer TO PUBLIC;

-- PackageDetailsWithFlightAndHotel view (accessible by all roles)
GRANT SELECT ON PackageDetailsWithFlightAndHotel TO PUBLIC;

-- EmployeePerformance view (accessible by manager_role)
GRANT SELECT ON EmployeePerformance TO manager_role;

-- Installment_Details_With_Customers view (accessible by accountant_role)
GRANT SELECT ON Installment_Details_With_Customers TO accountant_role;

-- Revoke privileges on tables
REVOKE SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- Revoke privileges on sequences
REVOKE USAGE ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

-- Revoke privileges on functions
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

-- Grant Table Permissions

-- HOTEL table (accessible by manager_role)
GRANT SELECT, INSERT, UPDATE, DELETE ON HOTEL TO manager_role;

-- HOTEL_AMENITY, AMENITY, HOTEL_FACILITY, FACILITY tables (accessible by manager_role)
GRANT SELECT, INSERT, UPDATE ON HOTEL_AMENITY TO manager_role;
GRANT SELECT, INSERT, UPDATE ON AMENITY TO manager_role;
GRANT SELECT, INSERT, UPDATE ON HOTEL_FACILITY TO manager_role;
GRANT SELECT, INSERT, UPDATE ON FACILITY TO manager_role;

-- PACKAGE table (accessible by all roles)
GRANT SELECT ON PACKAGE TO PUBLIC;

-- FLIGHT table (accessible by employee_role)
GRANT SELECT ON FLIGHT TO employee_role;

-- EMPLOYEE table (accessible by manager_role)
GRANT SELECT ON EMPLOYEE TO manager_role;

-- CUSTOMER table (accessible by employee_role)
GRANT SELECT ON CUSTOMER TO employee_role;

-- BOOKING table (accessible by employee_role)
GRANT SELECT, INSERT, UPDATE ON BOOKING TO employee_role;

-- PAYMENT table (accessible by employee_role)
GRANT SELECT, INSERT, UPDATE ON PAYMENT TO employee_role;

-- PAYMENT_INSTALLMENT table (accessible by employee_role and accountant_role)
GRANT SELECT, INSERT ON PAYMENT_INSTALLMENT TO employee_role;
GRANT SELECT, INSERT ON PAYMENT_INSTALLMENT TO accountant_role;

-- FACILITY table (accessible by manager_role)
GRANT SELECT, INSERT, UPDATE ON FACILITY TO manager_role;

-- AMENITY table (accessible by manager_role)
GRANT SELECT, INSERT, UPDATE ON AMENITY TO manager_role;

-- PAYMENT table (accessible by accountant_role)
GRANT SELECT, INSERT, UPDATE ON PAYMENT TO accountant_role;

-- FLIGHT table (accessible by employee_role)
GRANT SELECT, INSERT, UPDATE ON FLIGHT TO employee_role;


-- Restrict CREATE TABLE and ALTER TABLE for all roles except sysadmin_role
DO $$ 
DECLARE
    current_db_name text;
BEGIN
    current_db_name := current_database();  -- Get the current database name
    EXECUTE format('REVOKE CREATE ON SCHEMA public FROM PUBLIC');
    EXECUTE format('REVOKE ALL ON DATABASE %I FROM PUBLIC', current_db_name);
    EXECUTE format('GRANT CREATE ON SCHEMA public TO sys_admin_role');
    EXECUTE format('GRANT ALL ON DATABASE %I TO sys_admin_role', current_db_name);
END $$;


-- Revoke privileges on tables
REVOKE SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM PUBLIC;

-- Revoke privileges on sequences
REVOKE USAGE ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;

-- Revoke privileges on functions
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;



----------------------------Data Insert for Testing -----------------------------------------------------------

INSERT INTO Customer (cust_id, cust_fname, cust_lname, cust_email, cust_phone, cust_street_address, cust_city, cust_postcode, cust_dob)
VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '+123456789', '123 Main St', 'Los Angeles', '90001', '1990-05-15'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '+987654321', '456 Elm St', 'New York', '10001', '1985-09-22'),
(3, 'Michael', 'Johnson', 'michael.johnson@example.com', '+555123456', '789 Oak St', 'Chicago', '60601', '1992-03-08'),
(4, 'Emily', 'Williams', 'emily.williams@example.com', '+789456123', '101 Maple St', 'Miami', '33130', '1988-11-03'),
(5, 'David', 'Brown', 'david.brown@example.com', '+123789456', '202 Pine St', 'San Francisco', '94101', '1983-07-18'),
(6, 'Sarah', 'Miller', 'sarah.miller@example.com', '+654987321', '303 Cedar St', 'Los Angeles', '90001', '1995-02-27'),
(7, 'Daniel', 'Davis', 'daniel.davis@example.com', '+321654987', '404 Birch St', 'New York', '10001', '1991-10-12'),
(8, 'Olivia', 'Wilson', 'olivia.wilson@example.com', '+789321654', '505 Willow St', 'Chicago', '60601', '1987-06-30'),
(9, 'Matthew', 'Moore', 'matthew.moore@example.com', '+159753456', '606 Oak St', 'Miami', '33130', '1984-12-25'),
(10, 'Ava', 'Taylor', 'ava.taylor@example.com', '+357159456', '707 Maple St', 'San Francisco', '94101', '1998-08-14'),
(11, 'Christopher', 'Anderson', 'christopher.anderson@example.com', '+9123789456', '808 Cedar St', 'Los Angeles', '90001', '1989-04-05'),
(12, 'Sophia', 'Thomas', 'sophia.thomas@example.com', '+159753357', '909 Birch St', 'New York', '10001', '1993-01-17'),
(13, 'Andrew', 'Jackson', 'andrew.jackson@example.com', '+789654123', '1010 Willow St', 'Chicago', '60601', '1986-09-08'),
(14, 'Isabella', 'White', 'isabella.white@example.com', '+951753852', '1111 Oak St', 'Miami', '33130', '1997-05-21'),
(15, 'William', 'Harris', 'william.harris@example.com', '+753951852', '1212 Maple St', 'San Francisco', '94101', '1994-11-13'),
(16, 'Emma', 'Martinez', 'emma.martinez@example.com', '+987654123', '1313 Pine St', 'London', 'SW1A 1AA', '1997-08-10'),
(17, 'Liam', 'Garcia', 'liam.garcia@example.com', '+123987456', '1414 Cedar St', 'Paris', '75001', '1994-02-18'),
(18, 'Mia', 'Rodriguez', 'mia.rodriguez@example.com', '+789654321', '1515 Birch St', 'Tokyo', '100-0001', '1991-10-07'),
(19, 'Noah', 'Lopez', 'noah.lopez@example.com', '+357159753', '1616 Willow St', 'Sydney', '2000', '1988-06-24'),
(20, 'Sophia', 'Perez', 'sophia.perez@example.com', '+951753159', '1717 Oak St', 'Beijing', '100000', '1985-12-14'),
(21, 'Oliver', 'Hernandez', 'oliver.hernandez@example.com', '+31123951753', '1818 Maple St', 'Cairo', '11511', '1996-03-29'),
(22, 'Ava', 'Gonzalez', 'ava.gonzalez@example.com', '+159753123', '1919 Cedar St', 'Moscow', '101000', '1983-09-02'),
(23, 'Ethan', 'Wilson', 'ethan.wilson@example.com', '+987654951', '2020 Birch St', 'Berlin', '10115', '1999-07-12'),
(24, 'Amelia', 'Moore', 'amelia.moore@example.com', '+123987654', '2121 Willow St', 'Rio de Janeiro', '20000-000', '1996-04-01'),
(25, 'Lucas', 'Lee', 'lucas.lee@example.com', '+789654357', '2222 Oak St', 'Bangkok', '10110', '1993-11-20'),
(26, 'Isabella', 'Martin', 'isabella.martin@example.com', '+357151119951', '2323 Maple St', 'Dubai', '00000', '1990-02-09'),
(27, 'Mason', 'Jackson', 'mason.jackson@example.com', '+123951357', '2424 Cedar St', 'Toronto', 'M5H 2N2', '1987-05-27'),
(28, 'Emma', 'Thompson', 'emma.thompson@example.com', '+99951753987', '2525 Birch St', 'SÃ£o Paulo', '01310-200', '1994-01-03'),
(29, 'Liam', 'Taylor', 'liam.taylor@example.com', '+99123987159', '2626 Willow St', 'Mumbai', '400001', '1991-08-16'),
(30, 'Olivia', 'Martinez', 'olivia.martinez@example.com', '+789654753', '2727 Oak St', 'Seoul', '04524', '1988-03-05'),
(31, 'Noah', 'Brown', 'noah.brown@example.com', '+357951753', '2828 Pine St', 'Los Angeles', '90001', '1993-07-19'),
(32, 'Sophia', 'Davis', 'sophia.davis@example.com', '+987159753', '2929 Cedar St', 'New York', '10001', '1986-04-12'),
(33, 'Liam', 'Wilson', 'liam.wilson@example.com', '+951753987', '3030 Birch St', 'Chicago', '60601', '1990-11-28'),
(34, 'Emma', 'Miller', 'emma.miller@example.com', '+123987159', '3131 Willow St', 'Miami', '33130', '1987-01-09');

-- INSERT VALUES INTO EMPLOYEE TABLE 
INSERT INTO EMPLOYEE (emp_id,emp_username,emp_firstname,emp_lastname,emp_role,emp_branch,emp_contact,emp_active_login)
VALUES
(1,'posuere','Graham','Lindsay','employee_role','Xinjiang','1-684-855-8804','Yes'),
  (2,'convallis','Nigel','Copeland','employee_role','Inner Mongolia','1-253-598-7738','No'),
  (3,'odio','Eve','Callahan','employee_role','Mandai','1-615-872-6442','Yes'),
(4,'felis,','Fuller','Pennington','employee_role','Meerut','1-653-582-7850','No'),
(5,'gravida','Uriah','Hudson','employee_role','Burnie','1-334-901-5332','No'),
  (6,'eleifend','Zia','Velez','employee_role','Kailua','854-1707','No'),
  (7,'iaculis','Malcolm','Mullins','employee_role','Darwin','666-7298','No'),
 (8,'dis','Berk','Coffey','employee_role','Gloucester','1-841-932-3126','No'),
(9,'sed','Emmanuel','Atkins','employee_role','Ningxia','1-412-812-3768','Yes'),(10,'sem','Ignatius','Avery','employee_role','Liaoning','861-6783','Yes'),
(11,'aliquam','Edan','Castaneda','employee_role','Chongqing','1-683-301-7812','Yes'),(12,'ut','Lani','Walsh','employee_role','Tampines','1-352-372-1257','Yes'),
 (13,'mauris.','Nevada','Gallagher','employee_role','Shanxi','211-9323','No'),
  (14,'montes,','Rahim','Forbes','employee_role','Hougang','333-1393','No'),
  (15,'aliquet,','Cameron','Mays','employee_role','Mount Gambier','835-8594','Yes');
  
-- INSERT VALUES INTO AMENITY TABLE 
INSERT INTO Amenity (amenity_description)
VALUES
    ('Free Wi-Fi'),
    ('Room Service'),
    ('Complimentary Breakfast'),
    ('Airport Shuttle'),
    ('Pet-Friendly'),
    ('Live Entertainment'),
    ('Cultural Tours'),
    ('Jacuzzi'),
    ('Sauna'),
    ('Spa Services'),
    ('Concierge Services'),
    ('24/7 Front Desk'),
    ('In-Room Dining'),
    ('Outdoor Activities'),
    ('Skiing Facilities'),
    ('Beach Access'),
    ('Golf Course Access'),
    ('Fitness Classes'),
    ('Business Support'),
    ('Valet Parking');
    
-- INSERT VALUES INTO FACILITY TABLE 
INSERT INTO Facility (fac_description)
VALUES
    ('Fitness Center'),
    ('Spa and Wellness'),
    ('Meeting Rooms'),
    ('Business Center'),
    ('Swimming Pool'),
    ('Restaurant'),
    ('Lounge Area'),
    ('Parking Facilities'),
    ('Banquet Hall'),
    ('Outdoor Terrace'),
    ('Concierge Services'),
    ('Shuttle Service'),
    ('Laundry Facilities'),
    ('Currency Exchange'),
    ('Car Rental Services'),
    ('Valet Parking'),
    ('Kids Play Area'),
    ('Event Spaces'),
    ('Golf Course'),
    ('Wedding Services');


-- INSERT VALUES INTO HOTEL TABLE 
INSERT INTO Hotel (hotel_rating, hotel_name, hotel_location)
VALUES
    (4, 'Grand View Hotel', 'New York City'),
    (5, 'Luxury Oasis Resort', 'Maldives'),
    (4, 'Metropolitan Suites', 'London'),
    (3, 'Sunset Beach Resort', 'Miami'),
    (4, 'Harborview Inn', 'San Francisco'),
    (5, 'Mountain Retreat Lodge', 'Swiss Alps'),
    (3, 'Coastal Haven Resort', 'Sydney'),
    (4, 'Golden Sands Resort', 'Dubai'),
    (5, 'Serenity Springs Spa', 'Bali'),
    (3, 'Riverside Inn', 'Paris'),
    (4, 'Urban View Suites', 'New York City'),
(5, 'Elegant Chateau', 'Paris'),
(4, 'Metropolitan Towers', 'London'),
(3, 'Coastal Retreat Inn', 'Miami Beach'),
(4, 'Cityscape Hotel', 'San Francisco'),
(5, 'Alpine Lodge', 'Swiss Alps'),
(3, 'Harborview Resort', 'Sydney'),
(4, 'Golden Sands Resort', 'Dubai'),
(5, 'Serenity Springs Spa', 'Bali'),
(3, 'Riverside Inn', 'Vienna'),
(4, 'Midtown Luxury Suites', 'New York City'),
(5, 'Tropical Oasis Resort', 'Maldives'),
(4, 'Urban Horizon Suites', 'London'),
(3, 'Sunset Vista Resort', 'Miami'),
(4, 'Harborview Hotel', 'San Francisco'),
(5, 'Mountain Peak Lodge', 'Swiss Alps'),
(3, 'Coastal Retreat Resort', 'Sydney'),
(4, 'Golden Shores Resort', 'Dubai'),
(5, 'Tropical Paradise Spa', 'Bali'),
(3, 'Riverside Suites', 'Paris'),
(4, 'Downtown Oasis Suites', 'New York City'),
(5, 'Beachfront Resort', 'Maldives'),
(4, 'Cityscape Suites', 'London'),
(3, 'Sunset Paradise Resort', 'Miami'),
(4, 'Harborview Suites', 'San Francisco'),
(5, 'Mountain Haven Lodge', 'Swiss Alps'),
(3, 'Coastal Bliss Resort', 'Sydney'),
(4, 'Golden Horizon Resort', 'Dubai'),
(5, 'Tropical Retreat Spa', 'Bali'),
(3, 'Riverside Retreat', 'Paris'),
(4, 'Cityscape Oasis Suites', 'New York City'),
(5, 'Seaside Resort', 'Maldives'),
(4, 'Metropolitan Suites', 'London'),
(3, 'Beachfront Paradise Resort', 'Miami'),
(4, 'Harborview Lodge', 'San Francisco'),
(5, 'Alpine Heights Lodge', 'Swiss Alps'),
(3, 'Coastal Comfort Resort', 'Sydney'),
(4, 'Golden Sands Hotel', 'Dubai'),
(5, 'Tropical Serenity Spa', 'Bali'),
(4, 'Urban Oasis Suites', 'Singapore'),
(5, 'Beachfront Paradise Resort', 'Sydney'),
(4, 'Cityscape Suites', 'Amsterdam'),
(3, 'Harborview Retreat Resort', 'San Francisco'),
(4, 'Skyline Lodge', 'Tokyo'),
(5, 'Swiss Alpine Lodge', 'Swiss Alps'),
(3, 'Tropical Oasis Resort', 'Bali'),
(4, 'Golden Sands Hotel', 'Dubai'),
(5, 'Elegant Chateau', 'Paris'),
(3, 'Riverside Serenity Spa', 'London'),
(3, 'Riverside Bliss Inn', 'Paris'),
(4, 'Urban Oasis Suites', 'New York City'),
(5, 'Tropical Paradise Resort', 'Maldives'),
(4, 'Metropolitan Suites', 'London'),
(3, 'Sunset Vista Resort', 'Miami'),
(4, 'Harborview Inn', 'San Francisco'),
(5, 'Mountain Haven Lodge', 'Swiss Alps'),
(3, 'Coastal Comfort Resort', 'Sydney'),
(4, 'Golden Sands Resort', 'Dubai'),
(5, 'Tropical Retreat Spa', 'Bali'),
(3, 'Tropical Oasis Resort', 'Maldives'),
(4, 'Cityscape Suites', 'New York City'),
(5, 'Azure Shores Resort', 'Maldives'),
(4, 'Harborview Suites', 'London'),
(3, 'Sunset Retreat Resort', 'Miami'),
(4, 'Harborview Lodge', 'San Francisco'),
(5, 'Alpine Heights Lodge', 'Swiss Alps'),
(3, 'Coastal Comfort Resort', 'Sydney'),
(4, 'Golden Sands Hotel', 'Dubai'),
(5, 'Tropical Serenity Spa', 'Bali'),
(5, 'Marina Bay Sands', 'Singapore'),
(5, 'Tokyo Tower Hotel', 'Tokyo'),
(4, 'Sydney Harbour Resort', 'Sydney'),
(3, 'Golden Gate Inn', 'San Francisco'),
(4, 'Swiss Chalet Lodge', 'Swiss Alps'),
(5, 'Desert Mirage Resort', 'Dubai'),
(3, 'Bali Beach Retreat', 'Bali'),
(4, 'Louvre View Hotel', 'Paris'),
(5, 'Vienna Grand Palace', 'Vienna'),
(3, 'Opera Riverside Inn', 'New York City'),
(4, 'Palm Paradise Hotel', 'Los Angeles'),
(5, 'Elegant Chateau', 'Vienna'),
(4, 'Urban View Suites', 'Tokyo'),
(3, 'Sea Breeze Resort', 'Miami Beach'),
(4, 'Cityscape Inn', 'New York City'),
(5, 'Alpine Lodge', 'Swiss Alps'),
(3, 'Seaside Escape Hotel', 'Gold Coast'),
(4, 'Desert Oasis Resort', 'Dubai'),
(5, 'Balinese Bliss Resort', 'Bali'),
(3, 'Eiffel View Hotel', 'Paris'),
(5, 'Eiffel View Hotel+', 'Paris');


-- Generate random rows for HOTEL_FACILITY table with unique combinations
DO $$
DECLARE
    hotel_id INT;
    facility_id INT;
BEGIN
    FOR i IN 1..1000 LOOP  -- Generate 1000 random rows
        -- Generate random hotel_id and facility_id
        hotel_id := floor(random() * 100) + 1; -- Range from 1 to 100
        facility_id := floor(random() * 20) + 1; -- Range from 1 to 20
        -- Insert the row if it doesn't already exist
        BEGIN
            INSERT INTO HOTEL_FACILITY (hotel_id, fac_id)
            VALUES (hotel_id, facility_id);
        EXCEPTION
            WHEN unique_violation THEN
                -- Ignore if the combination already exists
                CONTINUE;
        END;
    END LOOP;
END $$;

-- Insert values into HOTEL_AMENITY TABLE 
-- Generate random rows for HOTEL_AMENITY table with unique combinations
DO $$
DECLARE
    hotel_id INT;
    amenity_id INT;
BEGIN
    FOR i IN 1..1000 LOOP  -- Generate 1000 random rows
        -- Generate random hotel_id and amenity_id
        hotel_id := floor(random() * 100) + 1; -- Range from 1 to 100
        amenity_id := floor(random() * 20) + 1; -- Range from 1 to 20
        -- Insert the row if it doesn't already exist
        BEGIN
            INSERT INTO HOTEL_AMENITY (hotel_id, amenity_id)
            VALUES (hotel_id, amenity_id);
        EXCEPTION
            WHEN unique_violation THEN
                -- Ignore if the combination already exists
                CONTINUE;
        END;
    END LOOP;
END $$;


-- INSERT VALUES TO FLIGHT
INSERT INTO Flight (flight_id, out_flight_no, ret_flight_no, out_destination, out_location, out_depart_date, out_arrival_date, ret_destination, ret_location, ret_depart_date, ret_arrival_date)
VALUES
(1, 'SG111', 'SG112', 'New York', 'London', '2023-08-20', '2023-08-21', 'London', 'New York', '2023-08-28', '2023-08-29'),
(2, 'LH222', 'LH223', 'Paris', 'Los Angeles', '2023-08-22', '2023-08-23', 'Los Angeles', 'Paris', '2023-08-29', '2023-08-30'),
(3, 'AA333', 'AA334', 'Tokyo', 'Sydney', '2023-08-23', '2023-08-24', 'Sydney', 'Tokyo', '2023-08-30', '2023-08-31'),
(4, 'EK444', 'EK445', 'Dubai', 'Istanbul', '2023-08-24', '2023-08-25', 'Istanbul', 'Dubai', '2023-08-31', '2023-09-01'),
(5, 'BA555', 'BA556', 'Hong Kong', 'Singapore', '2023-09-01', '2023-09-02', 'Singapore', 'Hong Kong', '2023-09-08', '2023-09-09'),
(6, 'AF666', 'AF667', 'Seoul', 'Beijing', '2023-09-02', '2023-09-03', 'Beijing', 'Seoul', '2023-09-09', '2023-09-10'),
(7, 'QF777', 'QF778', 'Mumbai', 'Delhi', '2023-09-03', '2023-09-04', 'Delhi', 'Mumbai', '2023-09-10', '2023-09-11'),
(8, 'UA888', 'UA889', 'Toronto', 'Vancouver', '2023-09-04', '2023-09-05', 'Vancouver', 'Toronto', '2023-09-11', '2023-09-12'),
(9, 'SQ999', 'SQ1000', 'Sydney', 'Auckland', '2023-09-05', '2023-09-06', 'Auckland', 'Sydney', '2023-09-12', '2023-09-13'),
(10, 'EY111', 'EY112', 'Dubai', 'New York', '2023-09-06', '2023-09-07', 'New York', 'Dubai', '2023-09-13', '2023-09-14'),
(11, 'DL222', 'DL223', 'Los Angeles', 'Chicago', '2023-09-07', '2023-09-08', 'Chicago', 'Los Angeles', '2023-09-14', '2023-09-15'),
(12, 'TK333', 'TK334', 'Istanbul', 'Rome', '2023-09-08', '2023-09-09', 'Rome', 'Istanbul', '2023-09-15', '2023-09-16'),
(13, 'CZ444', 'CZ445', 'Beijing', 'Shanghai', '2023-09-09', '2023-09-10', 'Shanghai', 'Beijing', '2023-09-16', '2023-09-17'),
(14, 'QF555', 'QF556', 'Sydney', 'Melbourne', '2023-09-10', '2023-09-11', 'Melbourne', 'Sydney', '2023-09-17', '2023-09-18'),
(15, 'UA666', 'UA667', 'Chicago', 'San Francisco', '2023-09-11', '2023-09-12', 'San Francisco', 'Chicago', '2023-09-18', '2023-09-19'),
(16, 'BA777', 'BA778', 'London', 'Amsterdam', '2023-09-12', '2023-09-13', 'Amsterdam', 'London', '2023-09-19', '2023-09-20'),
(17, 'AF888', 'AF889', 'Paris', 'Rome', '2023-09-13', '2023-09-14', 'Rome', 'Paris', '2023-09-20', '2023-09-21'),
(18, 'EY999', 'EY1000', 'Abu Dhabi', 'Dubai', '2023-09-14', '2023-09-15', 'Dubai', 'Abu Dhabi', '2023-09-21', '2023-09-22'),
(19, 'SQ111', 'SQ112', 'Singapore', 'Bangkok', '2023-09-15', '2023-09-16', 'Bangkok', 'Singapore', '2023-09-22', '2023-09-23'),
(20, 'TK222', 'TK223', 'Istanbul', 'Athens', '2023-09-16', '2023-09-17', 'Athens', 'Istanbul', '2023-09-23', '2023-09-24'),
(31, 'UA222', 'UA223', 'Chicago', 'Los Angeles', '2023-08-01', '2023-08-02', 'Los Angeles', 'Chicago', '2023-08-08', '2023-08-09'),
(32, 'LH333', 'LH334', 'Frankfurt', 'New York', '2023-08-02', '2023-08-03', 'New York', 'Frankfurt', '2023-08-09', '2023-08-10'),
(33, 'EK444', 'EK445', 'Dubai', 'Paris', '2023-08-03', '2023-08-04', 'Paris', 'Dubai', '2023-08-10', '2023-08-11'),
(34, 'BA555', 'BA556', 'London', 'Sydney', '2023-08-04', '2023-08-05', 'Sydney', 'London', '2023-08-11', '2023-08-12'),
(35, 'AF666', 'AF667', 'Paris', 'Tokyo', '2023-08-05', '2023-08-06', 'Tokyo', 'Paris', '2023-08-12', '2023-08-13'),
(36, 'AA777', 'AA778', 'New York', 'Los Angeles', '2023-08-06', '2023-08-07', 'Los Angeles', 'New York', '2023-08-13', '2023-08-14'),
(37, 'SQ888', 'SQ889', 'Singapore', 'Hong Kong', '2023-08-07', '2023-08-08', 'Hong Kong', 'Singapore', '2023-08-14', '2023-08-15'),
(38, 'DL999', 'DL1000', 'Atlanta', 'Miami', '2023-08-08', '2023-08-09', 'Miami', 'Atlanta', '2023-08-15', '2023-08-16'),
(39, 'EY111', 'EY112', 'Abu Dhabi', 'New York', '2023-08-09', '2023-08-10', 'New York', 'Abu Dhabi', '2023-08-16', '2023-08-17'),
(40, 'TK222', 'TK223', 'Istanbul', 'Cairo', '2023-08-10', '2023-08-11', 'Cairo', 'Istanbul', '2023-08-17', '2023-08-18'),
(41, 'QR333', 'QR334', 'Doha', 'London', '2023-08-11', '2023-08-12', 'London', 'Doha', '2023-08-18', '2023-08-19'),
(42, 'UA444', 'UA445', 'Chicago', 'Las Vegas', '2023-08-12', '2023-08-13', 'Las Vegas', 'Chicago', '2023-08-19', '2023-08-20'),
(43, 'BA555', 'BA556', 'London', 'Madrid', '2023-08-13', '2023-08-14', 'Madrid', 'London', '2023-08-20', '2023-08-21'),
(44, 'EK666', 'EK667', 'Dubai', 'Bangkok', '2023-08-14', '2023-08-15', 'Bangkok', 'Dubai', '2023-08-21', '2023-08-22'),
(45, 'SQ777', 'SQ778', 'Singapore', 'Sydney', '2023-08-15', '2023-08-16', 'Sydney', 'Singapore', '2023-08-22', '2023-08-23'),
(46, 'AF888', 'AF889', 'Paris', 'Rome', '2023-08-16', '2023-08-17', 'Rome', 'Paris', '2023-08-23', '2023-08-24'),
(47, 'EY999', 'EY1000', 'Abu Dhabi', 'Jeddah', '2023-08-17', '2023-08-18', 'Jeddah', 'Abu Dhabi', '2023-08-24', '2023-08-25'),
(48, 'TK111', 'TK112', 'Istanbul', 'Amsterdam', '2023-08-18', '2023-08-19', 'Amsterdam', 'Istanbul', '2023-08-25', '2023-08-26'),
(49, 'UA222', 'UA223', 'Chicago', 'New York', '2023-08-19', '2023-08-20', 'New York', 'Chicago', '2023-08-26', '2023-08-27'),
(50, 'LH333', 'LH334', 'Frankfurt', 'London', '2023-08-20', '2023-08-21', 'London', 'Frankfurt', '2023-08-27', '2023-08-28'),
(51, 'AA444', 'AA445', 'New York', 'Miami', '2023-08-21', '2023-08-22', 'Miami', 'New York', '2023-08-28', '2023-08-29'),
(52, 'EK555', 'EK556', 'Dubai', 'Tokyo', '2023-08-22', '2023-08-23', 'Tokyo', 'Dubai', '2023-08-29', '2023-08-30'),
(53, 'BA666', 'BA667', 'London', 'Paris', '2023-08-23', '2023-08-24', 'Paris', 'London', '2023-08-30', '2023-08-31'),
(54, 'SQ777', 'SQ778', 'Singapore', 'Bangkok', '2023-08-24', '2023-08-25', 'Bangkok', 'Singapore', '2023-08-31', '2023-09-01'),
(55, 'AF888', 'AF889', 'Paris', 'Rome', '2023-08-25', '2023-08-26', 'Rome', 'Paris', '2023-09-01', '2023-09-02'),
(56, 'UA999', 'UA1000', 'Chicago', 'Los Angeles', '2023-08-26', '2023-08-27', 'Los Angeles', 'Chicago', '2023-09-02', '2023-09-03'),
(57, 'TK111', 'TK112', 'Istanbul', 'Cairo', '2023-08-27', '2023-08-28', 'Cairo', 'Istanbul', '2023-09-03', '2023-09-04'),
(58, 'QR222', 'QR223', 'Doha', 'London', '2023-08-28', '2023-08-29', 'London', 'Doha', '2023-09-04', '2023-09-05'),
(59, 'BA333', 'BA334', 'London', 'New York', '2023-08-29', '2023-08-30', 'New York', 'London', '2023-09-05', '2023-09-06'),
(60, 'EK444', 'EK445', 'Dubai', 'Istanbul', '2023-08-30', '2023-08-31', 'Istanbul', 'Dubai', '2023-09-06', '2023-09-07'),
(61, 'SQ555', 'SQ556', 'Singapore', 'Hong Kong', '2023-08-31', '2023-09-01', 'Hong Kong', 'Singapore', '2023-09-07', '2023-09-08'),
(62, 'UA666', 'UA667', 'Chicago', 'Los Angeles', '2023-09-01', '2023-09-02', 'Los Angeles', 'Chicago', '2023-09-08', '2023-09-09'),
(63, 'LH777', 'LH778', 'Frankfurt', 'New York', '2023-09-02', '2023-09-03', 'New York', 'Frankfurt', '2023-09-09', '2023-09-10'),
(64, 'AF888', 'AF889', 'Paris', 'Rome', '2023-09-03', '2023-09-04', 'Rome', 'Paris', '2023-09-10', '2023-09-11'),
(65, 'TK999', 'TK1000', 'Istanbul', 'Athens', '2023-09-04', '2023-09-05', 'Athens', 'Istanbul', '2023-09-11', '2023-09-12'),
(66, 'QR111', 'QR112', 'Doha', 'London', '2023-09-05', '2023-09-06', 'London', 'Doha', '2023-09-12', '2023-09-13'),
(67, 'BA222', 'BA223', 'London', 'Amsterdam', '2023-09-06', '2023-09-07', 'Amsterdam', 'London', '2023-09-13', '2023-09-14'),
(68, 'EK333', 'EK334', 'Dubai', 'Paris', '2023-09-07', '2023-09-08', 'Paris', 'Dubai', '2023-09-14', '2023-09-15'),
(69, 'SQ444', 'SQ445', 'Singapore', 'Tokyo', '2023-09-08', '2023-09-09', 'Tokyo', 'Singapore', '2023-09-15', '2023-09-16'),
(70, 'AF555', 'AF556', 'Paris', 'New York', '2023-09-09', '2023-09-10', 'New York', 'Paris', '2023-09-16', '2023-09-17'),
(71, 'DL666', 'DL667', 'New York', 'Los Angeles', '2023-07-15', '2023-07-16', 'Los Angeles', 'New York', '2023-07-22', '2023-07-23'),
(72, 'UA222', 'UA223', 'Chicago', 'Miami', '2023-07-16', '2023-07-17', 'Miami', 'Chicago', '2023-07-23', '2023-07-24'),
(73, 'LH333', 'LH334', 'Frankfurt', 'London', '2023-07-17', '2023-07-18', 'London', 'Frankfurt', '2023-07-24', '2023-07-25'),
(74, 'EK444', 'EK445', 'Dubai', 'Paris', '2023-07-18', '2023-07-19', 'Paris', 'Dubai', '2023-07-25', '2023-07-26'),
(75, 'BA555', 'BA556', 'London', 'New York', '2023-07-19', '2023-07-20', 'New York', 'London', '2023-07-26', '2023-07-27'),
(76, 'AF666', 'AF667', 'Paris', 'Tokyo', '2023-07-20', '2023-07-21', 'Tokyo', 'Paris', '2023-07-27', '2023-07-28'),
(77, 'SQ777', 'SQ778', 'Singapore', 'Bangkok', '2023-07-21', '2023-07-22', 'Bangkok', 'Singapore', '2023-07-28', '2023-07-29'),
(78, 'UA888', 'UA889', 'Chicago', 'Los Angeles', '2023-07-22', '2023-07-23', 'Los Angeles', 'Chicago', '2023-07-29', '2023-07-30'),
(79, 'TK999', 'TK1000', 'Istanbul', 'Cairo', '2023-07-23', '2023-07-24', 'Cairo', 'Istanbul', '2023-07-30', '2023-07-31'),
(80, 'QR111', 'QR112', 'Doha', 'London', '2023-07-24', '2023-07-25', 'London', 'Doha', '2023-07-31', '2023-08-01'),
(81, 'BA222', 'BA223', 'London', 'Amsterdam', '2023-07-25', '2023-07-26', 'Amsterdam', 'London', '2023-08-01', '2023-08-02'),
(82, 'EK333', 'EK334', 'Dubai', 'Paris', '2023-07-26', '2023-07-27', 'Paris', 'Dubai', '2023-08-02', '2023-08-03'),
(83, 'SQ444', 'SQ445', 'Singapore', 'Tokyo', '2023-07-27', '2023-07-28', 'Tokyo', 'Singapore', '2023-08-03', '2023-08-04'),
(84, 'AF555', 'AF556', 'Paris', 'New York', '2023-07-28', '2023-07-29', 'New York', 'Paris', '2023-08-04', '2023-08-05'),
(85, 'DL666', 'DL667', 'New York', 'Los Angeles', '2023-07-29', '2023-07-30', 'Los Angeles', 'New York', '2023-08-05', '2023-08-06'),
(86, 'UA222', 'UA223', 'Chicago', 'Miami', '2023-07-30', '2023-07-31', 'Miami', 'Chicago', '2023-08-06', '2023-08-07'),
(87, 'LH333', 'LH334', 'Frankfurt', 'London', '2023-07-31', '2023-08-01', 'London', 'Frankfurt', '2023-08-07', '2023-08-08'),
(88, 'EK444', 'EK445', 'Dubai', 'Paris', '2023-08-01', '2023-08-02', 'Paris', 'Dubai', '2023-08-08', '2023-08-09'),
(89, 'BA555', 'BA556', 'London', 'New York', '2023-08-02', '2023-08-03', 'New York', 'London', '2023-08-09', '2023-08-10'),
(90, 'AF666', 'AF667', 'Paris', 'Tokyo', '2023-08-03', '2023-08-04', 'Tokyo', 'Paris', '2023-08-10', '2023-08-11'),
(91, 'SQ777', 'SQ778', 'Singapore', 'Bangkok', '2023-08-04', '2023-08-05', 'Bangkok', 'Singapore', '2023-08-11', '2023-08-12'),
(92, 'UA888', 'UA889', 'Chicago', 'Los Angeles', '2023-08-05', '2023-08-06', 'Los Angeles', 'Chicago', '2023-08-12', '2023-08-13'),
(93, 'TK999', 'TK1000', 'Istanbul', 'Cairo', '2023-08-06', '2023-08-07', 'Cairo', 'Istanbul', '2023-08-13', '2023-08-14'),
(94, 'QR111', 'QR112', 'Doha', 'London', '2023-08-07', '2023-08-08', 'London', 'Doha', '2023-08-14', '2023-08-15'),
(95, 'BA222', 'BA223', 'London', 'Amsterdam', '2023-08-08', '2023-08-09', 'Amsterdam', 'London', '2023-08-15', '2023-08-16'),
(96, 'EK333', 'EK334', 'Dubai', 'Paris', '2023-08-09', '2023-08-10', 'Paris', 'Dubai', '2023-08-16', '2023-08-17'),
(97, 'SQ444', 'SQ445', 'Singapore', 'Tokyo', '2023-08-10', '2023-08-11', 'Tokyo', 'Singapore', '2023-08-17', '2023-08-18'),
(98, 'AF555', 'AF556', 'Paris', 'New York', '2023-08-11', '2023-08-12', 'New York', 'Paris', '2023-08-18', '2023-08-19'),
(99, 'DL666', 'DL667', 'New York', 'Los Angeles', '2023-08-12', '2023-08-13', 'Los Angeles', 'New York', '2023-08-19', '2023-08-20'),
(100, 'UA222', 'UA223', 'Chicago', 'Miami', '2023-08-13', '2023-08-14', 'Miami', 'Chicago', '2023-08-20', '2023-08-21'),
(21, 'LH111', 'LH112', 'Frankfurt', 'London', '2023-07-01', '2023-07-02', 'London', 'Frankfurt', '2023-07-08', '2023-07-09'),
(22, 'EK222', 'EK223', 'Dubai', 'Paris', '2023-07-02', '2023-07-03', 'Paris', 'Dubai', '2023-07-09', '2023-07-10'),
(23, 'BA333', 'BA334', 'London', 'New York', '2023-07-03', '2023-07-04', 'New York', 'London', '2023-07-10', '2023-07-11'),
(24, 'AF444', 'AF445', 'Paris', 'Tokyo', '2023-07-04', '2023-07-05', 'Tokyo', 'Paris', '2023-07-11', '2023-07-12'),
(25, 'SQ555', 'SQ556', 'Singapore', 'Bangkok', '2023-07-05', '2023-07-06', 'Bangkok', 'Singapore', '2023-07-12', '2023-07-13'),
(26, 'UA666', 'UA667', 'Chicago', 'Los Angeles', '2023-07-06', '2023-07-07', 'Los Angeles', 'Chicago', '2023-07-13', '2023-07-14'),
(27, 'TK777', 'TK778', 'Istanbul', 'Cairo', '2023-07-07', '2023-07-08', 'Cairo', 'Istanbul', '2023-07-14', '2023-07-15'),
(28, 'QR888', 'QR889', 'Doha', 'London', '2023-07-08', '2023-07-09', 'London', 'Doha', '2023-07-15', '2023-07-16'),
(29, 'BA999', 'BA1000', 'London', 'Amsterdam', '2023-07-09', '2023-07-10', 'Amsterdam', 'London', '2023-07-16', '2023-07-17'),
(30, 'EK111', 'EK112', 'Dubai', 'Paris', '2023-07-10', '2023-07-11', 'Paris', 'Dubai', '2023-07-17', '2023-07-18');

-- INSERT VALUES INTO PACKAGE TABLE based on flight number, hotel rating, hotel location and duration

INSERT INTO PACKAGE (hotel_id, flight_id, pack_name, pack_pricePP, pack_duration, pack_location)
SELECT
    H.hotel_id,
    F.flight_id,
    CONCAT(
        ROUND(EXTRACT(EPOCH FROM (F.ret_depart_date - F.out_depart_date)) / (60 * 60 * 24))::INT,
        ' Days to ',
        H.hotel_location,
        ' at ',
        H.hotel_name
    ) AS pack_name,
    ROUND(RANDOM() * 500 + 500)::numeric(10, 2) AS pack_pricePP,
    ROUND(EXTRACT(EPOCH FROM (F.ret_depart_date - F.out_depart_date)) / (60 * 60 * 24))::INT AS pack_duration,
    F.out_location AS pack_location
FROM
    (SELECT DISTINCT ON (hotel_location) hotel_id, hotel_location, hotel_name FROM HOTEL) AS H
    CROSS JOIN LATERAL (
        SELECT * FROM FLIGHT
        WHERE out_destination = H.hotel_location
        ORDER BY RANDOM()
        LIMIT 1
    ) AS F
WHERE
    EXISTS (SELECT 1 FROM HOTEL WHERE hotel_id = H.hotel_id)
    AND EXISTS (SELECT 1 FROM FLIGHT WHERE flight_id = F.flight_id)
LIMIT 100;  


-- INSERT VALUES INTO BOOKING TABLE
INSERT INTO Booking (cust_id, pack_id, emp_id, book_depart_date, book_adult_no, book_child_no, book_discount)
VALUES
    (1, 1, 1, '2023-09-15', 2, 1, 0.1),
    (2, 2, 2, '2023-10-10', 1, 0, 0.2),
    (3, 3, 3, '2023-09-20', 2, 0, 0.0),
    (4, 4, 4, '2023-11-05', 1, 1, 0.15),
    (5, 5, 5, '2023-10-15', 2, 2, 0.05),
    (6, 6, 6, '2023-09-25', 1, 0, 0.0),
    (7, 7, 7, '2023-12-01', 2, 1, 0.1);

-- UPDATE PAYMENT TABLE
UPDATE Payment
SET pay_amt_paid = CASE
    WHEN pay_id = 1 THEN 150.45
    WHEN pay_id = 2 THEN 85.20
    WHEN pay_id = 3 THEN 120.75
    WHEN pay_id = 4 THEN 220.10
    WHEN pay_id = 5 THEN 180.60
    WHEN pay_id = 6 THEN 250.90
    WHEN pay_id = 7 THEN 135.30
    ELSE pay_amt_paid
END,
pay_status = 'Partially Paid'
WHERE pay_id IN (1, 2, 3, 4, 5, 6, 7);


------CREATE INDEXES------------------------------------------------------
-- Indexes for Package table
CREATE INDEX idx_package_pack_name ON package(pack_name);

-- Indexes for Flight table
CREATE INDEX idx_flight_out_flight_no ON flight(out_flight_no);
CREATE INDEX idx_flight_out_destination ON flight(out_destination);
CREATE INDEX idx_flight_out_depart_date ON flight(out_depart_date);
CREATE INDEX idx_flight_out_arrival_date ON flight(out_arrival_date);

-- Indexes for Hotel table
CREATE INDEX idx_hotel_hotel_name ON hotel(hotel_name);
CREATE INDEX idx_hotel_hotel_location ON hotel(hotel_location);

-- PAYMENT table
CREATE INDEX idx_pay_book_id ON PAYMENT(book_id);
CREATE INDEX idx_pay_status ON PAYMENT(pay_status);

-- PAYMENT_INSTALLMENT table
CREATE INDEX idx_payinstallment_payid ON PAYMENT_INSTALLMENT(pay_id);
COMMIT;
