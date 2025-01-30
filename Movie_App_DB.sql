CREATE DATABASE moviedb;
GO

-- Use the Database
USE moviedb;
GO


CREATE TABLE Users (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) CHECK (role IN ('user', 'admin')) NOT NULL
);
GO

CREATE TABLE Members (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    membership_type VARCHAR(50) NOT NULL,
    membership_start_date DATE NOT NULL,
    membership_end_date DATE NOT NULL,
    status VARCHAR(20) CHECK (status IN ('Active', 'Suspended')) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE
);
GO

CREATE TABLE Genres (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);
GO

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
GO

CREATE TABLE Actors (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    dob DATE,
    biography TEXT,
    profile_url VARCHAR(255)
);
GO

CREATE TABLE Movie_Actors (
    movie_id INT NOT NULL,
    actor_id INT NOT NULL,
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES Actors(id) ON DELETE CASCADE
);
GO

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
GO

CREATE TABLE Watchlist (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    added_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE
);
GO

CREATE TABLE Favorites (
    id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    movie_id INT NOT NULL,
    added_at DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES Users(id) ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE
);
GO

CREATE TABLE Streaming_Providers (
    id INT IDENTITY(1,1) PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    logo_url VARCHAR(255),
    website_url VARCHAR(255)
);
GO

CREATE TABLE Movie_Providers (
    movie_id INT NOT NULL,
    provider_id INT NOT NULL,
    availability_status VARCHAR(50) CHECK (availability_status IN ('Free', 'Rent', 'Buy', 'Subscription')) NOT NULL,
    PRIMARY KEY (movie_id, provider_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(id) ON DELETE CASCADE,
    FOREIGN KEY (provider_id) REFERENCES Streaming_Providers(id) ON DELETE CASCADE
);
GO

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
GO

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
GO


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
GO

-- Procedure to Mark Overdue Transactions
CREATE PROCEDURE MarkOverdueTransactions
AS
BEGIN
    UPDATE Transactions
    SET status = 'Overdue'
    WHERE return_date IS NULL AND borrow_date < DATEADD(DAY, -14, GETDATE());
END;
GO

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
GO

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
GO

