const pg = require("pg")
const SQL = require("sql-template-strings");

// Connect to PostgreSQL database
const client = new pg.Client({
  database: process.env.DB_DATABASE,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
});

client.connect();

client.query(SQL`
    CREATE TABLE IF NOT EXISTS player_scores
    (
        id    SERIAL PRIMARY KEY,
        name  TEXT NOT NULL,
        score INT  NOT NULL
    );
`)

module.exports = client;
