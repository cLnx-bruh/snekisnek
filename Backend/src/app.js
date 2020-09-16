const path = require('path');
require('custom-env').env(true, path.join(__dirname, '/environments'));

const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const scoreRoute = require('./routes/scores.route');
const port = process.env.APP_PORT;

const mongoose = require("mongoose") // new

// Connect to MongoDB database
mongoose.connect(process.env.DB_CONN_STRING, { useNewUrlParser: true,  useUnifiedTopology: true })
    .then(() => {
        const app = express()

        const corsOptions = {
            origin: '*',
            optionsSuccessStatus: 200 // some legacy browsers (IE11, various SmartTVs) choke on 204
        }

        app.use(cors(corsOptions));

        app.use(bodyParser.json());

        app.use('/', scoreRoute);

        app.use(async (error, req, res, next) => {
            console.error(error.stack);
            res.sendStatus(500);
        });

        const server = app.listen(port, () => {
            console.log(`Example app listening at http://localhost:${port}`)
        })
        server.keepAliveTimeout = 65000;
    });
