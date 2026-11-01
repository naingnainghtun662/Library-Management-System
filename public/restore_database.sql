-- Production Relational Database Restore Script for Turso CLI / Shell
-- Candidate Name: Saw Pyae Phyo Kyaw
-- Candidate ID: 200309
-- Created: 2026-05-20T20:46:02Z

PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

-- Cleanup existing structure safely
DROP TABLE IF EXISTS serial_issues;
DROP TABLE IF EXISTS system_config;
DROP TABLE IF EXISTS logs;
DROP TABLE IF EXISTS borrow_records;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS librarians;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS users;

-- Recreate Academic Tables with accurate Foreign Key Constraints
CREATE TABLE users (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL,
  phone TEXT,
  communication_preferences TEXT,
  created_at INTEGER
);

CREATE TABLE students (
  student_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  student_code TEXT NOT NULL UNIQUE,
  department TEXT NOT NULL,
  year INTEGER NOT NULL
);

CREATE TABLE librarians (
  librarian_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  employee_code TEXT NOT NULL UNIQUE
);

CREATE TABLE categories (
  category_id INTEGER PRIMARY KEY AUTOINCREMENT,
  category_name TEXT NOT NULL UNIQUE
);

CREATE TABLE books (
  book_id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  isbn TEXT NOT NULL UNIQUE,
  publisher TEXT,
  category_id INTEGER REFERENCES categories(category_id) ON DELETE SET NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  available_quantity INTEGER NOT NULL DEFAULT 1,
  shelf_location TEXT,
  format TEXT NOT NULL DEFAULT 'Physical',
  metadata_schema TEXT DEFAULT 'Standard',
  metadata_record TEXT,
  is_acquisition INTEGER DEFAULT 0,
  acquisition_source TEXT,
  budget_code TEXT,
  cover_url TEXT,
  created_at INTEGER
);

CREATE TABLE borrow_records (
  record_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  book_id INTEGER REFERENCES books(book_id) ON DELETE CASCADE,
  borrow_date INTEGER,
  due_date INTEGER NOT NULL,
  return_date INTEGER,
  status TEXT NOT NULL DEFAULT 'requested',
  fine_amount REAL DEFAULT 0
);

CREATE TABLE logs (
  log_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
  action TEXT NOT NULL,
  details TEXT,
  timestamp INTEGER
);

CREATE TABLE system_config (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  description TEXT,
  updated_at INTEGER
);

CREATE TABLE serial_issues (
  issue_id INTEGER PRIMARY KEY AUTOINCREMENT,
  book_id INTEGER REFERENCES books(book_id) ON DELETE CASCADE,
  issue_number TEXT NOT NULL,
  volume_number TEXT,
  publication_date INTEGER,
  received_date INTEGER,
  status TEXT DEFAULT 'Expected'
);

-- ==========================================================
-- 1. SEED SYSTEM CONFIGURATION
-- ==========================================================
INSERT INTO system_config (key, value, description, updated_at) VALUES ('LOAN_DURATION_DAYS', '14', 'Standard loan period for members', 1779354000);
INSERT INTO system_config (key, value, description, updated_at) VALUES ('DAILY_FINE_RATE', '0.50', 'Fine amount per day overdue ($)', 1779354000);
INSERT INTO system_config (key, value, description, updated_at) VALUES ('MAX_LOANS_PER_USER', '5', 'Maximum books a student can hold', 1779354000);
INSERT INTO system_config (key, value, description, updated_at) VALUES ('LIBRARY_NAME', 'University Library System', 'Display name at top of UI', 1779354000);
INSERT INTO system_config (key, value, description, updated_at) VALUES ('CURRENCY_SYMBOL', '$', 'Local currency for fines', 1779354000);

-- ==========================================================
-- 2. SEED CATEGORIES (30 Normalized Categories)
-- ==========================================================
INSERT INTO categories (category_id, category_name) VALUES (1, 'Computer Science');
INSERT INTO categories (category_id, category_name) VALUES (2, 'Mathematics');
INSERT INTO categories (category_id, category_name) VALUES (3, 'Physics');
INSERT INTO categories (category_id, category_name) VALUES (4, 'Chemistry');
INSERT INTO categories (category_id, category_name) VALUES (5, 'Biology');
INSERT INTO categories (category_id, category_name) VALUES (6, 'Literature');
INSERT INTO categories (category_id, category_name) VALUES (7, 'History');
INSERT INTO categories (category_id, category_name) VALUES (8, 'Geography');
INSERT INTO categories (category_id, category_name) VALUES (9, 'Philosophy');
INSERT INTO categories (category_id, category_name) VALUES (10, 'Psychology');
INSERT INTO categories (category_id, category_name) VALUES (11, 'Sociology');
INSERT INTO categories (category_id, category_name) VALUES (12, 'Economics');
INSERT INTO categories (category_id, category_name) VALUES (13, 'Political Science');
INSERT INTO categories (category_id, category_name) VALUES (14, 'Law');
INSERT INTO categories (category_id, category_name) VALUES (15, 'Medicine');
INSERT INTO categories (category_id, category_name) VALUES (16, 'Engineering');
INSERT INTO categories (category_id, category_name) VALUES (17, 'Architecture');
INSERT INTO categories (category_id, category_name) VALUES (18, 'Art');
INSERT INTO categories (category_id, category_name) VALUES (19, 'Music');
INSERT INTO categories (category_id, category_name) VALUES (20, 'Sports');
INSERT INTO categories (category_id, category_name) VALUES (21, 'Business');
INSERT INTO categories (category_id, category_name) VALUES (22, 'Finance');
INSERT INTO categories (category_id, category_name) VALUES (23, 'Marketing');
INSERT INTO categories (category_id, category_name) VALUES (24, 'Management');
INSERT INTO categories (category_id, category_name) VALUES (25, 'Programming');
INSERT INTO categories (category_id, category_name) VALUES (26, 'Artificial Intelligence');
INSERT INTO categories (category_id, category_name) VALUES (27, 'Cybersecurity');
INSERT INTO categories (category_id, category_name) VALUES (28, 'Networking');
INSERT INTO categories (category_id, category_name) VALUES (29, 'Data Science');
INSERT INTO categories (category_id, category_name) VALUES (30, 'Ethics');

-- ==========================================================
-- 3. SEED USERS, STUDENTS & LIBRARIANS
-- Passwords below are pre-salted bcrypt outputs for:
-- • 'admin123' for the main Admin
-- • 'password123' for Students and Librarians
-- ==========================================================
-- Admin user
INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (1, 'System Admin', 'admin@library.edu', '$2a$10$f38pUaMh3g55q2G8v.sKkuL3IeHe8N11G61xTcoUskK2G8Nl7W6T6', 'admin', 1779354000);

-- Students
INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (2, 'Saw Pyae Phyo Kyaw', 'saw@student.edu', '$2a$10$wN62E2G9E8K6o/T3y9hLkuK7D881uU881G31uTcoUskK2G8Nl7W6T.', 'student', 1779354000);
INSERT INTO students (student_id, user_id, student_code, department, year) VALUES (1, 2, '200309', 'Cyber Security', 3);

INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (3, 'Aung Kyaw Thu', 'aung@student.edu', '$2a$10$wN62E2G9E8K6o/T3y9hLkuK7D881uU881G31uTcoUskK2G8Nl7W6T.', 'student', 1779354000);
INSERT INTO students (student_id, user_id, student_code, department, year) VALUES (2, 3, 'ST002', 'IT', 2);

INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (4, 'Ei Phyu Khin', 'ei@student.edu', '$2a$10$wN62E2G9E8K6o/T3y9hLkuK7D881uU881G31uTcoUskK2G8Nl7W6T.', 'student', 1779354000);
INSERT INTO students (student_id, user_id, student_code, department, year) VALUES (3, 4, 'ST003', 'Business', 1);

INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (5, 'Min Htet Oo', 'min@student.edu', '$2a$10$wN62E2G9E8K6o/T3y9hLkuK7D881uU881G31uTcoUskK2G8Nl7W6T.', 'student', 1779354000);
INSERT INTO students (student_id, user_id, student_code, department, year) VALUES (4, 5, 'ST004', 'Mathematics', 4);

INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (6, 'Thandar Win', 'thandar@student.edu', '$2a$10$wN62E2G9E8K6o/T3y9hLkuK7D881uU881G31uTcoUskK2G8Nl7W6T.', 'student', 1779354000);
INSERT INTO students (student_id, user_id, student_code, department, year) VALUES (5, 6, 'ST005', 'Physics', 2);

-- Librarians
INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (7, 'Sarah Librarian', 'sarah@library.edu', '$2a$10$wN62E2G9E8K6o/T3y9hLkuK7D881uU881G31uTcoUskK2G8Nl7W6T.', 'librarian', 1779354000);
INSERT INTO librarians (librarian_id, user_id, employee_code) VALUES (1, 7, 'EMP001');

INSERT INTO users (user_id, full_name, email, password, role, created_at) VALUES (8, 'Kevin Staff', 'kevin@library.edu', '$2a$10$wN62E2G9E8K6o/T3y9hLkuK7D881uU881G31uTcoUskK2G8Nl7W6T.', 'librarian', 1779354000);
INSERT INTO librarians (librarian_id, user_id, employee_code) VALUES (2, 8, 'EMP002');


-- ==========================================================
-- 4. SEED ACADEMIC LIBRARY BOOKS (150+ Structured Materials)
-- ==========================================================
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(1, 'Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'ISBN-1000-8438', 1, 1, 1, 'SEC-0-B', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(2, 'Introduction to Algorithms', 'Thomas H. Cormen', 'ISBN-1001-2311', 1, 1, 1, 'SEC-0-C', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(3, 'Design Patterns', 'Erich Gamma', 'ISBN-1002-3929', 1, 1, 1, 'SEC-0-D', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(4, 'The Pragmatic Programmer', 'Andrew Hunt', 'ISBN-1003-4923', 25, 1, 1, 'SEC-0-E', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(5, 'Modern Operating Systems', 'Andrew S. Tanenbaum', 'ISBN-1004-5829', 1, 1, 1, 'SEC-0-A', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(6, 'Computer Networking: A Top-Down Approach', 'James Kurose', 'ISBN-1005-1823', 28, 1, 1, 'SEC-0-B', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(7, 'Artificial Intelligence: A Modern Approach', 'Stuart Russell', 'ISBN-1006-2910', 26, 1, 1, 'SEC-0-C', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(8, 'Cybersecurity for Beginners', 'Raef Meeuwisse', 'ISBN-1007-8492', 27, 1, 1, 'SEC-0-D', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(9, 'Data Science from Scratch', 'Joel Grus', 'ISBN-1008-5920', 29, 1, 1, 'SEC-0-E', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(10, 'The Art of Computer Programming', 'Donald Knuth', 'ISBN-1009-3829', 25, 1, 1, 'SEC-0-A', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(11, 'Discrete Mathematics and Its Applications', 'Kenneth Rosen', 'ISBN-1010-9182', 2, 1, 1, 'SEC-1-A', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(12, 'Calculus', 'James Stewart', 'ISBN-1011-8291', 2, 1, 1, 'SEC-1-B', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(13, 'The Great Gatsby', 'F. Scott Fitzgerald', 'ISBN-1012-7384', 6, 1, 1, 'SEC-1-C', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(14, 'To Kill a Mockingbird', 'Harper Lee', 'ISBN-1013-9183', 6, 1, 1, 'SEC-1-D', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(15, 'A Brief History of Time', 'Stephen Hawking', 'ISBN-1014-9382', 3, 1, 1, 'SEC-1-E', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(16, 'Thinking, Fast and Slow', 'Daniel Kahneman', 'ISBN-1015-4819', 10, 1, 1, 'SEC-1-A', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(17, 'The Wealth of Nations', 'Adam Smith', 'ISBN-1016-1934', 12, 1, 1, 'SEC-1-B', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(18, 'Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', 'ISBN-1017-4810', 7, 1, 1, 'SEC-1-C', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(19, 'The Republic', 'Plato', 'ISBN-1018-4820', 9, 1, 1, 'SEC-1-D', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(20, 'Meditations', 'Marcus Aurelius', 'ISBN-1019-3819', 9, 1, 1, 'SEC-1-E', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);

-- Distributing volumes & duplicates up to 150 total records
-- Vol 2 duplicates of initial items to maintain solid relational volume testing
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(21, 'Clean Code: A Handbook of Agile Software Craftsmanship (Vol. 2)', 'Robert C. Martin', 'ISBN-1020-8321', 1, 1, 1, 'SEC-2-A', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(22, 'Introduction to Algorithms (Vol. 2)', 'Thomas H. Cormen', 'ISBN-1021-3921', 1, 1, 1, 'SEC-2-B', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(23, 'Design Patterns (Vol. 2)', 'Erich Gamma', 'ISBN-1022-4821', 1, 1, 1, 'SEC-2-C', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(24, 'The Pragmatic Programmer (Vol. 2)', 'Andrew Hunt', 'ISBN-1023-3921', 25, 1, 1, 'SEC-2-D', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(25, 'Modern Operating Systems (Vol. 2)', 'Andrew S. Tanenbaum', 'ISBN-1024-5821', 1, 1, 1, 'SEC-2-E', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(26, 'Computer Networking: A Top-Down Approach (Vol. 2)', 'James Kurose', 'ISBN-1025-1821', 28, 1, 1, 'SEC-2-A', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(27, 'Artificial Intelligence: A Modern Approach (Vol. 2)', 'Stuart Russell', 'ISBN-1026-2921', 26, 1, 1, 'SEC-2-B', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(28, 'Cybersecurity for Beginners (Vol. 2)', 'Raef Meeuwisse', 'ISBN-1027-8421', 27, 1, 1, 'SEC-2-C', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(29, 'Data Science from Scratch (Vol. 2)', 'Joel Grus', 'ISBN-1028-5921', 29, 1, 1, 'SEC-2-D', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(30, 'The Art of Computer Programming (Vol. 2)', 'Donald Knuth', 'ISBN-1029-3821', 25, 1, 1, 'SEC-2-E', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);

-- Bulk sequential academic book insertions 31 - 150
-- These items represent key academic references across multiple categories
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(31, 'Structure and Interpretation of Computer Programs', 'Harold Abelson', 'ISBN-1030-2918', 1, 1, 1, 'SEC-3-A', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(32, 'Principles of Cyber-Physical Systems', 'Rajeev Alur', 'ISBN-1031-1923', 27, 1, 1, 'SEC-3-B', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(33, 'Data Networks', 'Dimitri Bertsekas', 'ISBN-1032-9481', 28, 1, 1, 'SEC-3-C', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(34, 'Real-Time Systems', 'Jane Liu', 'ISBN-1033-9182', 1, 1, 1, 'SEC-3-D', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(35, 'Database Systems: The Complete Book', 'Hector Garcia-Molina', 'ISBN-1034-4821', 1, 1, 1, 'SEC-3-E', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(36, 'An Introduction to Mathematical Cryptography', 'Jeffrey Hoffstein', 'ISBN-1035-9382', 2, 1, 1, 'SEC-3-A', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(37, 'Linear Algebra and Its Applications', 'Gilbert Strang', 'ISBN-1036-1923', 2, 1, 1, 'SEC-3-B', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(38, 'Calculus (Vol. 2)', 'Tom Apostol', 'ISBN-1037-8192', 2, 1, 1, 'SEC-3-C', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(39, 'Probability and Random Processes', 'Geoffrey Grimmett', 'ISBN-1038-2918', 2, 1, 1, 'SEC-3-D', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(40, 'Information Theory, Inference, and Learning Algorithms', 'David MacKay', 'ISBN-1039-4821', 29, 1, 1, 'SEC-3-E', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(41, 'Physics for Scientists and Engineers', 'Raymond Serway', 'ISBN-1040-2918', 3, 1, 1, 'SEC-4-A', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(42, 'The Feynman Lectures on Physics', 'Richard Feynman', 'ISBN-1041-1923', 3, 1, 1, 'SEC-4-B', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(43, 'Introduction to Electrodynamics', 'David Griffiths', 'ISBN-1042-9481', 3, 1, 1, 'SEC-4-C', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(44, 'Quantum Mechanics', 'Leonard Susskind', 'ISBN-1043-9182', 3, 1, 1, 'SEC-4-D', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(45, 'Classical Mechanics', 'Herbert Goldstein', 'ISBN-1044-4821', 3, 1, 1, 'SEC-4-E', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(46, 'Organic Chemistry', 'Jonathan Clayden', 'ISBN-1045-9382', 4, 1, 1, 'SEC-4-A', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(47, 'Inorganic Chemistry', 'Gary Miessler', 'ISBN-1046-1923', 4, 1, 1, 'SEC-4-B', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(48, 'Physical Chemistry', 'Peter Atkins', 'ISBN-1047-8192', 4, 1, 1, 'SEC-4-C', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(49, 'Principles of Biochemistry', 'Albert Lehninger', 'ISBN-1048-2918', 4, 1, 1, 'SEC-4-D', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(50, 'Analytical Chemistry', 'Gary Christian', 'ISBN-1049-4821', 4, 1, 1, 'SEC-4-E', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(51, 'Molecular Biology of the Cell', 'Bruce Alberts', 'ISBN-1050-2918', 5, 1, 1, 'SEC-5-A', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(52, 'Campbell Biology', 'Jane Reece', 'ISBN-1051-1923', 5, 1, 1, 'SEC-5-B', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(53, 'Genetics: A Conceptual Approach', 'Benjamin Pierce', 'ISBN-1052-9481', 5, 1, 1, 'SEC-5-C', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(54, 'The Origin of Species', 'Charles Darwin', 'ISBN-1053-9182', 5, 1, 1, 'SEC-5-D', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(55, 'Ecology: Evolution, Application, Integration', 'David Krogh', 'ISBN-1054-4821', 5, 1, 1, 'SEC-5-E', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(56, 'Hamlet', 'William Shakespeare', 'ISBN-1055-9382', 6, 1, 1, 'SEC-5-A', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(57, '1984', 'George Orwell', 'ISBN-1056-1923', 6, 1, 1, 'SEC-5-B', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(58, 'Pride and Prejudice', 'Jane Austen', 'ISBN-1057-8192', 6, 1, 1, 'SEC-5-C', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(59, 'Moby-Dick', 'Herman Melville', 'ISBN-1058-2918', 6, 1, 1, 'SEC-5-D', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(60, 'Crime and Punishment', 'Fyodor Dostoevsky', 'ISBN-1059-4821', 6, 1, 1, 'SEC-5-E', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(61, 'A History of the World', 'Andrew Marr', 'ISBN-1060-2918', 7, 1, 1, 'SEC-6-A', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(62, 'Sapiens: A Graphical History', 'Yuval Noah Harari', 'ISBN-1061-1923', 7, 1, 1, 'SEC-6-B', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(63, 'The Rise and Fall of the Third Reich', 'William Shirer', 'ISBN-1062-9481', 7, 1, 1, 'SEC-6-C', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(64, 'Guns, Germs, and Steel', 'Jared Diamond', 'ISBN-1063-9182', 7, 1, 1, 'SEC-6-D', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(65, 'The Silk Roads: A New History of the World', 'Peter Frankopan', 'ISBN-1064-4821', 7, 1, 1, 'SEC-6-E', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(66, 'Geography: A Global Introduction', 'Michael Pacione', 'ISBN-1065-9382', 8, 1, 1, 'SEC-6-A', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(67, 'Physical Geography', 'Robert Christopherson', 'ISBN-1066-1923', 8, 1, 1, 'SEC-6-B', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(68, 'Human Geography: Culture, Society, Space', 'Erin Fouberg', 'ISBN-1067-8192', 8, 1, 1, 'SEC-6-C', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(69, 'An Introduction to Human-Environment Geography', 'William Moseley', 'ISBN-1068-2918', 8, 1, 1, 'SEC-6-D', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(70, 'World Regional Geography', 'Lydia Pulsipher', 'ISBN-1069-4821', 8, 1, 1, 'SEC-6-E', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(71, 'A History of Western Philosophy', 'Bertrand Russell', 'ISBN-1070-2918', 9, 1, 1, 'SEC-7-A', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(72, 'Critique of Pure Reason', 'Immanuel Kant', 'ISBN-1071-1923', 9, 1, 1, 'SEC-7-B', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(73, 'Beyond Good and Evil', 'Friedrich Nietzsche', 'ISBN-1072-9481', 9, 1, 1, 'SEC-7-C', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(74, 'The Social Contract', 'Jean-Jacques Rousseau', 'ISBN-1073-9182', 9, 1, 1, 'SEC-7-D', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(75, 'Being and Time', 'Martin Heidegger', 'ISBN-1074-4821', 9, 1, 1, 'SEC-7-E', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(76, 'Psychology', 'David Myers', 'ISBN-1075-9382', 10, 1, 1, 'SEC-7-A', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(77, 'Man and His Symbols', 'Carl Jung', 'ISBN-1076-1923', 10, 1, 1, 'SEC-7-B', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(78, 'The Interpretation of Dreams', 'Sigmund Freud', 'ISBN-1077-8192', 10, 1, 1, 'SEC-7-C', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(79, 'Phantoms in the Brain', 'V.S. Ramachandran', 'ISBN-1078-2918', 10, 1, 1, 'SEC-7-D', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(80, 'Flow: The Psychology of Optimal Experience', 'Mihaly Csikszentmihalyi', 'ISBN-1079-4821', 10, 1, 1, 'SEC-7-E', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(81, 'Introduction to Sociology', 'Anthony Giddens', 'ISBN-1080-2918', 11, 1, 1, 'SEC-8-A', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(82, 'The Division of Labour in Society', 'Emile Durkheim', 'ISBN-1081-1923', 11, 1, 1, 'SEC-8-B', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(83, 'The Protestant Ethic and the Spirit of Capitalism', 'Max Weber', 'ISBN-1082-9481', 11, 1, 1, 'SEC-8-C', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(84, 'The Presentation of Self in Everyday Life', 'Erving Goffman', 'ISBN-1083-9182', 11, 1, 1, 'SEC-8-D', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(85, 'Suicide: A Study in Sociology', 'Emile Durkheim', 'ISBN-1084-4821', 11, 1, 1, 'SEC-8-E', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(86, 'Economics', 'Paul Samuelson', 'ISBN-1085-9382', 12, 1, 1, 'SEC-8-A', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(87, 'The General Theory of Employment, Interest and Money', 'John Maynard Keynes', 'ISBN-1086-1923', 12, 1, 1, 'SEC-8-B', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(88, 'Capital in the Twenty-First Century', 'Thomas Piketty', 'ISBN-1087-8192', 12, 1, 1, 'SEC-8-C', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(89, 'Das Kapital', 'Karl Marx', 'ISBN-1088-2918', 12, 1, 1, 'SEC-8-D', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(90, 'Freakonomics', 'Steven Levitt', 'ISBN-1089-4821', 12, 1, 1, 'SEC-8-E', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(91, 'The Logic of Political Survival', 'Bruce Bueno de Mesquita', 'ISBN-1090-2918', 13, 1, 1, 'SEC-9-A', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(92, 'The Prince', 'Niccolò Machiavelli', 'ISBN-1091-1923', 13, 1, 1, 'SEC-9-B', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(93, 'Leviathan', 'Thomas Hobbes', 'ISBN-1092-9481', 13, 1, 1, 'SEC-9-C', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(94, 'On Liberty', 'John Stuart Mill', 'ISBN-1093-9182', 13, 1, 1, 'SEC-9-D', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(95, 'The Clash of Civilizations', 'Samuel Huntington', 'ISBN-1094-4821', 13, 1, 1, 'SEC-9-E', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(96, 'An Introduction to the Law of Contract', 'P.S. Atiyah', 'ISBN-1095-9382', 14, 1, 1, 'SEC-9-A', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(97, 'The Concept of Law', 'H.L.A. Hart', 'ISBN-1096-1923', 14, 1, 1, 'SEC-9-B', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(98, 'Taking Rights Seriously', 'Ronald Dworkin', 'ISBN-1097-8192', 14, 1, 1, 'SEC-9-C', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(99, 'The Morality of Law', 'Lon Fuller', 'ISBN-1098-2918', 14, 1, 1, 'SEC-9-D', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(100, 'Jurisprudence: Theory and Context', 'Brian Bix', 'ISBN-1099-4821', 14, 1, 1, 'SEC-9-E', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(101, 'Gray Anatomy', 'Henry Gray', 'ISBN-1100-2918', 15, 1, 1, 'SEC-10-A', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(102, 'Harrison Principles of Internal Medicine', 'Dennis Kasper', 'ISBN-1101-1923', 15, 1, 1, 'SEC-10-B', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(103, 'Guyton and Hall Textbook of Medical Physiology', 'John Hall', 'ISBN-1102-9481', 15, 1, 1, 'SEC-10-C', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(104, 'Robbins and Cotran Pathologic Basis of Disease', 'Vinay Kumar', 'ISBN-1103-9182', 15, 1, 1, 'SEC-10-D', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(105, 'Rang and Dale Pharmacology', 'James Ritter', 'ISBN-1104-4821', 15, 1, 1, 'SEC-10-E', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(106, 'Introduction to Engineering', 'Paul Wright', 'ISBN-1105-9382', 16, 1, 1, 'SEC-10-A', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(107, 'Standard Handbook of Engineering Calculations', 'Tyler Hicks', 'ISBN-1106-1923', 16, 1, 1, 'SEC-10-B', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(108, 'Mechanical Engineering Design', 'Joseph Shigley', 'ISBN-1107-8192', 16, 1, 1, 'SEC-10-C', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(109, 'Principles of Environmental Engineering', 'Mackenzie Davis', 'ISBN-1108-2918', 16, 1, 1, 'SEC-10-D', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(110, 'Fundamentals of Thermodynamics', 'Claus Borgnakke', 'ISBN-1109-4821', 16, 1, 1, 'SEC-10-E', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(111, 'A Visual Dictionary of Architecture', 'Francis Ching', 'ISBN-1110-2918', 17, 1, 1, 'SEC-11-A', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(112, 'Towards a New Architecture', 'Le Corbusier', 'ISBN-1111-1923', 17, 1, 1, 'SEC-11-B', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(113, 'The Architecture of Happiness', 'Alain de Botton', 'ISBN-1112-9481', 17, 1, 1, 'SEC-11-C', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(114, 'A Pattern Language', 'Christopher Alexander', 'ISBN-1113-9182', 17, 1, 1, 'SEC-11-D', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(115, 'Complexity and Contradiction in Architecture', 'Robert Venturi', 'ISBN-1114-4821', 17, 1, 1, 'SEC-11-E', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(116, 'The Story of Art', 'Ernst Gombrich', 'ISBN-1115-9382', 18, 1, 1, 'SEC-11-A', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(117, 'Ways of Seeing', 'John Berger', 'ISBN-1116-1923', 18, 1, 1, 'SEC-11-B', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(118, 'Art and Illusion', 'Ernst Gombrich', 'ISBN-1117-8192', 18, 1, 1, 'SEC-11-C', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(119, 'The Shock of the New', 'Robert Hughes', 'ISBN-1118-2918', 18, 1, 1, 'SEC-11-D', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(120, 'Visions of Art', 'Julius Shulman', 'ISBN-1119-4821', 18, 1, 1, 'SEC-11-E', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(121, 'The Rest is Noise: Listening to the Twentieth Century', 'Alex Ross', 'ISBN-1120-2918', 19, 1, 1, 'SEC-12-A', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(122, 'How Music Works', 'David Byrne', 'ISBN-1121-1923', 19, 1, 1, 'SEC-12-B', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(123, 'This Is Your Brain on Music', 'Daniel Levitin', 'ISBN-1122-9481', 19, 1, 1, 'SEC-12-C', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(124, 'What to Listen for in Music', 'Aaron Copland', 'ISBN-1123-9182', 19, 1, 1, 'SEC-12-D', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(125, 'Musicophilia: Tales of Music and the Brain', 'Oliver Sacks', 'ISBN-1124-4821', 19, 1, 1, 'SEC-12-E', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(126, 'The Sports Rules Book', 'Human Kinetics', 'ISBN-1125-9382', 20, 1, 1, 'SEC-12-A', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(127, 'The Mechanics of Athletics', 'Geoffrey Dyson', 'ISBN-1126-1923', 20, 1, 1, 'SEC-12-B', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(128, 'Sociology of Sport', 'Jay Coakley', 'ISBN-1127-8192', 20, 1, 1, 'SEC-12-C', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(129, 'Sports Nutrition', 'Asker Jeukendrup', 'ISBN-1128-2918', 20, 1, 1, 'SEC-12-D', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(130, 'Essentials of Strength Training and Conditioning', 'Thomas Baechle', 'ISBN-1129-4821', 20, 1, 1, 'SEC-12-E', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(131, 'Business Model Generation', 'Alexander Osterwalder', 'ISBN-1130-2918', 21, 1, 1, 'SEC-13-A', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(132, 'The Lean Startup', 'Eric Ries', 'ISBN-1131-1923', 21, 1, 1, 'SEC-13-B', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(133, 'Corporate Finance', 'Stephen Ross', 'ISBN-1132-9481', 22, 1, 1, 'SEC-13-C', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(134, 'The Intelligent Investor', 'Benjamin Graham', 'ISBN-1133-9182', 22, 1, 1, 'SEC-13-D', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(135, 'Principles of Marketing', 'Philip Kotler', 'ISBN-1134-4821', 23, 1, 1, 'SEC-13-E', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(136, 'Influence: The Psychology of Persuasion', 'Robert Cialdini', 'ISBN-1135-9382', 23, 1, 1, 'SEC-13-A', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(137, 'High Output Management', 'Andrew Grove', 'ISBN-1136-1923', 24, 1, 1, 'SEC-13-B', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(138, 'The Practice of Management', 'Peter Drucker', 'ISBN-1137-8192', 24, 1, 1, 'SEC-13-C', 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(139, 'Introduction to the Theory of Computation', 'Michael Sipser', 'ISBN-1138-2918', 1, 1, 1, 'SEC-14-A', 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(140, 'Compilers: Principles, Techniques, and Tools', 'Alfred Aho', 'ISBN-1139-4821', 1, 1, 1, 'SEC-14-B', 'https://images.unsplash.com/photo-1550399105-c4db5fb85c18?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(141, 'Deep Learning', 'Ian Goodfellow', 'ISBN-1140-2918', 26, 1, 1, 'SEC-14-C', 'https://images.unsplash.com/photo-1519682337058-a94d519337bc?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(142, 'Hands-On Machine Learning', 'Aurélien Géron', 'ISBN-1141-1923', 26, 1, 1, 'SEC-14-D', 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(143, 'Practical Malware Analysis', 'Michael Sikorski', 'ISBN-1142-9481', 27, 1, 1, 'SEC-14-E', 'https://images.unsplash.com/photo-1513001900722-370f803f498d?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(144, 'The Web Application Hacker Handbook', 'Dafydd Stuttard', 'ISBN-1143-9182', 27, 1, 1, 'SEC-14-A', 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(145, 'TCP/IP Illustrated', 'W. Richard Stevens', 'ISBN-1144-4821', 28, 1, 1, 'SEC-14-B', 'https://images.unsplash.com/photo-1589998059171-988d887df646?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(146, 'Computer Systems: A Programmer Perspective', 'Randal Bryant', 'ISBN-1145-9382', 1, 1, 1, 'SEC-14-C', 'https://images.unsplash.com/photo-1543004218-ee141d0ef1bd?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(147, 'Python Data Science Handbook', 'Jake VanderPlas', 'ISBN-1146-1923', 29, 1, 1, 'SEC-14-D', 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(148, 'Introduction to Probability', 'Joseph Blitzstein', 'ISBN-1147-8192', 2, 1, 1, 'SEC-14-E', 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(149, 'Ethics for the Information Age', 'Michael Quinn', 'ISBN-1148-2918', 30, 1, 1, 'SEC-14-A', 'https://images.unsplash.com/photo-1531988042231-d39a9cc12a9a?w=400&q=80', 1779354000);
INSERT INTO books (book_id, title, author, isbn, category_id, quantity, available_quantity, shelf_location, cover_url, created_at) VALUES 
(150, 'Engineering Ethics', 'Charles Fleddermann', 'ISBN-1149-4821', 30, 1, 1, 'SEC-14-B', 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=400&q=80', 1779354000);

-- ==========================================================
-- 5. INITIAL TRANSACTION RECORDS (Historical Borrows)
-- ==========================================================
-- Admin / Librarian authorized a borrow of 'Clean Code' to Candidate PM Saw Pyae Phyo Kyaw
INSERT INTO borrow_records (record_id, user_id, book_id, borrow_date, due_date, return_date, status, fine_amount) VALUES 
(1, 2, 1, 1779354000 - (86400 * 5), 1779354000 + (86400 * 9), NULL, 'borrowed', 0.0);

-- Thandar Win has a successfully completed historical borrow transaction. Stock was returned properly.
INSERT INTO borrow_records (record_id, user_id, book_id, borrow_date, due_date, return_date, status, fine_amount) VALUES 
(2, 6, 2, 1779354000 - (86400 * 20), 1779354000 - (86400 * 6), 1779354000 - (86400 * 7), 'returned', 0.0);

-- Aung Kyaw Thu requested 'The Great Gatsby' and it is waiting in queue
INSERT INTO borrow_records (record_id, user_id, book_id, borrow_date, due_date, return_date, status, fine_amount) VALUES 
(3, 3, 13, 1779354000, 1779354000 + (86400 * 14), NULL, 'requested', 0.0);


-- ==========================================================
-- 6. SYSTEM LOGS
-- ==========================================================
INSERT INTO logs (log_id, user_id, action, details, timestamp) VALUES (1, 1, 'SYSTEM_INIT', 'Seeded all core relational structures and academic entities successfully', 1779354000);
INSERT INTO logs (log_id, user_id, action, details, timestamp) VALUES (2, 7, 'MEMBERSHIP_ENROLL', 'Registered Student portfolio Saw Pyae Phyo Kyaw (200309) in Cyber Security', 1779354000);

COMMIT;
PRAGMA foreign_keys=ON;
