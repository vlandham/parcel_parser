#!/usr/bin/env node

var fs = require('fs'),
    _ = require('lodash');

clean = require("./lib/clean");

clean("../data_test");
