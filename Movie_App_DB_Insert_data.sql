INSERT INTO Users (name, email, password_hash, role) VALUES 
('John Doe', 'john@example.com', 'hashed_password1', 'user'), 
('Jane Smith', 'jane@example.com', 'hashed_password2', 'admin'),
('Alice Johnson', 'alice@example.com', 'hashed_password3', 'user'),
('Bob Brown', 'bob@example.com', 'hashed_password4', 'user');

INSERT INTO Genres (name) VALUES 
('Action'), ('Comedy'), ('Drama'), ('Sci-Fi');

INSERT INTO Movies (title, description, release_date, duration, rating, poster_url, trailer_url, genre_id) VALUES 
('Inception', 'A mind-bending thriller', '2010-07-16', 148, 8.8, 'inception.jpg', 'trailer.com/inception', 1),
('The Mask', 'A comedy classic', '1994-07-29', 101, 6.9, 'themask.jpg', 'trailer.com/themask', 2),
('Interstellar', 'A space adventure', '2014-11-07', 169, 8.6, 'interstellar.jpg', 'trailer.com/interstellar', 4),
('The Godfather', 'A mafia saga', '1972-03-24', 175, 9.2, 'godfather.jpg', 'trailer.com/godfather', 3);

INSERT INTO Members (user_id, membership_type, membership_start_date, membership_end_date, status) VALUES 
(1, 'Gold', '2023-01-01', '2024-01-01', 'Active'), 
(2, 'Silver', '2023-02-01', '2024-02-01', 'Active'),
(3, 'Bronze', '2023-03-15', '2024-03-15', 'Suspended'),
(4, 'Gold', '2023-04-10', '2024-04-10', 'Active');

INSERT INTO Transactions (member_id, movie_id, borrow_date, return_date, status) VALUES 
(1, 1, '2024-01-01', '2024-01-15', 'Returned'),
(2, 3, '2024-01-05', NULL, 'Borrowed'),
(3, 4, '2024-01-10', NULL, 'Overdue');

INSERT INTO Late_Fees (transaction_id, member_id, fee_amount, paid_status, due_date) VALUES 
(1, 1, 5.00, 0, '2024-01-22');

INSERT INTO Movie_Providers (movie_id, provider_id, availability_status) VALUES 
(1, 1, 'Subscription'), (3, 2, 'Rent');

INSERT INTO Streaming_Providers (name, logo_url, website_url) VALUES 
('Netflix', 'netflix.png', 'netflix.com'), ('Hulu', 'hulu.png', 'hulu.com');

INSERT INTO Favorites (user_id, movie_id) VALUES 
(1, 1), (2, 3);

INSERT INTO Watchlist (user_id, movie_id) VALUES 
(2, 2), (3, 4);

INSERT INTO Reviews (user_id, movie_id, rating, review_text) VALUES 
(1, 1, 9, 'Amazing movie!'),
(3, 3, 8, 'Great visuals!');

INSERT INTO Movie_Actors (movie_id, actor_id) VALUES 
(1, 1), (3, 2);

INSERT INTO Actors (name, dob, biography, profile_url) VALUES 
('Leonardo DiCaprio', '1974-11-11', 'Famous actor known for Titanic, Inception.', 'leo.jpg'),
('Matthew McConaughey', '1969-11-04', 'Academy Award winner, known for Interstellar.', 'matt.jpg');
