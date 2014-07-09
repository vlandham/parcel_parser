var elasticsearch = require('elasticsearch');
var q = require('q');


var client = new elasticsearch.Client({
  host: '127.0.0.1:9200'
  // log: 'trace'
});

client.search({
  "query": {
    "query_string": {
      "query": "xxxdsd",
      "fields":["Name"]
    }
  }
  
  
}).then(function(body) {
  var hits = body.hits.hits;
  console.log(body);
}).done();
