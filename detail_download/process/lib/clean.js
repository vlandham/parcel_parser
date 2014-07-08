
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
  "Base Land Value Tax Year": year,
  "Land SqFt": int,
  "Acres": float,
  "Year Built": year,
  "Year Renovated": year,
  "Stories": float,
  "Living Units": float,
  "Total Finished Area":float,
  "Bedrooms":int,
  "Full Baths":int,
  "3/4 Baths":int,
  "1/2 Baths": int,
  "Deck Area SqFt":int,
  "Open Porch SqFt":int,
  "Enclosed Porch SqFt":int
}

TAX = {
  "Valued Year":year,
  "Tax Year": year,
  "Appraised Land Value ($)":dollar,
  "Appraised Imps Value ($)":dollar,
  "Appraised Total Value ($)":dollar,
  "Taxable Total Value ($)":dollar
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

function float(a_string) {
  return stringToNum(a_string);
}

function year(a_string) {
  return stringToNum(a_string);
}

function dollar(a_string) {
  return dollarToNum(a_string);
}

function date(a_string) {
  return moment(a_string, "MM-DD-YYYY").utc()
}


function cleanList(object, list) {
  _.forOwn(list, function(cb, key) {
    if(_.has(object, key)) {
      object[key] = cb(object[key]);
    }
  });
  return object;
}

function cleanTax(taxes) {
  return taxes.map(function(tax) {
    return cleanList(tax, TAX);
  })
}

function cleanSales(sales) {
  sales.forEach(function(sale) {
    if(sale["Document Date"]) {
      sale['date'] = date(sale["Document Date"]);
    }
    if(sale["Sale Price"]) {
      sale['price'] = dollarToNum(sale["Sale Price"]);
    }
  });
  return sales;
}

function cleanBase(parcel) {
  parcel = cleanList(parcel, TYPES);
  return parcel;
}

function cleanParcel(parcel) {
  parcel = cleanBase(parcel);
  parcel.sales = cleanSales(parcel.sales);
  parcel.tax_roll = cleanTax(parcel.tax_roll);
  return parcel;
}

function cleanData(dirname, opts, cb) {
  var all = [];
  var files = fs.readdirSync(dirname);
  files.forEach(function(file) {
    parcel = getParcel(dirname, file);
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


