#!/usr/bin/env ruby

require 'json'
require 'csv'
require 'open-uri'

OUTPUT_DIR = "data"
system("mkdir -p #{OUTPUT_DIR}")

ZIP = ARGV[0]

PAGE_SIZE = 100

if !ZIP or ZIP.length != 5
  puts "ERROR: call with zip: ./zip_to_parcels.rb 98107"
  exit(1)
end

puts ZIP

url = "http://gismaps.kingcounty.gov/arcgis/rest/services/Address/KingCo_AddressPoints/MapServer/0/query?where=ZIP5+%3D+#{ZIP}&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelContains&relationParam=&outFields=PIN%2CADDR_FULL%2CPOSTALCTYNAME%2CZIP5%2CPLUS4%2CSITETYPE%2CLAT%2CLON%2CCOMMENTS%2COBJECTID&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=json"

object_id_url = "http://gismaps.kingcounty.gov/arcgis/rest/services/Address/KingCo_AddressPoints/MapServer/0/query?where=ZIP5+%3D+#{ZIP}&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelContains&relationParam=&outFields=PIN%2CADDR_FULL%2CPOSTALCTYNAME%2CZIP5%2CPLUS4%2CSITETYPE%2CLAT%2CLON%2CCOMMENTS%2COBJECTID&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=true&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=json"

count_url = "http://gismaps.kingcounty.gov/arcgis/rest/services/Address/KingCo_AddressPoints/MapServer/0/query?where=ZIP5+%3D+#{ZIP}&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelContains&relationParam=&outFields=PIN%2CADDR_FULL%2CPOSTALCTYNAME%2CZIP5%2CPLUS4%2CSITETYPE%2CLAT%2CLON%2CCOMMENTS%2COBJECTID&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=true&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=json"

def get_ids id_url
  data = JSON.parse(open(id_url).read)
  data['objectIds']
end

def get_count count_url
  data = JSON.parse(open(count_url).read)
  data['count'].to_i
end

def get_url ids
  id_string = ids.join("+%2C+")
  url = "http://gismaps.kingcounty.gov/arcgis/rest/services/Address/KingCo_AddressPoints/MapServer/0/query?where=&text=&objectIds=#{id_string}&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelContains&relationParam=&outFields=PIN%2CADDR_FULL%2CPOSTALCTYNAME%2CZIP5%2CPLUS4%2CSITETYPE%2CLAT%2CLON%2CCOMMENTS%2COBJECTID&returnGeometry=true&maxAllowableOffset=&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=json"
  url
end

def get_data ids
  url = get_url(ids)
  puts url
  data = JSON.parse(open(url).read)
  data['features']
end

count = get_count count_url
ids = get_ids object_id_url

puts count

all_data = []

ids.each_slice(PAGE_SIZE) do |slice|
  data = get_data(slice)
  puts data.length
  all_data.concat(data)
end


output_filename = File.join(OUTPUT_DIR, ZIP + ".json")
File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(all_data.to_json))
end
