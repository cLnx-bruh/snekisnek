const db = require('../db');
const SQL = require('sql-template-strings');

module.exports = class PlayerScore {
  constructor(name, score) {
    this.name = name;
    this.score = score;
  }

  async save() {
    return db.query(SQL`INSERT INTO player_scores (name, score)
                        VALUES (${this.name}, ${this.score})`)
  }

  static async find() {
    const result = await db.query(SQL`
        SELECT *
        FROM player_scores
        ORDER BY score DESC
    `);
    return result.rows;
  };
}
