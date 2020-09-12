const express = require("express")
const PlayerScore = require("../models/player-score.model")
const router = express.Router()

// Get all posts
router.get("/scores", async (req, res) => {
  const playerScores = await PlayerScore.find()
  res.send(playerScores)
});

router.post('/scores', async (req, res, next) => {
  const scoreFromRequest = req.body;

  const playerScore = new PlayerScore({
    name: scoreFromRequest.name,
    score: scoreFromRequest.score
  });

  try {
    await playerScore.save();
    res.send(playerScore);
  } catch (error){
    next(req, res, error);
  }
});

module.exports = router