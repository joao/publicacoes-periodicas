# encoding: utf-8

require 'open-uri'
require 'nokogiri'
require 'rubysh'


@erc_page = "https://www.erc.pt/pt/registo-de-ocs/listagem-de-registos-"
@csv_file = "publicacoes_periodicas.csv"
@temp_csv_file = "temp.csv"
@last_update = ""


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
  
  puts "Cleaning CSV..."

  # Last update date
  first_line = File.open(@csv_file) {|file| first_line = file.readline}
  date = first_line.gsub(',','').encode("US-ASCII", invalid: :replace, undef: :replace).split(' ').last
  @last_update = date

  # Clean CSV columns and fix headers
  output_and_rename_files = "#{@csv_file} > #{@temp_csv_file} && mv #{@temp_csv_file} #{@csv_file}"
  
  clean = "tail -n +2 #{output_and_rename_files}\n" + # remove first line
          "cut -d, -f3- #{output_and_rename_files}\n" + # remove first two columns
          "awk -F, 'NR==1{$1=\"MODIFICADO EM\";} {print}' OFS=, #{output_and_rename_files}" # rename the first column header 
  
  system(clean)

end


def thousands_delimiter(records_count)
  number = records_count.to_s.reverse.scan(/.{1,3}/).join('.').reverse
  return number 
end


def readme_update

  puts "Updating README..."

  # Number of records
  records_counter = Rubysh('wc', '-l', @csv_file, Rubysh.stdout > :stdout) # build line counter
  records = records_counter.run # run line counter
  number_of_records = records.read(:stdout).split(' ')[0].strip().to_i - 1 # account for headers row

  # Number of active records
  active_records_counter = Rubysh('grep', '-c', 'ativo', @csv_file, Rubysh.stdout > :stdout)
  active_records = active_records_counter.run
  number_of_active_records = active_records.read(:stdout)

  
  # insert a thousands separator on the lines number
  number_of_records_with_thousand_separator = thousands_delimiter(number_of_records)
  number_of_active_records = thousands_delimiter(number_of_active_records)
  # text to update
  text_to_replace_number_records = "#{number_of_records_with_thousand_separator} registos de publicações periódicas, #{number_of_active_records} ativas.  "
  # run command
  system("sed -i -e '/registos de publicações periódicas/s/^.*$/#{text_to_replace_number_records}/' README.md && rm -rf README.md-e")


  # text to update date
  date_character_escaped = @last_update.gsub('/','\/') # escape / for use with bash
  text_to_replace_last_update = "Última actualização a #{date_character_escaped}.  "
  # run command
  system("sed -i -e '/Última actualização a/s/^.*$/#{text_to_replace_last_update}/' README.md && rm -rf README.md-e")

end



# Run
download_data()
clean_csv()
readme_update()

