# encoding: utf-8

require 'open-uri'
require 'nokogiri'
require 'csv'


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
  
  puts "Remove first line..."
  system("tail -n +2 #{@csv_file} > #{@temp_csv_file} && mv #{@temp_csv_file} #{@csv_file}")

  puts "Remove first two columns..."
  system("cut -d, -f3- #{@csv_file} > #{@temp_csv_file} && mv #{@temp_csv_file} #{@csv_file}")
  
  puts "Rename the first column header..."
  system("awk -F, 'NR==1{$1=\"MODIFICADO EM\";} {print}' OFS=, #{@csv_file} > #{@temp_csv_file} && mv #{@temp_csv_file} #{@csv_file} ")

end

download_data()
clean_csv()
