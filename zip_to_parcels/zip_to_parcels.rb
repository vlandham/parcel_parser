#!/usr/bin/env ruby

require 'json'
require 'csv'
require 'open-uri'

ZIPS_FILE = "Zip4RatesQ12014-Long.txt"

OUTPUT_DIR = "data"
SUBS_DIR = "subs"
system("mkdir -p #{OUTPUT_DIR}")
system("mkdir -p #{SUBS_DIR}")

ZIP = ARGV[0]


if !ZIP or ZIP.length != 5
  puts "ERROR: call with zip: ./zip_to_parcels.rb 98107"
  exit(1)
end

puts ZIP


def save_subs zip, subs
  output_file = File.join(SUBS_DIR, zip + ".json")
  File.open(output_file, 'w') do |file|
    file.puts JSON.pretty_generate(JSON.parse(subs.to_json))
  end
end

def read_subs root_zip
  input_file = File.join(SUBS_DIR, root_zip + ".json")
  subs = nil
  if File.exists?(input_file)
    subs = JSON.parse(File.open(input_file, 'r').read)
  end
  subs
end

def get_sub_zips root_zip
  subs = read_subs(root_zip)
  if !subs
    subs = []
    CSV.foreach(ZIPS_FILE) do |csv|
      if csv[0] == root_zip
        subs << csv[1]
      end
    end
    save_subs(root_zip, subs)
  end
  subs
end

def get_data zip, sub
  url = "http://gismaps.kingcounty.gov/arcgis/rest/services/Address/KingCo_AddressPoints/MapServer/0/query?where=ZIP5+%3D+#{zip}+AND+PLUS4+%3D+#{sub}&text=&objectIds=&time=&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&relationParam=&outFields=ADDR_FULL%2CPOSTALCTYNAME%2CZIP5%2CPLUS4%2CPIN%2CSITETYPE%2CMAJOR%2CMINOR%2CCR_ID&returnGeometry=true&geometryPrecision=&outSR=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&returnDistinctValues=false&f=json"
  data = JSON.parse(open(url).read)
  data['features']
end

subs = get_sub_zips ZIP


# puts subs.inspect
all_data = []
subs.each_with_index do |sub, index|
  # if index == 1
  data = get_data(ZIP, sub)
  puts data.size
  if data.size > 990
    puts "WARNING: #{ZIP} #{sub} has size #{data.size}"
  end
  all_data = all_data.concat(data)
  puts all_data.length
end

output_filename = File.join(OUTPUT_DIR, ZIP + ".json")
File.open(output_filename, 'w') do |file|
  file.puts JSON.pretty_generate(JSON.parse(all_data.to_json))
end






