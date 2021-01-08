# encoding: utf-8

require 'csv'
require 'babosa'


# Get data from original CSV
filename = ""

ARGV.each do |a|
  filename = a
end

data = File.read(filename, :encoding => 'utf-8')


# Machine readable headers
headers = data.lines.first
new_headers = []

headers.split(',').each_with_index do |h, i|
  if i == 0
    h = '"numero-de-registo"'
  end

  h = h.strip.gsub(' ', '-').to_slug.transliterate.downcase.to_s

  new_headers << h
end

new_headers = new_headers.join(',') # join array
new_headers = new_headers += "\n" # add new line


# Replace headers on first line
new_data = data.gsub(headers, new_headers)


# Write CSV file
File.write(filename, new_data)
