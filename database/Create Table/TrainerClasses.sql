CREATE TABLE trainerclasses (
    id INT AUTO_INCREMENT PRIMARY KEY,
    className VARCHAR(255) NOT NULL,
    gymName VARCHAR(255) NOT NULL,
    gymLocation VARCHAR(255) NOT NULL,
    trainerName VARCHAR(255) NOT NULL,
    classDescription TEXT NOT NULL,
    maxParticipants INT NOT NULL,
    classFee DECIMAL(10, 2) NOT NULL,
    specialRequirements TEXT,
    classType VARCHAR(100),
    fitnessLevel VARCHAR(100),
    classGender VARCHAR(20) NOT NULL,
    classCategory VARCHAR(100),
    selectedDays JSON NOT NULL,  -- Store the selected days as JSON
    startTime TIME NOT NULL,
    endTime TIME NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    imageData JSON,  -- For storing the image name
    userId INT,  -- Foreign key reference to Users table
    FOREIGN KEY (userId) REFERENCES Users(id) ON DELETE CASCADE
);
