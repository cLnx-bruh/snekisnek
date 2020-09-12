const mongoose = require("mongoose")

const schema = mongoose.Schema({
  name: String,
  score: Number,
})

module.exports = mongoose.model("PlayerScore", schema)