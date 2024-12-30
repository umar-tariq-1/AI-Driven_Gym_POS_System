CREATE TABLE registeredclasses (
    clientId INT,
    classId INT,
    registrationDateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(clientId, classId),
    FOREIGN KEY (clientId) REFERENCES gym_pos_system.users(id),
    FOREIGN KEY (classId) REFERENCES gym_pos_system.trainerclasses(id)
);