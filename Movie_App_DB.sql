-- Drop constraints first
ALTER TABLE Late_Fees DROP CONSTRAINT IF EXISTS FK__Late_Fees__membe__70DDC3D8;
ALTER TABLE Late_Fees DROP CONSTRAINT IF EXISTS FK__Late_Fees__trans__71D1E811;
ALTER TABLE Transactions DROP CONSTRAINT IF EXISTS FK__Transactions__memb__72C60C4A;
ALTER TABLE Transactions DROP CONSTRAINT IF EXISTS FK__Transactions__movi__73B4E4F6;
ALTER TABLE Movie_Providers DROP CONSTRAINT IF EXISTS FK__Movie_Providers__movi__74A3CBFB;
ALTER TABLE Movie_Providers DROP CONSTRAINT IF EXISTS FK__Movie_Providers__prov__7593B1DE;
ALTER TABLE Favorites DROP CONSTRAINT IF EXISTS FK__Favorites__user__768F439A;
ALTER TABLE Favorites DROP CONSTRAINT IF EXISTS FK__Favorites__movi__777C4178;
ALTER TABLE Watchlist DROP CONSTRAINT IF EXISTS FK__Watchlist__user__786B292E;
ALTER TABLE Watchlist DROP CONSTRAINT IF EXISTS FK__Watchlist__movi__795B1C56;
ALTER TABLE Reviews DROP CONSTRAINT IF EXISTS FK__Reviews__user__7A4A1C1D;
ALTER TABLE Reviews DROP CONSTRAINT IF EXISTS FK__Reviews__movi__7B3A11F3;
ALTER TABLE Movie_Actors DROP CONSTRAINT IF EXISTS FK__Movie_Actors__movi__7C2A1E33;
ALTER TABLE Movie_Actors DROP CONSTRAINT IF EXISTS FK__Movie_Actors__acto__7D1A1F99;
ALTER TABLE Movies DROP CONSTRAINT IF EXISTS FK__Movies__genre__7E0A221A;
ALTER TABLE Members DROP CONSTRAINT IF EXISTS FK__Members__user__7EF027D5;

-- Drop tables if they exist
DROP TABLE IF EXISTS Late_Fees;
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Movie_Providers;
DROP TABLE IF EXISTS Streaming_Providers;
DROP TABLE IF EXISTS Favorites;
DROP TABLE IF EXISTS Watchlist;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Movie_Actors;
DROP TABLE IF EXISTS Actors;
DROP TABLE IF EXISTS Movies;
DROP TABLE IF EXISTS Genres;
DROP TABLE IF EXISTS Members;
DROP TABLE IF EXISTS Users;

CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) CHECK (role IN ('user', 'admin')) NOT NULL
);

CREATE TABLE Members (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    membership_type VARCHAR(50) NOT NULL,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Active', 'Suspended')) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);

CREATE TABLE Genres (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Movies (
    id INT IDENTITY(1,1) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    release_date DATE NOT NULL,
    duration INT NOT NULL,
    rating DECIMAL(3,1),
    poster_url VARCHAR(255),
    trailer_url VARCHAR(255),
    genre_id INT NOT NULL,
    FOREIGN KEY (genre_id) REFERENCES Genres(id) ON DELETE CASCADE
);

CREATE TABLE Actors (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    dob DATE,
    biography TEXT,
    profile_url VARCHAR(255)
);

CREATE TABLE Movie_Actors (
    movie_id INT NOT NULL,
    actor_id INT NOT NULL,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES Actors(id) ON DELETE CASCADE
);

CREATE TABLE Reviews (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 10) NOT NULL,
    review_text TEXT,
    created_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE
);

CREATE TABLE Watchlist (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    added_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE
);

CREATE TABLE Favorites (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    added_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE
);

CREATE TABLE Streaming_Providers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    logo_url VARCHAR(255),
    website_url VARCHAR(255)
);

CREATE TABLE Movie_Providers (
    movie_id INT NOT NULL,
    provider_id INT NOT NULL,
    availability_status VARCHAR(50) CHECK (availability_status IN ('Free', 'Rent', 'Buy', 'Subscription')) NOT NULL,
    PRIMARY KEY (movie_id, provider_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES Streaming_Providers(id) ON DELETE CASCADE
);

CREATE TABLE Transactions (
    id INT IDENTITY(1,1) PRIMARY KEY,
    member_id INT NOT NULL,
    movie_id INT NOT NULL,
    borrow_date DATETIME DEFAULT GETDATE(),
    return_date DATETIME NULL,
    status VARCHAR(20) CHECK (status IN ('Borrowed', 'Returned', 'Overdue')) NOT NULL,
    FOREIGN KEY (member_id) REFERENCES Members(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE
);

CREATE TABLE Late_Fees (
    id INT IDENTITY(1,1) PRIMARY KEY,
    transaction_id INT NOT NULL,
    member_id INT NOT NULL,
    fee_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    paid_status BIT DEFAULT 0,
    due_date DATE NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES Transactions(id) ON DELETE CASCADE,
    FOREIGN KEY (member_id) REFERENCES Members(id) ON DELETE NO ACTION
);


-- Trigger to Prevent Borrowing if Movie is Already Borrowed
CREATE TRIGGER PreventDuplicateBorrowing ON Transactions
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM Transactions t
        JOIN inserted i ON t.movie_id = i.movie_id AND t.member_id = i.member_id AND t.status = 'Borrowed'
    )
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR ('This movie is already borrowed.', 16, 1);
    END
END;

-- Procedure to Mark Overdue Transactions
CREATE PROCEDURE MarkOverdueTransactions
AS
BEGIN
    UPDATE Transactions
    SET status = 'Overdue'
    WHERE return_date IS NULL AND borrow_date < DATEADD(DAY, -14, GETDATE());
END;

-- Trigger to Calculate Late Fees
CREATE TRIGGER trg_CalculateLateFee
ON Transactions
AFTER UPDATE
AS
BEGIN
    IF UPDATE(return_date)
    BEGIN
        INSERT INTO Late_Fees (transaction_id, member_id, fee_amount, paid_status, due_date)
        SELECT 
            i.id, 
            i.member_id, 
            DATEDIFF(DAY, i.borrow_date, i.return_date) - 14 * 0.50, 
            0, 
            DATEADD(DAY, 7, i.return_date)
        FROM inserted i
        WHERE i.return_date > DATEADD(DAY, 14, i.borrow_date);
    END
END;

-- Procedure to Extend Borrowing Period
CREATE PROCEDURE Extend_Borrowing
    @transaction_id INT,
    @extra_days INT
AS
BEGIN
    UPDATE Transactions
    SET return_date = DATEADD(DAY, @extra_days, return_date)
    WHERE id = @transaction_id AND status = 'Borrowed';
END;