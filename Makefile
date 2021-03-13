install:
	gem install csv json babosa nokogiri

update-data:
	ruby scripts/download_google_spreadsheet.rb
	#ruby scripts/csv_cleanup.rb "publicacoes_periodicas.csv"
	#ruby scripts/csv_to_json.rb "publicacoes_periodicas.csv"

push:
	git push origin main

	

