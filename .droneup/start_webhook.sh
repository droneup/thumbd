#!/usr/bin/env node
var _ = require('lodash')
var express = require('express'),
    bodyParser = require('body-parser'),
    app = express(),
    port = process.env.WEBHOOK_PORT || 3000
app.use(bodyParser.json());

app.post('/', function (req, res) {
    if (req.body.token === process.env.WEBHOOK_TOKEN) {
        process.env.REMOTE_IMAGE = req.body.obj_url;
        require(process.env.PWD + '/.droneup/add_thumbnail.sh');
        console.log('REMOTE IMAGE:', process.env.REMOTE_IMAGE)
        res.json({
            message: "Processing: " + req.body.obj_url
        })
    } else {
        res.status(500).end();
    }
});

var server = app.listen(port, function () {
    var host = server.address().address
    var port = server.address().port
    console.log('Listening at http://%s:%s', host, port)
});