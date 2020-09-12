const express = require("express")
const PlayerScore = require("../models/player-score.model")
const router = express.Router()

router.get("/", async (req, res) => {
  const result = await PlayerScore.find().sort({score: -1});

  const response = result.map(score => ({name: score.name, score: score.score}));
    res.send(response)
});

router.post('/', async (req, res, next) => {
  const scoreFromRequest = req.body;

  const playerScore = new PlayerScore({
    name: scoreFromRequest.name,
    score: scoreFromRequest.score
  });

  try {
    await playerScore.save();
    res.send({name: playerScore.name, score: playerScore.score});
  } catch (error){
    next(req, res, error);
  }
});

module.exports = router