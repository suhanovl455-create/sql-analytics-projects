CREATE TABLE users(user_id INTEGER PRIMARY KEY, channel TEXT NOT NULL, signup_date TEXT NOT NULL);
CREATE TABLE events(event_id INTEGER PRIMARY KEY, user_id INTEGER NOT NULL REFERENCES users,
 event_name TEXT NOT NULL CHECK(event_name IN ('signup','verify','activate')), event_time TEXT NOT NULL);
