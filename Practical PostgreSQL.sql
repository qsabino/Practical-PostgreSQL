--------------------------------------------------------------
-- Reference:
-- Practical SQL: A Beginner's Guide to Storytelling with Data
-- by Anthony DeBarros
--------------------------------------------------------------


-- 1. CREATING YOUR FIRST DATABASE AND TABLE


-- 1-2: Creating a table named teachers with six columns
CREATE TABLE teachers (
 	id bigserial,
	first_name varchar(25),
	last_name varchar(50),
	school varchar(50),
	hire_date date,
	salary numeric
);

-- 1-3: Inserting data into the teachers table
INSERT INTO teachers (first_name, last_name, school, hire_date, salary)
VALUES ('Janet', 'Smith', 'F.D. Roosevelt HS', '2011-10-30', 36200),
	('Lee', 'Reynolds', 'F.D. Roosevelt HS', '1993-05-22', 65000),
	('Samuel', 'Cole', 'Myers Middle School', '2005-08-01', 43500),
	('Samantha', 'Bush', 'Myers Middle School', '2011-10-30', 36200),
	('Betty', 'Diaz', 'Myers Middle School', '2005-08-30', 43500),
	('Kathleen', 'Roush', 'F.D. Roosevelt HS', '2010-10-22', 38500);


-- 2. BEGIN DATA EXPLORATON

-- SELECT
-- 2-1: Querying all rows and columns from the teachers table
SELECT * FROM teachers;

-- 2-2: Querying a subset of columns
SELECT last_name, first_name, salary FROM teachers;

-- 2-3: Querying distinct values in the school column
SELECT DISTINCT school FROM teachers;

-- 2-4: Querying distinct pairs of values in the school and salary columns
SELECT DISTINCT school, salary FROM teachers;

-- Sorting Data with ORDER BY
-- 2-5: Sorting a column with ORDER BY
SELECT first_name, last_name, salary
FROM teachers
ORDER BY salary DESC;

-- 2-6: Sorting multiple columns with ORDER BY
SELECT last_name, school, hire_date
FROM teachers
ORDER BY school ASC, hire_date DESC;

-- Filtering Rows with WHERE
-- 2-7: Filtering rows using WHERE
SELECT last_name, school, hire_date
FROM teachers
WHERE school = 'Myers Middle School';

-- Find teachers whose first name is Janet
SELECT first_name, last_name, school
FROM teachers
WHERE first_name = 'Janet';

-- List all school names in the table but exclude F.D. Roosevelt HS
SELECT school
FROM teachers
WHERE school != 'F.D. Roosevelt HS';

-- List teachers hired before January 1, 2000 (using the date format YYYY-MM-DD
SELECT first_name, last_name, hire_date
FROM teachers
WHERE hire_date < '2000-01-01';

-- Find teachers who earn $43,500 or more
SELECT first_name, last_name, salary
FROM teachers
WHERE salary >= 43500;

-- Find teachers who earn between $40,000 and $65,000
SELECT first_name, last_name, school, salary
FROM teachers
WHERE salary BETWEEN 40000 AND 65000;

-- Using LIKE and ILIKE with WHERE
-- 2-8: Filtering with LIKE and ILIKE
SELECT first_name
FROM teachers
WHERE first_name LIKE 'sam%';

-- Case-insensitive search 
SELECT first_name
FROM teachers
WHERE first_name ILIKE 'sam%';

-- Combining Operators with AND and OR
-- 2-9: Combining operators using AND and OR
-- Find teachers who work at Myers Middle School and have a salary less than $40,000
SELECT *
FROM teachers
WHERE school = 'Myers Middle School'
	AND salary < 40000;

-- Search for any teacher whose last name matches Cole or Bush
SELECT *
FROM teachers
WHERE last_name = 'Cole'
	OR last_name = 'Bush';
	
-- Looks for teachers at Roosevelt whose salaries are either less than $38,000 or greater than $40,000
SELECT *
FROM teachers
WHERE school = 'F.D. Roosevelt HS'
	AND (salary < 38000 OR salary > 40000);

-- Putting It All Together
-- 2-10: A SELECT statement including WHERE and ORDER BY
SELECT first_name, last_name, school, hire_date, salary
FROM teachers
WHERE school LIKE '%Roos%'
ORDER BY hire_date DESC;


-- 3. UNDERSTANDING DATA TYPES


-- Characters
-- 3-1: Character data types in action
CREATE TABLE char_data_types (
varchar_column varchar(10), -- The maximum length is specified
char_column char(10), -- The character length is specified
text_column text -- Unlimited length
);

INSERT INTO char_data_types
VALUES
('abc', 'abc', 'abc'),
('defghi', 'defghi', 'defghi');

COPY char_data_types TO 'C:/Users/QDS/PostgreSQL_Projects/typetest.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- If you get an error like Permission Denied, in SQL Shell (psql) run this code
\c analysis -- Switch to analysis database
\COPY char_data_types TO 'C:/Users/QDS/PostgreSQL_Projects/typetest.txt' 
WITH (FORMAT CSV, HEADER, DELIMITER '|');

select * from char_data_types;

-- Numbers
-- Auto-Incrementing Integers
CREATE TABLE people (
id serial,
person_name varchar(100)
);

-- 3-2: Number data types in action
CREATE TABLE number_data_types (
	numeric_column numeric(20,5), -- The maximum number of digits to the left and right of the decimal point
	real_column real, -- Allows precision to six decimal digits
	double_column double precision -- To 15 decimal points of precision
);

INSERT INTO number_data_types
VALUES
	(.7, .7, .7),
	(2.13579, 2.13579, 2.13579),
	(2.1357987654, 2.1357987654, 2.1357987654);
	
SELECT * FROM number_data_types;

-- 3-3: Rounding issues with float columns
SELECT
	numeric_column * 10000000 AS "Fixed",
	real_column * 10000000 AS "Float"
FROM number_data_types
WHERE numeric_column = .7;


-- Dates and Times
-- 3-4: The timestamp and interval types in action
 CREATE TABLE date_time_types (
	timestamp_column timestamp with time zone,
	interval_column interval
);

INSERT INTO date_time_types
VALUES
	('2018-12-31 01:00 EST','2 days'),
	('2018-12-31 01:00 -8','1 month'),
	('2018-12-31 01:00 Australia/Melbourne','1 century'),
	(now(),'1 week');
	
SELECT * FROM date_time_types;

-- Using the interval Data Type in Calculations
-- 3-5: Using the interval data type
SELECT
	timestamp_column,
	interval_column,
	timestamp_column - interval_column AS new_date
FROM date_time_types;

-- Transforming Values from One Type to Another with CAST
-- 3-6: Three CAST() examples
SELECT timestamp_column, 
	CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT numeric_column,
	CAST(numeric_column AS integer),
	CAST(numeric_column AS varchar(6))
FROM number_data_types;

SELECT CAST(char_column AS integer) 
FROM char_data_types; -- It returns an error of invalid input syntax for integer because letters can’t become integers!

-- CAST Shortcut Notation
-- These two statements cast timestamp_column as a varchar
SELECT timestamp_column, 
	CAST(timestamp_column AS varchar(10))
FROM date_time_types;

SELECT timestamp_column::varchar(10)
FROM date_time_types;


-- 4. IMPORTING AND EXPORTING DATA


-- Using COPY to Import Data
-- 4-2: A CREATE TABLE statement for census county data
CREATE TABLE us_counties_2010 (
    geo_name varchar(90),                    -- Name of the geography
    state_us_abbreviation varchar(2),        -- State/U.S. abbreviation
    summary_level varchar(3),                -- Summary Level
    region smallint,                         -- Region
    division smallint,                       -- Division
    state_fips varchar(2),                   -- State FIPS code
    county_fips varchar(3),                  -- County code
    area_land bigint,                        -- Area (Land) in square meters
    area_water bigint,                       -- Area (Water) in square meters
    population_count_100_percent integer,    -- Population count (100%)
    housing_unit_count_100_percent integer,  -- Housing Unit count (100%)
    internal_point_lat numeric(10,7),        -- Internal point (latitude)
    internal_point_lon numeric(10,7),        -- Internal point (longitude)

    -- This section is referred to as P1. Race:
    p0010001 integer,   -- Total population
    p0010002 integer,   -- Population of one race:
    p0010003 integer,   -- White Alone
    p0010004 integer,   -- Black or African American alone
    p0010005 integer,   -- American Indian and Alaska Native alone
    p0010006 integer,   -- Asian alone
    p0010007 integer,   -- Native Hawaiian and Other Pacific Islander alone
    p0010008 integer,   -- Some Other Race alone
    p0010009 integer,   -- Population of two or more races
    p0010010 integer,   -- Population of two races:
    p0010011 integer,   -- White; Black or African American
    p0010012 integer,   -- White; American Indian and Alaska Native
    p0010013 integer,   -- White; Asian
    p0010014 integer,   -- White; Native Hawaiian and Other Pacific Islander
    p0010015 integer,   -- White; Some Other Race
    p0010016 integer,   -- Black or African American; American Indian and Alaska Native
    p0010017 integer,   -- Black or African American; Asian
    p0010018 integer,   -- Black or African American; Native Hawaiian and Other Pacific Islander
    p0010019 integer,   -- Black or African American; Some Other Race
    p0010020 integer,   -- American Indian and Alaska Native; Asian
    p0010021 integer,   -- American Indian and Alaska Native; Native Hawaiian and Other Pacific Islander
    p0010022 integer,   -- American Indian and Alaska Native; Some Other Race
    p0010023 integer,   -- Asian; Native Hawaiian and Other Pacific Islander
    p0010024 integer,   -- Asian; Some Other Race
    p0010025 integer,   -- Native Hawaiian and Other Pacific Islander; Some Other Race
    p0010026 integer,   -- Population of three races
    p0010047 integer,   -- Population of four races
    p0010063 integer,   -- Population of five races
    p0010070 integer,   -- Population of six races

    -- This section is referred to as P2. HISPANIC OR LATINO, AND NOT HISPANIC OR LATINO BY RACE
    p0020001 integer,   -- Total
    p0020002 integer,   -- Hispanic or Latino
    p0020003 integer,   -- Not Hispanic or Latino:
    p0020004 integer,   -- Population of one race:
    p0020005 integer,   -- White Alone
    p0020006 integer,   -- Black or African American alone
    p0020007 integer,   -- American Indian and Alaska Native alone
    p0020008 integer,   -- Asian alone
    p0020009 integer,   -- Native Hawaiian and Other Pacific Islander alone
    p0020010 integer,   -- Some Other Race alone
    p0020011 integer,   -- Two or More Races
    p0020012 integer,   -- Population of two races
    p0020028 integer,   -- Population of three races
    p0020049 integer,   -- Population of four races
    p0020065 integer,   -- Population of five races
    p0020072 integer,   -- Population of six races

    -- This section is referred to as P3. RACE FOR THE POPULATION 18 YEARS AND OVER
    p0030001 integer,   -- Total
    p0030002 integer,   -- Population of one race:
    p0030003 integer,   -- White alone
    p0030004 integer,   -- Black or African American alone
    p0030005 integer,   -- American Indian and Alaska Native alone
    p0030006 integer,   -- Asian alone
    p0030007 integer,   -- Native Hawaiian and Other Pacific Islander alone
    p0030008 integer,   -- Some Other Race alone
    p0030009 integer,   -- Two or More Races
    p0030010 integer,   -- Population of two races
    p0030026 integer,   -- Population of three races
    p0030047 integer,   -- Population of four races
    p0030063 integer,   -- Population of five races
    p0030070 integer,   -- Population of six races

    -- This section is referred to as P4. HISPANIC OR LATINO, AND NOT HISPANIC OR LATINO BY RACE
    -- FOR THE POPULATION 18 YEARS AND OVER
    p0040001 integer,   -- Total
    p0040002 integer,   -- Hispanic or Latino
    p0040003 integer,   -- Not Hispanic or Latino:
    p0040004 integer,   -- Population of one race:
    p0040005 integer,   -- White alone
    p0040006 integer,   -- Black or African American alone
    p0040007 integer,   -- American Indian and Alaska Native alone
    p0040008 integer,   -- Asian alone
    p0040009 integer,   -- Native Hawaiian and Other Pacific Islander alone
    p0040010 integer,   -- Some Other Race alone
    p0040011 integer,   -- Two or More Races
    p0040012 integer,   -- Population of two races
    p0040028 integer,   -- Population of three races
    p0040049 integer,   -- Population of four races
    p0040065 integer,   -- Population of five races
    p0040072 integer,   -- Population of six races

    -- This section is referred to as H1. OCCUPANCY STATUS
    h0010001 integer,   -- Total housing units
    h0010002 integer,   -- Occupied
    h0010003 integer    -- Vacant
);

SELECT * FROM us_counties_2010;

-- 4-3: Importing census data using COPY
COPY us_counties_2010 
FROM 'C:/Users/QDS/PostgreSQL_Projects/us_counties_2010.csv' 
WITH (FORMAT CSV, HEADER);

SELECT * from us_counties_2010 LIMIT 10;

SELECT geo_name, state_us_abbreviation, area_land
FROM us_counties_2010
ORDER BY area_land DESC
LIMIT 3;

SELECT geo_name, state_us_abbreviation, internal_point_lon
FROM us_counties_2010
ORDER BY internal_point_lon DESC
LIMIT 5;

-- Importing a Subset of Columns with COPY
-- 4-4: Creating a table to track supervisor salaries
CREATE TABLE supervisor_salaries (
town varchar(30),
county varchar(30),
supervisor varchar(30),
start_date date,
salary money,
benefits money
);

-- 4-5: Importing salaries data from CSV to three table columns
COPY supervisor_salaries(town, supervisor, salary)
FROM 'C:/Users/QDS/PostgreSQL_Projects/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

SELECT * FROM supervisor_salaries;

-- Adding a Default Value to a Column During Import
DELETE FROM supervisor_salaries; -- Clear data from the table

-- 4-6: Using a temporary table to add a default value to a column during import
CREATE TEMPORARY TABLE supervisor_salaries_temp (LIKE supervisor_salaries);

COPY supervisor_salaries_temp (town, supervisor, salary)
FROM 'C:/Users/QDS/PostgreSQL_Projects/supervisor_salaries.csv'
WITH (FORMAT CSV, HEADER);

INSERT INTO supervisor_salaries (town, county, supervisor, salary)
SELECT town, 'Some County', supervisor, salary
FROM supervisor_salaries_temp;

DROP TABLE supervisor_salaries_temp;

SELECT * FROM supervisor_salaries;

-- Using COPY to Export Data
-- 4-7: Exporting an entire table with COPY
COPY us_counties_2010
TO 'C:/Users/QDS/PostgreSQL_Projects/us_counties_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

-- 4-8: Exporting selected columns from a table with COPY
COPY us_counties_2010 (geo_name, internal_point_lat, internal_point_lon)
TO 'C:/Users/QDS/PostgreSQL_Projects/us_counties_latlon_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');

--  4-9: Exporting query results with COPY
COPY (
SELECT geo_name, state_us_abbreviation
FROM us_counties_2010
WHERE geo_name ILIKE '%mill%'
)
TO 'C:/Users/QDS/PostgreSQL_Projects/us_counties_mill_export.txt'
WITH (FORMAT CSV, HEADER, DELIMITER '|');


-- 5. BASIC MATH AND STATS WITH SQL


-- 5-1: Basic addition, subtraction, and multiplication with SQL
SELECT 2 + 2;
SELECT 9 - 1;
SELECT 3 * 4;

-- 5-2: Integer and decimal division with SQL
SELECT 11 / 6;
SELECT 11 % 6; -- modulo
SELECT 11.0 / 6;
SELECT CAST (11 AS numeric(3,1)) / 6;

-- 5-3: Exponents, roots, and factorials with SQL
SELECT 3 ^ 4;
SELECT |/ 10; -- = sqrt(n)
SELECT sqrt(10);
SELECT ||/ 10; -- cube root
SELECT 4 !;

-- Doing Math Across Census Table Columns
-- 5-4: Selecting census population columns by race with aliases
SELECT geo_name,
	state_us_abbreviation AS "st",
	p0010001 AS "Total Population",
	p0010003 AS "White Alone",
	p0010004 AS "Black or African American Alone",
	p0010005 AS "Am Indian/Alaska Native Alone",
	p0010006 AS "Asian Alone",
	p0010007 AS "Native Hawaiian and Other Pacific Islander Alone",
	p0010008 AS "Some Other Race Alone",
	p0010009 AS "Two or More Races"
FROM us_counties_2010;

-- 5-5: Adding two columns in us_counties_2010
SELECT geo_name,
	state_us_abbreviation AS "st",
	p0010003 AS "White Alone",
	p0010004 AS "Black Alone",
	p0010003 + p0010004 AS "Total White and Black"
FROM us_counties_2010;

-- 5-6: Checking census data totals
-- Test to see if our import was clean
SELECT geo_name,
	state_us_abbreviation AS "st",
	p0010001 AS "Total",
	p0010003 + p0010004 + p0010005 + p0010006 + p0010007 + p0010008 + p0010009 AS "All Races",
	(p0010003 + p0010004 + p0010005 + p0010006 + p0010007 + p0010008 + p0010009) - p0010001 AS "Difference"
FROM us_counties_2010
ORDER BY "Difference" DESC;

-- Finding Percentages of the Whole
-- 5-7: Calculating the percentage of the population that is Asian by county
SELECT geo_name,
	state_us_abbreviation AS "st",
	(CAST(p0010006 AS numeric(8,1)) / p0010001) * 100 AS "pct_asian"
FROM us_counties_2010
ORDER BY "pct_asian" DESC;

-- Tracking Percent Change
-- 5-8: Calculating percent change
CREATE TABLE percent_change (
	department varchar(20),
	spend_2014 numeric(10,2),
	spend_2017 numeric(10,2)
);

INSERT INTO percent_change
VALUES
	('Building', 250000, 289000),
	('Assessor', 178556, 179500),
	('Library', 87777, 90001),
	('Clerk', 451980, 650000),
	('Police', 250000, 223000),
	('Recreation', 199000, 195000);
	
SELECT department,
	spend_2014,
	spend_2017,
	round( (spend_2017 - spend_2014) / spend_2014 * 100, 1) AS "pct_change"
FROM percent_change;

-- Aggregate Functions for Averages and Sums
-- 5-9: Using the sum() and avg() aggregate functions
SELECT sum(p0010001) AS "County Sum",
	round(avg(p0010001), 0) AS "County Average"
FROM us_counties_2010;

-- Finding the Median with Percentile Functions
-- 5-10: Testing SQL percentile functions
CREATE TABLE percentile_test (
	numbers integer
);

INSERT INTO percentile_test (numbers) 
VALUES
	(1), (2), (3), (4), (5), (6);
	
SELECT
	percentile_cont(.5) WITHIN GROUP (ORDER BY numbers),
	percentile_disc(.5) WITHIN GROUP (ORDER BY numbers)
FROM percentile_test;

-- Median and Percentiles with Census Data
-- 5-11: Using sum(), avg(), and percentile_cont() aggregate functions
SELECT sum(p0010001) AS "County Sum",
	round(avg(p0010001), 0) AS "County Average",
	percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) AS "County Median"
FROM us_counties_2010;

-- Finding Other Quantiles with Percentile Functions
-- 5-12: Passing an array of values to percentile_cont()
SELECT 
	percentile_cont(array[.25,.5,.75]) WITHIN GROUP (ORDER BY p0010001) AS "quartiles"
FROM us_counties_2010;

-- 5-13: Using unnest() to turn an array into rows
SELECT unnest(
	percentile_cont(array[.25,.5,.75]) WITHIN GROUP (ORDER BY p0010001) 
	) AS "quartiles"
FROM us_counties_2010;

-- Creating a median() Function
-- 5-14: Creating a median() aggregate function in PostgreSQL
-- First, makea function called _final_median that sorts the values in the column and finds the midpoint
 CREATE OR REPLACE FUNCTION _final_median(anyarray) 
RETURNS float8 AS
$$
	WITH q AS
	(
		SELECT val
		FROM unnest($1) val
		WHERE VAL IS NOT NULL
		ORDER BY 1
	),
	cnt AS
	(
		SELECT COUNT(*) AS c FROM q
	)
	SELECT AVG(val)::float8
	FROM
	(
		SELECT val FROM q
		LIMIT 2 - MOD((SELECT c FROM cnt), 2)
		OFFSET GREATEST(CEIL((SELECT c FROM cnt) / 2.0) - 1,0)
	) q2;
$$
LANGUAGE sql IMMUTABLE;

-- Second, create the callable aggregate function median() and passes values to _final_median
CREATE AGGREGATE median(anyelement) (
	SFUNC=array_append,
	STYPE=anyarray,
	FINALFUNC=_final_median,
	INITCOND='{}'
);

-- 5-15: Using a median() aggregate function
SELECT sum(p0010001) AS "County Sum",
	round(AVG(p0010001), 0) AS "County Average",
	median(p0010001) AS "County Median",
	percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) AS "50th Percentile"
FROM us_counties_2010;

-- Finding the Mode
-- 5-16: Finding the most frequent value with mode()
SELECT mode() WITHIN GROUP (ORDER BY p0010001)
FROM us_counties_2010;


-- 6. JOINING TABLES IN A RELATIONAL DATABASE


-- Relating Tables with Key Columns
-- 6-1: Creating the departments and employees tables
CREATE TABLE departments (
	dept_id bigserial,
	dept varchar(100),
	city varchar(100),
	CONSTRAINT dept_key PRIMARY KEY (dept_id),
	CONSTRAINT dept_city_unique UNIQUE (dept, city)
);

CREATE TABLE employees (
	emp_id bigserial,
	first_name varchar(100),
	last_name varchar(100),
	salary integer,
	dept_id integer REFERENCES departments (dept_id),
	CONSTRAINT emp_key PRIMARY KEY (emp_id),
	CONSTRAINT emp_dept_unique UNIQUE (emp_id, dept_id)
);

INSERT INTO departments (dept, city)
VALUES
('Tax', 'Atlanta'),
('IT', 'Boston');

INSERT INTO employees (first_name, last_name, salary, dept_id)
VALUES
	('Nancy', 'Jones', 62500, 1),
	('Lee', 'Smith', 59300, 1),
	('Soo', 'Nguyen', 83000, 2),
	('Janet', 'King', 95000, 2);

SELECT * FROM departments;

SELECT * FROM employees;

-- Querying Multiple Tables Using JOIN
-- 6-2: Joining the employees and departments tables
SELECT *
FROM employees 
	JOIN departments ON employees.dept_id = departments.dept_id;

-- 6-3: Creating two tables to explore JOIN types
CREATE TABLE schools_left (
	id integer CONSTRAINT left_id_key PRIMARY KEY,
	left_school varchar(30)
);

CREATE TABLE schools_right (
	id integer CONSTRAINT right_id_key PRIMARY KEY,
	right_school varchar(30)
);

INSERT INTO schools_left (id, left_school) 
VALUES
	(1, 'Oak Street School'),
	(2, 'Roosevelt High School'),
	(5, 'Washington Middle School'),
	(6, 'Jefferson High School');
	
INSERT INTO schools_right (id, right_school) 
VALUES
	(1, 'Oak Street School'),
	(2, 'Roosevelt High School'),
	(3, 'Morrison Elementary'),
	(4, 'Chase Magnet Academy'),
	(6, 'Jefferson High School');

-- 6-4: Using JOIN
SELECT *
FROM schools_left 
	JOIN schools_right 	ON schools_left.id = schools_right.id;

-- 6-5: Using LEFT JOIN
SELECT *
FROM schools_left 
	LEFT JOIN schools_right ON schools_left.id = schools_right.id;

-- 6-6: Using RIGHT JOIN
SELECT *
FROM schools_left 
	RIGHT JOIN schools_right ON schools_left.id = schools_right.id;

-- 6-7: Using FULL OUTER JOIN
SELECT *
FROM schools_left 
	FULL OUTER JOIN schools_right ON schools_left.id = schools_right.id;

-- 6-8: Using CROSS JOIN
SELECT *
FROM schools_left CROSS JOIN schools_right;

-- Using NULL to Find Rows with Missing Values
-- 6-9: Filtering to show missing values with IS NULL
SELECT *
FROM schools_left 
	LEFT JOIN schools_right ON schools_left.id = schools_right.id
WHERE schools_right.id IS NULL;

-- Selecting Specific Columns in a Join
-- 6-10: Querying specific columns in a join
SELECT schools_left.id,
	schools_left.left_school,
	schools_right.right_school
FROM schools_left 
	LEFT JOIN schools_right ON schools_left.id = schools_right.id;

-- Simplifying JOIN Syntax with Table Aliases
-- 6-11: Simplifying code with table aliases
SELECT lt.id,
	lt.left_school,
	rt.right_school
FROM schools_left AS lt 
	LEFT JOIN schools_right AS rt ON lt.id = rt.id;

-- Joining Multiple Tables
-- 6-12: Joining multiple tables
CREATE TABLE schools_enrollment (
	id integer,
	enrollment integer
);

CREATE TABLE schools_grades (
	id integer,
	grades varchar(10)
);

INSERT INTO schools_enrollment (id, enrollment)
VALUES
	(1, 360),
	(2, 1001),
	(5, 450),
	(6, 927);
	
INSERT INTO schools_grades (id, grades)
VALUES
	(1, 'K-3'),
	(2, '9-12'),
	(5, '6-8'),
	(6, '9-12');

SELECT lt.id, lt.left_school, en.enrollment, gr.grades
FROM schools_left AS lt 
	LEFT JOIN schools_enrollment AS en ON lt.id = en.id
 	LEFT JOIN schools_grades AS gr ON lt.id = gr.id;

-- Performing Math on Joined Table Columns
-- 6-13: Performing math on joined census tables 
CREATE TABLE us_counties_2000 (
	geo_name varchar(90),
	state_us_abbreviation varchar(2),
	state_fips varchar(2),
	county_fips varchar(3),
	p0010001 integer,
	p0010002 integer,
	p0010003 integer,
	p0010004 integer,
	p0010005 integer,
	p0010006 integer,
	p0010007 integer,
	p0010008 integer,
	p0010009 integer,
	p0010010 integer,
	p0020002 integer,
	p0020003 integer
);

COPY us_counties_2000 
FROM 'C:/Users/QDS/PostgreSQL_Projects/us_counties_2000.csv' 
WITH (FORMAT CSV, HEADER);

SELECT c2010.geo_name,
	c2010.state_us_abbreviation AS state,
	c2010.p0010001 AS pop_2010,
	c2000.p0010001 AS pop_2000,
	c2010.p0010001 - c2000.p0010001 AS raw_change,
	round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001) / c2000.p0010001 * 100, 1 ) AS pct_change
FROM us_counties_2010 c2010 
	INNER JOIN us_counties_2000 c2000 
		ON c2010.state_fips = c2000.state_fips AND c2010.county_fips = c2000.county_fips AND c2010.p0010001 <> c2000.p0010001
ORDER BY pct_change DESC;


-- 7. TABLE DESIGN THAT WORKS FOR YOU


-- Primary Key Syntax
-- 7-1: Declaring a single-column natural key as a primary key
-- Column constraint
CREATE TABLE natural_key_example (
	license_id varchar(10) CONSTRAINT license_key PRIMARY KEY, -- natural key as primary key
	first_name varchar(50),
	last_name varchar(50)
);

DROP TABLE natural_key_example;

--  Table constraint, used when you want to create a primary key using more than one column
CREATE TABLE natural_key_example (
	license_id varchar(10),
	first_name varchar(50),
	last_name varchar(50),
	CONSTRAINT license_key PRIMARY KEY (license_id) -- same primary key using table constrain syntax
);

-- 7-2: An example of a primary key violation
INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

INSERT INTO natural_key_example (license_id, first_name, last_name)
VALUES ('T229901', 'Sam', 'Tracy');

-- Creating a Composite Primary Key
-- 7-3: Declaring a composite primary key as a natural key
CREATE TABLE natural_key_composite_example (
	student_id varchar(10),
	school_day date,
	present boolean,
	CONSTRAINT student_key PRIMARY KEY (student_id, school_day)
);

-- 7-4: Example of a composite primary key violation
INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/22/2017', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/23/2017', 'Y');

INSERT INTO natural_key_composite_example (student_id, school_day, present)
VALUES(775, '1/23/2017', 'N');

-- Creating an Auto-Incrementing Surrogate Key
-- 7-5: Declaring a bigserial column as a surrogate key
CREATE TABLE surrogate_key_example (
	order_number bigserial, -- shows how to declare the bigserial data type for an order_number column
	product_name varchar(50),
	order_date date,
	CONSTRAINT order_key PRIMARY KEY (order_number) -- set the order_number column as the primary key
);

INSERT INTO surrogate_key_example (product_name, order_date)
VALUES ('Beachball Polish', '2015-03-17'),
	('Wrinkle De-Atomizer', '2017-05-22'),
	('Flux Capacitor', '1985-10-26');
	
SELECT * FROM surrogate_key_example;

-- Foreign Keys
-- 7-6: A foreign key example
CREATE TABLE licenses (
	license_id varchar(10),
	first_name varchar(50),
	last_name varchar(50),
	CONSTRAINT licenses_key PRIMARY KEY (license_id) --  uses a driver’s unique license_id as a natural primary key
);

CREATE TABLE registrations (
	registration_id varchar(10),
	registration_date date,
	license_id varchar(10) REFERENCES licenses (license_id), -- as a foreign key by adding the REFERENCES keyword
	CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);

INSERT INTO licenses (license_id, first_name, last_name)
VALUES ('T229901', 'Lynn', 'Malero');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A203391', '3/17/2017', 'T229901');

INSERT INTO registrations (registration_id, registration_date, license_id)
VALUES ('A75772', '3/17/2017', 'T000001'); -- tries to add a row to registrations with a value for license_id that’s not in licenses

-- Automatically Deleting Related Records with CASCADE
-- This deleting a row in licenses should also delete all related rows in registrations, leave no orphaned rows
CREATE TABLE registrations (
	registration_id varchar(10),
	registration_date date,
	license_id varchar(10) REFERENCES licenses (license_id) ON DELETE CASCADE,
CONSTRAINT registration_key PRIMARY KEY (registration_id, license_id)
);

-- The CHECK Constraint
-- 7-7: Examples of CHECK constraints
CREATE TABLE check_constraint_example (
	user_id bigserial,
	user_role varchar(50),
	salary integer,
	CONSTRAINT user_id_key PRIMARY KEY (user_id),
	CONSTRAINT check_role_in_list CHECK (user_role IN('Admin', 'Staff')), -- tests whether values entered into the user_role column match one of two predefined strings, Admin or Staff
	CONSTRAINT check_salary_not_zero CHECK (salary > 0) -- tests whether values entered in the salary column are greater than 0
);

-- The UNIQUE Constraint
-- 7-8: A UNIQUE constraint example
CREATE TABLE unique_constraint_example (
	contact_id bigserial CONSTRAINT contact_id_key PRIMARY KEY,
	first_name varchar(50),
	last_name varchar(50),
	email varchar(200),
	CONSTRAINT email_unique UNIQUE (email) -- ensure that any time we add or update a contact’s email we’re not providing one that already exists.
);

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Samantha', 'Lee', 'slee@example.org');

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Betty', 'Diaz', 'bdiaz@example.org');

INSERT INTO unique_constraint_example (first_name, last_name, email)
VALUES ('Sasha', 'Lee', 'slee@example.org'); --  try to insert an email that already exists, the database will return an error

-- The NOT NULL Constraint
-- 7-9: A NOT NULL constraint example
CREATE TABLE not_null_example (
	student_id bigserial,
	first_name varchar(50) NOT NULL, -- don’t include values for this column, the database will notify us of the violation.
	last_name varchar(50) NOT NULL,
	CONSTRAINT student_id_key PRIMARY KEY (student_id)
);

-- Removing Constraints or Adding Them Later
-- 7-10: Dropping and adding a primary key and a NOT NULL constraint
ALTER TABLE not_null_example DROP CONSTRAINT student_id_key;
ALTER TABLE not_null_example ADD CONSTRAINT student_id_key PRIMARY KEY (student_id);
ALTER TABLE not_null_example ALTER COLUMN first_name DROP NOT NULL;
ALTER TABLE not_null_example ALTER COLUMN first_name SET NOT NULL;

-- Speeding Up Queries with Indexes
-- B-Tree: PostgreSQL’s Default Index
-- 7-11: Importing New York City address data
CREATE TABLE new_york_addresses (
	longitude numeric(9,6),
	latitude numeric(9,6),
	street_number varchar(10),
	street varchar(32),
	unit varchar(7),
	postcode varchar(5),
	id integer CONSTRAINT new_york_key PRIMARY KEY
);

COPY new_york_addresses
FROM 'C:/Users/QDS/PostgreSQL_Projects/city_of_new_york.csv'
WITH (FORMAT CSV, HEADER);

-- Benchmarking Query Performance with EXPLAIN
-- Recording Some Control Execution Times
-- 7-12: Benchmark queries for index performance
-- EXPLAIN AANALYZE keywords tell the database to execute the query and display statistics about the query process and how long it took to execute.
EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'BROADWAY';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = '52 STREET';

EXPLAIN ANALYZE SELECT * FROM new_york_addresses
WHERE street = 'ZWICKY AVENUE';

-- Adding the Index
-- 7-13: Creating a B-Tree index on the new_york_addresses table
CREATE INDEX street_idx ON new_york_addresses (street);
-- rerun queries in 7-12, compare the execution times before and after adding the index


-- 8. EXTRACTING INFORMATION BY GROUPING AND SUMMARIZING
-- 8-1: Creating and filling the 2014 Public Libraries Survey table
CREATE TABLE pls_fy2014_pupld14a (
    stabr varchar(2) NOT NULL,
    fscskey varchar(6) CONSTRAINT fscskey2014_key PRIMARY KEY,
    libid varchar(20) NOT NULL,
    libname varchar(100) NOT NULL,
    obereg varchar(2) NOT NULL,
    rstatus integer NOT NULL,
    statstru varchar(2) NOT NULL,
    statname varchar(2) NOT NULL,
    stataddr varchar(2) NOT NULL,
    longitud numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    fipsst varchar(2) NOT NULL,
    fipsco varchar(3) NOT NULL,
    address varchar(35) NOT NULL,
    city varchar(20) NOT NULL,
    zip varchar(5) NOT NULL,
    zip4 varchar(4) NOT NULL,
    cnty varchar(20) NOT NULL,
    phone varchar(10) NOT NULL,
    c_relatn varchar(2) NOT NULL,
    c_legbas varchar(2) NOT NULL,
    c_admin varchar(2) NOT NULL,
    geocode varchar(3) NOT NULL,
    lsabound varchar(1) NOT NULL,
    startdat varchar(10),
    enddate varchar(10),
    popu_lsa integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    master numeric(8,2) NOT NULL,
    libraria numeric(8,2) NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    locgvt integer NOT NULL,
    stgvt integer NOT NULL,
    fedgvt integer NOT NULL,
    totincm integer NOT NULL,
    salaries integer,
    benefit integer,
    staffexp integer,
    prmatexp integer NOT NULL,
    elmatexp integer NOT NULL,
    totexpco integer NOT NULL,
    totopexp integer NOT NULL,
    lcap_rev integer NOT NULL,
    scap_rev integer NOT NULL,
    fcap_rev integer NOT NULL,
    cap_rev integer NOT NULL,
    capital integer NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio_ph integer NOT NULL,
    audio_dl float NOT NULL,
    video_ph integer NOT NULL,
    video_dl float NOT NULL,
    databases integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    referenc integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    elmatcir integer NOT NULL,
    loanto integer NOT NULL,
    loanfm integer NOT NULL,
    totpro integer NOT NULL,
    totatten integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    wifisess integer NOT NULL,
    yr_sub integer NOT NULL
);

CREATE INDEX libname2014_idx ON pls_fy2014_pupld14a (libname);
CREATE INDEX stabr2014_idx ON pls_fy2014_pupld14a (stabr);
CREATE INDEX city2014_idx ON pls_fy2014_pupld14a (city);
CREATE INDEX visits2014_idx ON pls_fy2014_pupld14a (visits);

COPY pls_fy2014_pupld14a 
FROM 'C:/Users/QDS/PostgreSQL_Projects/pls_fy2014_pupld14a.csv' -- problem with encoding
WITH (FORMAT CSV, HEADER);

-- 8-2: Creating and filling the 2009 Public Libraries Survey table
CREATE TABLE pls_fy2009_pupld09a (
    stabr varchar(2) NOT NULL,
    fscskey varchar(6) CONSTRAINT fscskey2009_key PRIMARY KEY,
    libid varchar(20) NOT NULL,
    libname varchar(100) NOT NULL,
    address varchar(35) NOT NULL,
    city varchar(20) NOT NULL,
    zip varchar(5) NOT NULL,
    zip4 varchar(4) NOT NULL,
    cnty varchar(20) NOT NULL,
    phone varchar(10) NOT NULL,
    c_relatn varchar(2) NOT NULL,
    c_legbas varchar(2) NOT NULL,
    c_admin varchar(2) NOT NULL,
    geocode varchar(3) NOT NULL,
    lsabound varchar(1) NOT NULL,
    startdat varchar(10),
    enddate varchar(10),
    popu_lsa integer NOT NULL,
    centlib integer NOT NULL,
    branlib integer NOT NULL,
    bkmob integer NOT NULL,
    master numeric(8,2) NOT NULL,
    libraria numeric(8,2) NOT NULL,
    totstaff numeric(8,2) NOT NULL,
    locgvt integer NOT NULL,
    stgvt integer NOT NULL,
    fedgvt integer NOT NULL,
    totincm integer NOT NULL,
    salaries integer,
    benefit integer,
    staffexp integer,
    prmatexp integer NOT NULL,
    elmatexp integer NOT NULL,
    totexpco integer NOT NULL,
    totopexp integer NOT NULL,
    lcap_rev integer NOT NULL,
    scap_rev integer NOT NULL,
    fcap_rev integer NOT NULL,
    cap_rev integer NOT NULL,
    capital integer NOT NULL,
    bkvol integer NOT NULL,
    ebook integer NOT NULL,
    audio integer NOT NULL,
    video integer NOT NULL,
    databases integer NOT NULL,
    subscrip integer NOT NULL,
    hrs_open integer NOT NULL,
    visits integer NOT NULL,
    referenc integer NOT NULL,
    regbor integer NOT NULL,
    totcir integer NOT NULL,
    kidcircl integer NOT NULL,
    loanto integer NOT NULL,
    loanfm integer NOT NULL,
    totpro integer NOT NULL,
    totatten integer NOT NULL,
    gpterms integer NOT NULL,
    pitusr integer NOT NULL,
    yr_sub integer NOT NULL,
    obereg varchar(2) NOT NULL,
    rstatus integer NOT NULL,
    statstru varchar(2) NOT NULL,
    statname varchar(2) NOT NULL,
    stataddr varchar(2) NOT NULL,
    longitud numeric(10,7) NOT NULL,
    latitude numeric(10,7) NOT NULL,
    fipsst varchar(2) NOT NULL,
    fipsco varchar(3) NOT NULL
);

CREATE INDEX libname2009_idx ON pls_fy2009_pupld09a (libname);
CREATE INDEX stabr2009_idx ON pls_fy2009_pupld09a (stabr);
CREATE INDEX city2009_idx ON pls_fy2009_pupld09a (city);
CREATE INDEX visits2009_idx ON pls_fy2009_pupld09a (visits);

COPY pls_fy2009_pupld09a 
FROM 'C:/Users/QDS/PostgreSQL_Projects/pls_fy2009_pupld09a.csv' -- problem with encoding
WITH (FORMAT CSV, HEADER);

-- Counting Rows and Values Using count()
-- 8-3: Using count() for table row counts
SELECT count(*)
FROM pls_fy2014_pupld14a;

SELECT count(*)
FROM pls_fy2009_pupld09a;

-- Counting Values Present in a Column
-- 8-4: Using count() for the number of values in a column
SELECT count(salaries)
FROM pls_fy2014_pupld14a;

-- Counting Distinct Values in a Column
-- 8-5: Using count() for the number of distinct values in a column
SELECT count(libname)
FROM pls_fy2014_pupld14a;

SELECT count(DISTINCT libname)
FROM pls_fy2014_pupld14a;

-- Finding Maximum and Minimum Values Using max() and min()
-- 8-6: Finding the most and fewest visits using max() and min()
SELECT max(visits), min(visits)
FROM pls_fy2014_pupld14a;

-- Aggregating Data Using GROUP BY
-- 8-7: Using GROUP BY on the stabr column
SELECT stabr
FROM pls_fy2014_pupld14a
GROUP BY stabr
ORDER BY stabr;

-- 8-8: Using GROUP BY on the city and stabr columns
SELECT city, stabr
FROM pls_fy2014_pupld14a
GROUP BY city, stabr
ORDER BY city, stabr;

-- Combining GROUP BY with count()
-- 8-9: Using GROUP BY with count() on the stabr column
SELECT stabr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr
ORDER BY count(*) DESC;

-- Using GROUP BY on Multiple Columns with count()
-- 8-10: Using GROUP BY with count() of the stabr and stataddr columns
SELECT stabr, stataddr, count(*)
FROM pls_fy2014_pupld14a
GROUP BY stabr, stataddr
ORDER BY stabr ASC, count(*) DESC;

-- Revisiting sum() to Examine Library Visits
-- 8-11: Using the sum() aggregate function to total visits to libraries in 2014 and 2009
SELECT sum(visits) AS visits_2014
FROM pls_fy2014_pupld14a
WHERE visits >= 0;

SELECT sum(visits) AS visits_2009
FROM pls_fy2009_pupld09a
WHERE visits >= 0;

-- 8-12: Using the sum() aggregate function to total visits on joined 2014 and 2009 library tables
SELECT sum(pls14.visits) AS visits_2014,
	sum(pls09.visits) AS visits_2009
FROM pls_fy2014_pupld14a pls14 
	JOIN pls_fy2009_pupld09a pls09 ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0;

-- Grouping Visit Sums by State
-- Using GROUP BY to track percent change in library visits by state
SELECT pls14.stabr,
	sum(pls14.visits) AS visits_2014,
	sum(pls09.visits) AS visits_2009,
	round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) / sum(pls09.visits) * 100, 2 ) AS pct_change
FROM pls_fy2014_pupld14a pls14 
	JOIN pls_fy2009_pupld09a pls09 ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.stabr
ORDER BY pct_change DESC;

-- Filtering an Aggregate Query Using HAVING
-- 8-14: Using a HAVING clause to filter the results of an aggregate query
SELECT pls14.stabr,
	sum(pls14.visits) AS visits_2014,
	sum(pls09.visits) AS visits_2009,
	round( (CAST(sum(pls14.visits) AS decimal(10,1)) - sum(pls09.visits)) / sum(pls09.visits) * 100, 2 ) AS pct_change
FROM pls_fy2014_pupld14a pls14 
	JOIN pls_fy2009_pupld09a pls09 ON pls14.fscskey = pls09.fscskey
WHERE pls14.visits >= 0 AND pls09.visits >= 0
GROUP BY pls14.stabr
HAVING sum(pls14.visits) > 50000000 -- only rows with a sum of visits in 2014 greater than 50 million
ORDER BY pct_change DESC;


-- 9. INSPECTING AND MODIFYING DATA


-- Importing Data on Meat, Poultry, and Egg Producers
-- 9-1: Importing the FSIS Meat, Poultry, and Egg Inspection Directory
CREATE TABLE meat_poultry_egg_inspect (
	est_number varchar(50) CONSTRAINT est_number_key PRIMARY KEY,
	company varchar(100),
	street varchar(100),
	city varchar(30),
	st varchar(2),
	zip varchar(5),
	phone varchar(14),
	grant_date date,
	activities text,
	dbas text
);

COPY meat_poultry_egg_inspect 
FROM 'C:/Users/QDS/PostgreSQL_Projects/MPI_Directory_by_Establishment_Name.csv' 
WITH (FORMAT CSV, HEADER, DELIMITER ',');

CREATE INDEX company_idx ON meat_poultry_egg_inspect (company);

-- Interviewing the Data Set
-- 9-2: Finding multiple companies at the same address
SELECT company,
	street,
	city,
	st,
	count(*) AS address_count
FROM meat_poultry_egg_inspect
GROUP BY company, street, city, st
HAVING count(*) > 1
ORDER BY company, street, city, st;

-- Checking for Missing Values
-- 9-3: Grouping and counting states
SELECT st, count(*) AS st_count
FROM meat_poultry_egg_inspect
GROUP BY st
ORDER BY st NULLS FIRST;

-- 9-4: Using IS NULL to find missing values in the st column
SELECT est_number,
	company,
	city,
	st,
	zip
FROM meat_poultry_egg_inspect
WHERE st IS NULL;

-- Checking for Inconsistent Data Values
-- 9-5: Using GROUP BY and count() to find inconsistent company names
SELECT company, count(*) AS company_count
FROM meat_poultry_egg_inspect
GROUP BY company
ORDER BY company ASC;

-- Checking for Malformed Values Using length()
-- 9-6: Using length() and count() to test the zip column
SELECT length(zip), count(*) AS length_count
FROM meat_poultry_egg_inspect
GROUP BY length(zip)
ORDER BY length(zip) ASC;

-- 9-7: Filtering with length() to find short zip values
SELECT st, count(*) AS st_count
FROM meat_poultry_egg_inspect
WHERE length(zip) < 5
GROUP BY st
ORDER BY st ASC;

-- Modifying Tables, Columns, and Data
-- Modifying Values with UPDATE
-- update the data in every row in a column
UPDATE table
SET column = value;

-- update values in multiple columns at a time
UPDATE table
SET column_a = value,
column_b = value;

-- restrict the update to particular rows
UPDATE table
SET column = value
WHERE criteria;

-- update one table with values from another table
UPDATE table
SET column = (SELECT column
				FROM table_b
				WHERE table.column = table_b.column)
WHERE EXISTS (SELECT column
				FROM table_b
				WHERE table.column = table_b.column);

-- updating values across tables
UPDATE table
SET column = table_b.column
FROM table_b
WHERE table.column = table_b.column;

-- Creating Backup Tables
-- 9-8: Backing up a table
CREATE TABLE meat_poultry_egg_inspect_backup AS
	SELECT * 
	FROM meat_poultry_egg_inspect;
-- Indexes are not copied when creating a table backup using the CREATE TABLE statement
 
-- confirm this backup by counting the number of records in both tables
SELECT
	(SELECT count(*) FROM meat_poultry_egg_inspect) AS original,
	(SELECT count(*) FROM meat_poultry_egg_inspect_backup) AS backup;

-- Restoring Missing Column Values
-- Creating a Column Copy
-- 9-9: Creating and filling the st_copy column with ALTER TABLE and UPDATE
ALTER TABLE meat_poultry_egg_inspect 
ADD COLUMN st_copy varchar(2);

UPDATE meat_poultry_egg_inspect
SET st_copy = st;

-- 9-10: Checking values in the st and st_copy columns
SELECT st, st_copy
FROM meat_poultry_egg_inspect
ORDER BY st;

-- Updating Rows Where Values Are Missing
-- 9-11: Updating the st column for three establishments
UPDATE meat_poultry_egg_inspect
SET st = 'MN'
WHERE est_number = 'V18677A';

UPDATE meat_poultry_egg_inspect
SET st = 'AL'
WHERE est_number = 'M45319+P45319';

UPDATE meat_poultry_egg_inspect
SET st = 'WI'
WHERE est_number = 'M263A+P263A+V263A';

-- Restoring Original Values
-- 9-12: Restoring original st column values
UPDATE meat_poultry_egg_inspect
SET st = st_copy;

-- Aternately,
UPDATE meat_poultry_egg_inspect original
SET st = backup.st
FROM meat_poultry_egg_inspect_backup backup
WHERE original.est_number = backup.est_number;

-- Updating Values for Consistency
-- 9-13: Creating and filling the company_standard column
ALTER TABLE meat_poultry_egg_inspect 
ADD COLUMN company_standard varchar(100);

UPDATE meat_poultry_egg_inspect
SET company_standard = company;

-- 9-14: Using an UPDATE statement to modify field values that match a string
UPDATE meat_poultry_egg_inspect
SET company_standard = 'Armour-Eckrich Meats'
WHERE company LIKE 'Armour%';

SELECT company, company_standard
FROM meat_poultry_egg_inspect
WHERE company LIKE 'Armour%';

-- Repairing ZIP Codes Using Concatenation
-- 9-15: Creating and filling the zip_copy column
ALTER TABLE meat_poultry_egg_inspect 
ADD COLUMN zip_copy varchar(5);

UPDATE meat_poultry_egg_inspect
SET zip_copy = zip;

-- States with zip length less than 5
SELECT DISTINCT st, length(zip)
FROM meat_poultry_egg_inspect
WHERE length(zip) < 5;

-- 9-16: Modifying codes in the zip column missing two leading zeros
UPDATE meat_poultry_egg_inspect
SET zip = '00' || zip -- concatenate the string 00 and the existing content of the zip column
WHERE st IN('PR','VI') AND length(zip) = 3;

-- 9-17: Modifying codes in the zip column missing one leading zero
UPDATE meat_poultry_egg_inspect
SET zip = '0' || zip
WHERE st IN('CT','MA','ME','NH','NJ','RI','VT') AND length(zip) = 4;

-- Before modifying
SELECT length(zip_copy), count(*)
FROM meat_poultry_egg_inspect
GROUP BY length(zip_copy);

-- After modifying
SELECT length(zip), count(*)
FROM meat_poultry_egg_inspect
GROUP BY length(zip);

-- Updating Values Across Tables
-- 9-18: Creating and filling a state_regions table
CREATE TABLE state_regions (
	st varchar(2) CONSTRAINT st_key PRIMARY KEY,
	region varchar(20) NOT NULL
);

COPY state_regions 
FROM 'C:/Users/QDS/PostgreSQL_Projects/state_regions.csv' 
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- 9-19: Adding and updating an inspection_date column
ALTER TABLE meat_poultry_egg_inspect 
ADD COLUMN inspection_date date;

-- This query will update the inspection_date for all records in the meat_poultry_egg_inspect table where the st matches a state in the state_regions table, and the region for that state is 'New England'.
UPDATE meat_poultry_egg_inspect inspect
SET inspection_date = '2019-12-01'
WHERE EXISTS (SELECT state_regions.region
			FROM state_regions
			WHERE inspect.st = state_regions.st AND state_regions.region = 'New England');

-- 9-20: Viewing updated inspection_date values
SELECT st, inspection_date
FROM meat_poultry_egg_inspect
GROUP BY st, inspection_date
ORDER BY st;

-- Deleting Unnecessary Data
-- Deleting Rows from a Table
-- delete all rows from a table
DELETE FROM table_name;

-- 9-21: Deleting rows matching an expression
DELETE FROM meat_poultry_egg_inspect
WHERE st IN('PR','VI');

-- Deleting a Column from a Table
-- 9-22: Removing a column from a table using DROP
ALTER TABLE meat_poultry_egg_inspect 
DROP COLUMN zip_copy;

-- Deleting a Table from a Database
-- 9-23: Removing a table from a database using DROP
DROP TABLE meat_poultry_egg_inspect_backup;

-- Using Transaction Blocks to Save or Revert Changes
-- START TRANSACTION signals the start of the transaction block. In PostgreSQL, you can also use the non-ANSI SQL BEGIN keyword.
-- COMMIT signals the end of the block and saves all changes.
-- ROLLBACK signals the end of the block and reverts all changes.
-- 9-24: Demonstrating a transaction block
START TRANSACTION;
UPDATE meat_poultry_egg_inspect
SET company = 'AGRO Merchantss Oakland LLC' -- mistake "ss"
WHERE company = 'AGRO Merchants Oakland, LLC';

SELECT company
FROM meat_poultry_egg_inspect
WHERE company LIKE 'AGRO%'
ORDER BY company;

ROLLBACK;

-- Improving Performance When Updating Large Tables
/* Instead of adding a column and filling it with values, we can save disk
space by copying the entire table and adding a populated column during the
operation. Then, we rename the tables so the copy replaces the original, and
the original becomes a backup.*/

-- 9-25: Backing up a table while adding and filling a new column
CREATE TABLE meat_poultry_egg_inspect_backup AS
	SELECT *,
		'2018-02-07'::date AS reviewed_date
	FROM meat_poultry_egg_inspect;

SELECT * FROM meat_poultry_egg_inspect_backup LIMIT 3;

-- 9-26: Swapping table names using ALTER TABLE
ALTER TABLE meat_poultry_egg_inspect RENAME TO meat_poultry_egg_inspect_temp;
ALTER TABLE meat_poultry_egg_inspect_backup RENAME TO meat_poultry_egg_inspect;
ALTER TABLE meat_poultry_egg_inspect_temp RENAME TO meat_poultry_egg_inspect_backup;


-- 10. STATISTICAL FUNCTIONS IN SQL


-- Creating a Census Stats Table
-- 10-1: Creating the Census 2011–2015 ACS 5-Year stats table and import data
CREATE TABLE acs_2011_2015_stats (
	geoid varchar(14) CONSTRAINT geoid_key PRIMARY KEY,
	county varchar(50) NOT NULL,
	st varchar(20) NOT NULL,
	pct_travel_60_min numeric(5,3) NOT NULL, -- percentage of workers who commute more than 60 minutes to work.
	pct_bachelors_higher numeric(5,3) NOT NULL, -- The percentage of people whose level of education is a bachelor’s degree or higher.
	pct_masters_higher numeric(5,3) NOT NULL, -- The percentage of people whose level of education is a master’s degree or higher.
	median_hh_income integer, -- The county’s median household income in 2015 inflationa djusted dollars. 
	CHECK (pct_masters_higher <= pct_bachelors_higher)
);

COPY acs_2011_2015_stats 
FROM 'C:/Users/QDS/PostgreSQL_Projects/acs_2011_2015_stats.csv' 
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM acs_2011_2015_stats;

-- Measuring Correlation with corr(Y, X)
/*
0				No relationship
.01 to .29 		Weak relationship
.3 to .59 		Moderate relationship
.6 to .99 		Strong to nearly perfect relationship
1 				Perfect relationship
*/
-- 10-2: Using corr(Y, X) to measure the relationship between education and income
SELECT corr(median_hh_income, pct_bachelors_higher) AS bachelors_income_r
FROM acs_2011_2015_stats;

-- Checking Additional Correlations
-- 10-3: Using corr(Y, X) on additional variables
SELECT
	round(corr(median_hh_income, pct_bachelors_higher)::numeric, 2) AS bachelors_income_r,
	round(corr(pct_travel_60_min, median_hh_income)::numeric, 2) AS income_travel_r,
	round(corr(pct_travel_60_min, pct_bachelors_higher)::numeric, 2) AS bachelors_travel_r
FROM acs_2011_2015_stats;

-- Predicting Values with Regression Analysis
-- 10-4: Regression slope and intercept functions
SELECT
	round(regr_slope(median_hh_income, pct_bachelors_higher)::numeric, 2) AS slope,
	round(regr_intercept(median_hh_income, pct_bachelors_higher)::numeric, 2) AS y_intercept
FROM acs_2011_2015_stats;

-- Finding the Effect of an Independent Variable with rsquared
/* An r-squared value is between zero and one and indicates the
percentage of the variation that is explained by the independent variable. */
-- 10-5: Calculating the coefficient of determination, or r-squared
SELECT round(regr_r2(median_hh_income, pct_bachelors_higher)::numeric, 3) AS r_squared
FROM acs_2011_2015_stats;

-- Creating Rankings with SQL
-- Ranking with rank() and dense_rank()
-- rank() includes a gap in the rank order, but dense_rank() does not. 
-- 10-6: Using the rank() and dense_rank() window functions
CREATE TABLE widget_companies (
	id bigserial,
	company varchar(30) NOT NULL,
	widget_output integer NOT NULL
);

INSERT INTO widget_companies (company, widget_output)
VALUES
	('Morse Widgets', 125000),
	('Springfield Widget Masters', 143000),
	('Best Widgets', 196000),
	('Acme Inc.', 133000),
	('District Widget Inc.', 201000),
	('Clarke Amalgamated', 620000),
	('Stavesacre Industries', 244000),
	('Bowers Widget Emporium', 201000);
	
SELECT
	company,
	widget_output,
	rank() OVER (ORDER BY widget_output DESC),
	dense_rank() OVER (ORDER BY widget_output DESC)
FROM widget_companies;

-- Ranking Within Subgroups with PARTITION BY
-- 10-7: Applying rank() within groups using PARTITION BY
CREATE TABLE store_sales (
	store varchar(30),
	category varchar(30) NOT NULL,
	unit_sales bigint NOT NULL,
	CONSTRAINT store_category_key PRIMARY KEY (store, category)
);

INSERT INTO store_sales (store, category, unit_sales)
VALUES
	('Broders', 'Cereal', 1104),
	('Wallace', 'Ice Cream', 1863),
	('Broders', 'Ice Cream', 2517),
	('Cramers', 'Ice Cream', 2112),
	('Broders', 'Beer', 641),
	('Cramers', 'Cereal', 1003),
	('Cramers', 'Beer', 640),
	('Wallace', 'Cereal', 980),
	('Wallace', 'Beer', 988);
	
SELECT
	category,
	store,
	unit_sales,
	rank() OVER (PARTITION BY category ORDER BY unit_sales DESC)
FROM store_sales;

-- Calculating Rates for Meaningful Comparisons
-- 10-8: Creating and filling a 2015 FBI crime data table
CREATE TABLE fbi_crime_data_2015 (
	st varchar(20),
	city varchar(50),
	population integer,
	violent_crime integer,
	property_crime integer,
	burglary integer,
	larceny_theft integer,
	motor_vehicle_theft integer,
	CONSTRAINT st_city_key PRIMARY KEY (st, city)
);

COPY fbi_crime_data_2015 
FROM 'C:/Users/QDS/PostgreSQL_Projects/fbi_crime_data_2015.csv' 
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * 
FROM fbi_crime_data_2015
ORDER BY population DESC;

-- 10-9: Finding property crime rates per thousand in cities with 500,000 or more people
SELECT city,
	st,
	population,
	property_crime,
	round((property_crime::numeric / population) * 1000, 1) AS pc_per_1000
FROM fbi_crime_data_2015
WHERE population >= 500000
ORDER BY (property_crime::numeric / population) DESC;


-- 11. WORKING WITH DATES AND TIMES


-- Data Types and Functions for Dates and Times
-- Manipulating Dates and Times
-- Extracting the Components of a timestamp Value
-- 11-1: Extracting components of a timestamp value using date_part()
SELECT
	date_part('year', '2019-12-01 18:37:12 EST'::timestamptz) AS "year",
	date_part('month', '2019-12-01 18:37:12 EST'::timestamptz) AS "month",
	date_part('day', '2019-12-01 18:37:12 EST'::timestamptz) AS "day",
	date_part('hour', '2019-12-01 18:37:12 EST'::timestamptz) AS "hour",
	date_part('minute', '2019-12-01 18:37:12 EST'::timestamptz) AS "minute",
	date_part('seconds', '2019-12-01 18:37:12 EST'::timestamptz) AS "seconds",
	date_part('timezone_hour', '2019-12-01 18:37:12 EST'::timestamptz) AS "tz",
	date_part('week', '2019-12-01 18:37:12 EST'::timestamptz) AS "week",
	date_part('quarter', '2019-12-01 18:37:12 EST'::timestamptz) AS "quarter",
	date_part('epoch', '2019-12-01 18:37:12 EST'::timestamptz) AS "epoch";

-- Alternately,
SELECT extract('year' from '2019-12-01 18:37:12 EST'::timestamptz);

-- Creating Datetime Values from timestamp Components
-- 11-2: Three functions for making datetimes from components
SELECT make_date(2018, 2, 22);
SELECT make_time(18, 4, 30.3);
SELECT make_timestamptz(2018, 2, 22, 18, 4, 30.3, 'Europe/Lisbon');

-- Retrieving the Current Date and Time
-- 11-3: Comparing current_timestamp and clock_timestamp() during row insert
CREATE TABLE current_time_example (
	time_id bigserial,
	current_timestamp_col timestamp with time zone,
	clock_timestamp_col timestamp with time zone
);

INSERT INTO current_time_example (current_timestamp_col, clock_timestamp_col)
	(SELECT current_timestamp, -- the time in the current_timestamp_col is the same for all rows
			clock_timestamp() -- the time in clock_timestamp_col increases with each row inserted
	FROM generate_series(1,1000));

SELECT * FROM current_time_example;

-- Working with Time Zones
-- Finding Your Time Zone Setting
-- 11-4: Showing your PostgreSQL server’s default time zone
SHOW timezone;

-- 11-5: Showing time zone abbreviations and names
SELECT * FROM pg_timezone_abbrevs;
SELECT * FROM pg_timezone_names;

-- Look up specific location names or time zones
SELECT * 
FROM pg_timezone_names
WHERE name LIKE 'Europe%';

-- Setting the Time Zone
-- 11-6: Setting the time zone for a client session
SET timezone TO 'US/Pacific';

CREATE TABLE time_zone_test (
	test_date timestamp with time zone
);

INSERT INTO time_zone_test 
VALUES ('2020-01-01 4:00');

SELECT test_date
FROM time_zone_test;

SET timezone TO 'US/Eastern';

SELECT test_date
FROM time_zone_test;

SELECT test_date AT TIME ZONE 'Asia/Seoul'
FROM time_zone_test;

-- Calculations with Dates and Times
-- subtract one date from another date to get an integer that represents the difference in days between the two dates
SELECT '9/30/1929'::date - '9/27/1929'::date;

-- add a time interval to a date to return a new date
SELECT '9/30/1929'::date + '5 years'::interval;

-- Finding Patterns in New York City Taxi Data
-- 11-7: Creating a table and importing NYC yellow taxi data
CREATE TABLE nyc_yellow_taxi_trips_2016_06_01 (
	trip_id bigserial PRIMARY KEY,
	vendor_id varchar(1) NOT NULL,
	tpep_pickup_datetime timestamp with time zone NOT NULL,
	tpep_dropoff_datetime timestamp with time zone NOT NULL,
	passenger_count integer NOT NULL,
	trip_distance numeric(8,2) NOT NULL,
	pickup_longitude numeric(18,15) NOT NULL,
	pickup_latitude numeric(18,15) NOT NULL,
	rate_code_id varchar(2) NOT NULL,
	store_and_fwd_flag varchar(1) NOT NULL,
	dropoff_longitude numeric(18,15) NOT NULL,
	dropoff_latitude numeric(18,15) NOT NULL,
	payment_type varchar(1) NOT NULL,
	fare_amount numeric(9,2) NOT NULL,
	extra numeric(9,2) NOT NULL,
	mta_tax numeric(5,2) NOT NULL,
	tip_amount numeric(9,2) NOT NULL,
	tolls_amount numeric(9,2) NOT NULL,
	improvement_surcharge numeric(9,2) NOT NULL,
	total_amount numeric(9,2) NOT NULL
);

COPY nyc_yellow_taxi_trips_2016_06_01 (
	vendor_id,
	tpep_pickup_datetime,
	tpep_dropoff_datetime,
	passenger_count,
	trip_distance,
	pickup_longitude,
	pickup_latitude,
	rate_code_id,
	store_and_fwd_flag,
	dropoff_longitude,
	dropoff_latitude,
	payment_type,
	fare_amount,
	extra,
	mta_tax,
	tip_amount,
	tolls_amount,
	improvement_surcharge,
	total_amount
)
FROM 'C:/Users/QDS/PostgreSQL_Projects/yellow_tripdata_2016_06_01.csv'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

SELECT * FROM nyc_yellow_taxi_trips_2016_06_01 LIMIT 100;

SELECT count(*) FROM nyc_yellow_taxi_trips_2016_06_01;

CREATE INDEX tpep_pickup_idx
ON nyc_yellow_taxi_trips_2016_06_01 (tpep_pickup_datetime);

-- The Busiest Time of Day
-- 11-8: Counting taxi trips by hour
SET timezone TO 'US/Eastern';

SELECT
	date_part('hour', tpep_pickup_datetime) AS trip_hour,
	count(*)
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY trip_hour
ORDER BY trip_hour;

-- Exporting to CSV for Visualization in Excel
-- 11-9: Exporting taxi pickups per hour to a CSV file
\COPY (
    SELECT
        date_part('hour', tpep_pickup_datetime) AS trip_hour,
        count(*)
    FROM nyc_yellow_taxi_trips_2016_06_01
    GROUP BY trip_hour
    ORDER BY trip_hour
) TO 'C:/Users/QDS/PostgreSQL_Projects/hourly_pickups_2016_06_01.txt'
WITH (FORMAT CSV, HEADER, DELIMITER ',');

-- When Do Trips Take the Longest?
-- 11-10: Calculating median trip time by hour
SELECT
	date_part('hour', tpep_pickup_datetime) AS trip_hour,
	percentile_cont(.5) WITHIN GROUP (ORDER BY	tpep_dropoff_datetime - tpep_pickup_datetime) AS median_trip
FROM nyc_yellow_taxi_trips_2016_06_01
GROUP BY trip_hour
ORDER BY trip_hour;

-- Finding Patterns in Amtrak Data
-- 11-11: Creating a table to hold train trip data
SET timezone TO 'US/Central';

CREATE TABLE train_rides (
	trip_id bigserial PRIMARY KEY,
	segment varchar(50) NOT NULL,
	departure timestamp with time zone NOT NULL,
	arrival timestamp with time zone NOT NULL
);

INSERT INTO train_rides (segment, departure, arrival)
VALUES
	('Chicago to New York', '2017-11-13 21:30 CST', '2017-11-14 18:23 EST'),
	('New York to New Orleans', '2017-11-15 14:15 EST', '2017-11-16 19:32 CST'),
	('New Orleans to Los Angeles', '2017-11-17 13:45 CST', '2017-11-18 9:00 PST'),
	('Los Angeles to San Francisco', '2017-11-19 10:10 PST', '2017-11-19 21:24 PST'),
	('San Francisco to Denver', '2017-11-20 9:10 PST', '2017-11-21 18:38 MST'),
	('Denver to Chicago', '2017-11-22 19:10 MST', '2017-11-23 14:50 CST');
	
SELECT * FROM train_rides;

-- 11-12: Calculating the length of each trip segment
SELECT segment,
	-- the to_char() function turns the departure timestamp column into a string of characters formatted as YYYY-MM-DD HH12:MI a.m. TZ
	to_char(departure, 'YYYY-MM-DD HH12:MI a.m. TZ') AS departure,
	arrival - departure AS segment_time
FROM train_rides;

-- Calculating Cumulative Trip Time
-- 11-13: Calculating cumulative intervals using OVER
SELECT segment,
	arrival - departure AS segment_time,
	-- computes a cumulative total of the segment_time for all segments, ordered by trip_id
	sum(arrival - departure) OVER (ORDER BY trip_id) AS cume_time 
FROM train_rides;

-- 11-14: Better formatting for cumulative trip time
SELECT segment,
	arrival - departure AS segment_time,
	-- extract the number of seconds elapsed between the arrival and departure intervals. 
	-- Then we multiply each sum with an interval of 1 second to convert those seconds to an interval value.
	sum(date_part('epoch', (arrival - departure))) OVER (ORDER BY trip_id) * interval '1 second' AS cume_time
FROM train_rides;


-- 12. ADVANCED QUERY TECHNIQUES


-- Using Subqueries
-- Filtering with Subqueries in a WHERE Clause
-- Generating Values for a Query Expression
-- 12-1: Using a subquery in a WHERE clause
SELECT geo_name,
	state_us_abbreviation,
	p0010001
FROM us_counties_2010
WHERE p0010001 >= (
					SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
					FROM us_counties_2010
					)
ORDER BY p0010001 DESC;

-- Using a Subquery to Identify Rows to Delete
-- 12-2: Using a subquery in a WHERE clause with DELETE
CREATE TABLE us_counties_2010_top10 AS
	SELECT * FROM us_counties_2010;
	
DELETE FROM us_counties_2010_top10
WHERE p0010001 < (
					SELECT percentile_cont(.9) WITHIN GROUP (ORDER BY p0010001)
					FROM us_counties_2010_top10
					);

SELECT count(*) FROM us_counties_2010_top10;

-- Creating Derived Tables with Subqueries
-- 12-3: Subquery as a derived table in a FROM clause
SELECT round(calcs.average, 0) AS average,
	calcs.median,
	round(calcs.average - calcs.median, 0) AS median_average_diff
FROM (
	SELECT avg(p0010001) AS average,
		percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001)::numeric(10,1) AS median
	FROM us_counties_2010
	) AS calcs;

-- Joining Derived Tables
-- 12-4: Joining two derived tables
SELECT census.state_us_abbreviation AS st,
	census.st_population,
	plants.plant_count,
	round((plants.plant_count/census.st_population::numeric(10,1))*1000000, 1) AS plants_per_million
FROM
	(
	SELECT st,
		count(*) AS plant_count
	FROM meat_poultry_egg_inspect
	GROUP BY st
	) AS plants
JOIN
	(
	SELECT state_us_abbreviation,
		sum(p0010001) AS st_population
	FROM us_counties_2010
	GROUP BY state_us_abbreviation
	) AS census
ON plants.st = census.state_us_abbreviation
ORDER BY plants_per_million DESC;

-- Generating Columns with Subqueries
-- 12-5: Adding a subquery to a column list
SELECT geo_name,
	state_us_abbreviation AS st,
	p0010001 AS total_pop,
	-- adding us_median column, saame vaalue for all rows
	(SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010) AS us_median
FROM us_counties_2010;

-- 12-6: Using a subquery expression in a calculation
SELECT geo_name,
	state_us_abbreviation AS st,
	p0010001 AS total_pop,
	(SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010) AS us_median,
	-- adding diff_from_median column
	p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010) AS diff_from_median
FROM us_counties_2010
WHERE (p0010001 - (SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) FROM us_counties_2010)) BETWEEN -1000 AND 1000;

-- Subquery Expressions
-- Generating Values for the IN Operator
SELECT first_name, last_name
FROM employees
WHERE id IN (
			SELECT id
			FROM retirees);

-- Checking Whether Values Exist
SELECT first_name, last_name
FROM employees
WHERE EXISTS (
			SELECT id
			FROM retirees);

SELECT first_name, last_name
FROM employees
WHERE EXISTS (
			SELECT id
			FROM retirees
			WHERE id = employees.id);

-- Common Table Expressions (CTE)
-- 12-7: Using a simple CTE to find large counties
WITH large_counties (geo_name, st, p0010001)
AS
	(
	SELECT geo_name, state_us_abbreviation, p0010001
	FROM us_counties_2010
	WHERE p0010001 >= 100000
	)

SELECT st, count(*)
FROM large_counties
GROUP BY st
ORDER BY count(*) DESC;

-- Without CTE,
SELECT state_us_abbreviation, count(*)
FROM us_counties_2010
WHERE p0010001 >= 100000
GROUP BY state_us_abbreviation
ORDER BY count(*) DESC;

-- 12-8: Using CTEs in a table join
WITH counties (st, population) 
AS
	(
	SELECT state_us_abbreviation, sum(population_count_100_percent)
	FROM us_counties_2010
	GROUP BY state_us_abbreviation
	),
plants (st, plants)
AS
	(
	SELECT st, count(*) AS plants
	FROM meat_poultry_egg_inspect
	GROUP BY st
	)

SELECT counties.st,
	population,
	plants,
	round((plants/population::numeric(10,1)) * 1000000, 1) AS per_million
FROM counties 
	JOIN plants ON counties.st = plants.st
ORDER BY per_million DESC;

-- 12-9: Using CTEs to minimize redundant code
WITH us_median 
AS
	(
	SELECT percentile_cont(.5) WITHIN GROUP (ORDER BY p0010001) AS us_median_pop
	FROM us_counties_2010
	)
	
SELECT geo_name,
	state_us_abbreviation AS st,
	p0010001 AS total_pop,
	us_median_pop,
	p0010001 - us_median_pop AS diff_from_median
FROM us_counties_2010 CROSS JOIN us_median
WHERE (p0010001 - us_median_pop) BETWEEN -1000 AND 1000;

-- Cross Tabulations, also called pivot tables or crosstabs
-- Installing the crosstab() Function
CREATE EXTENSION tablefunc;

-- Tabulating Survey Results
-- 12-10: Creating and filling the ice_cream_survey table
CREATE TABLE ice_cream_survey (
	response_id integer PRIMARY KEY,
	office varchar(20),
	flavor varchar(20)
);

COPY ice_cream_survey 
FROM 'C:/Users/QDS/PostgreSQL_Projects/ice_cream_survey.csv' 
WITH (FORMAT CSV, HEADER);

SELECT *
FROM ice_cream_survey
LIMIT 5;

-- 12-11: Generating the ice cream survey crosstab
SELECT *
FROM crosstab('SELECT office, -- supplies the row names for the crosstab
					flavor, -- supplies the category columns
					count(*) -- supplies the values for each cell where row and column intersect
				FROM ice_cream_survey
				GROUP BY office, flavor
				ORDER BY office',
				
				'SELECT flavor -- produces the set of category names for the columns
				FROM ice_cream_survey
				GROUP BY flavor
				ORDER BY flavor')
AS (office varchar(20),
	chocolate bigint,
	strawberry bigint,
	vanilla bigint);

-- Tabulating City Temperature Readings
-- 12-12: Creating and filling a temperature_readings table
CREATE TABLE temperature_readings (
	reading_id bigserial,
	station_name varchar(50),
	observation_date date,
	max_temp integer,
	min_temp integer
);

COPY temperature_readings (station_name, observation_date, max_temp, min_temp)
FROM 'C:/Users/QDS/PostgreSQL_Projects/temperature_readings.csv'
WITH (FORMAT CSV, HEADER);

-- 12-13: Generating the temperature readings crosstab
SELECT *
FROM crosstab('SELECT station_name,
					date_part(''month'', observation_date),
					percentile_cont(.5) WITHIN GROUP (ORDER BY max_temp)
				FROM temperature_readings
				GROUP BY station_name, date_part(''month'', observation_date)
				ORDER BY station_name',
				
				'SELECT month
				FROM generate_series(1,12) month')
AS (station varchar(50),
	jan numeric(3,0),
	feb numeric(3,0),
	mar numeric(3,0),
	apr numeric(3,0),
	may numeric(3,0),
	jun numeric(3,0),
	jul numeric(3,0),
	aug numeric(3,0),
	sep numeric(3,0),
	oct numeric(3,0),
	nov numeric(3,0),
	dec numeric(3,0)
);

-- Reclassifying Values with CASE
-- 12-14: Reclassifying temperature data with CASE
SELECT max_temp,
	CASE WHEN max_temp >= 90 THEN 'Hot'
		WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
		WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
		WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
		WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
		ELSE 'Inhumane'
	END AS temperature_group
FROM temperature_readings;

-- Using CASE in a Common Table Expression
-- 12-15: Using CASE in a CTE
WITH temps_collapsed (station_name, max_temperature_group) 
AS
	(
	SELECT station_name,
		CASE WHEN max_temp >= 90 THEN 'Hot'
			WHEN max_temp BETWEEN 70 AND 89 THEN 'Warm'
			WHEN max_temp BETWEEN 50 AND 69 THEN 'Pleasant'
			WHEN max_temp BETWEEN 33 AND 49 THEN 'Cold'
			WHEN max_temp BETWEEN 20 AND 32 THEN 'Freezing'
			ELSE 'Inhumane'
		END
	FROM temperature_readings
	)

SELECT station_name, max_temperature_group, count(*)
FROM temps_collapsed
GROUP BY station_name, max_temperature_group
ORDER BY station_name, count(*) DESC;


-- 13. MINING TEXT TO FIND MEANINGFUL DATA


-- Formatting Text Using String Functions
-- Case Formatting
SELECT upper('Neal7');
SELECT lower('Randy');
SELECT initcap('at the end of the day');
-- Note initcap's imperfect for acronyms
SELECT initcap('Practical SQL');

-- Character Information
SELECT char_length(' Pat ');
SELECT length(' Pat ');
SELECT position(', ' in 'Tan, Bella');

-- Removing Characters
SELECT trim('s' from 'socks');
SELECT trim(trailing 's' from 'socks');
SELECT trim(' Pat ');
SELECT char_length(trim(' Pat ')); -- note the length change
SELECT ltrim('socks', 's');
SELECT rtrim('socks', 's');

-- Extracting and Replacing Characters
SELECT left('703-555-1212', 3);
SELECT right('703-555-1212', 8);
SELECT replace('bat', 'b', 'c');

-- Matching Text Patterns with Regular Expressions
/*
. 		A dot is a wildcard that finds any character except a newline.
[FGz] 	Any character in the square brackets. Here, F, G, or z.
[a-z] 	A range of characters. Here, lowercase a to z.
[^a-z] 	The caret negates the match. Here, not lowercase a to z.
\w 		Any word character or underscore. Same as [A-Za-z0-9_].
\d 		Any digit.
\s 		A space.
\t 		Tab character.
\n 		Newline character.
\r 		Carriage return character.
^ 		Match at the start of a string.
$ 		Match at the end of a string.
? 		Get the preceding match zero or one time.
* 		Get the preceding match zero or more times.
+ 		Get the preceding match one or more times.
{m} 	Get the preceding match exactly m times.
{m,n} 	Get the preceding match between m and n times.
a|b 	The pipe denotes alternation. Find either a or b.
( ) 	Create and report a capture group or set precedence.
(?: ) 	Negate the reporting of a capture group.
*/

-- Regular Expression Matching Examples
--  Sentence “The game starts at 7 p.m. on May 2, 2019.”
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '.+');
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{1,2} (?:a.m.|p.m.)');
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '^\w+');
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\w+.$');
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from 'May|June');
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from '\d{4}');
SELECT substring('The game starts at 7 p.m. on May 2, 2019.' from 'May \d, \d{4}');

-- Turning Text to Data with Regular Expression Functions
-- 13-1: Crime reports text
*/
4/16/17-4/17/17
2100-0900 hrs.
46000 Block Ashmere Sq.
Sterling
Larceny: The victim reported that a
bicycle was stolen from their opened
garage door during the overnight hours.
C0170006614

04/10/17
1605 hrs.
21800 block Newlin Mill Rd.
Middleburg
Larceny: A license plate was reported
stolen from a vehicle.
SO170006250
*/

-- Creating a Table for Crime Reports
-- 13-2: Creating and loading the crime_reports table
CREATE TABLE crime_reports (
	crime_id bigserial PRIMARY KEY,
	date_1 timestamp with time zone,
	date_2 timestamp with time zone,
	street varchar(250),
	city varchar(100),
	crime_type varchar(100),
	description text,
	case_number varchar(50),
	original_text text NOT NULL
);

COPY crime_reports (original_text) 
FROM 'C:/Users/QDS/PostgreSQL_Projects/crime_reports.csv' 
WITH (FORMAT CSV, HEADER OFF, QUOTE '"');

SELECT original_text FROM crime_reports;

-- Matching Crime Report Date Patterns
-- 13-3: Using regexp_match() to find the first date. 
-- regexp_match() returns the first match it finds by default
SELECT crime_id,
	regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;

-- Matching the Second Date When Present
-- 13-4: Using the regexp_matches() function with the 'g' flag
SELECT crime_id,
	regexp_matches(original_text, '\d{1,2}\/\d{1,2}\/\d{2}', 'g')
FROM crime_reports;

-- 13-5: Using regexp_match() to find the second date
SELECT crime_id,
	regexp_match(original_text, '-\d{1,2}\/\d{1,2}\/\d{2}')
FROM crime_reports;

-- 13-6: Using a capture group to return only the date
SELECT crime_id,
regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})')
FROM crime_reports;

-- Matching Additional Crime Report Elements
-- 13-7: Matching case number, date, crime type, and city
SELECT
	regexp_match(original_text, '(?:C0|SO)[0-9]+') AS case_number,
	regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}') AS date_1,
	regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):') AS crime_type,
	regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n') AS city
FROM crime_reports;

-- Extracting Text from the regexp_match() Result
-- 13-8: Retrieving a value from within an array
SELECT
	crime_id,
	(regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1] AS case_number
FROM crime_reports;

-- Updating the crime_reports Table with Extracted Data
-- 13-9: Updating the crime_reports date_1 column
UPDATE crime_reports
SET date_1 =
	(
		(regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] || ' ' ||
		(regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] ||' US/Eastern'
	 )::timestamptz;
		 
SELECT crime_id,
	date_1,
	original_text
FROM crime_reports;

-- Using CASE to Handle Special Instances
-- 13-10: Updating all crime_reports columns
UPDATE crime_reports
SET date_1 = 
    (
		(regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] || ' ' ||
	    (regexp_match(original_text, '\/\d{2}\n(\d{4})'))[1] ||' US/Eastern'
    )::timestamptz,
             
    date_2 = 
    CASE 
    -- if there is no second date but there is a second hour
        WHEN (SELECT regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})') IS NULL)
              AND (SELECT regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL)
        THEN 
          (
		  	(regexp_match(original_text, '\d{1,2}\/\d{1,2}\/\d{2}'))[1] || ' ' ||
          	(regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1] ||' US/Eastern'
          )::timestamptz 

    -- if there is both a second date and second hour
        WHEN (SELECT regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})') IS NOT NULL)
              AND (SELECT regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})') IS NOT NULL)
        THEN 
          (
		  	(regexp_match(original_text, '-(\d{1,2}\/\d{1,2}\/\d{1,2})'))[1] || ' ' ||
          	(regexp_match(original_text, '\/\d{2}\n\d{4}-(\d{4})'))[1] ||' US/Eastern'
          )::timestamptz
		
    -- if neither of those conditions exist, provide a NULL
        ELSE NULL 
    END,
    street = (regexp_match(original_text, 'hrs.\n(\d+ .+(?:Sq.|Plz.|Dr.|Ter.|Rd.))'))[1],
    city = (regexp_match(original_text, '(?:Sq.|Plz.|Dr.|Ter.|Rd.)\n(\w+ \w+|\w+)\n'))[1],
    crime_type = (regexp_match(original_text, '\n(?:\w+ \w+|\w+)\n(.*):'))[1],
    description = (regexp_match(original_text, ':\s(.+)(?:C0|SO)'))[1],
    case_number = (regexp_match(original_text, '(?:C0|SO)[0-9]+'))[1];

-- 13-11: Viewing selected crime data
SELECT date_1,
	date_2,
	street,
	city,
	crime_type,
	description,
	case_number
FROM crime_reports;

-- Using Regular Expressions with WHERE
/*
We use a tilde (~) to make a case-sensitive match on a regular expression
and a tilde-asterisk (~*) to perform a case-insensitive match. You can negate
either expression by adding an exclamation point in front
*/
-- 13-12: Using regular expressions in a WHERE clause
SELECT geo_name
FROM us_counties_2010
-- find any county names that contain either the letters lade or lare between other characters
WHERE geo_name ~* '(.+lade.+|.+lare.+)'
ORDER BY geo_name;

SELECT geo_name
FROM us_counties_2010
-- find county names containing the letters ash but excluding those starting with Wash
WHERE geo_name ~* '.+ash.+' AND geo_name !~ 'Wash.+'
ORDER BY geo_name;

-- Additional Regular Expression Functions
-- 13-13: Regular expression functions to replace and split text
-- The regexp_replace(string, pattern, replacement text) 
SELECT regexp_replace('05/12/2018', '\d{4}', '2017');

-- The regexp_split_to_table(string, pattern) function splits delimited text into rows. 
SELECT regexp_split_to_table('Four,score,and,seven,years,ago', ',');

-- The regexp_split_to_array(string, pattern) function splits delimited text into an array
SELECT regexp_split_to_array('Phil Mike Tony Steve', ' ');

-- 13-14: Finding an array length
-- The array_length(array anyarray, dimension integer) function returns the length of an array
-- This function works for arrays of any data type
SELECT array_length(regexp_split_to_array('Phil Mike Tony Steve', ' '), 1);

-- Full Text Search in PostgreSQL
-- Text Search Data Types
-- The tsvector data type represents the text to be searched and to be stored in an optimized form
-- The tsquery data type represents the search query terms and operators
-- 13-15: Converting text to tsvector data
SELECT to_tsvector('I am walking across the sitting room to sit with you.');

-- Creating the Search Terms with tsquery
-- tsquery also provides operators (&, |, !, <->) for controlling the search 
-- 13-16: Converting search terms to tsquery data
SELECT to_tsquery('walking & sitting');

-- Using the @@ Match Operator for Searching
--  the double at sign (@@) match operator to check whether a query matches text
-- 13-17: Querying a tsvector type with a tsquery
-- returns true because both walking and sitting are present in the text converted by to_tsvector()
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & sitting');

-- returns false because both walking and running are not present in the text
SELECT to_tsvector('I am walking across the sitting room') @@ to_tsquery('walking & running');

-- Creating a Table for Full Text Search
CREATE TABLE president_speeches (
	sotu_id serial PRIMARY KEY,
	president varchar(100) NOT NULL,
	title varchar(250) NOT NULL,
	speech_date date NOT NULL,
	speech_text text NOT NULL,
	search_speech_text tsvector
);

COPY president_speeches (president, title, speech_date, speech_text) 
FROM 'C:/Users/QDS/PostgreSQL_Projects/sotu-1946-1977.csv' 
WITH (FORMAT CSV, DELIMITER '|', HEADER OFF, QUOTE '@');

-- 13-19: Converting speeches to tsvector in the search_speech_text column
UPDATE president_speeches
SET search_speech_text = to_tsvector('english', speech_text);

-- 13-20: Creating a GIN index for text search
CREATE INDEX search_idx ON president_speeches USING gin(search_speech_text);

-- 13-21: Finding speeches containing the word Vietnam
SELECT president, speech_date
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam')
ORDER BY speech_date;

-- Showing Search Result Locations
-- To see where our search terms appear in text, we can use the ts_headline() function
-- 13-22: Displaying search results with ts_headline()
SELECT president,
	speech_date,
	ts_headline(speech_text, 
				to_tsquery('Vietnam'),
				'StartSel = <,
				StopSel = >,
				MinWords=5,
				MaxWords=7,
				MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('Vietnam');

-- Using Multiple Search Terms
-- Listing 13-23: Finding speeches with the word transportation but not roads
SELECT president,
       speech_date,
       ts_headline(speech_text, 
	   				to_tsquery('transportation & !roads'),
                   'StartSel = <,
                    StopSel = >,
                    MinWords=5,
                    MaxWords=7,
                    MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('transportation & !roads');

-- Searching for Adjacent Words
-- The distance (<->) operator to find adjacent words
-- 13-24: Finding speeches where defense follows military
SELECT president,
		speech_date,
		ts_headline(speech_text, 
					to_tsquery('military <-> defense'),
					'StartSel = <,
					StopSel = >,
					MinWords=5,
					MaxWords=7,
					MaxFragments=1')
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('military <-> defense');

-- Ranking Query Matches by Relevance
-- ts_rank(), generates a rank value based on how often the lexemes you’re searching for appear in the text. 
-- ts_rank_cd(), considers how close the lexemes searched are to each other
-- 13-25: Scoring relevance with ts_rank()
-- Uses ts_rank() to rank speeches containing all the words war, security, threat, and enemy
SELECT president,
	speech_date,
	ts_rank(search_speech_text, 
			to_tsquery('war & security & threat & enemy')) AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;

-- 13-26: Normalizing ts_rank() by speech length
SELECT president,
	speech_date,
	ts_rank(search_speech_text,
			-- optional code 2 instructs the function to divide the score by the length of the data in the search_speech_text column
			to_tsquery('war & security & threat & enemy'), 2)::numeric AS score
FROM president_speeches
WHERE search_speech_text @@ to_tsquery('war & security & threat & enemy')
ORDER BY score DESC
LIMIT 5;


-- 14. ANALYZING SPATIAL DATA WITH POSTGIS


-- 15. SAVING TIME WITH VIEWS, FUNCTIONS, AND TRIGGERS
-- Using Views to Simplify Queries
-- Creating and Querying Views
-- 15-1: Creating a view that displays Nevada 2010 counties
CREATE OR REPLACE VIEW nevada_counties_pop_2010 AS
SELECT geo_name,
	state_fips, -- fips is Federal Information Processing Standards
	county_fips,
	p0010001 AS pop_2010
FROM us_counties_2010
WHERE state_us_abbreviation = 'NV'
ORDER BY county_fips;

-- Delete a view
-- DROP VIEW nevada_counties_pop_2010;

-- 15-2: Querying the nevada_counties_pop_2010 view
SELECT *
FROM nevada_counties_pop_2010
LIMIT 5;


-- 15-3: Creating a view showing population change for U.S. counties
CREATE OR REPLACE VIEW county_pop_change_2010_2000 AS
SELECT c2010.geo_name,
	c2010.state_us_abbreviation AS st,
	c2010.state_fips,
	c2010.county_fips,
	c2010.p0010001 AS pop_2010,
	c2000.p0010001 AS pop_2000,
	round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001) / c2000.p0010001 * 100, 1 ) AS pct_change_2010_2000
FROM us_counties_2010 c2010 
	INNER JOIN us_counties_2000 c2000 ON c2010.state_fips = c2000.state_fips
										AND c2010.county_fips = c2000.county_fips
ORDER BY c2010.state_fips, c2010.county_fips;

-- 15-4: Selecting columns from the county_pop_change_2010_2000 view
SELECT geo_name,
	st,
	pop_2010,
	pct_change_2010_2000
FROM county_pop_change_2010_2000
WHERE st = 'NV'
LIMIT 5;

-- Inserting, Updating, and Deleting Data Using a View
-- Creating a View of Employees
SELECT * FROM employees;

-- 15-5: Creating a view on the employees table
CREATE OR REPLACE VIEW employees_tax_dept AS
SELECT emp_id,
	first_name,
	last_name,
	dept_id
FROM employees
WHERE dept_id = 1
ORDER BY emp_id
-- restrict inserts or updates to Tax Department employees only. 
-- rejects any insert or update in the underlying table that does not meet the criteria of the WHERE clause
WITH LOCAL CHECK OPTION;

SELECT * FROM employees_tax_dept;

-- Inserting Rows Using the employees_tax_dept View
/* After we add or change data using a view, the change is applied to the underlying
table, which in this case is employees */
-- 15-6: Successful and rejected inserts via the employees_tax_dept view
INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
VALUES ('Suzanne', 'Legere', 1);

INSERT INTO employees_tax_dept (first_name, last_name, dept_id)
VALUES ('Jamil', 'White', 2); -- The dept_id of 2 does not pass the LOCAL CHECK in the view

SELECT * FROM employees_tax_dept;

SELECT * FROM employees;

-- Updating Rows Using the employees_tax_dept View
/* The same restrictions on accessing data in an underlying table apply when
we make updates on data in the employees_tax_dept view*/
-- 15-7: Updating a row via the employees_tax_dept view
UPDATE employees_tax_dept
SET last_name = 'Le Gere'
WHERE emp_id = 5;

SELECT * FROM employees_tax_dept;

-- This will fail because the salary column is not in the view
UPDATE employees_tax_dept
SET salary = 100000
WHERE emp_id = 5;

-- Deleting Rows Using the employees_tax_dept View
-- 15-8: Deleting a row via the employees_tax_dept view
DELETE FROM employees_tax_dept
WHERE emp_id = 5;

-- Programming Your Own Functions
-- Creating the percent_change() Function
-- 15-9: Creating a percent_change() function
CREATE OR REPLACE FUNCTION percent_change(
											new_value numeric,
											old_value numeric,
											decimal_places integer DEFAULT 1
											)
RETURNS numeric AS
	'SELECT round(
					((new_value - old_value) / old_value) * 100, decimal_places
					);'
LANGUAGE SQL -- this function using plain SQL
IMMUTABLE -- function won’t be making any changes to the database, which can improve performance
RETURNS NULL ON NULL INPUT;

-- Using the percent_change() Function
-- 15-10: Testing the percent_change() function
SELECT percent_change(110, 108, 2);

-- 15-11: Testing percent_change() on census data
SELECT c2010.geo_name,
	c2010.state_us_abbreviation AS st,
	c2010.p0010001 AS pop_2010,
	percent_change(c2010.p0010001, c2000.p0010001) AS pct_chg_func,
	round( (CAST(c2010.p0010001 AS numeric(8,1)) - c2000.p0010001) / c2000.p0010001 * 100, 1 ) AS pct_chg_formula
FROM us_counties_2010 c2010 
	INNER JOIN us_counties_2000 c2000 ON c2010.state_fips = c2000.state_fips
										AND c2010.county_fips = c2000.county_fips
ORDER BY pct_chg_func DESC
LIMIT 5;

-- Updating Data with a Function
-- 15-12: Adding a column to the teachers table and seeing the data
ALTER TABLE teachers 
ADD COLUMN personal_days integer;

SELECT first_name,
	last_name,
	hire_date,
	personal_days
FROM teachers;

-- 15-13: Creating an update_personal_days() function
CREATE OR REPLACE FUNCTION update_personal_days()
RETURNS void AS -- function returns no data
	$$ --  to mark the start and end of the string that contains all the function’s commands
	BEGIN -- denote the function
	UPDATE teachers
	SET personal_days =
		CASE 
			WHEN (now() - hire_date) BETWEEN '5 years'::interval AND '10 years'::interval THEN 4
			WHEN (now() - hire_date) > '10 years'::interval THEN 5
			ELSE 3
		END;
	RAISE NOTICE 'personal_days updated!'; -- display a message in pgAdmin
	END;
	$$ 
LANGUAGE plpgsql; -- this function using PL/pgSQL.

SELECT update_personal_days();

-- Rerun 15-12 to see pesonal_days column updated
SELECT first_name,
	last_name,
	hire_date,
	personal_days
FROM teachers;

-- Automating Database Actions with Triggers
-- Logging Grade Updates to a Table
/*
1. A grades_history table to record the changes to grades in a grades table
2. A trigger to run a function every time a change occurs in the grades
table, which we’ll name grades_update
3. The function the trigger will execute; we’ll call this function
record_if_grade_changed()
*/
-- Creating Tables to Track Grades and Updates
-- 15-17: Creating the grades and grades_history tables
CREATE TABLE grades (
	student_id bigint,
	course_id bigint,
	course varchar(30) NOT NULL,
	grade varchar(5) NOT NULL,
	PRIMARY KEY (student_id, course_id)
);

INSERT INTO grades
VALUES
	(1, 1, 'Biology 2', 'F'),
	(1, 2, 'English 11B', 'D'),
	(1, 3, 'World History 11B', 'C'),
	(1, 4, 'Trig 2', 'B');
	
CREATE TABLE grades_history (
	student_id bigint NOT NULL,
	course_id bigint NOT NULL,
	change_time timestamp with time zone NOT NULL,
	course varchar(30) NOT NULL,
	old_grade varchar(5) NOT NULL,
	new_grade varchar(5) NOT NULL,
	PRIMARY KEY (student_id, course_id, change_time)
);

-- Creating the Function and Trigger
-- 15-18: Creating the record_if_grade_changed() function
CREATE OR REPLACE FUNCTION record_if_grade_changed()
RETURNS trigger AS
	$$
	BEGIN
		IF NEW.grade <> OLD.grade THEN
				INSERT INTO grades_history (
						student_id,
						course_id,
						change_time,
						course,
						old_grade,
						new_grade)
				VALUES
						(OLD.student_id,
						OLD.course_id,
						now(),
						OLD.course,
						OLD.grade,
						NEW.grade);
		END IF;
		RETURN NEW;
	END;
	$$ 
LANGUAGE plpgsql;

-- 15-19: Creating the grades_update trigger
CREATE TRIGGER grades_update
AFTER UPDATE -- the trigger to fire after the update occurs on the grades row
ON grades
FOR EACH ROW --  (default is FOR EACH STATEMENT)
EXECUTE PROCEDURE record_if_grade_changed(); -- the function the trigger should run

-- Testing the Trigger
SELECT * FROM grades_history; -- empty because we haven’t made any changes to the grades table yet

-- grade before update
 SELECT * FROM grades;

-- 15-20: Testing the grades_update trigger
UPDATE grades
SET grade = 'C'
WHERE student_id = 1 AND course_id = 1;

-- Check the results after update
SELECT student_id,
	change_time,
	course,
	old_grade,
	new_grade
FROM grades_history;

-- Automatically Classifying Temperatures
-- 15-21: Creating a temperature_test table
CREATE TABLE temperature_test (
	station_name varchar(50),
	observation_date date,
	max_temp integer,
	min_temp integer,
	max_temp_group varchar(40),
	PRIMARY KEY (station_name, observation_date)
);

-- 15-22: Creating the classify_max_temp() function
CREATE OR REPLACE FUNCTION classify_max_temp()
RETURNS trigger AS
	$$
	BEGIN
		CASE
			WHEN NEW.max_temp >= 90 THEN NEW.max_temp_group := 'Hot';
			WHEN NEW.max_temp BETWEEN 70 AND 89 THEN NEW.max_temp_group := 'Warm';
			WHEN NEW.max_temp BETWEEN 50 AND 69 THEN NEW.max_temp_group := 'Pleasant';
			WHEN NEW.max_temp BETWEEN 33 AND 49 THEN NEW.max_temp_group := 'Cold';
			WHEN NEW.max_temp BETWEEN 20 AND 32 THEN NEW.max_temp_group := 'Freezing';
			ELSE NEW.max_temp_group := 'Inhumane';
		END CASE;
		RETURN NEW;
	END;
	$$ 
LANGUAGE plpgsql;

-- 15-23: Creating the temperature_insert trigger
CREATE TRIGGER temperature_insert
BEFORE INSERT
ON temperature_test
FOR EACH ROW
EXECUTE PROCEDURE classify_max_temp();

-- 15-24: Inserting rows to test the temperature_insert trigger
INSERT INTO temperature_test (station_name, observation_date, max_temp, min_temp)
VALUES
	('North Station', '1/19/2019', 10, -3),
	('North Station', '3/20/2019', 28, 19),
	('North Station', '5/2/2019', 65, 42),
	('North Station', '8/9/2019', 93, 74);
	
SELECT * FROM temperature_test;


-- 16. USING POSTGRESQL FROM THE COMMAND LINE


-- 17. MAINTAINING YOUR DATABASE


-- Recovering Unused Space with VACUUM
-- Tracking Table Size
-- 17-1: Creating a table to test vacuuming
CREATE TABLE vacuum_test (
	integer_column integer
);

-- 17-2: Determining the size of vacuum_test
-- pg_size_pretty() converts bytes to a more easily understandable format in kilobytes, megabytes, or gigabytes.
-- pg_total_relation_size() function reports how many bytes a table, its indexes, and offline compressed data takes up
SELECT pg_size_pretty(
	pg_total_relation_size('vacuum_test')
); -- size of zero

-- Checking Table Size After Adding New Data
-- 17-3: Inserting 500,000 rows into vacuum_test
INSERT INTO vacuum_test
SELECT * FROM generate_series(1,500000);

-- Rerun 17-2, we got size of 17MB

-- Checking Table Size After Updates
-- 17-4: Updating all rows in vacuum_test
UPDATE vacuum_test
SET integer_column = integer_column + 1;

-- Rerun 17-2, we got size of 35MB

-- Monitoring the autovacuum Process
-- 17-5: Viewing autovacuum statistics for vacuum_test
SELECT relname,
	last_vacuum,
	last_autovacuum,
	vacuum_count,
	autovacuum_count
FROM pg_stat_all_tables
WHERE relname = 'vacuum_test';

-- Running VACUUM Manually
-- 17-6: Running VACUUM manually
VACUUM vacuum_test; -- then rerun 17-5

VACUUM; -- vacuums the whole database

VACUUM; -- vacuums the whole database

-- Reducing Table Size with VACUUM FULL
-- 17-7: Using VACUUM FULL to reclaim disk space
VACUUM FULL vacuum_test;

-- Test its size again
SELECT pg_size_pretty(
           pg_table_size('vacuum_test')
       );

-- Changing Server Settings
-- Locating and Editing postgresql.conf
-- 17-8: Showing the location of postgresql.conf
SHOW config_file; -- C:/Program Files/PostgreSQL/12/data/postgresql.conf

-- 17-9: Sample postgresql.conf settings
/*
datestyle = 'iso, mdy'
timezone = 'US/Eastern'
default_text_search_config = 'pg_catalog.english'
*/

-- 17-10: Showing the location of the data directory
SHOW data_directory;

-- Reloading Settings with pg_ctl
-- Run on system’s command prompt (not in psql)
pg_ctl reload -D "C:/Program Files/PostgreSQL/12/data/"

-- Backing Up and Restoring Your Database
-- 17-11: Backing up the analysis database with pg_dump. 
pg_dump -d analysis -U user_name -Fc > analysis_backup.sql

-- Back up just a table
pg_dump -t 'train_rides' -d analysis -U [user_name] -Fc > train_backup.sql 

-- Restoring a Database Backup with pg_restore
-- 17-12: Restoring the analysis database with pg_restore
pg_restore -C -d postgres -U user_name analysis_backup.sql









