CREATE TABLE schema_migrations (
  filename varchar(255),
);

CREATE TABLE rooms (
  id varchar(255),
  name varchar(255),
  capacity INTEGER,
  location varchar(255),
);

CREATE TABLE reservations (
  id varchar(255),
  room_id varchar(255),
  start_time timestamp,
  end_time timestamp,
  description TEXT,
  responsible varchar(255),
  status varchar(255),
);

CREATE TABLE users (
  id varchar(255),
  email varchar(255),
  password_digest varchar(255),
  name varchar(255),
);

