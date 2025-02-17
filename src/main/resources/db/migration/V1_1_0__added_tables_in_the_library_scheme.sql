CREATE TABLE library.books (
                               id SERIAL PRIMARY KEY,
                               title VARCHAR(255) NOT NULL,
                               author VARCHAR(255) NOT NULL,
                               year_published INT NOT NULL
);

CREATE TABLE library.readers (
                                 id SERIAL PRIMARY KEY,
                                 name VARCHAR(100) NOT NULL,
                                 email VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE library.bookings (
                                  id SERIAL PRIMARY KEY,
                                  book_id INT NOT NULL,
                                  reader_id INT NOT NULL,
                                  booking_date DATE NOT NULL,
                                  return_date DATE,
                                  CONSTRAINT fk_books FOREIGN KEY (book_id) REFERENCES library.books (id) ON DELETE CASCADE,
                                  CONSTRAINT fk_readers FOREIGN KEY (reader_id) REFERENCES library.readers (id) ON DELETE CASCADE
);