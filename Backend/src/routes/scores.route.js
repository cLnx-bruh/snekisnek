const express = require("express")
const PlayerScore = require("../models/player-score.model")
const router = express.Router()

router.get("/", async (req, res) => {
  const result = await PlayerScore.find().sort({score: -1});

  const response = result.map(score => ({name: score.name, score: score.score}));
    res.send(response)
});

router.get('/healthcheck', async (_req, res, _next) => {
	// optional: add further things to check (e.g. connecting to dababase)
	const healthcheck = {
		uptime: process.uptime(),
		message: 'OK',
		timestamp: Date.now()
	};
	try {
		res.send(healthcheck);
	} catch (e) {
		healthcheck.message = e;
		res.status(503).send();
	}
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