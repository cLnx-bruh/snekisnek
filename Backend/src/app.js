const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const scoreRoute = require('./routes/scores.route');
const port = 3000

const mongoose = require("mongoose") // new

// Connect to MongoDB database
mongoose.connect("mongodb://localhost:27017/snakedb", { useNewUrlParser: true,  useUnifiedTopology: true })
    .then(() => {
        const app = express()

        const corsOptions = {
            origin: '*',
            optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
        }

        app.use(cors(corsOptions));

        app.use(bodyParser.json());

        app.use('/api/scores', scoreRoute);

        app.use(async (error, req, res, next) => {
            console.error(error.stack);
            res.sendStatus(500);
        });

        app.listen(port, () => {
            console.log(`Example app listening at http://localhost:${port}`)
        })
    });
