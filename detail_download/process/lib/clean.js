
var fs = require('fs'),
    _ = require('lodash'),
    mkdirp = require("mkdirp"),
    moment = require('moment');

module.exports = function(dirname, opts, callback) {
	cleanData(dirname, opts, callback);
}

TYPES = {
  "Base Land Value SqFt": int,
  "Base Land Value": int,
  "% Base Land Value": int,
  "Land SqFt": int,
  "Acres": floater
}

function stringToNum(dollar_string) {
  return +dollar_string.replace(",","");
}

function dollarToNum(dollar_string) {
  return +dollar_string.replace("$","").replace(",","");
}

function int(a_string) {
  return stringToNum(a_string);
}

function floater(a_string) {
  return stringToNum(a_string);
}

function cleanSales(sales) {
  sales.forEach(function(sale) {
    if(sale["Document Date"]) {
      sale['date'] = moment(sale["Document Date"], "MM-DD-YYYY").utc();
    }
    if(sale["Sale Price"]) {
      sale['price'] = dollarToNum(sale["Sale Price"]);
    }
  });
  return sales;
}

function cleanBase(parcel) {
  _.forOwn(TYPES, function(cb, key) {
    if(_.has(parcel, key)) {
      console.log(key)
      console.log(parcel[key])
      parcel[key] = cb(parcel[key])
      console.log(parcel[key])
    }
  });
  return parcel;
}

function cleanParcel(parcel) {
  parcel.sales = cleanSales(parcel.sales);
  return parcel;
}

function cleanData(dirname, opts, cb) {
  var all = [];
  var files = fs.readdirSync(dirname);
  files.forEach(function(file) {
    parcel = getParcel(dirname, file);
    parcel = cleanBase(parcel);
    parcel = cleanParcel(parcel);
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


