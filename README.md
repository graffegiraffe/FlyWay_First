# README

## Project Description

This project uses PostgreSQL to manage the database using **Flyway** and consists of several parts:
1. Created triggers to write the history of operations to the `logs` table when updating or deleting users.
2. Wrote a function to return the login of the last registered user.
3. Created a schema for a small library management application with tables for books, readers and reservations.

---

## 1: Create triggers for the `logs` table

Created triggers to automatically write operations to the `logs` table. It stores information about changes to the `users` table when:
- Data in `users` is updated.
- Records from `users` are deleted.

### Creating the `logs` table:
Sample DDL code for creating the `logs` table:

```sql
CREATE TABLE public.logs (
id BIGSERIAL PRIMARY KEY,
user_id BIGINT NOT NULL,
action VARCHAR(50) NOT NULL,
action_timestamp TIMESTAMP(6) NOT NULL DEFAULT now(),
old_data JSONB,
new_data JSONB
);
```

### Trigger for writing on **update** (`UPDATE`):
The trigger writes old data and new data to the `logs` table.

```sql
CREATE OR REPLACE FUNCTION log_user_update()
RETURNS trigger AS
$$
BEGIN
INSERT INTO public.logs (user_id, action, action_timestamp, old_data, new_data)
VALUES (
NEW.id,
'UPDATE',
now(),
row_to_json(OLD),
row_to_json(NEW)
);
RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_update
BEFORE UPDATE ON public.users
FOR EACH ROW
EXECUTE FUNCTION log_user_update();
```

### Trigger for writing on **delete** (`DELETE`):
The trigger writes only old data since the record no longer exists.

```sql
CREATE OR REPLACE FUNCTION log_user_delete()
RETURNS trigger AS
$$
BEGIN
 INSERT INTO public.logs (user_id, action, action_timestamp, old_data, new_data)
 VALUES (
 OLD.id,
 'DELETE'
 now(),
 row_to_json(OLD),
 NULL
 );
 RETURN OLD;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_delete
 BEFORE DELETE ON public.users
 FOR EACH ROW
 EXECUTE FUNCTION log_user_delete();
```

---

## 2: Writing a function to get the login of the last logged in user

Created a function `get_last_user_login` that returns the login of the last logged in user based on the record creation time.

### Example implementation:

```sql
CREATE OR REPLACE FUNCTION get_last_user_login()
RETURNS VARCHAR
LANGUAGE plpgsql
AS
$$
DECLARE
last_user_id BIGINT;
last_user_login VARCHAR;
BEGIN
SELECT id
INTO last_user_id
FROM public.users
ORDER BY created DESC
LIMIT 1;

IF last_user_id IS NOT NULL THEN
SELECT login
INTO last_user_login
FROM public.user_credentials
WHERE user_id = last_user_id;

RETURN last_user_login;
ELSE
RETURN NULL;
END IF;
END;
$$;
``

### Usage:
```sql
SELECT public.get_last_user_login();
```

---

## 3: Library Management System Database Schema

Three tables have been created to implement the library management system: `books`, `readers` and `bookings`.

### Schema:

#### Table `books`:
Contains information about books.
```sql
CREATE TABLE library.books (
id SERIAL PRIMARY KEY,
title VARCHAR(255) NOT NULL,
author VARCHAR(255) NOT NULL,
year_published INT NOT NULL
);
```

#### Table `readers`:
Stores information about readers.
```sql
CREATE TABLE library.readers (
id SERIAL PRIMARY KEY,
name VARCHAR(100) NOT NULL,
email VARCHAR(255) NOT NULL UNIQUE
);
```

#### Table `bookings`:
Stores information about book reservations.
```sql
CREATE TABLE library.bookings (
 id SERIAL PRIMARY KEY,
 book_id INT NOT NULL,
 reader_id INT NOT NULL,
 booking_date DATE NOT NULL,
 return_date DATE,
 CONSTRAINT fk_books FOREIGN KEY (book_id) REFERENCES library.books (id) ON DELETE CASCADE,
 CONSTRAINT fk_readers FOREIGN KEY (reader_id) REFERENCES library.readers (id) ON DELETE CASCADE
);
```

---

## Examples of queries for the library

1. Inserting data into tables:
```sql
INSERT INTO library.books (title, author, year_published)
VALUES
('War and Peace', 'Leo Tolstoy', 1869),
('Crime and Punishment', 'Fyodor Dostoevsky', 1866);

INSERT INTO library.readers (name, email)
VALUES
('Kate Rublevskaya', 'kate@example.com'),
('Serhey Pavirayeu', 'serhey@example.com');

INSERT INTO library.bookings (book_id, reader_id, booking_date, return_date)
VALUES
(1, 1, '2025-02-17', '2025-02-25'),
(2, 2, '2025-02-18', NULL);
```

2. Get a list of all books:
```sql
SELECT * FROM library.books;
```

3. Display books that a certain reader has booked:
```sql
SELECT b.title, b.author
FROM library.bookings bo
JOIN library.books b ON bo.book_id = b.id
JOIN library.readers r ON bo.reader_id = r.id
WHERE r.name= 'Serhey';
```

4. Display active bookings (books not returned yet):
```sql
SELECT r.name AS reader_name, b.title AS book_title, bo.booking_date
FROM library.bookings bo
JOIN library.books b ON bo.book_id = b.id
JOIN library.readers r ON bo.reader_id = r.id
WHERE bo.return_date IS NULL;
```

---

## Using Flyway

### Flyway version:
- **Plugin:** `org.flywaydb:flyway-maven-plugin:11.3.1`
- **Database:** `PostgreSQL` (driver version: `42.7.4`)

### Flyway configuration example:
`pom.xml` file:
```xml
<configuration>
<url>jdbc:postgresql://localhost:5432/postgres</url>
<user>katusha</user>
<password>katusha</password>
<baselineVersion>1.0.0</baselineVersion>
<cleanDisabled>false</cleanDisabled>
</configuration>
```

### Migration sequence:
1. `V1_0_1__added_users_table.sql` - Adding the `users` table.
2. `V1_0_2__create_triggers.sql` - Creating triggers for `logs`.
3. `V1_0_3__create_user_credentials.sql` - `user_credentials` table.
4. `V1_0_4__get_user_login.sql` - Function for getting login.
5. `V1_1_0__added_tables_in_the_library_scheme.sql` - Tables for the library.

---

## Working with the console

Example of actions in the SQL console:
<img width="583" alt="Снимок экрана 2025-02-17 в 22 21 24" src="https://github.com/user-attachments/assets/1ddbdfda-4f30-4ff2-938f-1f0d933cf5ff" />
