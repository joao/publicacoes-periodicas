install:
	gem install csv json babosa

update-data:
	wget -O "publicacoes_periodicas.csv" "https://docs.google.com/spreadsheets/d/1SE_YFp6zBglgEOexBN9Nq5HQZNg35UP-MJac7uOHPw8/gviz/tq?tqx=out:csv&sheet='TODOS|PUBLICAÇÕES PERIÓDICAS'"
	ruby scripts/csv_cleanup.rb "publicacoes_periodicas.csv"
	ruby scripts/csv_to_json.rb "publicacoes_periodicas.csv"

	