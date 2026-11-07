CREATE TABLE teams(team_id INTEGER PRIMARY KEY, name TEXT NOT NULL);
CREATE TABLE tickets(ticket_id INTEGER PRIMARY KEY, team_id INTEGER NOT NULL REFERENCES teams,
 created_at TEXT NOT NULL, closed_at TEXT,
 CHECK(closed_at IS NULL OR closed_at>=created_at));
