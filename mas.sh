#!/bin/sh

# EXPORT BINANCE SPOT TRADE HISTORY AND COPY IT IN THE PATH. CHECK IF EXTENSION NOT '.xlsx' THEN RENAME IT.
xlsx2csv *.xlsx > spot_temp.csv
sed -i '1d' spot_temp.csv
tac spot_temp.csv > spot.csv

# GOTO coinmarketcap.com LOGIN AND MAKE A PORTFLIO THEN OPEN NETWORK TAB U WILL FIND auth VALUE AND PORTFOLIO ID REPLACE WITH "REPLACE-ME"
auth="Bearer REPLACE-ME"
poid="REPLACE-ME"

#GENARATE RANDOM 33 ALPHA NUMERIC STRING AS (x-request-id) 
req=$(echo $RANDOM | md5sum | head -c 33; echo;)


COUNT=1
# GETTING HOW MANY LINES IN URL FILE
STOP=$(grep -c . spot.csv)
#STOP=4
while [ $COUNT -le $STOP ]
do
mn=$(sed "$COUNT!d" spot.csv)
echo $mn

tm=$(echo $mn | awk -F ',' '{print $1}' | sed 's/ /T/g;s/$/.000Z/g')
amo=$(echo $mn | awk -F ',' '{print $5}')
pri=$(echo $mn | awk -F ',' '{print $4}')
typ=$(echo $mn | awk -F ',' '{print $3}' | awk '{print tolower($0)}')
nm=$(echo $mn | awk -F ',' '{print $2}' | sed 's/USDT//g;s/BUSD//g')
idn=$(grep -w "$nm" sym-id.txt | awk -F ',' '{print $2}' | sed '1!d')

feenm=$(echo $mn | awk -F ',' '{print $8}')

echo "$COUNT $nm ADDING"
echo "--------------------------------------------"

if echo "$feenm" | grep -w "USDT"; then
#echo "FEE IN USDT"

fee=$(echo $mn | awk -F ',' '{print $7}')
feeusd=$(echo "$fee" | awk '{printf("%.5f \n",$1)}' | sed 's/ //g')
curl -X POST -H "authorization:$auth" -H "content-type:application/json; charset=utf-8" -H "x-request-id:$req" -H "host:api.coinmarketcap.com" -d '{"cryptocurrencyId":'"$idn"',"amount":'"$amo"',"price":'"$pri"',"cryptoUnit":1,"fiatUnit":2781,"fee":'"$feeusd"',"transactionType":"'"$typ"'","transactionTime":"'"$tm"'","note":"","portfolioSourceId":"'"$poid"'"}' "https://api.coinmarketcap.com/asset/v3/portfolio/add"

else

#echo "FEE NOT IN USDT"
fee=$(echo $mn | awk -F ',' '{print $7}')
feet=$(echo "$fee $pri" | awk '{printf "%f", $1 * $2}')
feeusd=$(echo "$feet" | awk '{printf("%.5f \n",$1)}' | sed 's/ //g')

amt=$(echo "$amo $fee" | awk '{printf "%.9f", $1 - $2}')
echo $amo
echo $amt

curl -X POST -H "authorization:$auth" -H "content-type:application/json; charset=utf-8" -H "x-request-id:$req" -H "host:api.coinmarketcap.com" -d '{"cryptocurrencyId":'"$idn"',"amount":'"$amt"',"price":'"$pri"',"cryptoUnit":1,"fiatUnit":2781,"fee":0,"transactionType":"'"$typ"'","transactionTime":"'"$tm"'","note":"","portfolioSourceId":"'"$poid"'"}' "https://api.coinmarketcap.com/asset/v3/portfolio/add"

fi

echo -e "\n"
echo "$COUNT $nm ADDING DONE"
echo "--------------------------------------------"
#TO PREVENT ABUSE TO API USE DELAY
sleep 10
COUNT=$(($COUNT+1))
done
rm *.xlsx
