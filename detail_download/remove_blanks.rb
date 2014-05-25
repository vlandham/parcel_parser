#!/usr/bin/env ruby

require 'json'

DIR = "data"

json_files = Dir.glob(File.join(DIR, "*.json"))

exclude = []

json_files.each do |json_file|
  json = JSON.parse(File.open(json_file,'r').read)
  if json.keys.length < 10
    exclude << json_file
  end
end

puts exclude.length

exclude.each do |file|
  puts file
  system("rm #{file}")
end
