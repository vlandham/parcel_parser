
var fs = require('fs'),
    _ = require('lodash'),
    mkdirp = require("mkdirp");

module.exports = function(dirname, opts, callback) {
	cleanData(dirname, opts, callback);
}

function cleanSales(sales) {
  sales.forEach(function(sale) {
  });
  return sales;
}


function cleanData(dirname, opts, cb) {
  var all = [];
  var files = fs.readdirSync(dirname);
  files.forEach(function(file) {
    parcel = getParcel(dirname, file);
    parcel.sales = cleanSales(parcel.sales);
    all.push(parcel);
  });
  output(all, "../data_clean");
}

function output(data, dirname) {
  mkdirp(dirname, function() {
    var path = dirname + "/" + "all.json";
    fs.writeFileSync(path, JSON.stringify(data, null, 2));
  });
}

function getParcel(dirname, filename) {
  var data = {};
	try {
    var path = dirname + "/" + filename;
		var raw = fs.readFileSync(path, "utf8");
    data = JSON.parse(raw);
	} catch (e) {
    console.log(e);
	}
  return data;
};


