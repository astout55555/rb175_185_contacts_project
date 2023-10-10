DROP TABLE IF EXISTS contacts;
DROP TYPE IF EXISTS category;

CREATE TYPE category AS ENUM ('family', 'friends', 'work', 'other');

CREATE TABLE contacts(
  id serial PRIMARY KEY,
  name text UNIQUE NOT NULL,
  phone text UNIQUE NOT NULL,
  email text UNIQUE NOT NULL,
  category category NOT NULL
);

INSERT INTO contacts (name, phone, email, category)
              VALUES ('My Son', '5551231234', 'sonnyday@email.com', 'family'),
                     ('My Wife', '1112223333', 'awesome@sauce.com', 'family'),
                     ('Mr. Boss', '9998887777', 'ontopofthe@world.com', 'work'),
                     ('Co Worker', '3333334444', 'anotherdayanother@dollar.com', 'work'),
                     ('Jane Doe', '4445556666', 'gonefishing@lake.com', 'friends'),
                     ('Joe Biggs', '7778889999', 'partyanimal@thebarn.com', 'friends'),
                     ('DEATH', '9876543210', 'memento@mori.com', 'other');
