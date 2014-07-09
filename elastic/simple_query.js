var elasticsearch = require('elasticsearch');
var q = require('q');

// localhost:9200/_search
// {
//     "query": {
//         "query_string": {
//             "query": "RYAN",
//           "fields":["Name"]
//         }
//     }
// }
// 

var client = new elasticsearch.Client({
  host: '127.0.0.1:9200'
  // log: 'trace'
});

var query = {
  body: {
    query: {
      "query_string": {
        "query": "RYAN",
        "fields":["Name"]
      }
    }
  }
}

client.search(query).then(function(body) {
  var hits = body.hits.hits;
  console.log(body);
}).done();
