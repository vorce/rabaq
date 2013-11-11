exchange_uri="http://guest:guest@localhost:15672/api/exchanges/%2f/test/publish"
count=1
while true; do
curl --verbose --request POST -d "{\"properties\":{}, \"routing_key\":\"mykey\", \"payload\":\"mybody $count\", \"payload_encoding\":\"string\"}" $exchange_uri > /dev/null 2>&1
count=$[$count+1]
done
