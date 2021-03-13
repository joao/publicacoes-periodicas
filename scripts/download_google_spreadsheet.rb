# encoding: utf-8

require 'open-uri'
require 'nokogiri'


html = URI.open("https://www.erc.pt/pt/listagem-registos-na-erc")

doc = Nokogiri::HTML(html)

google_spreadsheet_link = doc.css('.text > ul:nth-child(2) > li:nth-child(1) > a:nth-child(1)')[0]['href']
download_link = google_spreadsheet_link.split[0].gsub('edit?usp=sharing', 'gviz/tq?tqx=out:csv')

system("wget -O \"publicacoes_periodicas.csv\" #{download_link}")