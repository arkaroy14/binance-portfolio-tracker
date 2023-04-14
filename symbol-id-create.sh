# RUN THIS CODE ONLY IF BUY NEW COIN #
curl "https://api.coinmarketcap.com/data-api/v3/map/all?listing_status=active%2Cinactive%2Cuntracked&limit=10000&start=1" --output all.json
jq -r .data.cryptoCurrencyMap[].id all.json > id.txt
jq -r .data.cryptoCurrencyMap[].symbol all.json > symbol.txt
paste -d ',' symbol.txt id.txt > sym-id.txt
rm all.json symbol.txt id.txt
