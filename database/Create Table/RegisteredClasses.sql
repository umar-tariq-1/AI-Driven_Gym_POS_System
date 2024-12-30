CREATE TABLE registeredclasses (
    clientId INT NOT NULL,
    classId INT NOT NULL,
    registrationDateTime DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(clientId, classId),
    FOREIGN KEY (clientId) REFERENCES gym_pos_system.users(id),
    FOREIGN KEY (classId) REFERENCES gym_pos_system.trainerclasses(id)
);
