var elasticsearch = require('elasticsearch');
var q = require('q');
var FS = require('q-io/fs');
var _ = require('lodash');


var client = new elasticsearch.Client({
  host: '127.0.0.1:9200',
  log: 'trace'
});


var inputFile = __dirname + "/../detail_download/data_clean/all.json"

function loadIntoES(client, data) {
  return client.bulk({body:data});
}

function toBulk(data) {
  return data.map(function(d) {
    return [{index: {_index:'houses', _type:'house', _id: d["Parcel"]}}, d];
  });
}


FS.read(inputFile)
  .then(function(data) { return JSON.parse(data); })
  // .then(function(data) { return data.map(function(d) { return {"Parcel":d["Parcel"], "Name":d["Name"]}; }) })
  .then(toBulk)
  .then(function(data) { return _.flatten(data); })
  // .then(function(data) { return data.filter(function(d,i) {return i < 2;})})
  .then(loadIntoES.bind(this, client))
  .done();


