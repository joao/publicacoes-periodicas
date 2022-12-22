# encoding: utf-8

require 'open-uri'
require 'nokogiri'
require 'csv'
require 'rubysh'


@erc_page = "https://www.erc.pt/pt/registo-de-ocs/listagem-de-registos-"
@csv_file = "publicacoes_periodicas.csv"
@temp_csv_file = "temp.csv"


def download_data
  puts "Downloading data..."

  html = URI.open(@erc_page)

  # Parse the HTML document
  doc = Nokogiri::HTML(html)

  # Select the link element with the desired text
  link_element = doc.css("a:contains('Publicações Periódicas')")[0]

  # Get the href attribute of the link element
  # https://docs.google.com/spreadsheets/d/1C1ii_GwRWKZyYDQCr4P59CFYaPuEMb0jJXUVPoR9_xk/export?format=csv&id=1C1ii_GwRWKZyYDQCr4P59CFYaPuEMb0jJXUVPoR9_xk&gid=217316155
  google_spreadsheet_link = link_element.attribute('href').value

  # Get CSV
  download_link = google_spreadsheet_link.split[0].gsub('edit?usp=sharing', 'export?format=csv')

  # Download
  system("wget -O #{@csv_file} #{download_link}")
end



def clean_csv
  
  output_and_rename = "#{@csv_file} > #{@temp_csv_file} && mv #{@temp_csv_file} #{@csv_file}"
  
  clean = "tail -n +2 #{output_and_rename}\n" + # remove first line
          "cut -d, -f3- #{output_and_rename}\n" + # remove first two columns
          "awk -F, 'NR==1{$1=\"MODIFICADO EM\";} {print}' OFS=, #{output_and_rename}" # remove the first column header 
  
  puts "Cleaning CSV..."
  system(clean)
  
  puts "Updating README..."
  lines_counter = Rubysh('wc', '-l', @csv_file, Rubysh.stdout > :stdout) # build line counter
  lines = lines_counter.run # run line counter
  number_of_lines = lines.read(:stdout).split(' ')[0].strip().to_i - 1 # account for headers row
  number_of_lines_with_thousand_separator = number_of_lines.to_s.reverse.scan(/.{1,3}/).join('.').reverse # insert a thousands separator
  text_to_replace = "#{number_of_lines_with_thousand_separator} registos de publicações periódicas  " # text to update on README
  system("sed -i -e '/registos de publicações periódicas/s/^.*$/#{text_to_replace}/' README.md && rm -rf README.md-e")

end

download_data()
clean_csv()
