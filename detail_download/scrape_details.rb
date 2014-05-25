#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'nokogiri'

OUTPUT_DIR = "data"
system("mkdir -p #{OUTPUT_DIR}")


ID = '5038300030'

URL = 'http://info.kingcounty.gov/Assessor/eRealProperty/Detail.aspx?ParcelNbr='

def parse_long_table doc, table_id
  data = {}
  doc.css("table##{table_id} tr").each do |row|
    details = row.css('td')
    data[details[0].text.strip] = details[1].text.strip
  end
  data
end

def parse_wide_table doc, table_id
  d = []
  headers = doc.css("table##{table_id} th").collect {|h| h.text.strip}
  doc.css("table##{table_id} tr").each_with_index do |row, index|
    if index == 0
      next
    end
    values = row.css("td").collect {|v| v.text.strip}
    dd = Hash[headers.zip(values)]
    d << dd
  end

  d
end

def save doc, all, css_id
  d = parse_long_table(doc, css_id)
  all.merge!(d)
  all
end

def save_wide doc, all, css_id, attribute
  d = parse_wide_table(doc, css_id)
  all[attribute] = d
  all
end

def parse_details parcel_id
  url = URL + parcel_id
  doc = Nokogiri::HTML(open(url))
  all_data = {}
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewParcel'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewParcel2'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLand'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLandSystem'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLandViews'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLandWaterfront'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLandDesignations'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLandNuisances'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLandProblems'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewLandEnviro'
  all_data = save doc, all_data, 'kingcounty_gov_cphContent_DetailsViewResBldg'

  all_data = save_wide doc, all_data, 'kingcounty_gov_cphContent_GridViewSales', "sales"
  all_data = save_wide doc, all_data, 'kingcounty_gov_cphContent_GridViewTaxRoll', "tax_roll"
  all_data = save_wide doc, all_data, 'kingcounty_gov_cphContent_GridViewPermits', "permits"

  # puts doc.text

  all_data
end

def save_details parcel_id, all_data
  output_filename = File.join(OUTPUT_DIR, parcel_id + ".json")
  File.open(output_filename, 'w') do |file|
    file.puts JSON.pretty_generate(JSON.parse(all_data.to_json))
  end
end

def get_ids
  filename = "../zip_to_parcels/data/98107.json"
  zips = JSON.parse(File.open(filename,'r').read)
  ids = zips.collect {|z| z['attributes']['PIN']}
  ids
end

ids = get_ids()

ids.each do |id|
  if !id
    next
  end
  if File.exists? File.join(OUTPUT_DIR, id + ".json")
    puts "skipping #{id}"
    next
  end

  begin
  data = parse_details id
  save_details(id, data)
  puts id
  puts data.length
  rescue
    puts "ERROR: #{id}"
  end
end



