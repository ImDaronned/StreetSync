IF OBJECT_ID('events', 'U') IS NOT NULL
    DROP TABLE events;

CREATE TABLE events (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(1000) NOT NULL,
    Description VARCHAR(10000),
    tags VARCHAR(500) NOT NULL,
    Date DATE NOT NULL DEFAULT GETDATE(),
    ImageLink VARCHAR(10000),
    Owner VARCHAR(20) NOT NULL,
    coord VARCHAR(200) NOT NULL
);


IF OBJECT_ID('reservations_events', 'U') IS NOT NULL
    DROP TABLE reservations_events;

CREATE TABLE reservations_events (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    events_id INT NOT NULL
);


IF OBJECT_ID('services', 'U') IS NOT NULL
    DROP TABLE services;

CREATE TABLE services (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(1000) NOT NULL,
    Description VARCHAR(10000),
    Tags VARCHAR(500) NOT NULL,
    Price INT NOT NULL,
    ImageLink VARCHAR(10000),
    Owner VARCHAR(20) NOT NULL,
    coord VARCHAR(200) NOT NULL
);


IF OBJECT_ID('services_reservations', 'U') IS NOT NULL
    DROP TABLE services_reservations;

CREATE TABLE services_reservations (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    services_id INT NOT NULL,
    reservation_day DATETIME2 NOT NULL,
    accepted BIT NOT NULL DEFAULT 0,
    paid BIT NOT NULL DEFAULT 0
);


IF OBJECT_ID('services_score', 'U') IS NOT NULL
    DROP TABLE services_score;

CREATE TABLE services_score (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    services_id INT NOT NULL,
    score TINYINT NOT NULL,
    description VARCHAR(10000) NOT NULL
);


IF OBJECT_ID('users', 'U') IS NOT NULL
    DROP TABLE users;

CREATE TABLE users (
    id INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL,
    email VARCHAR(1000) NOT NULL,
    password VARCHAR(1000) NOT NULL,
    firstname VARCHAR(1000) NOT NULL,
    name VARCHAR(1000) NOT NULL,
    coord VARCHAR(200) NOT NULL DEFAULT '45.810557-15.941105'
);

