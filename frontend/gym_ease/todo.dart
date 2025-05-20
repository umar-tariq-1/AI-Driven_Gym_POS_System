// TODO: 

// I have gyms table in which id, gymName, gymLocation and ownerId(fk from users table) is
// I have gymtrainers table in which gymId(fk gyms table, column id) and trainerId(fk users table, column id)
// I have trainerclasses table that has id, className, classFee, trainerId(fk users table, cloumn id) and gymId(in which gym this class will take place. fk gyms table, column id)
// I have registeredclasses table in which clientId(fk users table, column id), classId( fk trainerclasses table, column id)
// I have clientretention table that has userId(fk users table, column id), gymId(fk gyms table, column id), churn(bool) and classId(of which class this churn is, fk trainerclasses table , column id)