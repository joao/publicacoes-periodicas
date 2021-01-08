# encoding: utf-8

require 'csv'
require 'json'


# Get data from original CSV
filename = ""

ARGV.each do |a|
  filename = a
end

data = File.read(filename, :encoding => 'utf-8')


# Convert to JSON
json = CSV.parse(data).to_json


# Write JSON file
File.write("publicacoes_periodicas.json", json)